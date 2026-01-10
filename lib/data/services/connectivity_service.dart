// FILE: lib/data/services/connectivity_service.dart
// OPIS: Praćenje internet konekcije i auto-sync
// VERZIJA: 1.2 - FIX: Kompatibilno sa connectivity_plus koji vraća single ConnectivityResult
// DATUM: 2026-01-10

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'offline_queue_service.dart';
import 'sentry_service.dart';

class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();
  static StreamSubscription<ConnectivityResult>? _subscription;

  static bool _isOnline = true;
  static final _onlineController = StreamController<bool>.broadcast();

  // ============================================================
  // GETTERS
  // ============================================================

  /// Trenutni online status
  static bool get isOnline => _isOnline;

  /// Stream za slušanje promjena
  static Stream<bool> get onConnectivityChanged => _onlineController.stream;

  // ============================================================
  // INICIJALIZACIJA
  // ============================================================

  /// Pokreće praćenje konekcije
  static Future<void> init() async {
    try {
      // Provjeri početni status
      final result = await _connectivity.checkConnectivity();
      _updateStatus(result);

      // Slušaj promjene
      _subscription = _connectivity.onConnectivityChanged.listen(
        _handleConnectivityChange,
        onError: (e) {
          debugPrint('❌ Connectivity error: $e');
          SentryService.captureException(e,
              hint: 'Connectivity listener error');
        },
      );

      debugPrint('📡 Connectivity service initialized. Online: $_isOnline');
    } catch (e) {
      debugPrint('❌ Connectivity init error: $e');
      SentryService.captureException(e, hint: 'Connectivity init failed');
    }
  }

  /// Zaustavlja praćenje
  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
    debugPrint('📡 Connectivity service disposed');
  }

  // ============================================================
  // HANDLERS
  // ============================================================

  static void _handleConnectivityChange(ConnectivityResult result) {
    final wasOnline = _isOnline;
    _updateStatus(result);

    if (!wasOnline && _isOnline) {
      // Upravo smo se spojili na internet
      debugPrint('🌐 Back online! Processing queue...');
      SentryService.addBreadcrumb(
        message: 'Device came back online',
        category: 'connectivity',
      );

      // Procesiraj queue
      _processQueueOnReconnect();
    } else if (wasOnline && !_isOnline) {
      // Izgubili smo internet
      debugPrint('📴 Gone offline');
      SentryService.addBreadcrumb(
        message: 'Device went offline',
        category: 'connectivity',
      );
    }
  }

  static void _updateStatus(ConnectivityResult result) {
    final previousStatus = _isOnline;

    // Provjeri je li rezultat različit od 'none'
    _isOnline = result != ConnectivityResult.none;

    if (previousStatus != _isOnline) {
      _onlineController.add(_isOnline);
    }
  }

  static Future<void> _processQueueOnReconnect() async {
    try {
      final processed = await OfflineQueueService.processQueue();
      debugPrint('✅ Processed $processed queued operations');

      SentryService.addBreadcrumb(
        message: 'Queue processed on reconnect',
        category: 'offline',
        data: {'processed_count': processed},
      );
    } catch (e) {
      debugPrint('❌ Queue processing error: $e');
      SentryService.captureException(e, hint: 'Queue processing failed');
    }
  }

  // ============================================================
  // MANUAL CHECK
  // ============================================================

  /// Ručna provjera konekcije
  static Future<bool> checkConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateStatus(result);
      return _isOnline;
    } catch (e) {
      debugPrint('❌ Connection check error: $e');
      return false;
    }
  }

  /// Čeka dok se ne uspostavi konekcija (timeout u sekundama)
  static Future<bool> waitForConnection({int timeoutSeconds = 30}) async {
    if (_isOnline) return true;

    final completer = Completer<bool>();
    Timer? timeout;
    StreamSubscription<bool>? subscription;

    timeout = Timer(Duration(seconds: timeoutSeconds), () {
      subscription?.cancel();
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });

    subscription = onConnectivityChanged.listen((online) {
      if (online) {
        timeout?.cancel();
        subscription?.cancel();
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      }
    });

    return completer.future;
  }
}
