// FILE: lib/data/services/kiosk_service.dart
// OPIS: Kiosk Lockdown servis - SLAVE prema Web Panel MASTER specifikaciji
// VERZIJA: 3.0 - Prilagođeno Web Panel uputama
// DATUM: 2026-01-10
//
// VAŽNE PROMJENE OD WEB TIMA:
// - Default: OTKLJUČANO (kioskModeEnabled = false)
// - PIN: TOČNO 6 znamenki
// - Default PIN: "000000"
// - PIN prioritet: tablet override > owner master PIN
// - Lokalni unlock: PRIVREMENI (ne mijenja Firestore)

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'storage_service.dart';

class KioskService {
  // ============================================================
  // CONSTANTS (prema Web Panel specifikaciji)
  // ============================================================

  static const String _methodChannel = 'com.villaos.tablet/kiosk';
  static const String defaultPin = '000000'; // 6 nula = "nije postavljeno"
  static const int pinLength = 6; // FIKSNO 6 znamenki

  // ============================================================
  // PRIVATE FIELDS
  // ============================================================

  static const MethodChannel _channel = MethodChannel(_methodChannel);

  // Firestore listeneri
  static StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _tabletSubscription;
  static StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _settingsSubscription;

  // State
  static bool _isKioskEnabled = false; // DEFAULT: OTKLJUČANO!
  static bool _isLocked = false;
  static bool _isTemporarilyUnlocked = false; // Za lokalni unlock

  // PIN-ovi
  static String _masterPin = defaultPin; // Iz settings/{ownerId}
  static String _tabletPin = defaultPin; // Iz tablets/{tabletId} (override)

  // ID-evi
  static String? _currentOwnerId;
  static String? _currentUnitId;
  static String? _tabletDocId;

  static final _kioskStateController = StreamController<bool>.broadcast();

  // ============================================================
  // GETTERS
  // ============================================================

  /// Je li kiosk mode uključen (remote config)
  static bool get isKioskEnabled => _isKioskEnabled;

  /// Je li tablet trenutno zaključan
  static bool get isLocked => _isLocked && !_isTemporarilyUnlocked;

  /// Stream za praćenje stanja
  static Stream<bool> get onKioskStateChanged => _kioskStateController.stream;

  /// Efektivni PIN (tablet override > master PIN)
  static String get _effectivePin {
    // Ako tablet ima override PIN (nije default), koristi njega
    if (_tabletPin != defaultPin) {
      return _tabletPin;
    }
    // Inače koristi owner's master PIN
    return _masterPin;
  }

  // ============================================================
  // INICIJALIZACIJA
  // ============================================================

  /// Inicijalizira kiosk servis i počinje slušati remote config
  static Future<void> init() async {
    _currentOwnerId = StorageService.getOwnerId();
    _currentUnitId = StorageService.getUnitId();

    if (_currentOwnerId == null || _currentUnitId == null) {
      debugPrint('⚠️ KioskService: Missing ownerId or unitId - skipping init');
      return;
    }

    debugPrint('🔒 KioskService initializing (SLAVE mode)...');
    debugPrint('   OwnerId: $_currentOwnerId');
    debugPrint('   UnitId: $_currentUnitId');

    try {
      // 1. Pronađi tablet dokument i počni slušati
      await _startTabletListener();

      // 2. Počni slušati owner settings za master PIN
      _startSettingsListener();

      debugPrint('🔒 KioskService initialized. Enabled: $_isKioskEnabled');
    } catch (e) {
      debugPrint('❌ KioskService init error: $e');
    }
  }

  /// Zaustavi sve listenere
  static void dispose() {
    _tabletSubscription?.cancel();
    _tabletSubscription = null;
    _settingsSubscription?.cancel();
    _settingsSubscription = null;
    debugPrint('🔒 KioskService disposed');
  }

  // ============================================================
  // FIRESTORE LISTENERS
  // ============================================================

  /// Listener za tablet dokument (kiosk state + override PIN)
  static Future<void> _startTabletListener() async {
    debugPrint('👂 Starting tablet listener...');

    // Prvo pronađi tablet dokument
    final query = await FirebaseFirestore.instance
        .collection('tablets')
        .where('ownerId', isEqualTo: _currentOwnerId)
        .where('unitId', isEqualTo: _currentUnitId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      debugPrint('⚠️ No tablet document found - staying unlocked');
      return;
    }

    _tabletDocId = query.docs.first.id;
    debugPrint('✅ Found tablet document: $_tabletDocId');

    // Sada slušaj promjene
    final docRef =
        FirebaseFirestore.instance.collection('tablets').doc(_tabletDocId);

    _tabletSubscription = docRef.snapshots().listen(
      (DocumentSnapshot<Map<String, dynamic>> snapshot) {
        if (!snapshot.exists || snapshot.data() == null) {
          debugPrint('⚠️ Tablet document deleted or empty');
          return;
        }

        final data = snapshot.data()!;

        // Dohvati kiosk state
        final remoteKioskEnabled = data['kioskModeEnabled'] as bool? ?? false;
        final remoteTabletPin = data['kioskExitPin'] as String? ?? defaultPin;

        debugPrint('📡 Tablet config received:');
        debugPrint('   kioskModeEnabled: $remoteKioskEnabled');
        debugPrint(
            '   kioskExitPin: ${remoteTabletPin != defaultPin ? "******" : "(default)"}');

        // Ažuriraj tablet override PIN
        _tabletPin = remoteTabletPin;

        // Ako se promijenio kiosk status
        if (remoteKioskEnabled != _isKioskEnabled) {
          _isKioskEnabled = remoteKioskEnabled;
          _isTemporarilyUnlocked = false; // Reset privremenog unlocka

          _applyKioskState();
          _kioskStateController.add(_isKioskEnabled);
        }
      },
      onError: (e) {
        debugPrint('❌ Tablet listener error: $e');
      },
    );
  }

  /// Listener za owner settings (master PIN)
  static void _startSettingsListener() {
    if (_currentOwnerId == null || _currentOwnerId!.isEmpty) {
      debugPrint('⚠️ Cannot start settings listener - no ownerId');
      return;
    }

    debugPrint('👂 Starting settings listener for master PIN...');

    final docRef =
        FirebaseFirestore.instance.collection('settings').doc(_currentOwnerId);

    _settingsSubscription = docRef.snapshots().listen(
      (DocumentSnapshot<Map<String, dynamic>> snapshot) {
        if (!snapshot.exists || snapshot.data() == null) {
          debugPrint('⚠️ Settings document not found');
          return;
        }

        final data = snapshot.data()!;
        final remoteMasterPin = data['kioskExitPin'] as String? ?? defaultPin;

        if (remoteMasterPin != _masterPin) {
          _masterPin = remoteMasterPin;
          debugPrint(
              '📡 Master PIN updated: ${_masterPin != defaultPin ? "******" : "(default)"}');
        }
      },
      onError: (e) {
        debugPrint('❌ Settings listener error: $e');
      },
    );
  }

  // ============================================================
  // KIOSK STATE CONTROL
  // ============================================================

  /// Primijeni kiosk state prema remote configu
  static void _applyKioskState() {
    if (_isKioskEnabled) {
      debugPrint('🔒 Remote command: LOCK');
      enableKioskMode();
    } else {
      debugPrint('🔓 Remote command: UNLOCK');
      disableKioskMode();
    }
  }

  /// Uključi kiosk mode (zaključaj tablet)
  static Future<bool> enableKioskMode() async {
    try {
      debugPrint('🔒 Enabling kiosk mode...');

      final result = await _channel.invokeMethod<bool>('enableKioskMode');
      _isLocked = result ?? false;
      _isTemporarilyUnlocked = false;

      if (_isLocked) {
        debugPrint('✅ Kiosk mode ENABLED');
      }

      return _isLocked;
    } on PlatformException catch (e) {
      debugPrint('❌ Failed to enable kiosk mode: ${e.message}');
      return false;
    } on MissingPluginException {
      debugPrint('⚠️ Kiosk native code not available (debug mode?)');
      _isLocked = true;
      return true;
    }
  }

  /// Isključi kiosk mode (otključaj tablet)
  static Future<bool> disableKioskMode() async {
    try {
      debugPrint('🔓 Disabling kiosk mode...');

      final result = await _channel.invokeMethod<bool>('disableKioskMode');
      _isLocked = !(result ?? true);

      if (!_isLocked) {
        debugPrint('✅ Kiosk mode DISABLED');
      }

      return !_isLocked;
    } on PlatformException catch (e) {
      debugPrint('❌ Failed to disable kiosk mode: ${e.message}');
      return false;
    } on MissingPluginException {
      debugPrint('⚠️ Kiosk native code not available (debug mode?)');
      _isLocked = false;
      return true;
    }
  }

  // ============================================================
  // PIN VALIDATION & LOCAL UNLOCK
  // ============================================================

  /// Validira format PIN-a (mora biti točno 6 znamenki)
  static bool isValidPinFormat(String pin) {
    return RegExp(r'^\d{6}$').hasMatch(pin);
  }

  /// Provjeri PIN i otključaj PRIVREMENO ako je točan
  /// VAŽNO: Ovo NE mijenja Firestore! Samo privremeni lokalni unlock.
  static Future<bool> unlockWithPin(String enteredPin) async {
    // Validiraj format
    if (!isValidPinFormat(enteredPin)) {
      debugPrint('❌ Invalid PIN format (must be 6 digits)');
      return false;
    }

    // Provjeri PIN
    if (enteredPin == _effectivePin) {
      debugPrint('✅ PIN correct - TEMPORARY unlock');

      // Privremeni unlock (ne mijenja Firestore!)
      _isTemporarilyUnlocked = true;
      await disableKioskMode();

      return true;
    } else {
      debugPrint('❌ Incorrect PIN');
      return false;
    }
  }

  /// Ponovo zaključaj nakon privremenog unlocka
  static Future<void> relockAfterTemporaryUnlock() async {
    if (_isTemporarilyUnlocked && _isKioskEnabled) {
      debugPrint('🔒 Re-locking after temporary unlock');
      _isTemporarilyUnlocked = false;
      await enableKioskMode();
    }
  }

  // ============================================================
  // SCREEN & SYSTEM CONTROLS
  // ============================================================

  static Future<void> keepScreenOn(bool enabled) async {
    try {
      await _channel.invokeMethod('keepScreenOn', {'enabled': enabled});
      debugPrint('💡 Keep screen on: $enabled');
    } on PlatformException catch (e) {
      debugPrint('❌ keepScreenOn error: ${e.message}');
    } on MissingPluginException {
      debugPrint('⚠️ keepScreenOn not available');
    }
  }

  static Future<void> hideSystemBars() async {
    try {
      await _channel.invokeMethod('hideSystemBars');
      debugPrint('🙈 System bars hidden');
    } on PlatformException catch (e) {
      debugPrint('❌ hideSystemBars error: ${e.message}');
    } on MissingPluginException {
      debugPrint('⚠️ hideSystemBars not available');
    }
  }

  static Future<void> showSystemBars() async {
    try {
      await _channel.invokeMethod('showSystemBars');
      debugPrint('👁️ System bars shown');
    } on PlatformException catch (e) {
      debugPrint('❌ showSystemBars error: ${e.message}');
    } on MissingPluginException {
      debugPrint('⚠️ showSystemBars not available');
    }
  }

  // ============================================================
  // DEBUG & STATUS
  // ============================================================

  static Future<bool> checkKioskStatus() async {
    try {
      final result = await _channel.invokeMethod<bool>('isInKioskMode');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('❌ checkKioskStatus error: ${e.message}');
      return false;
    } on MissingPluginException {
      return _isLocked;
    }
  }

  static Map<String, dynamic> getDebugInfo() {
    return {
      'isKioskEnabled': _isKioskEnabled,
      'isLocked': _isLocked,
      'isTemporarilyUnlocked': _isTemporarilyUnlocked,
      'effectiveLocked': isLocked,
      'hasMasterPin': _masterPin != defaultPin,
      'hasTabletOverridePin': _tabletPin != defaultPin,
      'ownerId': _currentOwnerId,
      'unitId': _currentUnitId,
      'tabletDocId': _tabletDocId,
      'hasTabletListener': _tabletSubscription != null,
      'hasSettingsListener': _settingsSubscription != null,
    };
  }
}
