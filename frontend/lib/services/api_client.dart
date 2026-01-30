import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'dart:io' show Platform;
import 'auth_service.dart';
import '../main.dart' show navigatorKey;

/// Client API centralisé avec intercepteur JWT automatique
class ApiClient {
  // Rendre _dio nullable pour la vérification
  static Dio? _dio; 
  
  /// Base URL dynamique selon la plateforme
  static String get baseUrl {
    // Always use the local network IP for all platforms to allow phone access
    return 'http://192.168.68.100:8080/api/v1';
  }

  /// Initialisation du client Dio avec intercepteur JWT
  static Future<void> init() async {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 🔑 INTERCEPTEUR JWT - Ajoute automatiquement le token à chaque requête
    _dio!.interceptors.add( // Utiliser _dio! car il vient d'être initialisé
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // ✅ CORRECTION JWT: L'attente ASYNCHRONE est déjà correcte ici.
          final token = await AuthService.getToken();
          
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            if (kDebugMode) {
              print('🔑 [API] Token ajouté: ${token.substring(0, 20)}...');
            }
          } else {
            if (kDebugMode) {
              // Ce log est CRITIQUE. C'est l'indication du 403.
              print('⚠️ [API] Aucun token trouvé dans Hive pour ${options.path}');
            }
          }
          
          if (kDebugMode) {
            print('📤 [API REQUEST] ${options.method} ${options.path}');
          }
          
          return handler.next(options);
        },
        
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('✅ [API RESPONSE] ${response.statusCode} ${response.requestOptions.path}');
          }
          return handler.next(response);
        },
        
        onError: (DioException e, handler) async {
          if (kDebugMode) {
            print('❌ [API ERROR] ${e.response?.statusCode} ${e.requestOptions.path}');
            print('   Message: ${e.response?.data}');
          }
          
          // Gestion du 403/401
          if (e.response?.statusCode == 403 || e.response?.statusCode == 401) {
            // DEBUG: Ne pas logout automatiquement pour faciliter le debug.
            // En production, restaurez la logique suivante :
            //   await AuthService.logout();
            //   navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
            if (kDebugMode) {
              print('🚨 [DEBUG] Requête renvoyée 401/403. Déconnexion automatique désactivée pour debug.');
              print('🚨 [DEBUG] Vérifiez le token manuellement et testez avec curl.');
            }
            // Laisser l'erreur se propager pour que le FutureProvider la récupère
            // et que l'UI puisse afficher le message d'erreur.
          }
          
          return handler.next(e);
        },
      ),
    );
  }

  /// 🎯 CORRECTION : Accès sécurisé à l'instance Dio
  static Dio get dio {
    if (_dio == null) {
      throw Exception('Dio client n\'a pas été initialisé. Appelez ApiClient.init() au démarrage.');
    }
    return _dio!;
  }
}