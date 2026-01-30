import 'dart:io';
import 'package:dio/dio.dart';
import 'offline_storage_service.dart';
import 'api_client.dart';
import '../models/offline_contravention_model.dart';

class SyncManager {
  final OfflineStorageService _storageService;
  final Dio _dio = ApiClient.dio;
  bool _isSyncing = false;

  bool get isSyncing => _isSyncing;

  SyncManager(this._storageService);

  /// Sync all pending contraventions
  Future<SyncResult> syncAll() async {
    if (_isSyncing) {
      print('⏳ [SyncManager] Already syncing...');
      return SyncResult(
        success: false,
        message: 'Already syncing',
        syncedCount: 0,
        failedCount: 0,
      );
    }

    _isSyncing = true;
    print('🔄 [SyncManager] Starting sync...');

    try {
      final pendingContraventions =
          await _storageService.getPendingContraventions();

      if (pendingContraventions.isEmpty) {
        print('✅ [SyncManager] No pending contraventions');
        return SyncResult(
          success: true,
          message: 'No pending contraventions',
          syncedCount: 0,
          failedCount: 0,
        );
      }

      int syncedCount = 0;
      int failedCount = 0;
      final List<String> errors = [];

      for (final contravention in pendingContraventions) {
        try {
          await _syncContravention(contravention);
          syncedCount++;
        } catch (e) {
          failedCount++;
          errors.add('${contravention.id}: $e');
          await _storageService.incrementSyncAttempts(contravention.id);
        }
      }

      final success = failedCount == 0;
      final message =
          'Synced: $syncedCount, Failed: $failedCount';

      print('✅ [SyncManager] Sync completed: $message');

      return SyncResult(
        success: success,
        message: message,
        syncedCount: syncedCount,
        failedCount: failedCount,
        errors: errors,
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync a single contravention
  Future<void> _syncContravention(OfflineContravention contravention) async {
    print('📤 [SyncManager] Syncing: ${contravention.id}');

    // Upload media first if any
    List<String> uploadedMediaUrls = [];
    final mediaUrls = contravention.mediaUrls;

    for (int i = 0; i < mediaUrls.length; i++) {
      final filePath = mediaUrls[i];
      final mediaType = contravention.mediaTypes[i];

      // Check if it's a local file (offline media) or already uploaded
      if (filePath.startsWith('/') || filePath.contains('\\')) {
        final file = File(filePath);
        if (await file.exists()) {
          try {
            final uploadedUrl = await _uploadMedia(file, mediaType);
            uploadedMediaUrls.add(uploadedUrl);
          } catch (e) {
            print('⚠️  [SyncManager] Failed to upload media: $e');
            // Continue with sync even if media upload fails
            uploadedMediaUrls.add(filePath);
          }
        } else {
          print('⚠️  [SyncManager] Media file not found: $filePath');
          uploadedMediaUrls.add(filePath);
        }
      } else {
        // Already uploaded URL
        uploadedMediaUrls.add(filePath);
      }
    }

    // Send contravention to backend
    final payload = {
      'description': contravention.description,
      'typeLabel': contravention.typeLabel,
      'userAuthorId': contravention.userAuthorId,
      if (contravention.tiersId != null) 'tiersId': contravention.tiersId,
      if (uploadedMediaUrls.isNotEmpty) 'mediaUrls': uploadedMediaUrls,
    };

    print('📤 [SyncManager] Sending payload: $payload');

    try {
      final response = await _dio.post(
        '/contraventions',
        data: payload,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        await _storageService.updateSyncStatus(
          contravention.id,
          isSynced: true,
        );
        print('✅ [SyncManager] Synced successfully: ${contravention.id}');
      } else {
        throw Exception(
          'Backend returned ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data?.toString() ?? e.message;
      await _storageService.updateSyncStatus(
        contravention.id,
        isSynced: false,
        syncError: errorMsg,
      );
      throw Exception('API Error: $errorMsg');
    }
  }

  /// Upload a single media file
  Future<String> _uploadMedia(File file, String mediaType) async {
    print('⬆️  [SyncManager] Uploading media: ${file.path}');

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        'mediaType': mediaType,
      });

      final response = await _dio.post(
        '/upload',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final uploadedUrl = response.data['mediaUrl'] ?? response.data['url'];
        print('✅ [SyncManager] Media uploaded: $uploadedUrl');
        return uploadedUrl.toString();
      } else {
        throw Exception('Upload failed with status ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Media upload error: ${e.message}');
    }
  }

  /// Get sync statistics
  Future<SyncStats> getStats() async {
    final pending = await _storageService.getPendingContraventions();
    final synced = await _storageService.getSyncedContraventions();

    return SyncStats(
      totalPending: pending.length,
      totalSynced: synced.length,
      pendingWithErrors: pending.where((c) => c.syncError != null).length,
    );
  }
}

class SyncResult {
  final bool success;
  final String message;
  final int syncedCount;
  final int failedCount;
  final List<String> errors;

  SyncResult({
    required this.success,
    required this.message,
    required this.syncedCount,
    required this.failedCount,
    this.errors = const [],
  });

  @override
  String toString() =>
      'SyncResult(success: $success, synced: $syncedCount, failed: $failedCount)';
}

class SyncStats {
  final int totalPending;
  final int totalSynced;
  final int pendingWithErrors;

  SyncStats({
    required this.totalPending,
    required this.totalSynced,
    required this.pendingWithErrors,
  });

  @override
  String toString() =>
      'SyncStats(pending: $totalPending, synced: $totalSynced, errors: $pendingWithErrors)';
}
