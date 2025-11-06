import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io' show Platform;

// Modèle pour la réponse du backend
class LoginResponse {
  final String token;
  // Si le backend renvoie d'autres informations (comme le rôle de l'utilisateur), ajoutez-les ici.
  final String email; 

  LoginResponse({required this.token, required this.email});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      email: json['email'] as String,
    );
  }
}

class AuthService {
  final Dio _dio = Dio();
  
  /// Retourne l'URL de base en fonction de la plateforme
  /// - Android (émulateur): 10.0.2.2:8080
  /// - Web (Chrome): 127.0.0.1:8080 ou localhost:8080
  /// - iOS / Desktop: localhost:8080
  static String get _baseUrl {
    if (kIsWeb) {
      // Flutter Web (Chrome, Firefox, Safari, etc.)
      return 'http://127.0.0.1:8080/api/v1/auth';
    } else if (Platform.isAndroid) {
      // Android émulateur: 10.0.2.2 est le localhost de la machine hôte
      return 'http://10.0.2.2:8080/api/v1/auth';
    } else {
      // iOS, macOS, Windows, Linux : localhost fonctionne
      return 'http://localhost:8080/api/v1/auth';
    }
  }
  
  // Alternative si vous testez avec une adresse IP réelle (ex: ordinateur sur le réseau)
  // static const String _baseUrl = 'http://192.168.x.x:8080/api/v1/auth';
  static const String _authBoxName = 'authBox';

  /// 1. Appelle le backend pour l'authentification.
  /// Envoie {email, password} et attend {token, email}.
  Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/login', // L'endpoint de votre API Spring Boot
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(response.data);
        
        // 2. Stocke le token en cas de succès pour la persistance
        await _saveToken(loginResponse.token);
        
        return loginResponse;

      } else {
        // Gérer les cas inattendus du serveur
        throw Exception("Statut de connexion inattendu: ${response.statusCode}");
      }
    } on DioException catch (e) {
      // 3. Gérer les erreurs spécifiques (comme 401 Unauthorized)
      if (e.response?.statusCode == 401) {
        throw Exception("Identifiants incorrects. Veuillez réessayer.");
      }
      // Gérer les erreurs de réseau (pas d'internet, serveur inaccessible)
      throw Exception("Erreur réseau: Impossible de joindre le serveur.");
    }
  }

  /// Stocke le JWT dans la boîte Hive.
  Future<void> _saveToken(String token) async {
    final authBox = Hive.box(_authBoxName);
    await authBox.put('jwt_token', token);
  }

  /// Récupère le JWT stocké.
  static Future<String?> getToken() async {
    // Vérifie si la boîte est ouverte avant d'essayer de la lire (sécurité)
    if (!Hive.isBoxOpen(_authBoxName)) {
      await Hive.openBox(_authBoxName);
    }
    final authBox = Hive.box(_authBoxName);
    return authBox.get('jwt_token');
  }

  /// Supprime le JWT (déconnexion).
  Future<void> logout() async {
    final authBox = Hive.box(_authBoxName);
    await authBox.delete('jwt_token');
  }
}
