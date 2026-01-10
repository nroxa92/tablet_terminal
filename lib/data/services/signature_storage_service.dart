// FILE: lib/data/services/signature_storage_service.dart
// OPIS: Upload potpisa u Firebase Storage, URL u Firestore
// VERZIJA: 6.0 - FAZA 2: Offline Queue Integration
// DATUM: 2026-01-10
//
// ✅ STANDARD: SVE camelCase
// ✅ STORAGE PATH: signatures/{ownerId}/{signatureId}.png
// ✅ OFFLINE: Lokalno spremanje + queue

import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'storage_service.dart';
import 'connectivity_service.dart';
import 'offline_queue_service.dart';
import 'sentry_service.dart';
import 'performance_service.dart';

class SignatureStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============================================================
  // UPLOAD SIGNATURE TO FIREBASE STORAGE
  // ============================================================

  /// Upload potpisa u Storage i vraća URL
  /// S offline fallback - sprema lokalno ako nema interneta
  static Future<String> uploadSignature({
    required Uint8List signatureBytes,
    required String bookingId,
    required String guestName,
  }) async {
    // Start performance trace
    await PerformanceService.startSignatureUploadTrace();

    // Ako smo offline, spremi lokalno
    if (!ConnectivityService.isOnline) {
      debugPrint('📴 Offline: Saving signature locally...');

      final localPath = await OfflineQueueService.saveSignatureLocally(
        signatureBytes,
        bookingId,
      );

      // Queue upload za kasnije
      await OfflineQueueService.queueUploadSignature(
        bookingId: bookingId,
        guestName: guestName,
        localPath: localPath,
      );

      SentryService.logSignature(uploaded: false);
      await PerformanceService.stopSignatureUploadTrace(success: false);

      return 'offline://$localPath';
    }

    try {
      final ownerId = StorageService.getOwnerId() ?? 'unknown';
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final String path = 'signatures/$ownerId/${bookingId}_$timestamp.png';

      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putData(
        signatureBytes,
        SettableMetadata(
          contentType: 'image/png',
          customMetadata: {
            'bookingId': bookingId,
            'guestName': guestName,
            'ownerId': ownerId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();

      debugPrint('✅ Signature uploaded: $path');
      SentryService.logSignature(uploaded: true);
      await PerformanceService.stopSignatureUploadTrace(
        success: true,
        fileSizeKb: signatureBytes.length ~/ 1024,
      );

      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Signature upload error (saving locally): $e');
      SentryService.captureException(e, hint: 'Signature upload failed');

      // Fallback na lokalno spremanje
      final localPath = await OfflineQueueService.saveSignatureLocally(
        signatureBytes,
        bookingId,
      );

      await OfflineQueueService.queueUploadSignature(
        bookingId: bookingId,
        guestName: guestName,
        localPath: localPath,
      );

      await PerformanceService.stopSignatureUploadTrace(success: false);
      return 'offline://$localPath';
    }
  }

  // ============================================================
  // SAVE SIGNATURE DOCUMENT WITH BOOKING REFERENCE
  // ============================================================

  /// Sprema signature dokument u Firestore s referencom na booking
  /// S offline fallback
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

      // 1. Upload sliku u Storage (s offline fallback)
      final signatureUrl = await uploadSignature(
        signatureBytes: signatureBytes,
        bookingId: bookingId,
        guestName: guestName,
      );

      // Ako je offline (URL počinje s 'offline://'), ne spremaj u Firestore
      if (signatureUrl.startsWith('offline://')) {
        debugPrint('📴 Signature saved locally, will sync later');
        return 'queued_${DateTime.now().millisecondsSinceEpoch}';
      }

      // 2. Spremi dokument u Firestore
      final signatureData = {
        'ownerId': ownerId,
        'bookingId': bookingId,
        'unitId': unitId,
        'guestName': guestName,
        'signatureUrl': signatureUrl,
        'signedAt': FieldValue.serverTimestamp(),
        'language': StorageService.getLanguage(),
        'rulesVersion': rulesVersion,
        'platform': 'Android Kiosk',
      };

      final docRef = await _db.collection('signatures').add(signatureData);

      debugPrint('✅ Signature saved: ${docRef.id} for booking: $bookingId');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Save signature error: $e');
      SentryService.captureException(e, hint: 'Save signature failed');
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

      // 1. Upload u Storage (s offline fallback)
      final signatureUrl = await uploadSignature(
        signatureBytes: signatureBytes,
        bookingId: bookingId,
        guestName: guestName,
      );

      // Ako je offline, vrati placeholder
      if (signatureUrl.startsWith('offline://')) {
        debugPrint('📴 Guest signature saved locally');
        return signatureUrl;
      }

      // 2. Update guest dokument u subcollection
      await _db
          .collection('bookings')
          .doc(bookingId)
          .collection('guests')
          .doc(guestId)
          .update({
        'signatureUrl': signatureUrl,
        'signedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Guest signature saved for: $guestId');
      return signatureUrl;
    } catch (e) {
      debugPrint('❌ Save guest signature error: $e');
      SentryService.captureException(e, hint: 'Save guest signature failed');
      rethrow;
    }
  }

  // ============================================================
  // DELETE SIGNATURES BY BOOKING ID
  // ============================================================

  /// Briše sve potpise vezane uz booking (poziva se na FINISH)
  static Future<int> deleteSignaturesByBooking(String bookingId) async {
    // Ne možemo brisati offline
    if (!ConnectivityService.isOnline) {
      debugPrint('📴 Offline: Cannot delete signatures');
      return 0;
    }

    try {
      final querySnapshot = await _db
          .collection('signatures')
          .where('bookingId', isEqualTo: bookingId)
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
          final signatureUrl = data['signatureUrl'];
          if (signatureUrl != null &&
              signatureUrl.toString().isNotEmpty &&
              !signatureUrl.toString().startsWith('offline://')) {
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
      SentryService.captureException(e, hint: 'Delete signatures failed');
      return 0;
    }
  }

  // ============================================================
  // DELETE SIGNATURES BY UNIT ID (za Factory Reset)
  // ============================================================

  static Future<int> deleteSignaturesByUnit(String unitId) async {
    if (!ConnectivityService.isOnline) {
      debugPrint('📴 Offline: Cannot delete unit signatures');
      return 0;
    }

    try {
      final querySnapshot = await _db
          .collection('signatures')
          .where('unitId', isEqualTo: unitId)
          .get();

      int deletedCount = 0;
      final batch = _db.batch();

      for (final doc in querySnapshot.docs) {
        final data = doc.data();

        // Briši sliku iz Storage-a
        final signatureUrl = data['signatureUrl'];
        if (signatureUrl != null &&
            !signatureUrl.toString().startsWith('offline://')) {
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

  static Future<int> deleteSignaturesByOwner(String ownerId) async {
    if (!ConnectivityService.isOnline) {
      debugPrint('📴 Offline: Cannot delete owner signatures');
      return 0;
    }

    try {
      final querySnapshot = await _db
          .collection('signatures')
          .where('ownerId', isEqualTo: ownerId)
          .get();

      int deletedCount = 0;

      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data();

          // Briši sliku iz Storage-a
          final signatureUrl = data['signatureUrl'];
          if (signatureUrl != null &&
              !signatureUrl.toString().startsWith('offline://')) {
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

  static Future<List<Map<String, dynamic>>> getSignaturesForBooking(
      String bookingId) async {
    if (!ConnectivityService.isOnline) {
      debugPrint('📴 Offline: Cannot fetch signatures');
      return [];
    }

    try {
      final querySnapshot = await _db
          .collection('signatures')
          .where('bookingId', isEqualTo: bookingId)
          .orderBy('signedAt', descending: true)
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

  // ============================================================
  // HELPER: Check if signature is local (offline)
  // ============================================================

  static bool isOfflineSignature(String url) {
    return url.startsWith('offline://');
  }

  /// Dohvati lokalni path iz offline URL-a
  static String? getLocalPath(String offlineUrl) {
    if (!isOfflineSignature(offlineUrl)) return null;
    return offlineUrl.replaceFirst('offline://', '');
  }
}
