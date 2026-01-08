// FILE: lib/data/services/signature_storage_service.dart
// OPIS: Upload potpisa u Firebase Storage umjesto base64 u Firestore
// VERZIJA: 1.1 - Fixed imports

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
      final unitId = StorageService.getUnitId() ?? 'unknown';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // Putanja: signatures/{unitId}/{bookingId}_{timestamp}.png
      final String path = 'signatures/$unitId/${bookingId}_$timestamp.png';
      
      // Upload
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putData(
        signatureBytes,
        SettableMetadata(
          contentType: 'image/png',
          customMetadata: {
            'booking_id': bookingId,
            'guest_name': guestName,
            'unit_id': unitId,
            'uploaded_at': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Dohvati URL
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

      // 1. Upload sliku u Storage
      final signatureUrl = await uploadSignature(
        signatureBytes: signatureBytes,
        bookingId: bookingId,
        guestName: guestName,
      );

      // 2. Spremi dokument u Firestore
      final signatureData = {
        'unit_id': unitId,
        'owner_id': ownerId,
        'booking_id': bookingId, // ← KLJUČNO za cleanup!
        'guest_name': guestName,
        'first_name': firstName,
        'last_name': lastName,
        'signature_url': signatureUrl, // URL umjesto base64
        'signed_at': FieldValue.serverTimestamp(),
        'type': 'house_rules_consent',
        'language': StorageService.getLanguage(),
        'rules_version': rulesVersion,
        'status': 'active',
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
  // DELETE SIGNATURES BY BOOKING ID
  // ============================================================

  /// Briše sve potpise vezane uz booking (poziva se na FINISH)
  static Future<int> deleteSignaturesByBooking(String bookingId) async {
    try {
      // 1. Dohvati sve signature dokumente za ovaj booking
      final querySnapshot = await _db
          .collection('signatures')
          .where('booking_id', isEqualTo: bookingId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint('ℹ️ No signatures found for booking: $bookingId');
        return 0;
      }

      int deletedCount = 0;

      // 2. Briši svaki dokument i njegovu sliku iz Storage-a
      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          
          // Briši sliku iz Storage-a ako postoji URL
          if (data['signature_url'] != null) {
            try {
              final ref = _storage.refFromURL(data['signature_url']);
              await ref.delete();
              debugPrint('🗑️ Deleted signature image: ${ref.fullPath}');
            } catch (storageError) {
              // Možda je slika već obrisana
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
      final querySnapshot = await _db
          .collection('signatures')
          .where('unit_id', isEqualTo: unitId)
          .where('status', isEqualTo: 'active')
          .get();

      int deletedCount = 0;
      final batch = _db.batch();

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        
        // Briši sliku iz Storage-a
        if (data['signature_url'] != null) {
          try {
            final ref = _storage.refFromURL(data['signature_url']);
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
}