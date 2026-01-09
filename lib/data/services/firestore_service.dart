// FILE: lib/data/services/firestore_service.dart
// OPIS: Sinkronizacija podataka s Firebase Firestore.
// VERZIJA: 5.1 - FIX: Kompatibilno s postojećim StorageService
// DATUM: 2026-01-09
//
// ✅ STANDARD: SVE camelCase
// ✅ KOMPATIBILNO: Koristi samo postojeće StorageService metode

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';
import 'signature_storage_service.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============================================================
  // GLAVNA SINKRONIZACIJA (poziva se na Dashboard load)
  // ============================================================

  /// Sinkronizira sve podatke potrebne za rad tableta
  static Future<void> syncAllData() async {
    try {
      final unitId = StorageService.getUnitId();
      final ownerId = StorageService.getOwnerId();

      if (unitId == null || ownerId == null) {
        throw "Unit ID or Owner ID not found on device.";
      }

      debugPrint("🔄 Starting full data sync...");

      // 1. Sync Unit Data (WiFi, Address, Name)
      await _syncUnitData(unitId);

      // 2. Sync Owner Settings (PINs, AI Prompts, House Rules, Cleaner Tasks)
      await _syncOwnerSettings(ownerId);

      // 3. Sync Current Booking
      await _syncCurrentBooking(unitId);

      debugPrint("✅ Full sync completed!");
    } catch (e) {
      debugPrint("❌ Sync error: $e");
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
        data['wifiSsid'] ?? '', // ✅ camelCase
        data['wifiPass'] ?? '', // ✅ camelCase
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

      // ✅ cleanerChecklist (camelCase) - Web Panel koristi ovo ime!
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

      // ✅ Query koristi camelCase
      final snapshot = await _db
          .collection('bookings')
          .where('unitId', isEqualTo: unitId) // ✅ camelCase
          .where('endDate', // ✅ camelCase
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

      // ✅ Sva polja su camelCase
      final startDate = (data['startDate'] as Timestamp).toDate();
      final endDate = (data['endDate'] as Timestamp).toDate();

      if (startDate.isAfter(now)) {
        debugPrint("ℹ️ Booking hasn't started yet");
        await StorageService.clearCurrentBooking();
        return;
      }

      await StorageService.setCurrentBooking(
        guestName: data['guestName'] ?? '', // ✅ camelCase
        startDate: startDate,
        endDate: endDate,
        guestCount: data['guestCount'] ?? 1, // ✅ camelCase
        bookingId: bookingDoc.id,
        guestEmail: data['guestEmail'], // ✅ camelCase
        guestPhone: data['guestPhone'], // ✅ camelCase
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

  /// Javna metoda za dohvat imena gosta
  static Future<String?> getTodaysGuestName() async {
    final unitId = StorageService.getUnitId();
    if (unitId == null) return null;

    await _syncCurrentBooking(unitId);
    final name = StorageService.getGuestName();
    return name.isNotEmpty ? name : null;
  }

  /// Dohvati broj gostiju za trenutnu rezervaciju
  static Future<int> getTodaysGuestCount() async {
    final unitId = StorageService.getUnitId();
    if (unitId == null) return 1;

    try {
      final now = DateTime.now();
      // ✅ camelCase
      final snapshot = await _db
          .collection('bookings')
          .where('unitId', isEqualTo: unitId) // ✅ camelCase
          .where('endDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .orderBy('endDate')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        return data['guestCount'] ?? 1; // ✅ camelCase
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching guest count: $e");
    }
    return 1;
  }

  // ============================================================
  // ⭐ GUESTS SUBCOLLECTION
  // ============================================================

  /// Sprema gosta u subcollection bookings/{bookingId}/guests/{guestId}
  static Future<String> saveGuestToSubcollection({
    required String bookingId,
    required Map<String, dynamic> guestData,
  }) async {
    try {
      final docRef = await _db
          .collection('bookings')
          .doc(bookingId)
          .collection('guests')
          .add({
        ...guestData,
        'createdAt': FieldValue.serverTimestamp(), // ✅ camelCase
      });

      debugPrint('✅ Guest saved to subcollection: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Save guest error: $e');
      rethrow;
    }
  }

  /// Sprema sve goste u subcollection (batch)
  static Future<void> saveAllGuestsToSubcollection({
    required String bookingId,
    required List<Map<String, dynamic>> guests,
  }) async {
    try {
      final batch = _db.batch();
      final guestsRef =
          _db.collection('bookings').doc(bookingId).collection('guests');

      for (final guestData in guests) {
        final docRef = guestsRef.doc();
        batch.set(docRef, {
          ...guestData,
          'createdAt': FieldValue.serverTimestamp(), // ✅ camelCase
        });
      }

      // ✅ Update booking s camelCase poljima
      batch.update(_db.collection('bookings').doc(bookingId), {
        'isScanned': true, // ✅ camelCase
        'scannedAt': FieldValue.serverTimestamp(), // ✅ camelCase
        'scannedGuestCount': guests.length, // ✅ camelCase
      });

      await batch.commit();
      debugPrint('✅ ${guests.length} guests saved to subcollection');
    } catch (e) {
      debugPrint('❌ Batch save guests error: $e');
      rethrow;
    }
  }

  /// Briše sve goste iz subcollection
  static Future<int> deleteGuestsFromSubcollection(String bookingId) async {
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
  // ⭐ BOOKING ARCHIVE
  // ============================================================

  /// Arhivira booking nakon check-outa
  static Future<void> archiveBooking(String bookingId) async {
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

      // ✅ Sva polja camelCase
      final archivedData = {
        ...bookingData,
        'originalBookingId': bookingId, // ✅ camelCase
        'archivedAt': FieldValue.serverTimestamp(), // ✅ camelCase
        'guests': guests,
        'status': 'archived',
      };

      await _db.collection('archived_bookings').add(archivedData);

      await deleteGuestsFromSubcollection(bookingId);

      await _db.collection('bookings').doc(bookingId).update({
        'status': 'archived',
        'archivedAt': FieldValue.serverTimestamp(), // ✅ camelCase
      });

      debugPrint('✅ Booking archived successfully');
    } catch (e) {
      debugPrint('❌ Archive booking error: $e');
      rethrow;
    }
  }

  // ============================================================
  // ⭐ CLEANER FINISH - COMPLETE CLEANUP
  // ============================================================

  static Future<Map<String, int>> performCheckoutCleanup(
      String bookingId) async {
    debugPrint('🧹 Starting checkout cleanup for booking: $bookingId');

    final results = {
      'signatures_deleted': 0,
      'guests_deleted': 0,
      'booking_archived': 0,
    };

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
  // CHECK-IN / GUESTS (LEGACY - za kompatibilnost)
  // ============================================================

  /// Sprema podatke o gostu (OCR scan) - LEGACY metoda
  static Future<void> saveCheckIn(
    String docType,
    Map<String, String> guestData,
  ) async {
    final unitId = StorageService.getUnitId();
    final ownerId = StorageService.getOwnerId();

    if (unitId == null) throw "Tablet not registered (No Unit ID)";

    try {
      // ✅ SVA polja camelCase
      final checkInData = {
        'ownerId': ownerId, // ✅ camelCase
        'unitId': unitId, // ✅ camelCase
        'timestamp': FieldValue.serverTimestamp(),
        'docType': docType, // ✅ camelCase
        'guestData': guestData, // ✅ camelCase
        'status': 'pending_review',
        'platform': 'Android Kiosk',
        'language': StorageService.getLanguage(),
      };

      await _db.collection('check_ins').add(checkInData);

      await StorageService.addScannedGuest(guestData);

      debugPrint("✅ Check-in saved successfully");
    } catch (e) {
      debugPrint("❌ Error saving check-in: $e");
      rethrow;
    }
  }

  // ============================================================
  // POTPIS KUĆNOG REDA (LEGACY - za kompatibilnost)
  // ============================================================

  static Future<void> saveHouseRulesSignature(Uint8List signatureBytes) async {
    final unitId = StorageService.getUnitId();
    final ownerId = StorageService.getOwnerId();

    if (unitId == null) throw "No Unit ID";

    try {
      final String base64Image = base64Encode(signatureBytes);

      // ✅ SVA polja camelCase
      final Map<String, dynamic> signatureData = {
        'ownerId': ownerId, // ✅ camelCase
        'unitId': unitId, // ✅ camelCase
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'house_rules_consent',
        'signatureImage': base64Image, // ✅ camelCase
        'status': 'signed',
        'platform': 'Android Kiosk',
        'language': StorageService.getLanguage(),
        'guestName': StorageService.getGuestName(), // ✅ camelCase
      };

      await _db.collection('signatures').add(signatureData);
      debugPrint("✅ Signature saved for Unit: $unitId");
    } catch (e) {
      debugPrint("❌ Error saving signature: $e");
      rethrow;
    }
  }

  // ============================================================
  // FEEDBACK
  // ============================================================

  static Future<void> saveFeedback({
    required int rating,
    String? comment,
  }) async {
    final unitId = StorageService.getUnitId();
    final ownerId = StorageService.getOwnerId();

    if (unitId == null) throw "No Unit ID";

    try {
      // ✅ SVA polja camelCase
      await _db.collection('feedback').add({
        'ownerId': ownerId, // ✅ camelCase
        'unitId': unitId, // ✅ camelCase
        'rating': rating,
        'comment': comment ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'guestName': StorageService.getGuestName(), // ✅ camelCase
        'language': StorageService.getLanguage(),
        'isRead': false, // ✅ camelCase
        'platform': 'Android Kiosk',
      });

      debugPrint("⭐ Feedback saved: $rating stars");
    } catch (e) {
      debugPrint("❌ Error saving feedback: $e");
      rethrow;
    }
  }

  // ============================================================
  // AI CHAT LOGS
  // ============================================================

  static Future<void> logAIConversation({
    required String agentId,
    required String userMessage,
    required String aiResponse,
  }) async {
    final unitId = StorageService.getUnitId();
    final ownerId = StorageService.getOwnerId();

    if (unitId == null) return;

    try {
      // ✅ SVA polja camelCase
      await _db.collection('ai_logs').add({
        'ownerId': ownerId, // ✅ camelCase
        'unitId': unitId, // ✅ camelCase
        'agentId': agentId, // ✅ camelCase
        'userMessage': userMessage, // ✅ camelCase
        'aiResponse': aiResponse, // ✅ camelCase
        'timestamp': FieldValue.serverTimestamp(),
        'language': StorageService.getLanguage(),
      });
    } catch (e) {
      debugPrint("⚠️ AI log failed: $e");
    }
  }

  // ============================================================
  // CLEANING LOGS
  // ============================================================

  static Future<void> saveCleaningLog({
    required Map<String, bool> tasks,
    required String notes,
    String? bookingId,
  }) async {
    final unitId = StorageService.getUnitId();
    final ownerId = StorageService.getOwnerId();

    if (unitId == null) throw "No Unit ID";

    try {
      final completedCount = tasks.values.where((v) => v).length;

      // ✅ SVA polja camelCase
      await _db.collection('cleaning_logs').add({
        'ownerId': ownerId, // ✅ camelCase
        'unitId': unitId, // ✅ camelCase
        'bookingId': bookingId, // ✅ camelCase
        'timestamp': FieldValue.serverTimestamp(),
        'tasks': tasks,
        'completedCount': completedCount, // ✅ camelCase
        'totalCount': tasks.length, // ✅ camelCase
        'notes': notes,
        'status': completedCount == tasks.length ? 'completed' : 'partial',
        'platform': 'Android Kiosk',
      });

      debugPrint("🧹 Cleaning log saved");
    } catch (e) {
      debugPrint("❌ Error saving cleaning log: $e");
      rethrow;
    }
  }

  // ============================================================
  // GALLERY / SCREENSAVER IMAGES
  // ============================================================

  /// Dohvaća slike za screensaver
  /// ✅ Zadržano ime getGalleryImages za kompatibilnost s screensaver_screen.dart
  static Future<List<String>> getGalleryImages() async {
    try {
      final ownerId = StorageService.getOwnerId();

      if (ownerId == null) return [];

      // ✅ Prvo probaj novu kolekciju screensaver_images
      var snapshot = await _db
          .collection('screensaver_images')
          .where('ownerId', isEqualTo: ownerId) // ✅ camelCase
          .orderBy('uploadedAt', descending: true) // ✅ camelCase
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
    final unitId = StorageService.getUnitId();
    if (unitId == null) return null;

    try {
      final now = DateTime.now();
      // ✅ camelCase
      final snapshot = await _db
          .collection('bookings')
          .where('unitId', isEqualTo: unitId) // ✅ camelCase
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
    return null;
  }
}
