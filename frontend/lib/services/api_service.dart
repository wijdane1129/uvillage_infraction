import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'dart:io' show Platform;
import 'storage_service.dart';
import 'api_client.dart';
import 'auth_service.dart';
import '../models/dashboard_models.dart';
import '../config/api_config.dart';
// Removed dart:convert/http usage in favor of Dio which is already configured

class ApiService {
  static final ApiService _instance = ApiService._internal();

  final Dio _crm_dio = Dio(); // Separate instance for CRM API
  final _storage = StorageService();

  // Singleton factory
  factory ApiService() {
    return _instance;
  }

  /// Get base URL for public endpoints (without /v1)
  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    } else {
      return 'http://192.168.68.119:8080';
    }
  }

  ApiService._internal() {
    // Setup CRM API (when available)
    _crm_dio.options.baseUrl = ApiConfig.CRM_API_URL;
    _crm_dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Get authenticated Dio client from ApiClient
  Dio get _dio => ApiClient.dio;

  Future<Response> post(String path, dynamic data) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> get(String path) async {
    try {
      // Special-case dashboard endpoints which in backend are under `/api/dashboard` (no /v1)
      if (path.startsWith('/dashboard')) {
        // Try secure storage first, then Hive (AuthService.getToken)
        String? token = await _storage.getToken();
        if (token == null || token.isEmpty) {
          try {
            token = await AuthService.getToken();
            if (token != null && token.isNotEmpty && kDebugMode) {
              print(
                '🔑 [API SERVICE] Fallback token from Hive used for dashboard',
              );
            }
          } catch (_) {}
        } else {
          if (kDebugMode)
            print(
              '🔑 [API SERVICE] Token from secure storage used for dashboard',
            );
        }

        final client = Dio(
          BaseOptions(
            baseUrl: _baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
          ),
        );

        if (kDebugMode)
          print(
            '📤 [API SERVICE] GET -> ${client.options.baseUrl}/api$path (with auth=${token != null})',
          );
        return await client.get('/api$path');
      }

      return await _dio.get(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    print('API Error: ${e.toString()}');
    print('API Error Response: ${e.response?.data}');
    print('API Error Status Code: ${e.response?.statusCode}');

    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map) {
        return Exception(
          data['message'] ?? data.toString() ?? 'An error occurred',
        );
      } else if (data is String) {
        return Exception(data);
      }
      return Exception(data.toString());
    }
    return Exception('Network error: ${e.message}');
  }

  Future<DashboardStats> fetchDashboardStats() async {
    try {
      // Dashboard endpoint is public and at /api/dashboard/stats (not /api/v1/dashboard/stats)
      // Create a Dio instance that targets the correct base URL
      final publicDio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final response = await publicDio.get('/api/dashboard/stats');
      if (response.statusCode == 200) {
        return DashboardStats.fromJson(response.data);
      }
      throw Exception('Failed to load dashboard stats');
    } catch (e) {
      throw _handleError(e as DioException);
    }
  }
}
