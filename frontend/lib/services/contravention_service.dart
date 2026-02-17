// lib/services/contravention_service_fixed.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'api_client.dart';
import 'offline_storage_service.dart';
import 'connectivity_service.dart';
import 'MediaUploadService.dart';

class ContraventionService {
  final Dio _dio = ApiClient.dio;
  final OfflineStorageService _offlineStorage;
  final ConnectivityService _connectivity;
  final MediaUploadService _mediaUploadService = MediaUploadService();
  
  ContraventionService({
    required OfflineStorageService offlineStorage,
    required ConnectivityService connectivity,
  })  : _offlineStorage = offlineStorage,
        _connectivity = connectivity;
  
  Future<Map<String, dynamic>> fetchStats(int agentRowid) async {
    try {
      print('📡 [STATS] Requête des statistiques pour agent ID: $agentRowid');
      
      final response = await _dio.get('/contraventions/stats/$agentRowid');
      
      if (response.statusCode == 200 && response.data is Map) {
        print('✅ [STATS] Données de stats reçues.');
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Erreur lors de la récupération des stats: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ [STATS] Erreur Dio: ${e.response?.statusCode}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createContravention({
    required String description,
    required String typeLabel,
    required int userAuthorId,
    int? tiersId,
    List<String>? mediaUrls,
  }) async {
    try {
      // Check connectivity
      final hasConnection = await _connectivity.hasConnection();
      
      if (!hasConnection) {
        // Save offline
        print('📱 [CREATE] No connection - saving offline');
        final offlineId = await _offlineStorage.saveOfflineContravention(
          description: description,
          typeLabel: typeLabel,
          userAuthorId: userAuthorId,
          tiersId: tiersId,
          mediaUrls: mediaUrls ?? [],
          mediaTypes: List.filled(mediaUrls?.length ?? 0, 'unknown'),
        );
        
        return {
          'id': offlineId,
          'status': 'pending',
          'offline': true,
          'message': 'Contravention créée en mode hors ligne. Elle sera synchronisée automatiquement.',
        };
      }

      // 🎯 STEP 1: Upload media files first
      List<String> uploadedMediaUrls = [];
      
      if (mediaUrls != null && mediaUrls.isNotEmpty) {
        print('📤 [CREATE] Uploading ${mediaUrls.length} media files...');
        
        for (String mediaPath in mediaUrls) {
          // Check if it's a local file path
          if (mediaPath.startsWith('/') || mediaPath.contains('\\')) {
            final file = File(mediaPath);
            
            if (await file.exists()) {
              try {
                // Determine media type from file extension
                String mediaType = _getMediaTypeFromPath(mediaPath);
                
                // Upload the file
                final mediaUrl = await _mediaUploadService.uploadMedia(
                  file: file,
                  mediaType: mediaType,
                );
                
                uploadedMediaUrls.add(mediaUrl);
                print('✅ [CREATE] Media uploaded: $mediaUrl');
              } catch (e) {
                print('⚠️ [CREATE] Error uploading media: $e');
                // Continue with other files
              }
            } else {
              print('⚠️ [CREATE] Media file not found: $mediaPath');
            }
          } else {
            // Already an uploaded URL
            uploadedMediaUrls.add(mediaPath);
          }
        }
        
        print('✅ [CREATE] Uploaded ${uploadedMediaUrls.length} media files');
      }

      // 🎯 STEP 2: Create contravention with uploaded media URLs
      final Map<String, dynamic> payload = {
        'description': description,
        'typeLabel': typeLabel,
        'userAuthorId': userAuthorId,
        if (tiersId != null) 'tiersId': tiersId,
        if (uploadedMediaUrls.isNotEmpty) 'mediaUrls': uploadedMediaUrls,
      };

      print('📤 [CREATE] Payload envoyé: $payload');
      print('📤 [CREATE] Headers: ${_dio.options.headers}');

      final response = await _dio.post('/contraventions', data: payload);

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ [CREATE] Contravention created successfully');
        return {
          ...response.data as Map<String, dynamic>,
          'offline': false,
        };
      } else {
        throw Exception('Erreur création contravention: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ [CREATE] Erreur Dio: ${e.response?.statusCode}');
      print('❌ [CREATE] Erreur Dio détails: ${e.response?.data}');
      
      // Try to save offline if there's an error
      try {
        print('📱 [CREATE] Sauvegarde en mode hors ligne après erreur');
        final offlineId = await _offlineStorage.saveOfflineContravention(
          description: description,
          typeLabel: typeLabel,
          userAuthorId: userAuthorId,
          tiersId: tiersId,
          mediaUrls: mediaUrls ?? [],
          mediaTypes: List.filled(mediaUrls?.length ?? 0, 'unknown'),
        );
        
        return {
          'id': offlineId,
          'status': 'pending',
          'offline': true,
          'message': 'Erreur de connexion. Contravention créée en mode hors ligne.',
          'error': e.message,
        };
      } catch (offlineError) {
        print('❌ [CREATE] Impossible de sauvegarder hors ligne: $offlineError');
        rethrow;
      }
    }
  }

  Future<List<String>> fetchContraventionTypeLabels() async {
    final response = await _dio.get('/contraventions/types');
    return List<String>.from(response.data);
  }

  /// Determine media type from file path
  String _getMediaTypeFromPath(String path) {
    final extension = path.toLowerCase().split('.').last;
    
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return 'PHOTO';
      
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
        return 'VIDEO';
      
      case 'mp3':
      case 'm4a':
      case 'wav':
      case 'aac':
        return 'AUDIO';
      
      default:
        return 'DOCUMENT';
    }
  }
}