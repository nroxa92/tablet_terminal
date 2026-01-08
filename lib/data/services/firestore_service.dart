// FILE: lib/data/services/firestore_service.dart
// OPIS: Sinkronizacija podataka s Firebase Firestore.
// VERZIJA: 3.0 - Guests subcollection + Booking archive + Cleanup

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

      // Spremi osnovne podatke
      await StorageService.setVillaData(
        data['name'] ?? 'Villa Guest',
        data['address'] ?? '',
        data['wifi_ssid'] ?? '',
        data['wifi_pass'] ?? '',
        data['contact_phone'] ?? '',
      );

      // Spremi kontakte ako postoje
      if (data['contacts'] != null && data['contacts'] is Map) {
        final Map<String, String> contacts = {};
        (data['contacts'] as Map).forEach((key, value) {
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

      // 3. AI PROMPTS
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

      // 5. GOOGLE REVIEW URL (za Feedback screen)
      if (data['googleReviewUrl'] != null) {
        await StorageService.setGoogleReviewUrl(
            data['googleReviewUrl'].toString());
      }

      // 6. CLEANER TASKS
      if (data['cleanerTasks'] != null && data['cleanerTasks'] is List) {
        final tasks = List<String>.from(data['cleanerTasks']);
        await StorageService.setCleanerTasks(tasks);
      }

      // 7. KONTAKTI VLASNIKA (ako su u settings)
      if (data['ownerContacts'] != null && data['ownerContacts'] is Map) {
        final Map<String, String> contacts = {};
        (data['ownerContacts'] as Map).forEach((key, value) {
          contacts[key.toString()] = value.toString();
        });
        await StorageService.setContactOptions(contacts);
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

      // Traži aktivnu rezervaciju za danas
      final snapshot = await _db
          .collection('bookings')
          .where('unit_id', isEqualTo: unitId)
          .where('end_date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .orderBy('end_date')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint("ℹ️ No active booking found");
        await StorageService.clearCurrentBooking();
        return;
      }

      final bookingDoc = snapshot.docs.first;
      final data = bookingDoc.data();

      // Provjeri da li je rezervacija započela
      final startDate = (data['start_date'] as Timestamp).toDate();
      final endDate = (data['end_date'] as Timestamp).toDate();

      if (startDate.isAfter(now)) {
        debugPrint("ℹ️ Booking hasn't started yet");
        await StorageService.clearCurrentBooking();
        return;
      }

      // Spremi booking podatke
      await StorageService.setCurrentBooking(
        guestName: data['guest_name'] ?? '',
        startDate: startDate,
        endDate: endDate,
        guestCount: data['guest_count'] ?? 1,
        bookingId: bookingDoc.id,
        guestEmail: data['guest_email'],
        guestPhone: data['guest_phone'],
        notes: data['notes'],
      );

      debugPrint(
          "✅ Booking synced: ${data['guest_name']} (${data['guest_count']} guests)");
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
      final snapshot = await _db
          .collection('bookings')
          .where('unit_id', isEqualTo: unitId)
          .where('end_date', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .orderBy('end_date')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        return data['guest_count'] ?? 1;
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching guest count: $e");
    }
    return 1;
  }

  // ============================================================
  // ⭐ GUESTS SUBCOLLECTION (NOVO!)
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
        'created_at': FieldValue.serverTimestamp(),
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
      final guestsRef = _db
          .collection('bookings')
          .doc(bookingId)
          .collection('guests');

      for (final guestData in guests) {
        final docRef = guestsRef.doc();
        batch.set(docRef, {
          ...guestData,
          'created_at': FieldValue.serverTimestamp(),
        });
      }

      // Također ažuriraj booking dokument
      batch.update(_db.collection('bookings').doc(bookingId), {
        'is_scanned': true,
        'scanned_at': FieldValue.serverTimestamp(),
        'scanned_guest_count': guests.length,
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

      debugPrint('🗑️ Deleted ${guestsSnapshot.docs.length} guests from subcollection');
      return guestsSnapshot.docs.length;
    } catch (e) {
      debugPrint('❌ Delete guests error: $e');
      return 0;
    }
  }

  // ============================================================
  // ⭐ BOOKING ARCHIVE (NOVO!)
  // ============================================================

  /// Arhivira booking nakon check-outa
  /// Kopira booking u archived_bookings i briše originalni
  static Future<void> archiveBooking(String bookingId) async {
    try {
      debugPrint('📦 Archiving booking: $bookingId');

      // 1. Dohvati booking dokument
      final bookingDoc = await _db.collection('bookings').doc(bookingId).get();
      
      if (!bookingDoc.exists) {
        debugPrint('⚠️ Booking not found: $bookingId');
        return;
      }

      final bookingData = bookingDoc.data()!;

      // 2. Dohvati goste iz subcollection
      final guestsSnapshot = await _db
          .collection('bookings')
          .doc(bookingId)
          .collection('guests')
          .get();

      final guests = guestsSnapshot.docs.map((doc) => doc.data()).toList();

      // 3. Kreiraj arhivirani dokument
      final archivedData = {
        ...bookingData,
        'original_booking_id': bookingId,
        'archived_at': FieldValue.serverTimestamp(),
        'guests': guests, // Spremamo goste kao array u arhivi (OK jer je read-only)
        'status': 'archived',
      };

      // 4. Spremi u archived_bookings
      await _db.collection('archived_bookings').add(archivedData);

      // 5. Obriši goste iz subcollection
      await deleteGuestsFromSubcollection(bookingId);

      // 6. Obriši ili označi booking kao arhiviran
      // Opcija A: Potpuno brisanje
      // await _db.collection('bookings').doc(bookingId).delete();
      
      // Opcija B: Samo označi kao arhiviran (sigurnije)
      await _db.collection('bookings').doc(bookingId).update({
        'status': 'archived',
        'archived_at': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Booking archived successfully');
    } catch (e) {
      debugPrint('❌ Archive booking error: $e');
      rethrow;
    }
  }

  // ============================================================
  // ⭐ CLEANER FINISH - COMPLETE CLEANUP (NOVO!)
  // ============================================================

  /// Kompletni cleanup nakon što čistačica završi
  /// 1. Briše signatures
  /// 2. Briše guest podatke
  /// 3. Arhivira booking
  static Future<Map<String, int>> performCheckoutCleanup(String bookingId) async {
    debugPrint('🧹 Starting checkout cleanup for booking: $bookingId');
    
    final results = {
      'signatures_deleted': 0,
      'guests_deleted': 0,
      'booking_archived': 0,
    };

    try {
      // 1. Briši signatures vezane uz booking
      results['signatures_deleted'] = 
          await SignatureStorageService.deleteSignaturesByBooking(bookingId);

      // 2. Briši goste iz subcollection
      results['guests_deleted'] = 
          await deleteGuestsFromSubcollection(bookingId);

      // 3. Arhiviraj booking
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
      final checkInData = {
        'unit_id': unitId,
        'owner_id': ownerId,
        'timestamp': FieldValue.serverTimestamp(),
        'doc_type': docType,
        'guest_data': guestData,
        'status': 'pending_review',
        'platform': 'Android Kiosk',
        'language': StorageService.getLanguage(),
      };

      await _db.collection('check_ins').add(checkInData);

      // Također spremi lokalno
      await StorageService.addScannedGuest(guestData);

      debugPrint("✅ Check-in saved successfully");
    } catch (e) {
      debugPrint("❌ Error saving check-in: $e");
      rethrow;
    }
  }

  // ============================================================
  // POTPIS KUĆNOG REDA (LEGACY - koristi novu metodu)
  // ============================================================

  static Future<void> saveHouseRulesSignature(Uint8List signatureBytes) async {
    final unitId = StorageService.getUnitId();
    final ownerId = StorageService.getOwnerId();

    if (unitId == null) throw "No Unit ID";

    try {
      final String base64Image = base64Encode(signatureBytes);

      final Map<String, dynamic> signatureData = {
        'unit_id': unitId,
        'owner_id': ownerId,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'house_rules_consent',
        'signature_image': base64Image,
        'status': 'signed',
        'platform': 'Android Kiosk',
        'language': StorageService.getLanguage(),
        'guest_name': StorageService.getGuestName(),
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
      await _db.collection('feedback').add({
        'unit_id': unitId,
        'owner_id': ownerId,
        'rating': rating,
        'comment': comment ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'guest_name': StorageService.getGuestName(),
        'language': StorageService.getLanguage(),
        'read': false,
        'platform': 'Android Kiosk',
      });

      debugPrint("⭐ Feedback saved: $rating stars");
    } catch (e) {
      debugPrint("❌ Error saving feedback: $e");
      rethrow;
    }
  }

  // ============================================================
  // AI CHAT LOGS (Opcionalno)
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
      await _db.collection('ai_logs').add({
        'unit_id': unitId,
        'owner_id': ownerId,
        'agent_id': agentId,
        'user_message': userMessage,
        'ai_response': aiResponse,
        'timestamp': FieldValue.serverTimestamp(),
        'language': StorageService.getLanguage(),
      });
    } catch (e) {
      debugPrint("⚠️ AI log failed: $e");
      // Ne rethrow - logging nije kritičan
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

      await _db.collection('cleaning_logs').add({
        'unit_id': unitId,
        'owner_id': ownerId,
        'booking_id': bookingId, // Poveznica s bookingom
        'timestamp': FieldValue.serverTimestamp(),
        'tasks': tasks,
        'completed_count': completedCount,
        'total_count': tasks.length,
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
  // GALLERY (Screensaver images)
  // ============================================================

  static Future<List<String>> getGalleryImages() async {
    try {
      final ownerId = StorageService.getOwnerId();

      // Prvo probaj owner-specific gallery
      if (ownerId != null) {
        final ownerGallery = await _db
            .collection('gallery')
            .where('owner_id', isEqualTo: ownerId)
            .get();

        if (ownerGallery.docs.isNotEmpty) {
          return ownerGallery.docs
              .map((doc) => doc.data()['url'] as String?)
              .where((url) => url != null && url.isNotEmpty)
              .cast<String>()
              .toList();
        }
      }

      // Fallback na globalnu galeriju
      final globalGallery = await _db.collection('gallery').get();

      return globalGallery.docs
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
      final snapshot = await _db
          .collection('bookings')
          .where('unit_id', isEqualTo: unitId)
          .where('end_date', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .where('status', isNotEqualTo: 'archived')
          .orderBy('status')
          .orderBy('end_date')
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