// FILE: lib/data/services/signature_storage_service.dart
// OPIS: Upload potpisa u Firebase Storage, URL u Firestore
// VERZIJA: 5.1 - FIX: Kompatibilno s postojećim StorageService
// DATUM: 2026-01-09
//
// ✅ STANDARD: SVE camelCase
// ✅ STORAGE PATH: signatures/{ownerId}/{signatureId}.png

import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'storage_service.dart';

class SignatureStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============================================================
  // UPLOAD SIGNATURE TO FIREBASE STORAGE
  // ============================================================

  /// Upload potpisa u Storage i vraća URL
  ///
  /// [signatureBytes] - PNG bytes potpisa
  /// [bookingId] - ID bookinga za povezivanje
  /// [guestName] - Ime gosta
  ///
  /// Returns: Download URL slike
  static Future<String> uploadSignature({
    required Uint8List signatureBytes,
    required String bookingId,
    required String guestName,
  }) async {
    try {
      final ownerId = StorageService.getOwnerId() ?? 'unknown';
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // ✅ Path koristi ownerId
      // Storage path: signatures/{ownerId}/{bookingId}_{timestamp}.png
      final String path = 'signatures/$ownerId/${bookingId}_$timestamp.png';

      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putData(
        signatureBytes,
        SettableMetadata(
          contentType: 'image/png',
          customMetadata: {
            'bookingId': bookingId, // ✅ camelCase
            'guestName': guestName, // ✅ camelCase
            'ownerId': ownerId, // ✅ camelCase
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();

      debugPrint('✅ Signature uploaded: $path');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Signature upload error: $e');
      rethrow;
    }
  }

  // ============================================================
  // SAVE SIGNATURE DOCUMENT WITH BOOKING REFERENCE
  // ============================================================

  /// Sprema signature dokument u Firestore s referencom na booking
  ///
  /// ⚠️ KRITIČNO: bookingId je OBAVEZAN za GDPR cleanup!
  static Future<String> saveSignatureWithBooking({
    required Uint8List signatureBytes,
    required String bookingId,
    required String guestName,
    required String firstName,
    required String lastName,
    required String rulesVersion,
  }) async {
    try {
      final unitId = StorageService.getUnitId();
      final ownerId = StorageService.getOwnerId();

      if (unitId == null) throw "No Unit ID";
      if (ownerId == null) throw "No Owner ID";

      // 1. Upload sliku u Storage
      final signatureUrl = await uploadSignature(
        signatureBytes: signatureBytes,
        bookingId: bookingId,
        guestName: guestName,
      );

      // 2. Spremi dokument u Firestore
      // ✅ SVA polja camelCase
      final signatureData = {
        'ownerId': ownerId, // ✅ camelCase
        'bookingId': bookingId, // ✅ camelCase - KRITIČNO za cleanup!
        'unitId': unitId, // ✅ camelCase
        'guestName': guestName, // ✅ camelCase
        'signatureUrl': signatureUrl, // ✅ camelCase - Storage URL!
        'signedAt': FieldValue.serverTimestamp(), // ✅ camelCase
        'language': StorageService.getLanguage(),
        'rulesVersion': rulesVersion, // ✅ camelCase
        'platform': 'Android Kiosk',
      };

      final docRef = await _db.collection('signatures').add(signatureData);

      debugPrint('✅ Signature saved: ${docRef.id} for booking: $bookingId');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Save signature error: $e');
      rethrow;
    }
  }

  // ============================================================
  // SAVE GUEST SIGNATURE (za subcollection)
  // ============================================================

  /// Sprema potpis gosta i ažurira guest dokument u subcollection
  static Future<String> saveGuestSignature({
    required Uint8List signatureBytes,
    required String bookingId,
    required String guestId,
    required String guestName,
  }) async {
    try {
      final ownerId = StorageService.getOwnerId();
      if (ownerId == null) throw "No Owner ID";

      // 1. Upload u Storage
      final signatureUrl = await uploadSignature(
        signatureBytes: signatureBytes,
        bookingId: bookingId,
        guestName: guestName,
      );

      // 2. Update guest dokument u subcollection
      // ✅ camelCase
      await _db
          .collection('bookings')
          .doc(bookingId)
          .collection('guests')
          .doc(guestId)
          .update({
        'signatureUrl': signatureUrl, // ✅ camelCase
        'signedAt': FieldValue.serverTimestamp(), // ✅ camelCase
      });

      debugPrint('✅ Guest signature saved for: $guestId');
      return signatureUrl;
    } catch (e) {
      debugPrint('❌ Save guest signature error: $e');
      rethrow;
    }
  }

  // ============================================================
  // DELETE SIGNATURES BY BOOKING ID
  // ============================================================

  /// Briše sve potpise vezane uz booking (poziva se na FINISH)
  ///
  /// ⚠️ Ovo je GDPR cleanup - briše osobne podatke nakon checkout-a
  static Future<int> deleteSignaturesByBooking(String bookingId) async {
    try {
      // ✅ Query koristi camelCase
      final querySnapshot = await _db
          .collection('signatures')
          .where('bookingId', isEqualTo: bookingId) // ✅ camelCase
          .get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint('ℹ️ No signatures found for booking: $bookingId');
        return 0;
      }

      int deletedCount = 0;

      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data();

          // Briši sliku iz Storage-a ako postoji URL
          final signatureUrl = data['signatureUrl']; // ✅ camelCase
          if (signatureUrl != null && signatureUrl.toString().isNotEmpty) {
            try {
              final ref = _storage.refFromURL(signatureUrl);
              await ref.delete();
              debugPrint('🗑️ Deleted signature image: ${ref.fullPath}');
            } catch (storageError) {
              debugPrint('⚠️ Storage delete warning: $storageError');
            }
          }

          // Briši Firestore dokument
          await doc.reference.delete();
          deletedCount++;
        } catch (e) {
          debugPrint('⚠️ Error deleting signature ${doc.id}: $e');
        }
      }

      debugPrint('✅ Deleted $deletedCount signatures for booking: $bookingId');
      return deletedCount;
    } catch (e) {
      debugPrint('❌ Delete signatures error: $e');
      return 0;
    }
  }

  // ============================================================
  // DELETE SIGNATURES BY UNIT ID (za Factory Reset)
  // ============================================================

  /// Briše sve potpise za unit (factory reset scenario)
  static Future<int> deleteSignaturesByUnit(String unitId) async {
    try {
      // ✅ camelCase
      final querySnapshot = await _db
          .collection('signatures')
          .where('unitId', isEqualTo: unitId) // ✅ camelCase
          .get();

      int deletedCount = 0;
      final batch = _db.batch();

      for (final doc in querySnapshot.docs) {
        final data = doc.data();

        // Briši sliku iz Storage-a
        final signatureUrl = data['signatureUrl']; // ✅ camelCase
        if (signatureUrl != null) {
          try {
            final ref = _storage.refFromURL(signatureUrl);
            await ref.delete();
          } catch (_) {}
        }

        batch.delete(doc.reference);
        deletedCount++;
      }

      await batch.commit();
      debugPrint('✅ Deleted $deletedCount signatures for unit: $unitId');
      return deletedCount;
    } catch (e) {
      debugPrint('❌ Delete unit signatures error: $e');
      return 0;
    }
  }

  // ============================================================
  // DELETE SIGNATURES BY OWNER ID (za Account Delete / GDPR)
  // ============================================================

  /// Briše sve potpise za vlasnika (GDPR - pravo na zaborav)
  static Future<int> deleteSignaturesByOwner(String ownerId) async {
    try {
      // ✅ camelCase
      final querySnapshot = await _db
          .collection('signatures')
          .where('ownerId', isEqualTo: ownerId) // ✅ camelCase
          .get();

      int deletedCount = 0;

      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data();

          // Briši sliku iz Storage-a
          final signatureUrl = data['signatureUrl']; // ✅ camelCase
          if (signatureUrl != null) {
            try {
              final ref = _storage.refFromURL(signatureUrl);
              await ref.delete();
            } catch (_) {}
          }

          await doc.reference.delete();
          deletedCount++;
        } catch (e) {
          debugPrint('⚠️ Error deleting signature ${doc.id}: $e');
        }
      }

      debugPrint('✅ Deleted $deletedCount signatures for owner: $ownerId');
      return deletedCount;
    } catch (e) {
      debugPrint('❌ Delete owner signatures error: $e');
      return 0;
    }
  }

  // ============================================================
  // GET SIGNATURES FOR BOOKING
  // ============================================================

  /// Dohvaća sve potpise za booking
  static Future<List<Map<String, dynamic>>> getSignaturesForBooking(
      String bookingId) async {
    try {
      // ✅ camelCase
      final querySnapshot = await _db
          .collection('signatures')
          .where('bookingId', isEqualTo: bookingId) // ✅ camelCase
          .orderBy('signedAt', descending: true) // ✅ camelCase
          .get();

      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      debugPrint('❌ Get signatures error: $e');
      return [];
    }
  }
}
