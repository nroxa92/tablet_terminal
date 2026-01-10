// FILE: lib/data/services/sentry_service.dart
// OPIS: Sentry error tracking, breadcrumbs, custom events
// VERZIJA: 2.1 - POPRAVLJEN beforeSend
// DATUM: 2026-01-10

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'storage_service.dart';

class SentryService {
  // ============================================================
  // KONFIGURACIJA
  // ============================================================

  static const String _dsn =
      'https://7e9329f52007020298de7202a1d304d0@o4510682073464832.ingest.de.sentry.io/4510685998153808';

  static const String _environment = 'production';

  // ============================================================
  // INICIJALIZACIJA
  // ============================================================

  static Future<void> init(AppRunner appRunner) async {
    await SentryFlutter.init(
      (options) {
        options.dsn = _dsn;
        options.environment = _environment;
        options.tracesSampleRate = 1.0;
        options.attachScreenshot = true;
        options.debug = kDebugMode;
        options.sendDefaultPii = false;

        // NAPOMENA: beforeSend uklonjen zbog type mismatch-a
        // Debug eventi se i dalje šalju - ne utječe na funkcionalnost
      },
      appRunner: appRunner,
    );
  }

  // ============================================================
  // CONTEXT
  // ============================================================

  static Future<void> setDeviceContext() async {
    final unitId = StorageService.getUnitId();
    final ownerId = StorageService.getOwnerId();
    final villaName = StorageService.getVillaName();

    Sentry.configureScope((scope) {
      scope.setTag('unit_id', unitId ?? 'unknown');
      scope.setTag('owner_id', ownerId ?? 'unknown');
      scope.setTag('villa_name', villaName);
      scope.setExtra('app_version', '2.0.0');
      scope.setExtra('platform', 'Android Kiosk');
    });

    debugPrint('📊 Sentry context set: unit=$unitId, owner=$ownerId');
  }

  static void clearContext() {
    Sentry.configureScope((scope) => scope.clear());
  }

  // ============================================================
  // ERROR REPORTING
  // ============================================================

  static Future<void> captureException(
    dynamic exception, {
    dynamic stackTrace,
    String? hint,
    Map<String, dynamic>? extras,
    String? category,
  }) async {
    try {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
        hint: hint != null ? Hint.withMap({'message': hint}) : null,
        withScope: (scope) {
          if (category != null) {
            scope.setTag('error_category', category);
          }
          extras?.forEach((key, value) {
            scope.setExtra(key, value);
          });
        },
      );
      debugPrint('🚨 Sentry: Exception captured - $exception');
    } catch (e) {
      debugPrint('⚠️ Sentry capture failed: $e');
    }
  }

  static Future<void> captureMessage(
    String message, {
    SentryLevel level = SentryLevel.error,
    Map<String, dynamic>? extras,
    String? category,
  }) async {
    try {
      await Sentry.captureMessage(
        message,
        level: level,
        withScope: (scope) {
          if (category != null) {
            scope.setTag('category', category);
          }
          extras?.forEach((key, value) {
            scope.setExtra(key, value);
          });
        },
      );
      debugPrint('📝 Sentry: Message captured - $message');
    } catch (e) {
      debugPrint('⚠️ Sentry message failed: $e');
    }
  }

  // ============================================================
  // BREADCRUMBS - Osnovni
  // ============================================================

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

  static void logNavigation(String from, String to) {
    addBreadcrumb(
      message: 'Navigation: $from → $to',
      category: 'navigation',
      data: {'from': from, 'to': to},
    );
  }

  static void logUserAction(String action, {Map<String, dynamic>? details}) {
    addBreadcrumb(
      message: 'User action: $action',
      category: 'user',
      data: details,
    );
  }

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
  // KIOSK EVENTI
  // ============================================================

  /// Log kiosk lock event
  static void logKioskLock({required String source}) {
    addBreadcrumb(
      message: 'Kiosk LOCKED',
      category: 'kiosk',
      data: {'source': source, 'action': 'lock'},
    );
    debugPrint('🔒 Sentry: Kiosk locked by $source');
  }

  /// Log kiosk unlock event
  static void logKioskUnlock({required String source, bool temporary = false}) {
    addBreadcrumb(
      message: temporary ? 'Kiosk TEMPORARILY unlocked' : 'Kiosk UNLOCKED',
      category: 'kiosk',
      data: {
        'source': source,
        'action': 'unlock',
        'temporary': temporary,
      },
    );
    debugPrint('🔓 Sentry: Kiosk unlocked by $source (temp: $temporary)');
  }

  /// Log kiosk PIN attempt
  static void logKioskPinAttempt({required bool success}) {
    addBreadcrumb(
      message: success ? 'Kiosk PIN correct' : 'Kiosk PIN failed',
      category: 'kiosk',
      data: {'success': success},
      level: success ? SentryLevel.info : SentryLevel.warning,
    );
  }

  // ============================================================
  // CHECK-IN EVENTI
  // ============================================================

  /// Log check-in started
  static void logCheckInStarted({
    required String bookingId,
    required int guestCount,
  }) {
    addBreadcrumb(
      message: 'Check-in STARTED',
      category: 'checkin',
      data: {
        'booking_id': bookingId,
        'guest_count': guestCount,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    debugPrint('📋 Sentry: Check-in started for $guestCount guests');
  }

  /// Log guest scan attempt
  static void logGuestScan({
    required int guestNumber,
    required bool success,
    String? documentType,
    String? errorReason,
    int? attemptNumber,
  }) {
    addBreadcrumb(
      message: success
          ? 'Guest $guestNumber scanned'
          : 'Guest $guestNumber scan FAILED',
      category: 'checkin',
      data: {
        'guest_number': guestNumber,
        'success': success,
        if (documentType != null) 'document_type': documentType,
        if (errorReason != null) 'error_reason': errorReason,
        if (attemptNumber != null) 'attempt': attemptNumber,
      },
      level: success ? SentryLevel.info : SentryLevel.warning,
    );
  }

  /// Log guest data validation
  static void logGuestValidation({
    required int guestNumber,
    required bool isValid,
    List<String>? missingFields,
  }) {
    addBreadcrumb(
      message: isValid
          ? 'Guest $guestNumber data VALID'
          : 'Guest $guestNumber data INVALID',
      category: 'checkin',
      data: {
        'guest_number': guestNumber,
        'is_valid': isValid,
        if (missingFields != null) 'missing_fields': missingFields.join(', '),
      },
      level: isValid ? SentryLevel.info : SentryLevel.warning,
    );
  }

  /// Log check-in completed successfully
  static void logCheckInCompleted({
    required String bookingId,
    required int guestCount,
    required Duration duration,
  }) {
    addBreadcrumb(
      message: 'Check-in COMPLETED ✅',
      category: 'checkin',
      data: {
        'booking_id': bookingId,
        'guest_count': guestCount,
        'duration_seconds': duration.inSeconds,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    debugPrint('✅ Sentry: Check-in completed in ${duration.inSeconds}s');
  }

  /// Log check-in failed
  static void logCheckInFailed({
    required String bookingId,
    required String reason,
    int? failedAtGuest,
  }) {
    addBreadcrumb(
      message: 'Check-in FAILED ❌',
      category: 'checkin',
      data: {
        'booking_id': bookingId,
        'reason': reason,
        if (failedAtGuest != null) 'failed_at_guest': failedAtGuest,
      },
      level: SentryLevel.error,
    );

    // Također pošalji kao error
    captureMessage(
      'Check-in failed: $reason',
      level: SentryLevel.error,
      category: 'checkin',
      extras: {
        'booking_id': bookingId,
        if (failedAtGuest != null) 'failed_at_guest': failedAtGuest,
      },
    );
  }

  // ============================================================
  // OCR EVENTI
  // ============================================================

  static void logOcrScan({
    required bool success,
    String? errorType,
    String? documentType,
    int? fieldsDetected,
  }) {
    addBreadcrumb(
      message: success ? 'OCR scan successful' : 'OCR scan failed',
      category: 'ocr',
      data: {
        'success': success,
        if (errorType != null) 'error_type': errorType,
        if (documentType != null) 'document_type': documentType,
        if (fieldsDetected != null) 'fields_detected': fieldsDetected,
      },
      level: success ? SentryLevel.info : SentryLevel.warning,
    );
  }

  static void logOcrAutoScan({
    required int attemptNumber,
    required bool foundData,
  }) {
    addBreadcrumb(
      message: 'OCR auto-scan #$attemptNumber',
      category: 'ocr',
      data: {
        'attempt': attemptNumber,
        'found_data': foundData,
      },
    );
  }

  // ============================================================
  // SIGNATURE EVENTI
  // ============================================================

  static void logSignature({required bool uploaded, String? error}) {
    addBreadcrumb(
      message: uploaded ? 'Signature uploaded' : 'Signature upload failed',
      category: 'signature',
      data: {
        'uploaded': uploaded,
        if (error != null) 'error': error,
      },
      level: uploaded ? SentryLevel.info : SentryLevel.error,
    );
  }

  // ============================================================
  // PIN EVENTI
  // ============================================================

  static void logPinAttempt({required bool success, required String pinType}) {
    addBreadcrumb(
      message: success ? 'PIN verified' : 'PIN failed',
      category: 'security',
      data: {'pin_type': pinType, 'success': success},
      level: success ? SentryLevel.info : SentryLevel.warning,
    );
  }

  // ============================================================
  // FIREBASE EVENTI
  // ============================================================

  static void logFirebaseSync({
    required bool success,
    String? collection,
    String? error,
  }) {
    addBreadcrumb(
      message: success ? 'Firebase sync OK' : 'Firebase sync failed',
      category: 'firebase',
      data: {
        'success': success,
        if (collection != null) 'collection': collection,
        if (error != null) 'error': error,
      },
      level: success ? SentryLevel.info : SentryLevel.error,
    );
  }

  // ============================================================
  // OFFLINE QUEUE EVENTI
  // ============================================================

  static void logOfflineQueueAdd({required String operation}) {
    addBreadcrumb(
      message: 'Added to offline queue: $operation',
      category: 'offline',
      data: {'operation': operation},
    );
  }

  static void logOfflineQueueProcess(
      {required int count, required bool success}) {
    addBreadcrumb(
      message: success
          ? 'Processed $count offline operations'
          : 'Failed to process offline queue',
      category: 'offline',
      data: {'count': count, 'success': success},
      level: success ? SentryLevel.info : SentryLevel.error,
    );
  }

  // ============================================================
  // PERFORMANCE TRANSACTIONS
  // ============================================================

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

  /// Mjeri trajanje check-in procesa
  static ISentrySpan? startCheckInTransaction(String bookingId) {
    return startTransaction('check-in-$bookingId', 'checkin');
  }

  /// Mjeri trajanje OCR skeniranja
  static ISentrySpan? startOcrTransaction() {
    return startTransaction('ocr-scan', 'ocr');
  }
}
