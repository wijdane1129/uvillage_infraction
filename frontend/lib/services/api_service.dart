import 'package:dio/dio.dart';
import 'storage_service.dart';
import '../models/dashboard_models.dart';
import '../config/api_config.dart';
// Removed dart:convert/http usage in favor of Dio which is already configured

class ApiService {
  static final ApiService _instance = ApiService._internal();
  
  final Dio _dio = Dio();
  final Dio _crm_dio = Dio(); // Separate instance for CRM API
  final String _baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api',
  );
  final _storage = StorageService();

  // Singleton factory
  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    // Setup backend API
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Setup CRM API (when available)
    _crm_dio.options.baseUrl = ApiConfig.CRM_API_URL;
    _crm_dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add interceptor for JWT token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getToken();
          print('DEBUG: ApiService interceptor - token: ${token != null ? 'present' : 'missing'}');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            print('DEBUG: Authorization header added: Bearer ${token.substring(0, 20)}...');
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          if (error.response?.statusCode == 401) {
            // Handle token expiration
            print('DEBUG: 401 error received, clearing token');
            _storage.deleteToken();
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<Response> post(String path, dynamic data) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> get(String path) async {
    try {
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
        return Exception(data['message'] ?? data.toString() ?? 'An error occurred');
      } else if (data is String) {
        return Exception(data);
      }
      return Exception(data.toString());
    }
    return Exception('Network error: ${e.message}');
  }

  Future<DashboardStats> fetchDashboardStats() async {
    try {
      // Try CRM API first if configured (not mock mode)
      if (!ApiConfig.USE_MOCK_DATA) {
        try {
          final response = await _crm_dio.get(ApiConfig.CRM_DASHBOARD_ENDPOINT);
          if (response.statusCode == 200) {
            return DashboardStats.fromJson(response.data);
          }
        } catch (e) {
          // Fall back to backend if CRM API fails
          print('CRM API failed, falling back to backend: $e');
        }
      }

      // Use backend API
      final response = await _dio.get('/dashboard/stats');
      if (response.statusCode == 200) {
        return DashboardStats.fromJson(response.data);
      }
      throw Exception('Failed to load dashboard stats');
    } catch (e) {
      throw _handleError(e as DioException);
    }
  }
}
