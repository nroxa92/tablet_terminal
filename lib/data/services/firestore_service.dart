// FILE: lib/data/services/firestore_service.dart
// OPIS: Sinkronizacija podataka s Firebase Firestore.
// VERZIJA: 6.0 - FAZA 2: Offline Queue Integration
// DATUM: 2026-01-10
//
// ✅ STANDARD: SVE camelCase
// ✅ OFFLINE: Queue operacije kad nema interneta

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';
import 'signature_storage_service.dart';
import 'connectivity_service.dart';
import 'offline_queue_service.dart';
import 'sentry_service.dart';
import 'performance_service.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============================================================
  // GLAVNA SINKRONIZACIJA (poziva se na Dashboard load)
  // ============================================================

  /// Sinkronizira sve podatke potrebne za rad tableta
  static Future<void> syncAllData() async {
    // Start performance trace
    await PerformanceService.startSyncTrace();

    try {
      final unitId = StorageService.getUnitId();
      final ownerId = StorageService.getOwnerId();

      if (unitId == null || ownerId == null) {
        throw "Unit ID or Owner ID not found on device.";
      }

      debugPrint("🔄 Starting full data sync...");
      SentryService.addBreadcrumb(
          message: 'Sync started', category: 'firebase');

      // Provjeri online status
      if (!ConnectivityService.isOnline) {
        debugPrint("📴 Offline - using cached data");
        SentryService.logFirebaseSync(success: false, collection: 'all');
        await PerformanceService.stopSyncTrace(success: false);
        return;
      }

      // 1. Sync Unit Data (WiFi, Address, Name)
      await _syncUnitData(unitId);

      // 2. Sync Owner Settings (PINs, AI Prompts, House Rules, Cleaner Tasks)
      await _syncOwnerSettings(ownerId);

      // 3. Sync Current Booking
      await _syncCurrentBooking(unitId);

      debugPrint("✅ Full sync completed!");
      SentryService.logFirebaseSync(success: true, collection: 'all');
      await PerformanceService.stopSyncTrace(success: true);
    } catch (e) {
      debugPrint("❌ Sync error: $e");
      SentryService.captureException(e, hint: 'Full sync failed');
      await PerformanceService.stopSyncTrace(success: false);
      rethrow;
    }
  }

  // ============================================================
  // UNIT DATA SYNC
  // ============================================================

  static Future<void> _syncUnitData(String unitId) async {
    try {
      debugPrint("🏠 Syncing unit data for: $unitId");

      final unitDoc = await _db.collection('units').doc(unitId).get();

      if (!unitDoc.exists) {
        throw "Unit '$unitId' not found in database.";
      }

      final data = unitDoc.data()!;

      // ✅ camelCase polja
      await StorageService.setVillaData(
        data['name'] ?? 'Villa Guest',
        data['address'] ?? '',
        data['wifiSsid'] ?? '',
        data['wifiPass'] ?? '',
        data['contactPhone'] ?? '',
      );

      // ✅ contactOptions (camelCase)
      if (data['contactOptions'] != null && data['contactOptions'] is Map) {
        final Map<String, String> contacts = {};
        (data['contactOptions'] as Map).forEach((key, value) {
          contacts[key.toString()] = value.toString();
        });
        await StorageService.setContactOptions(contacts);
      }

      debugPrint("✅ Unit data synced: ${data['name']}");
    } catch (e) {
      debugPrint("⚠️ Unit sync failed: $e");
      rethrow;
    }
  }

  /// Javna metoda za ručni sync (npr. iz Admin panela)
  static Future<void> syncUnitSettings() async {
    final unitId = StorageService.getUnitId();
    final ownerId = StorageService.getOwnerId();

    if (unitId != null) await _syncUnitData(unitId);
    if (ownerId != null) await _syncOwnerSettings(ownerId);
  }

  // ============================================================
  // OWNER SETTINGS SYNC
  // ============================================================

  static Future<void> _syncOwnerSettings(String ownerId) async {
    try {
      debugPrint("⚙️ Syncing owner settings for: $ownerId");

      final settingsDoc = await _db.collection('settings').doc(ownerId).get();

      if (!settingsDoc.exists) {
        debugPrint("⚠️ No settings found for owner: $ownerId");
        return;
      }

      final data = settingsDoc.data()!;

      // 1. CLEANER PIN
      if (data['cleanerPin'] != null) {
        await StorageService.setCleanerPin(data['cleanerPin'].toString());
      }

      // 2. MASTER PIN (Hard Reset)
      if (data['hardResetPin'] != null) {
        await StorageService.setMasterPin(data['hardResetPin'].toString());
      }

      // 3. AI PROMPTS (camelCase)
      final Map<String, String> aiPrompts = {};

      if (data['aiConcierge'] != null) {
        aiPrompts['concierge'] = data['aiConcierge'].toString();
      }
      if (data['aiHousekeeper'] != null) {
        aiPrompts['housekeeper'] = data['aiHousekeeper'].toString();
      }
      if (data['aiGuide'] != null) {
        aiPrompts['guide'] = data['aiGuide'].toString();
      }
      if (data['aiTech'] != null) {
        aiPrompts['tech'] = data['aiTech'].toString();
      }

      if (aiPrompts.isNotEmpty) {
        await StorageService.setAIPrompts(aiPrompts);
      }

      // 4. HOUSE RULES TRANSLATIONS
      if (data['houseRulesTranslations'] != null &&
          data['houseRulesTranslations'] is Map) {
        final Map<String, String> rules = {};
        (data['houseRulesTranslations'] as Map).forEach((key, value) {
          rules[key.toString()] = value.toString();
        });
        await StorageService.setHouseRulesTranslations(rules);
      }

      // 5. GOOGLE REVIEW URL
      if (data['googleReviewUrl'] != null) {
        await StorageService.setGoogleReviewUrl(
            data['googleReviewUrl'].toString());
      }

      // ✅ cleanerChecklist (camelCase)
      if (data['cleanerChecklist'] != null &&
          data['cleanerChecklist'] is List) {
        final tasks = List<String>.from(data['cleanerChecklist']);
        await StorageService.setCleanerTasks(tasks);
        debugPrint("✅ Loaded ${tasks.length} cleaner tasks");
      }

      debugPrint("✅ Owner settings synced");
    } catch (e) {
      debugPrint("⚠️ Settings sync failed: $e");
    }
  }

  // ============================================================
  // BOOKING SYNC
  // ============================================================

  static Future<void> _syncCurrentBooking(String unitId) async {
    try {
      debugPrint("📅 Syncing current booking for unit: $unitId");

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final snapshot = await _db
          .collection('bookings')
          .where('unitId', isEqualTo: unitId)
          .where('endDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .orderBy('endDate')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint("ℹ️ No active booking found");
        await StorageService.clearCurrentBooking();
        return;
      }

      final bookingDoc = snapshot.docs.first;
      final data = bookingDoc.data();

      final startDate = (data['startDate'] as Timestamp).toDate();
      final endDate = (data['endDate'] as Timestamp).toDate();

      if (startDate.isAfter(now)) {
        debugPrint("ℹ️ Booking hasn't started yet");
        await StorageService.clearCurrentBooking();
        return;
      }

      await StorageService.setCurrentBooking(
        guestName: data['guestName'] ?? '',
        startDate: startDate,
        endDate: endDate,
        guestCount: data['guestCount'] ?? 1,
        bookingId: bookingDoc.id,
        guestEmail: data['guestEmail'],
        guestPhone: data['guestPhone'],
        notes: data['note'],
      );

      debugPrint(
          "✅ Booking synced: ${data['guestName']} (${data['guestCount']} guests)");
    } catch (e) {
      debugPrint("⚠️ Booking sync failed: $e");
    }
  }

  // ============================================================
  // GUEST DATA METHODS
  // ============================================================

  static Future<String?> getTodaysGuestName() async {
    final unitId = StorageService.getUnitId();
    if (unitId == null) return null;

    if (ConnectivityService.isOnline) {
      await _syncCurrentBooking(unitId);
    }

    final name = StorageService.getGuestName();
    return name.isNotEmpty ? name : null;
  }

  static Future<int> getTodaysGuestCount() async {
    final unitId = StorageService.getUnitId();
    if (unitId == null) return 1;

    // Ako smo offline, vrati cached vrijednost
    if (!ConnectivityService.isOnline) {
      return StorageService.getGuestCount();
    }

    try {
      final now = DateTime.now();
      final snapshot = await _db
          .collection('bookings')
          .where('unitId', isEqualTo: unitId)
          .where('endDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .orderBy('endDate')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        return data['guestCount'] ?? 1;
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching guest count: $e");
    }
    return StorageService.getGuestCount();
  }

  // ============================================================
  // ⭐ GUESTS SUBCOLLECTION - OFFLINE AWARE
  // ============================================================

  /// Sprema gosta u subcollection - s offline fallback
  static Future<String> saveGuestToSubcollection({
    required String bookingId,
    required Map<String, dynamic> guestData,
  }) async {
    // Ako smo offline, queue operaciju
    if (!ConnectivityService.isOnline) {
      debugPrint('📴 Offline: Queuing guest save...');
      await OfflineQueueService.queueCreateGuest(
        bookingId: bookingId,
        guestData: guestData,
      );
      SentryService.addBreadcrumb(
        message: 'Guest queued for offline sync',
        category: 'offline',
      );
      return 'queued_${DateTime.now().millisecondsSinceEpoch}';
    }

    try {
      final docRef = await _db
          .collection('bookings')
          .doc(bookingId)
          .collection('guests')
          .add({
        ...guestData,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Guest saved to subcollection: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Save guest error (queuing): $e');
      // Fallback na queue
      await OfflineQueueService.queueCreateGuest(
        bookingId: bookingId,
        guestData: guestData,
      );
      return 'queued_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Sprema sve goste u subcollection (batch) - s offline fallback
  static Future<void> saveAllGuestsToSubcollection({
    required String bookingId,
    required List<Map<String, dynamic>> guests,
  }) async {
    // Ako smo offline, queue sve operacije
    if (!ConnectivityService.isOnline) {
      debugPrint('📴 Offline: Queuing ${guests.length} guests...');
      for (final guestData in guests) {
        await OfflineQueueService.queueCreateGuest(
          bookingId: bookingId,
          guestData: guestData,
        );
      }
      return;
    }

    try {
      final batch = _db.batch();
      final guestsRef =
          _db.collection('bookings').doc(bookingId).collection('guests');

      for (final guestData in guests) {
        final docRef = guestsRef.doc();
        batch.set(docRef, {
          ...guestData,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      batch.update(_db.collection('bookings').doc(bookingId), {
        'isScanned': true,
        'scannedAt': FieldValue.serverTimestamp(),
        'scannedGuestCount': guests.length,
      });

      await batch.commit();
      debugPrint('✅ ${guests.length} guests saved to subcollection');
    } catch (e) {
      debugPrint('❌ Batch save guests error (queuing): $e');
      // Fallback na queue
      for (final guestData in guests) {
        await OfflineQueueService.queueCreateGuest(
          bookingId: bookingId,
          guestData: guestData,
        );
      }
    }
  }

  /// Briše sve goste iz subcollection
  static Future<int> deleteGuestsFromSubcollection(String bookingId) async {
    if (!ConnectivityService.isOnline) {
      debugPrint('📴 Offline: Cannot delete guests');
      return 0;
    }

    try {
      final guestsSnapshot = await _db
          .collection('bookings')
          .doc(bookingId)
          .collection('guests')
          .get();

      if (guestsSnapshot.docs.isEmpty) return 0;

      final batch = _db.batch();
      for (final doc in guestsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      debugPrint(
          '🗑️ Deleted ${guestsSnapshot.docs.length} guests from subcollection');
      return guestsSnapshot.docs.length;
    } catch (e) {
      debugPrint('❌ Delete guests error: $e');
      return 0;
    }
  }

  // ============================================================
  // FEEDBACK - OFFLINE AWARE
  // ============================================================

  static Future<void> saveFeedback({
    required int rating,
    String? comment,
  }) async {
    final unitId = StorageService.getUnitId();
    final ownerId = StorageService.getOwnerId();

    if (unitId == null) throw "No Unit ID";

    // Ako smo offline, queue
    if (!ConnectivityService.isOnline) {
      debugPrint('📴 Offline: Queuing feedback...');
      await OfflineQueueService.queueSaveFeedback(
        rating: rating,
        comment: comment,
      );
      return;
    }

    try {
      await _db.collection('feedback').add({
        'ownerId': ownerId,
        'unitId': unitId,
        'rating': rating,
        'comment': comment ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'guestName': StorageService.getGuestName(),
        'language': StorageService.getLanguage(),
        'isRead': false,
        'platform': 'Android Kiosk',
      });

      debugPrint("⭐ Feedback saved: $rating stars");
    } catch (e) {
      debugPrint("❌ Error saving feedback (queuing): $e");
      await OfflineQueueService.queueSaveFeedback(
        rating: rating,
        comment: comment,
      );
    }
  }

  // ============================================================
  // AI CHAT LOGS - OFFLINE AWARE
  // ============================================================

  static Future<void> logAIConversation({
    required String agentId,
    required String userMessage,
    required String aiResponse,
  }) async {
    final unitId = StorageService.getUnitId();
    final ownerId = StorageService.getOwnerId();

    if (unitId == null) return;

    // Ako smo offline, queue
    if (!ConnectivityService.isOnline) {
      await OfflineQueueService.queueSaveAiLog(
        agentId: agentId,
        userMessage: userMessage,
        aiResponse: aiResponse,
      );
      return;
    }

    try {
      await _db.collection('ai_logs').add({
        'ownerId': ownerId,
        'unitId': unitId,
        'agentId': agentId,
        'userMessage': userMessage,
        'aiResponse': aiResponse,
        'timestamp': FieldValue.serverTimestamp(),
        'language': StorageService.getLanguage(),
      });
    } catch (e) {
      debugPrint("⚠️ AI log failed (queuing): $e");
      await OfflineQueueService.queueSaveAiLog(
        agentId: agentId,
        userMessage: userMessage,
        aiResponse: aiResponse,
      );
    }
  }

  // ============================================================
  // CLEANING LOGS - OFFLINE AWARE
  // ============================================================

  static Future<void> saveCleaningLog({
    required Map<String, bool> tasks,
    required String notes,
    String? bookingId,
  }) async {
    final unitId = StorageService.getUnitId();
    final ownerId = StorageService.getOwnerId();

    if (unitId == null) throw "No Unit ID";

    // Ako smo offline, queue
    if (!ConnectivityService.isOnline) {
      debugPrint('📴 Offline: Queuing cleaning log...');
      await OfflineQueueService.queueSaveCleaningLog(
        tasks: tasks,
        notes: notes,
        bookingId: bookingId,
      );
      return;
    }

    try {
      final completedCount = tasks.values.where((v) => v).length;

      await _db.collection('cleaning_logs').add({
        'ownerId': ownerId,
        'unitId': unitId,
        'bookingId': bookingId,
        'timestamp': FieldValue.serverTimestamp(),
        'tasks': tasks,
        'completedCount': completedCount,
        'totalCount': tasks.length,
        'notes': notes,
        'status': completedCount == tasks.length ? 'completed' : 'partial',
        'platform': 'Android Kiosk',
      });

      debugPrint("🧹 Cleaning log saved");
    } catch (e) {
      debugPrint("❌ Error saving cleaning log (queuing): $e");
      await OfflineQueueService.queueSaveCleaningLog(
        tasks: tasks,
        notes: notes,
        bookingId: bookingId,
      );
    }
  }

  // ============================================================
  // BOOKING ARCHIVE
  // ============================================================

  static Future<void> archiveBooking(String bookingId) async {
    if (!ConnectivityService.isOnline) {
      debugPrint('📴 Offline: Cannot archive booking');
      return;
    }

    try {
      debugPrint('📦 Archiving booking: $bookingId');

      final bookingDoc = await _db.collection('bookings').doc(bookingId).get();

      if (!bookingDoc.exists) {
        debugPrint('⚠️ Booking not found: $bookingId');
        return;
      }

      final bookingData = bookingDoc.data()!;

      final guestsSnapshot = await _db
          .collection('bookings')
          .doc(bookingId)
          .collection('guests')
          .get();

      final guests = guestsSnapshot.docs.map((doc) => doc.data()).toList();

      final archivedData = {
        ...bookingData,
        'originalBookingId': bookingId,
        'archivedAt': FieldValue.serverTimestamp(),
        'guests': guests,
        'status': 'archived',
      };

      await _db.collection('archived_bookings').add(archivedData);

      await deleteGuestsFromSubcollection(bookingId);

      await _db.collection('bookings').doc(bookingId).update({
        'status': 'archived',
        'archivedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Booking archived successfully');
    } catch (e) {
      debugPrint('❌ Archive booking error: $e');
      rethrow;
    }
  }

  // ============================================================
  // CLEANER FINISH - COMPLETE CLEANUP
  // ============================================================

  static Future<Map<String, int>> performCheckoutCleanup(
      String bookingId) async {
    debugPrint('🧹 Starting checkout cleanup for booking: $bookingId');

    final results = {
      'signatures_deleted': 0,
      'guests_deleted': 0,
      'booking_archived': 0,
    };

    if (!ConnectivityService.isOnline) {
      debugPrint('📴 Offline: Cleanup will run when online');
      return results;
    }

    try {
      results['signatures_deleted'] =
          await SignatureStorageService.deleteSignaturesByBooking(bookingId);

      results['guests_deleted'] =
          await deleteGuestsFromSubcollection(bookingId);

      await archiveBooking(bookingId);
      results['booking_archived'] = 1;

      debugPrint('✅ Cleanup complete: $results');
      return results;
    } catch (e) {
      debugPrint('❌ Cleanup error: $e');
      return results;
    }
  }

  // ============================================================
  // CHECK-IN / GUESTS (LEGACY)
  // ============================================================

  static Future<void> saveCheckIn(
    String docType,
    Map<String, String> guestData,
  ) async {
    final unitId = StorageService.getUnitId();
    final ownerId = StorageService.getOwnerId();

    if (unitId == null) throw "Tablet not registered (No Unit ID)";

    final checkInData = {
      'ownerId': ownerId,
      'unitId': unitId,
      'timestamp': FieldValue.serverTimestamp(),
      'docType': docType,
      'guestData': guestData,
      'status': 'pending_review',
      'platform': 'Android Kiosk',
      'language': StorageService.getLanguage(),
    };

    if (!ConnectivityService.isOnline) {
      debugPrint('📴 Offline: Queuing check-in...');
      // Spremi lokalno
      await StorageService.addScannedGuest(guestData);
      return;
    }

    try {
      await _db.collection('check_ins').add(checkInData);
      await StorageService.addScannedGuest(guestData);
      debugPrint("✅ Check-in saved successfully");
    } catch (e) {
      debugPrint("❌ Error saving check-in: $e");
      await StorageService.addScannedGuest(guestData);
      rethrow;
    }
  }

  // ============================================================
  // POTPIS KUĆNOG REDA (LEGACY)
  // ============================================================

  static Future<void> saveHouseRulesSignature(Uint8List signatureBytes) async {
    final unitId = StorageService.getUnitId();
    final ownerId = StorageService.getOwnerId();

    if (unitId == null) throw "No Unit ID";

    try {
      final String base64Image = base64Encode(signatureBytes);

      final Map<String, dynamic> signatureData = {
        'ownerId': ownerId,
        'unitId': unitId,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'house_rules_consent',
        'signatureImage': base64Image,
        'status': 'signed',
        'platform': 'Android Kiosk',
        'language': StorageService.getLanguage(),
        'guestName': StorageService.getGuestName(),
      };

      if (!ConnectivityService.isOnline) {
        debugPrint('📴 Offline: Cannot save signature (base64)');
        return;
      }

      await _db.collection('signatures').add(signatureData);
      debugPrint("✅ Signature saved for Unit: $unitId");
    } catch (e) {
      debugPrint("❌ Error saving signature: $e");
      rethrow;
    }
  }

  // ============================================================
  // GALLERY / SCREENSAVER IMAGES
  // ============================================================

  static Future<List<String>> getGalleryImages() async {
    try {
      final ownerId = StorageService.getOwnerId();

      if (ownerId == null) return [];

      if (!ConnectivityService.isOnline) {
        debugPrint('📴 Offline: Cannot fetch gallery');
        return [];
      }

      var snapshot = await _db
          .collection('screensaver_images')
          .where('ownerId', isEqualTo: ownerId)
          .orderBy('uploadedAt', descending: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => doc.data()['url'] as String?)
            .where((url) => url != null && url.isNotEmpty)
            .cast<String>()
            .toList();
      }

      // Fallback na staru gallery kolekciju
      snapshot = await _db
          .collection('gallery')
          .where('ownerId', isEqualTo: ownerId)
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['url'] as String?)
          .where((url) => url != null && url.isNotEmpty)
          .cast<String>()
          .toList();
    } catch (e) {
      debugPrint("⚠️ Gallery fetch failed: $e");
      return [];
    }
  }

  // ============================================================
  // HELPER: Get current booking ID
  // ============================================================

  static Future<String?> getCurrentBookingId() async {
    // Prvo provjeri cache
    final cachedId = StorageService.getBookingId();

    if (!ConnectivityService.isOnline) {
      return cachedId;
    }

    final unitId = StorageService.getUnitId();
    if (unitId == null) return cachedId;

    try {
      final now = DateTime.now();
      final snapshot = await _db
          .collection('bookings')
          .where('unitId', isEqualTo: unitId)
          .where('endDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .where('status', isNotEqualTo: 'archived')
          .orderBy('status')
          .orderBy('endDate')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.id;
      }
    } catch (e) {
      debugPrint("⚠️ Get booking ID error: $e");
    }
    return cachedId;
  }
}
