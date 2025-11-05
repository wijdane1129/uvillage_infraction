import 'package:dio/dio.dart';
import 'storage_service.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://localhost:8080/api';
  final _storage = StorageService();

  ApiService() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add interceptor for JWT token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          if (error.response?.statusCode == 401) {
            // Handle token expiration
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
    if (e.response != null) {
      final data = e.response!.data;
      return Exception(data['message'] ?? 'An error occurred');
    }
    return Exception('Network error occurred');
  }
}
