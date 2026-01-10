// FILE: lib/data/services/performance_service.dart
// OPIS: Firebase Performance Monitoring - custom traces
// VERZIJA: 1.0 - FAZA 1
// DATUM: 2026-01-10

import 'package:flutter/foundation.dart';
import 'package:firebase_performance/firebase_performance.dart';

class PerformanceService {
  static final FirebasePerformance _performance = FirebasePerformance.instance;

  // Cache aktivnih trace-ova
  static final Map<String, Trace> _activeTraces = {};

  // ============================================================
  // INICIJALIZACIJA
  // ============================================================

  /// Omogući/onemogući performance collection
  static Future<void> setEnabled(bool enabled) async {
    await _performance.setPerformanceCollectionEnabled(enabled);
    debugPrint(
        '📊 Performance monitoring: ${enabled ? 'ENABLED' : 'DISABLED'}');
  }

  // ============================================================
  // CUSTOM TRACES
  // ============================================================

  /// Započni custom trace
  static Future<void> startTrace(String name) async {
    try {
      if (_activeTraces.containsKey(name)) {
        debugPrint('⚠️ Trace "$name" already running');
        return;
      }

      final trace = _performance.newTrace(name);
      await trace.start();
      _activeTraces[name] = trace;

      debugPrint('⏱️ Trace started: $name');
    } catch (e) {
      debugPrint('❌ Start trace error: $e');
    }
  }

  /// Završi custom trace
  static Future<void> stopTrace(String name,
      {Map<String, int>? metrics}) async {
    try {
      final trace = _activeTraces[name];
      if (trace == null) {
        debugPrint('⚠️ Trace "$name" not found');
        return;
      }

      // Dodaj metrike ako postoje
      if (metrics != null) {
        metrics.forEach((key, value) {
          trace.setMetric(key, value);
        });
      }

      await trace.stop();
      _activeTraces.remove(name);

      debugPrint('⏱️ Trace stopped: $name');
    } catch (e) {
      debugPrint('❌ Stop trace error: $e');
    }
  }

  /// Dodaj atribut aktivnom trace-u
  static void setTraceAttribute(String traceName, String key, String value) {
    final trace = _activeTraces[traceName];
    if (trace != null) {
      trace.putAttribute(key, value);
    }
  }

  /// Inkrementiraj metriku aktivnog trace-a
  static void incrementTraceMetric(String traceName, String metric, int value) {
    final trace = _activeTraces[traceName];
    if (trace != null) {
      trace.incrementMetric(metric, value);
    }
  }

  // ============================================================
  // PRE-DEFINED TRACES
  // ============================================================

  /// Trace za OCR skeniranje
  static Future<void> startOcrTrace() async {
    await startTrace('ocr_scan');
  }

  static Future<void> stopOcrTrace(
      {bool success = true, int? documentCount}) async {
    setTraceAttribute('ocr_scan', 'success', success.toString());
    await stopTrace('ocr_scan', metrics: {
      'success': success ? 1 : 0,
      if (documentCount != null) 'document_count': documentCount,
    });
  }

  /// Trace za Firebase sync
  static Future<void> startSyncTrace() async {
    await startTrace('firebase_sync');
  }

  static Future<void> stopSyncTrace({bool success = true}) async {
    setTraceAttribute('firebase_sync', 'success', success.toString());
    await stopTrace('firebase_sync', metrics: {
      'success': success ? 1 : 0,
    });
  }

  /// Trace za signature upload
  static Future<void> startSignatureUploadTrace() async {
    await startTrace('signature_upload');
  }

  static Future<void> stopSignatureUploadTrace(
      {bool success = true, int? fileSizeKb}) async {
    setTraceAttribute('signature_upload', 'success', success.toString());
    await stopTrace('signature_upload', metrics: {
      'success': success ? 1 : 0,
      if (fileSizeKb != null) 'file_size_kb': fileSizeKb,
    });
  }

  /// Trace za AI response
  static Future<void> startAiResponseTrace() async {
    await startTrace('ai_response');
  }

  static Future<void> stopAiResponseTrace(
      {bool success = true, int? tokenCount}) async {
    setTraceAttribute('ai_response', 'success', success.toString());
    await stopTrace('ai_response', metrics: {
      'success': success ? 1 : 0,
      if (tokenCount != null) 'token_count': tokenCount,
    });
  }

  /// Trace za screen load
  static Future<void> startScreenLoadTrace(String screenName) async {
    await startTrace('screen_load_$screenName');
  }

  static Future<void> stopScreenLoadTrace(String screenName) async {
    await stopTrace('screen_load_$screenName');
  }

  /// Trace za check-in flow
  static Future<void> startCheckInTrace() async {
    await startTrace('checkin_flow');
  }

  static Future<void> stopCheckInTrace(
      {bool completed = true, int? guestCount}) async {
    setTraceAttribute('checkin_flow', 'completed', completed.toString());
    await stopTrace('checkin_flow', metrics: {
      'completed': completed ? 1 : 0,
      if (guestCount != null) 'guest_count': guestCount,
    });
  }

  // ============================================================
  // HTTP METRICS (za custom API pozive)
  // ============================================================

  /// Kreiraj HTTP metric
  static HttpMetric? createHttpMetric(String url, HttpMethod method) {
    try {
      return _performance.newHttpMetric(url, method);
    } catch (e) {
      debugPrint('❌ Create HTTP metric error: $e');
      return null;
    }
  }

  /// Započni HTTP metric
  static Future<void> startHttpMetric(HttpMetric? metric) async {
    try {
      await metric?.start();
    } catch (e) {
      debugPrint('❌ Start HTTP metric error: $e');
    }
  }

  /// Završi HTTP metric
  static Future<void> stopHttpMetric(
    HttpMetric? metric, {
    int? responseCode,
    int? responsePayloadSize,
    int? requestPayloadSize,
  }) async {
    try {
      if (responseCode != null) {
        metric?.httpResponseCode = responseCode;
      }
      if (responsePayloadSize != null) {
        metric?.responsePayloadSize = responsePayloadSize;
      }
      if (requestPayloadSize != null) {
        metric?.requestPayloadSize = requestPayloadSize;
      }
      await metric?.stop();
    } catch (e) {
      debugPrint('❌ Stop HTTP metric error: $e');
    }
  }

  // ============================================================
  // HELPER - Measure async function
  // ============================================================

  /// Mjeri vrijeme izvršavanja async funkcije
  static Future<T> measureAsync<T>(
    String traceName,
    Future<T> Function() function,
  ) async {
    await startTrace(traceName);
    try {
      final result = await function();
      await stopTrace(traceName, metrics: {'success': 1});
      return result;
    } catch (e) {
      await stopTrace(traceName, metrics: {'success': 0});
      rethrow;
    }
  }
}
