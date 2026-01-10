// FILE: lib/data/services/storage_service.dart
// OPIS: Lokalna pohrana podataka (Hive).
// VERZIJA: 3.0 - FAZA 1: Dodane PIN lockout metode
// DATUM: 2026-01-10

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static const String _boxName = 'villa_storage';
  static late Box _box;

  static Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  // ============================================================
  // IDENTITET (UNIT & OWNER)
  // ============================================================

  static Future<void> setUnitId(String id) async =>
      await _box.put('unit_id', id);

  static Future<void> setOwnerId(String id) async =>
      await _box.put('owner_id', id);

  static String? getUnitId() => _box.get('unit_id');
  static String? getOwnerId() => _box.get('owner_id');
  static bool isRegistered() => _box.containsKey('unit_id');

  // ============================================================
  // PODACI O VILI (CACHE)
  // ============================================================

  static Future<void> setVillaData(String name, String address, String wifi,
      String pass, String phone) async {
    await _box.put('villa_name', name);
    await _box.put('villa_address', address);
    await _box.put('wifi_ssid', wifi);
    await _box.put('wifi_pass', pass);
    await _box.put('contact_phone', phone);
  }

  static Map<String, String> getVillaData() {
    return {
      'name': _box.get('villa_name', defaultValue: 'Villa Guest'),
      'address': _box.get('villa_address', defaultValue: ''),
      'wifi_ssid': _box.get('wifi_ssid', defaultValue: 'Villa WiFi'),
      'wifi_pass': _box.get('wifi_pass', defaultValue: ''),
      'contact_phone': _box.get('contact_phone', defaultValue: ''),
    };
  }

  static String getWifiSSID() =>
      _box.get('wifi_ssid', defaultValue: 'Villa Guest');

  static String getWifiPassword() => _box.get('wifi_pass', defaultValue: '');

  static String getVillaAddress() =>
      _box.get('villa_address', defaultValue: 'Croatia');

  static String getVillaName() => _box.get('villa_name', defaultValue: 'Villa');

  // ============================================================
  // KONTAKTI VLASNIKA (WhatsApp, Viber, Phone, etc.)
  // ============================================================

  static Future<void> setContactOptions(Map<String, String> contacts) async {
    await _box.put('contacts', contacts);
  }

  static Map<String, String> getContactOptions() {
    final contacts = _box.get('contacts');
    if (contacts != null && contacts is Map) {
      return contacts.map((k, v) => MapEntry(k.toString(), v.toString()));
    }
    return {};
  }

  static String getContactPhone() =>
      _box.get('contact_phone', defaultValue: '');

  // ============================================================
  // GOOGLE REVIEW URL (za Feedback Screen)
  // ============================================================

  static Future<void> setGoogleReviewUrl(String url) async =>
      await _box.put('google_review_url', url);

  static String getGoogleReviewUrl() =>
      _box.get('google_review_url', defaultValue: '');

  // ============================================================
  // AI PROMPTOVI (iz Web Panela)
  // ============================================================

  static Future<void> setAIPrompts(Map<String, String> prompts) async {
    await _box.put('ai_prompts', prompts);
  }

  static String getAIPrompt(String agentKey) {
    final prompts = _box.get('ai_prompts');
    if (prompts != null && prompts is Map) {
      final stringMap =
          prompts.map((k, v) => MapEntry(k.toString(), v.toString()));
      return stringMap[agentKey] ?? "";
    }
    return "";
  }

  static Map<String, String> getAllAIPrompts() {
    final prompts = _box.get('ai_prompts');
    if (prompts != null && prompts is Map) {
      return prompts.map((k, v) => MapEntry(k.toString(), v.toString()));
    }
    return {};
  }

  // ============================================================
  // TRENUTNA REZERVACIJA (Booking)
  // ============================================================

  static Future<void> setCurrentBooking({
    required String guestName,
    required DateTime startDate,
    required DateTime endDate,
    required int guestCount,
    String? bookingId,
    String? guestEmail,
    String? guestPhone,
    String? notes,
  }) async {
    await _box.put('booking_guest_name', guestName);
    await _box.put('booking_start', startDate.toIso8601String());
    await _box.put('booking_end', endDate.toIso8601String());
    await _box.put('booking_guest_count', guestCount);
    if (bookingId != null) await _box.put('booking_id', bookingId);
    if (guestEmail != null) await _box.put('booking_guest_email', guestEmail);
    if (guestPhone != null) await _box.put('booking_guest_phone', guestPhone);
    if (notes != null) await _box.put('booking_notes', notes);
  }

  static Map<String, dynamic> getCurrentBooking() {
    return {
      'guest_name': _box.get('booking_guest_name', defaultValue: ''),
      'start_date': _box.get('booking_start'),
      'end_date': _box.get('booking_end'),
      'guest_count': _box.get('booking_guest_count', defaultValue: 1),
      'booking_id': _box.get('booking_id'),
      'guest_email': _box.get('booking_guest_email'),
      'guest_phone': _box.get('booking_guest_phone'),
      'notes': _box.get('booking_notes'),
    };
  }

  static String getGuestName() =>
      _box.get('booking_guest_name', defaultValue: '');

  static Future<void> setGuestName(String name) async =>
      await _box.put('booking_guest_name', name);

  static int getGuestCount() =>
      _box.get('booking_guest_count', defaultValue: 1);

  static DateTime? getBookingStart() {
    final dateStr = _box.get('booking_start');
    if (dateStr != null) {
      return DateTime.tryParse(dateStr);
    }
    return null;
  }

  static DateTime? getBookingEnd() {
    final dateStr = _box.get('booking_end');
    if (dateStr != null) {
      return DateTime.tryParse(dateStr);
    }
    return null;
  }

  static Future<void> clearCurrentBooking() async {
    await _box.delete('booking_guest_name');
    await _box.delete('booking_start');
    await _box.delete('booking_end');
    await _box.delete('booking_guest_count');
    await _box.delete('booking_id');
    await _box.delete('booking_guest_email');
    await _box.delete('booking_guest_phone');
    await _box.delete('booking_notes');
  }

  // ============================================================
  // POSTAVKE APLIKACIJE (Jezik, Status)
  // ============================================================

  static Future<void> setLanguage(String lang) async =>
      await _box.put('language', lang);

  static String getLanguage() => _box.get('language', defaultValue: 'en');

  static Future<void> setWelcomeDone() async =>
      await _box.put('welcome_done', true);

  static bool isWelcomeDone() => _box.get('welcome_done', defaultValue: false);

  static Future<void> setCheckInStatus(String status) async =>
      await _box.put('checkin_status', status);

  static String getCheckInStatus() =>
      _box.get('checkin_status', defaultValue: 'pending');

  // ============================================================
  // SIGURNOST (PIN-ovi)
  // ============================================================

  // CLEANER PIN
  static String getCleanerPin() =>
      _box.get('cleaner_pin', defaultValue: '1234');

  static Future<void> setCleanerPin(String pin) async =>
      await _box.put('cleaner_pin', pin);

  // MASTER PIN (Factory Reset)
  static String getMasterPin() => _box.get('master_pin', defaultValue: '0000');

  static Future<void> setMasterPin(String pin) async =>
      await _box.put('master_pin', pin);

  // ============================================================
  // 🔒 PIN BRUTE-FORCE PROTECTION (FAZA 1)
  // ============================================================

  /// Maksimalan broj pokušaja prije lockout-a
  static const int maxPinAttempts = 3;

  /// Trajanje lockout-a u sekundama (15 minuta)
  static const int lockoutDurationSeconds = 15 * 60;

  /// Dohvati broj neuspjelih pokušaja
  static int getPinAttempts() {
    return _box.get('pin_attempts', defaultValue: 0);
  }

  /// Inkrementiraj broj pokušaja
  static Future<void> incrementPinAttempts() async {
    final current = getPinAttempts();
    await _box.put('pin_attempts', current + 1);
    debugPrint('🔐 PIN attempts: ${current + 1}/$maxPinAttempts');
  }

  /// Resetiraj broj pokušaja (nakon uspješnog unosa)
  static Future<void> resetPinAttempts() async {
    await _box.put('pin_attempts', 0);
    await _box.delete('pin_lockout_until');
    debugPrint('🔓 PIN attempts reset');
  }

  /// Postavi lockout (poziva se kad se dosegne max pokušaja)
  static Future<void> setPinLockout() async {
    final lockoutUntil = DateTime.now().add(
      const Duration(seconds: lockoutDurationSeconds),
    );
    await _box.put('pin_lockout_until', lockoutUntil.toIso8601String());
    debugPrint('🔒 PIN locked until: $lockoutUntil');
  }

  /// Provjeri je li PIN zaključan
  static bool isPinLockedOut() {
    final lockoutStr = _box.get('pin_lockout_until');
    if (lockoutStr == null) return false;

    final lockoutUntil = DateTime.tryParse(lockoutStr);
    if (lockoutUntil == null) return false;

    final isLocked = DateTime.now().isBefore(lockoutUntil);

    // Ako je lockout istekao, automatski resetiraj
    if (!isLocked) {
      resetPinAttempts();
    }

    return isLocked;
  }

  /// Dohvati preostalo vrijeme lockout-a u sekundama
  static int getRemainingLockoutSeconds() {
    final lockoutStr = _box.get('pin_lockout_until');
    if (lockoutStr == null) return 0;

    final lockoutUntil = DateTime.tryParse(lockoutStr);
    if (lockoutUntil == null) return 0;

    final remaining = lockoutUntil.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  /// Formatirano preostalo vrijeme (MM:SS)
  static String getRemainingLockoutFormatted() {
    final seconds = getRemainingLockoutSeconds();
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Dohvati vrijeme kada lockout završava
  static DateTime? getLockoutEndTime() {
    final lockoutStr = _box.get('pin_lockout_until');
    if (lockoutStr == null) return null;
    return DateTime.tryParse(lockoutStr);
  }

  /// Provjeri treba li aktivirati lockout
  static bool shouldLockout() {
    return getPinAttempts() >= maxPinAttempts;
  }

  // ============================================================
  // CLEANER TASKOVI (Cache s Web Panela)
  // ============================================================

  static Future<void> setCleanerTasks(List<String> tasks) async {
    await _box.put('cleaner_tasks', tasks);
  }

  static List<String> getCleanerTasks() {
    final tasks = _box.get('cleaner_tasks');
    if (tasks != null && tasks is List) {
      return tasks.cast<String>();
    }
    // Default taskovi
    return [
      'Change bed linen & make beds',
      'Clean bathroom & replace towels',
      'Vacuum & mop all floors',
      'Clean kitchen & appliances',
      'Empty all trash bins',
    ];
  }

  // ============================================================
  // HOUSE RULES (Cache s Web Panela)
  // ============================================================

  static Future<void> setHouseRulesTranslations(
      Map<String, String> rules) async {
    await _box.put('house_rules', rules);
  }

  static String getHouseRules(String languageCode) {
    final rules = _box.get('house_rules');
    if (rules != null && rules is Map) {
      final stringMap =
          rules.map((k, v) => MapEntry(k.toString(), v.toString()));
      return stringMap[languageCode] ?? stringMap['en'] ?? '';
    }
    return '';
  }

  // ============================================================
  // SCANNED GUESTS (Privremeno dok ne završi check-in)
  // ============================================================

  static Future<void> addScannedGuest(Map<String, String> guestData) async {
    List<Map<String, dynamic>> guests = getScannedGuests();
    guests.add(guestData);
    await _box.put('scanned_guests', guests);
  }

  static List<Map<String, dynamic>> getScannedGuests() {
    final guests = _box.get('scanned_guests');
    if (guests != null && guests is List) {
      return guests.cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<void> clearScannedGuests() async {
    await _box.delete('scanned_guests');
  }

  // ============================================================
  // RESET METODE
  // ============================================================

  /// Briše samo podatke gosta (nakon check-out / cleaner finish)
  static Future<void> clearGuestData() async {
    await _box.delete('checkin_status');
    await _box.delete('welcome_done');
    await _box.delete('language');
    await clearCurrentBooking();
    await clearScannedGuests();
  }

  /// Alias za clearGuestData
  static Future<void> clearCheckIn() async {
    await clearGuestData();
  }

  /// Potpuni reset - briše SVE (za Factory Reset / premještanje tableta)
  static Future<void> factoryReset() async {
    await _box.clear();
  }

  // ============================================================
  // DEBUG / HELPERS
  // ============================================================

  /// Ispisuje sve pohranjene podatke (za debug)
  static void debugPrintAll() {
    debugPrint("========== STORAGE DEBUG ==========");
    for (var key in _box.keys) {
      debugPrint("$key: ${_box.get(key)}");
    }
    debugPrint("====================================");
  }

  /// Dohvati trenutni booking ID
  static String? getBookingId() => _box.get('booking_id');

  /// Postavi booking ID
  static Future<void> setBookingId(String id) async =>
      await _box.put('booking_id', id);
}
