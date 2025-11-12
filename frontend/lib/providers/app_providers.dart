// Fichier: lib/providers/app_providers.dart (Nouveau)

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Définition de l'URL de base pour l'API
const String _baseUrl = 'http://localhost:8080/api/v1'; 

final dioProvider = Provider<Dio>((ref) {
  final box = Hive.box('authBox');
  final token = box.get('token');
  return Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            print('[DIO] Authorization header: Bearer $token');
          } else {
            print('[DIO] No token found in Hive');
          }
          return handler.next(options);
        },
      ),
    );
});