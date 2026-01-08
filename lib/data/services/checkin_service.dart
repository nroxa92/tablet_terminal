// FILE: lib/data/services/checkin_service.dart
// VERZIJA: 1.3 - Status NEBITAN, samo unit_id + datum
//
// Funkcije:
// - Spremanje gostiju u booking dokument
// - Dohvat booking podataka (bez provjere statusa!)
// - Brisanje booking dokumenta nakon checkout

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CheckInService {
  static final _firestore = FirebaseFirestore.instance;

  // ════════════════════════════════════════════════════════════════════════
  // DOHVAT BOOKING-a
  // ════════════════════════════════════════════════════════════════════════

  /// Dohvaća aktivni booking za danu jedinicu
  /// Provjera: unit_id + datum u rasponu (status je NEBITAN)
  /// Vraća null ako nema aktivnog bookinga
  static Future<Map<String, dynamic>?> getActiveBooking(String unitId) async {
    try {
      final now = DateTime.now();

      debugPrint('🔍 Tražim booking za unit_id: $unitId');

      // Dohvati sve bookinge za taj unit (status nebitan!)
      final query = await _firestore
          .collection('bookings')
          .where('unit_id', isEqualTo: unitId)
          .get();

      debugPrint('📦 Pronađeno ${query.docs.length} bookinga za unit $unitId');

      for (var doc in query.docs) {
        final data = doc.data();
        final startDate = (data['start_date'] as Timestamp?)?.toDate();
        final endDate = (data['end_date'] as Timestamp?)?.toDate();

        debugPrint('   📋 Booking ${doc.id}: start=$startDate, end=$endDate');

        if (startDate != null && endDate != null) {
          // Provjeri je li booking aktivan (startDate <= now <= endDate)
          // Dodajemo 1 dan tolerancije na obje strane
          if (now.isAfter(startDate.subtract(const Duration(days: 1))) &&
              now.isBefore(endDate.add(const Duration(days: 1)))) {
            debugPrint('   ✅ Pronađen aktivan booking: ${doc.id}');
            return {
              'id': doc.id,
              ...data,
            };
          } else {
            debugPrint('   ⏭️ Preskačem - datum nije u rasponu (now: $now)');
          }
        } else {
          debugPrint('   ⚠️ Booking nema startDate ili endDate');
        }
      }

      debugPrint('❌ Nema aktivnog bookinga za unit: $unitId');
      return null;
    } catch (e) {
      debugPrint('❌ getActiveBooking error: $e');
      return null;
    }
  }

  /// Dohvaća booking po ID-u
  static Future<Map<String, dynamic>?> getBookingById(String bookingId) async {
    try {
      final doc = await _firestore.collection('bookings').doc(bookingId).get();
      if (doc.exists) {
        return {
          'id': doc.id,
          ...doc.data()!,
        };
      }
      return null;
    } catch (e) {
      debugPrint('❌ getBookingById error: $e');
      return null;
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // SPREMANJE GOSTIJU
  // ════════════════════════════════════════════════════════════════════════

  /// Dodaje gosta u booking dokument
  static Future<bool> addGuestToBooking(
      String bookingId, Map<String, dynamic> guestData) async {
    try {
      final docRef = _firestore.collection('bookings').doc(bookingId);

      await docRef.update({
        'guests': FieldValue.arrayUnion([guestData]),
        'updated_at': FieldValue.serverTimestamp(),
      });

      debugPrint(
          '✅ Gost dodan u booking: ${guestData['firstName']} ${guestData['lastName']}');
      return true;
    } catch (e) {
      debugPrint('❌ addGuestToBooking error: $e');
      return false;
    }
  }

  /// Sprema sve goste odjednom
  static Future<bool> saveAllGuests(
      String bookingId, List<Map<String, dynamic>> guests) async {
    try {
      final docRef = _firestore.collection('bookings').doc(bookingId);

      await docRef.update({
        'guests': guests,
        'is_scanned': true,
        'scanned_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Svi gosti (${guests.length}) spremljeni u booking');
      return true;
    } catch (e) {
      debugPrint('❌ saveAllGuests error: $e');
      return false;
    }
  }

  /// Označava booking kao skeniran
  static Future<bool> markAsScanned(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'is_scanned': true,
        'scanned_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('❌ markAsScanned error: $e');
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // CHECK-OUT & BRISANJE
  // ════════════════════════════════════════════════════════════════════════

  /// Briše booking dokument (nakon checkout-a)
  static Future<bool> deleteBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).delete();
      debugPrint('✅ Booking obrisan: $bookingId');
      return true;
    } catch (e) {
      debugPrint('❌ deleteBooking error: $e');
      return false;
    }
  }

  /// Checkout proces - briše booking nakon review-a
  static Future<bool> processCheckout({
    required String bookingId,
    required int rating,
    String? feedback,
  }) async {
    try {
      // 1. Spremi review ako je loš rating
      if (rating < 5 && feedback != null && feedback.isNotEmpty) {
        await _firestore.collection('feedback').add({
          'booking_id': bookingId,
          'rating': rating,
          'feedback': feedback,
          'created_at': FieldValue.serverTimestamp(),
        });
        debugPrint('✅ Feedback spremljen');
      }

      // 2. Obriši booking
      await deleteBooking(bookingId);

      return true;
    } catch (e) {
      debugPrint('❌ processCheckout error: $e');
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // HELPER METODE
  // ════════════════════════════════════════════════════════════════════════

  /// Provjeri je li booking već skeniran
  static Future<bool> isAlreadyScanned(String bookingId) async {
    try {
      final doc = await _firestore.collection('bookings').doc(bookingId).get();
      if (doc.exists) {
        return doc.data()?['is_scanned'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Dohvati broj gostiju iz bookinga
  static Future<int> getGuestCount(String bookingId) async {
    try {
      final doc = await _firestore.collection('bookings').doc(bookingId).get();
      if (doc.exists) {
        return doc.data()?['guest_count'] ?? 1;
      }
      return 1;
    } catch (e) {
      return 1;
    }
  }

  /// Dohvati datum odlaska iz bookinga
  static Future<DateTime?> getDepartureDate(String bookingId) async {
    try {
      final doc = await _firestore.collection('bookings').doc(bookingId).get();
      if (doc.exists) {
        final endDate = doc.data()?['end_date'] as Timestamp?;
        return endDate?.toDate();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
