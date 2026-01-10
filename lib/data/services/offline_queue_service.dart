// FILE: lib/data/services/offline_queue_service.dart
// OPIS: Queue za offline operacije - auto-sync kad dođe WiFi
// VERZIJA: 1.1 - FIX: Dodan import za SentryLevel
// DATUM: 2026-01-10

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart'; // FIX: Dodan import
import 'storage_service.dart';
import 'sentry_service.dart';

/// Tipovi operacija koje se mogu queueati
enum QueueOperationType {
  createGuest,
  uploadSignature,
  saveFeedback,
  saveCleaningLog,
  saveAiLog,
  updateBooking,
}

/// Model za queued operaciju
class QueuedOperation {
  final String id;
  final QueueOperationType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  int retryCount;

  QueuedOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'data': data,
        'timestamp': timestamp.toIso8601String(),
        'retryCount': retryCount,
      };

  factory QueuedOperation.fromJson(Map<String, dynamic> json) {
    return QueuedOperation(
      id: json['id'] ?? '',
      type: QueueOperationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => QueueOperationType.createGuest,
      ),
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      retryCount: json['retryCount'] ?? 0,
    );
  }
}

class OfflineQueueService {
  static const String _queueBoxName = 'offline_queue';
  static const String _signatureBufferDir = 'signature_buffer';
  static const int _maxRetries = 3;

  static Box<String>? _queueBox;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // ============================================================
  // INICIJALIZACIJA
  // ============================================================

  /// Inicijalizira queue (poziva se iz main.dart)
  static Future<void> init() async {
    try {
      _queueBox = await Hive.openBox<String>(_queueBoxName);
      debugPrint(
          '📦 Offline queue initialized. Pending: ${_queueBox?.length ?? 0}');
    } catch (e) {
      debugPrint('❌ Queue init error: $e');
      SentryService.captureException(e, hint: 'Offline queue init failed');
    }
  }

  /// Broj operacija u čekanju
  static int get pendingCount => _queueBox?.length ?? 0;

  /// Ima li operacija u čekanju
  static bool get hasPendingOperations => pendingCount > 0;

  // ============================================================
  // DODAVANJE U QUEUE
  // ============================================================

  /// Dodaj operaciju u queue
  static Future<void> enqueue(QueuedOperation operation) async {
    try {
      if (_queueBox == null) await init();

      final json = jsonEncode(operation.toJson());
      await _queueBox?.put(operation.id, json);

      debugPrint('📥 Queued: ${operation.type.name} (${operation.id})');
      SentryService.addBreadcrumb(
        message: 'Operation queued',
        category: 'offline',
        data: {'type': operation.type.name, 'id': operation.id},
      );
    } catch (e) {
      debugPrint('❌ Enqueue error: $e');
      SentryService.captureException(e, hint: 'Failed to enqueue operation');
    }
  }

  /// Kreiraj i dodaj guest operaciju
  static Future<void> queueCreateGuest({
    required String bookingId,
    required Map<String, dynamic> guestData,
  }) async {
    final operation = QueuedOperation(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      type: QueueOperationType.createGuest,
      data: {
        'bookingId': bookingId,
        'guestData': guestData,
      },
      timestamp: DateTime.now(),
    );
    await enqueue(operation);
  }

  /// Kreiraj i dodaj signature operaciju
  static Future<void> queueUploadSignature({
    required String bookingId,
    required String guestName,
    required String localPath,
  }) async {
    final operation = QueuedOperation(
      id: 'sig_${DateTime.now().millisecondsSinceEpoch}',
      type: QueueOperationType.uploadSignature,
      data: {
        'bookingId': bookingId,
        'guestName': guestName,
        'localPath': localPath,
      },
      timestamp: DateTime.now(),
    );
    await enqueue(operation);
  }

  /// Kreiraj i dodaj feedback operaciju
  static Future<void> queueSaveFeedback({
    required int rating,
    String? comment,
  }) async {
    final operation = QueuedOperation(
      id: 'feedback_${DateTime.now().millisecondsSinceEpoch}',
      type: QueueOperationType.saveFeedback,
      data: {
        'rating': rating,
        'comment': comment ?? '',
        'unitId': StorageService.getUnitId(),
        'ownerId': StorageService.getOwnerId(),
        'guestName': StorageService.getGuestName(),
        'language': StorageService.getLanguage(),
      },
      timestamp: DateTime.now(),
    );
    await enqueue(operation);
  }

  /// Kreiraj i dodaj cleaning log operaciju
  static Future<void> queueSaveCleaningLog({
    required Map<String, bool> tasks,
    required String notes,
    String? bookingId,
  }) async {
    final operation = QueuedOperation(
      id: 'cleaning_${DateTime.now().millisecondsSinceEpoch}',
      type: QueueOperationType.saveCleaningLog,
      data: {
        'tasks': tasks,
        'notes': notes,
        'bookingId': bookingId,
        'unitId': StorageService.getUnitId(),
        'ownerId': StorageService.getOwnerId(),
      },
      timestamp: DateTime.now(),
    );
    await enqueue(operation);
  }

  /// Kreiraj i dodaj AI log operaciju
  static Future<void> queueSaveAiLog({
    required String agentId,
    required String userMessage,
    required String aiResponse,
  }) async {
    final operation = QueuedOperation(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      type: QueueOperationType.saveAiLog,
      data: {
        'agentId': agentId,
        'userMessage': userMessage,
        'aiResponse': aiResponse,
        'unitId': StorageService.getUnitId(),
        'ownerId': StorageService.getOwnerId(),
        'language': StorageService.getLanguage(),
      },
      timestamp: DateTime.now(),
    );
    await enqueue(operation);
  }

  // ============================================================
  // PROCESIRANJE QUEUE-a
  // ============================================================

  /// Procesiraj sve operacije u queue-u
  /// Returns: broj uspješno procesiranih operacija
  static Future<int> processQueue() async {
    if (_queueBox == null || _queueBox!.isEmpty) {
      debugPrint('📦 Queue is empty');
      return 0;
    }

    debugPrint('🔄 Processing queue... (${_queueBox!.length} items)');

    int successCount = 0;
    final keysToRemove = <String>[];
    final keysToRetry = <String, QueuedOperation>{};

    for (final key in _queueBox!.keys.toList()) {
      try {
        final json = _queueBox!.get(key);
        if (json == null) continue;

        final operation = QueuedOperation.fromJson(jsonDecode(json));

        final success = await _processOperation(operation);

        if (success) {
          keysToRemove.add(key.toString());
          successCount++;
          debugPrint('✅ Processed: ${operation.type.name}');
        } else {
          operation.retryCount++;
          if (operation.retryCount >= _maxRetries) {
            keysToRemove.add(key.toString());
            debugPrint('⚠️ Max retries reached: ${operation.type.name}');
            SentryService.captureMessage(
              'Queue operation max retries reached',
              level: SentryLevel.warning,
              extras: {
                'type': operation.type.name,
                'id': operation.id,
              },
            );
          } else {
            keysToRetry[key.toString()] = operation;
          }
        }
      } catch (e) {
        debugPrint('❌ Process error for $key: $e');
      }
    }

    // Ukloni uspješne
    for (final key in keysToRemove) {
      await _queueBox!.delete(key);
    }

    // Ažuriraj retry counts
    for (final entry in keysToRetry.entries) {
      await _queueBox!.put(entry.key, jsonEncode(entry.value.toJson()));
    }

    debugPrint(
        '✅ Queue processed: $successCount/${_queueBox!.length + successCount} successful');
    return successCount;
  }

  /// Procesiraj pojedinačnu operaciju
  static Future<bool> _processOperation(QueuedOperation operation) async {
    try {
      switch (operation.type) {
        case QueueOperationType.createGuest:
          return await _processCreateGuest(operation.data);

        case QueueOperationType.uploadSignature:
          return await _processUploadSignature(operation.data);

        case QueueOperationType.saveFeedback:
          return await _processSaveFeedback(operation.data);

        case QueueOperationType.saveCleaningLog:
          return await _processSaveCleaningLog(operation.data);

        case QueueOperationType.saveAiLog:
          return await _processSaveAiLog(operation.data);

        case QueueOperationType.updateBooking:
          return await _processUpdateBooking(operation.data);
      }
    } catch (e) {
      debugPrint('❌ Operation ${operation.type.name} failed: $e');
      return false;
    }
  }

  // ============================================================
  // PROCESORI ZA POJEDINE TIPOVE
  // ============================================================

  static Future<bool> _processCreateGuest(Map<String, dynamic> data) async {
    final bookingId = data['bookingId'] as String?;
    final guestData = data['guestData'] as Map<String, dynamic>?;

    if (bookingId == null || guestData == null) return false;

    await _db.collection('bookings').doc(bookingId).collection('guests').add({
      ...guestData,
      'createdAt': FieldValue.serverTimestamp(),
      'syncedFromOffline': true,
    });

    return true;
  }

  static Future<bool> _processUploadSignature(Map<String, dynamic> data) async {
    final bookingId = data['bookingId'] as String?;
    final guestName = data['guestName'] as String?;
    final localPath = data['localPath'] as String?;

    if (bookingId == null || localPath == null) return false;

    final file = File(localPath);
    if (!await file.exists()) {
      debugPrint('⚠️ Signature file not found: $localPath');
      return true; // Vrati true da se ukloni iz queue-a
    }

    final bytes = await file.readAsBytes();
    final ownerId = StorageService.getOwnerId() ?? 'unknown';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = 'signatures/$ownerId/${bookingId}_$timestamp.png';

    final ref = _storage.ref().child(path);
    await ref.putData(bytes);
    final url = await ref.getDownloadURL();

    await _db.collection('signatures').add({
      'ownerId': ownerId,
      'bookingId': bookingId,
      'unitId': StorageService.getUnitId(),
      'guestName': guestName ?? '',
      'signatureUrl': url,
      'signedAt': FieldValue.serverTimestamp(),
      'syncedFromOffline': true,
    });

    // Obriši lokalni fajl
    await file.delete();

    return true;
  }

  static Future<bool> _processSaveFeedback(Map<String, dynamic> data) async {
    await _db.collection('feedback').add({
      ...data,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'platform': 'Android Kiosk',
      'syncedFromOffline': true,
    });
    return true;
  }

  static Future<bool> _processSaveCleaningLog(Map<String, dynamic> data) async {
    final tasks = Map<String, bool>.from(data['tasks'] ?? {});
    final completedCount = tasks.values.where((v) => v).length;

    await _db.collection('cleaning_logs').add({
      ...data,
      'timestamp': FieldValue.serverTimestamp(),
      'completedCount': completedCount,
      'totalCount': tasks.length,
      'status': completedCount == tasks.length ? 'completed' : 'partial',
      'platform': 'Android Kiosk',
      'syncedFromOffline': true,
    });
    return true;
  }

  static Future<bool> _processSaveAiLog(Map<String, dynamic> data) async {
    await _db.collection('ai_logs').add({
      ...data,
      'timestamp': FieldValue.serverTimestamp(),
      'syncedFromOffline': true,
    });
    return true;
  }

  static Future<bool> _processUpdateBooking(Map<String, dynamic> data) async {
    final bookingId = data['bookingId'] as String?;
    final updates = Map<String, dynamic>.from(data['updates'] ?? {});

    if (bookingId == null || updates.isEmpty) return false;

    await _db.collection('bookings').doc(bookingId).update(updates);
    return true;
  }

  // ============================================================
  // SIGNATURE BUFFER (lokalno spremanje)
  // ============================================================

  /// Sprema potpis lokalno ako nema interneta
  static Future<String> saveSignatureLocally(
      Uint8List bytes, String bookingId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final bufferDir = Directory('${dir.path}/$_signatureBufferDir');

      if (!await bufferDir.exists()) {
        await bufferDir.create(recursive: true);
      }

      final filename =
          '${bookingId}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${bufferDir.path}/$filename');

      await file.writeAsBytes(bytes);

      debugPrint('💾 Signature saved locally: ${file.path}');
      return file.path;
    } catch (e) {
      debugPrint('❌ Local signature save error: $e');
      rethrow;
    }
  }

  /// Briše sve lokalno spremljene potpise
  static Future<void> clearLocalSignatures() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final bufferDir = Directory('${dir.path}/$_signatureBufferDir');

      if (await bufferDir.exists()) {
        await bufferDir.delete(recursive: true);
        debugPrint('🗑️ Local signatures cleared');
      }
    } catch (e) {
      debugPrint('❌ Clear local signatures error: $e');
    }
  }

  // ============================================================
  // QUEUE MANAGEMENT
  // ============================================================

  /// Briše cijeli queue (za factory reset)
  static Future<void> clearQueue() async {
    await _queueBox?.clear();
    await clearLocalSignatures();
    debugPrint('🗑️ Offline queue cleared');
  }

  /// Dohvati sve operacije u queue-u
  static List<QueuedOperation> getAllOperations() {
    if (_queueBox == null || _queueBox!.isEmpty) return [];

    return _queueBox!.values
        .map((json) => QueuedOperation.fromJson(jsonDecode(json)))
        .toList();
  }
}
