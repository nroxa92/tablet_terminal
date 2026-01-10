// FILE: lib/data/services/sentry_service.dart
// OPIS: Sentry error tracking i custom events
// VERZIJA: 1.0 - FAZA 1
// DATUM: 2026-01-10

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'storage_service.dart';

class SentryService {
  // ============================================================
  // KONFIGURACIJA
  // ============================================================

  /// Sentry DSN - Vesta Lumina System
  static const String _dsn =
      'https://7e9329f52007020298de7202a1d304d0@o4510682073464832.ingest.de.sentry.io/4510685998153808';

  /// Environment (production, staging, development)
  static const String _environment = 'production';

  // ============================================================
  // INICIJALIZACIJA
  // ============================================================

  /// Inicijalizira Sentry - poziva se iz main.dart
  static Future<void> init(AppRunner appRunner) async {
    await SentryFlutter.init(
      (options) {
        options.dsn = _dsn;
        options.environment = _environment;

        // Sample rate za performance (1.0 = 100%)
        options.tracesSampleRate = 1.0;

        // Automatski hvata screenshot na crash (opcijski)
        options.attachScreenshot = true;

        // Debug mode samo u development
        options.debug = kDebugMode;

        // Dodaj device context
        options.sendDefaultPii = false; // GDPR - ne šalji osobne podatke
      },
      appRunner: appRunner,
    );
  }

  // ============================================================
  // CONTEXT - Dodaj korisničke informacije
  // ============================================================

  /// Postavlja kontekst uređaja (poziva se nakon auth)
  static Future<void> setDeviceContext() async {
    final unitId = StorageService.getUnitId();
    final ownerId = StorageService.getOwnerId();
    final villaName = StorageService.getVillaName();

    Sentry.configureScope((scope) {
      // Tag-ovi za filtriranje u Sentry dashboardu
      scope.setTag('unit_id', unitId ?? 'unknown');
      scope.setTag('owner_id', ownerId ?? 'unknown');
      scope.setTag('villa_name', villaName);

      // Extra context
      scope.setExtra('app_version', '2.0.0');
      scope.setExtra('platform', 'Android Kiosk');
    });

    debugPrint('📊 Sentry context set: unit=$unitId, owner=$ownerId');
  }

  /// Briše kontekst (na logout/reset)
  static void clearContext() {
    Sentry.configureScope((scope) {
      scope.clear();
    });
  }

  // ============================================================
  // ERROR REPORTING
  // ============================================================

  /// Ručno prijavi exception
  static Future<void> captureException(
    dynamic exception, {
    dynamic stackTrace,
    String? hint,
    Map<String, dynamic>? extras,
  }) async {
    try {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
        hint: hint != null ? Hint.withMap({'message': hint}) : null,
        withScope: extras != null
            ? (scope) {
                extras.forEach((key, value) {
                  scope.setExtra(key, value);
                });
              }
            : null,
      );
      debugPrint('🚨 Sentry: Exception captured - $exception');
    } catch (e) {
      debugPrint('⚠️ Sentry capture failed: $e');
    }
  }

  /// Prijavi error poruku (bez exception objekta)
  static Future<void> captureMessage(
    String message, {
    SentryLevel level = SentryLevel.error,
    Map<String, dynamic>? extras,
  }) async {
    try {
      await Sentry.captureMessage(
        message,
        level: level,
        withScope: extras != null
            ? (scope) {
                extras.forEach((key, value) {
                  scope.setExtra(key, value);
                });
              }
            : null,
      );
      debugPrint('📝 Sentry: Message captured - $message');
    } catch (e) {
      debugPrint('⚠️ Sentry message failed: $e');
    }
  }

  // ============================================================
  // BREADCRUMBS - Tragovi za debugging
  // ============================================================

  /// Dodaj breadcrumb (trag što je korisnik radio prije errora)
  static void addBreadcrumb({
    required String message,
    String? category,
    Map<String, dynamic>? data,
    SentryLevel level = SentryLevel.info,
  }) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: category ?? 'app',
        data: data,
        level: level,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Navigation breadcrumb
  static void logNavigation(String from, String to) {
    addBreadcrumb(
      message: 'Navigation: $from → $to',
      category: 'navigation',
      data: {'from': from, 'to': to},
    );
  }

  /// User action breadcrumb
  static void logUserAction(String action, {Map<String, dynamic>? details}) {
    addBreadcrumb(
      message: 'User action: $action',
      category: 'user',
      data: details,
    );
  }

  /// API call breadcrumb
  static void logApiCall(String endpoint, {int? statusCode, String? error}) {
    addBreadcrumb(
      message: 'API: $endpoint',
      category: 'http',
      data: {
        'endpoint': endpoint,
        if (statusCode != null) 'status_code': statusCode,
        if (error != null) 'error': error,
      },
      level: error != null ? SentryLevel.error : SentryLevel.info,
    );
  }

  // ============================================================
  // CUSTOM EVENTS - Za analitiku
  // ============================================================

  /// Log check-in event
  static void logCheckInStarted(String bookingId) {
    addBreadcrumb(
      message: 'Check-in started',
      category: 'checkin',
      data: {'booking_id': bookingId},
    );
  }

  /// Log OCR scan event
  static void logOcrScan({required bool success, String? errorType}) {
    addBreadcrumb(
      message: success ? 'OCR scan successful' : 'OCR scan failed',
      category: 'ocr',
      data: {
        'success': success,
        if (errorType != null) 'error_type': errorType,
      },
      level: success ? SentryLevel.info : SentryLevel.warning,
    );
  }

  /// Log signature event
  static void logSignature({required bool uploaded}) {
    addBreadcrumb(
      message: uploaded ? 'Signature uploaded' : 'Signature upload failed',
      category: 'signature',
      data: {'uploaded': uploaded},
      level: uploaded ? SentryLevel.info : SentryLevel.error,
    );
  }

  /// Log PIN attempt
  static void logPinAttempt({required bool success, required String pinType}) {
    addBreadcrumb(
      message: success ? 'PIN verified' : 'PIN failed',
      category: 'security',
      data: {'pin_type': pinType, 'success': success},
      level: success ? SentryLevel.info : SentryLevel.warning,
    );
  }

  /// Log Firebase sync
  static void logFirebaseSync({required bool success, String? collection}) {
    addBreadcrumb(
      message: success ? 'Firebase sync OK' : 'Firebase sync failed',
      category: 'firebase',
      data: {
        'success': success,
        if (collection != null) 'collection': collection,
      },
      level: success ? SentryLevel.info : SentryLevel.error,
    );
  }

  // ============================================================
  // TRANSACTIONS - Za performance tracking
  // ============================================================

  /// Započni performance transaction
  static ISentrySpan? startTransaction(String name, String operation) {
    try {
      final transaction = Sentry.startTransaction(
        name,
        operation,
        bindToScope: true,
      );
      return transaction;
    } catch (e) {
      debugPrint('⚠️ Sentry transaction failed: $e');
      return null;
    }
  }
}
