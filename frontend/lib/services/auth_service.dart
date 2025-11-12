import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io' show Platform;

// Modèle pour la réponse du backend
class LoginResponse {
  final String token;
  final int? agentRowid;
  final String? nomComplet;
  final String email;
  final String? role; // Ajout du rôle retourné par le backend (ADMIN, AGENT, RESPONSABLE)

  LoginResponse({
    required this.token,
    this.agentRowid,
    this.nomComplet,
    required this.email,
    this.role,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Lecture sécurisée des données
    final tokenValue = json['token']?.toString() ?? '';
    final agentRowidValue = json['agentRowid'] as int?;
    final nomCompletValue = json['nomComplet'] as String?;
    final emailValue = json['email']?.toString() ?? '';
    final roleValue = json['role'] as String?;

    if (kDebugMode) {
      print('🔍 [AUTH RESPONSE] Données reçues du backend:');
      print('   Token: ${tokenValue.isNotEmpty ? "${tokenValue.substring(0, 20)}..." : "VIDE"}');
      print('   Agent Rowid: $agentRowidValue');
      print('   Nom Complet: $nomCompletValue');
      print('   Email: $emailValue');
      print('   Role: $roleValue');
    }

    return LoginResponse(
      token: tokenValue,
      agentRowid: agentRowidValue,
      nomComplet: nomCompletValue,
      email: emailValue,
      role: roleValue,
    );
  }
}

class AuthService {
  final Dio _dio = Dio();
  
  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8080/api/v1/auth';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api/v1/auth';
    } else {
      return 'http://localhost:8080/api/v1/auth';
    }
  }
  
  static const String _authBoxName = 'authBox';

  Future<LoginResponse> login(String email, String password) async {
    try {
      if (kDebugMode) {
        print('📡 [AUTH] Tentative de connexion pour: $email');
        print('   URL: $_baseUrl/login');
      }

      final response = await _dio.post(
        '$_baseUrl/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('✅ [AUTH] Réponse serveur reçue: ${response.data}');
        }

        final loginResponse = LoginResponse.fromJson(response.data);

        // Sauvegarder le token dans Hive (vérifier non vide)
        if (loginResponse.token.isEmpty) {
          throw Exception('Token vide reçu du backend');
        }
        await _saveToken(loginResponse.token);

        if (kDebugMode) {
          print('✅ [AUTH] Token sauvegardé dans Hive');
        }

        return loginResponse;
      } else {
        throw Exception("Statut de connexion inattendu: ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [AUTH] Erreur Dio:');
        print('   Status: ${e.response?.statusCode}');
        print('   Message: ${e.response?.data}');
      }

      String errorMessage;
      if (e.response?.statusCode == 401) {
        // Le backend renvoie le message exact dans le body
        errorMessage = e.response?.data?.toString() ?? "Identifiants incorrects";
        throw Exception(errorMessage);
      } else if (e.response?.statusCode == 403) {
        throw Exception("Accès refusé. Contactez l'administrateur.");
      } else if (e.response?.statusCode == 404) {
        throw Exception("Utilisateur introuvable");
      } else {
        throw Exception("Erreur réseau: Impossible de joindre le serveur. Veuillez réessayer plus tard.");
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [AUTH] Erreur inattendue: $e');
      }
      rethrow;
    }
  }

  Future<void> _saveToken(String token) async {
    final authBox = Hive.box(_authBoxName);
    await authBox.put('jwt_token', token);
  }

  static Future<String?> getToken() async {
    if (!Hive.isBoxOpen(_authBoxName)) {
      await Hive.openBox(_authBoxName);
    }
    final authBox = Hive.box(_authBoxName);
    final token = authBox.get('jwt_token') as String?;
    if (token == null) {
      if (kDebugMode) {
        print('🔑 [AUTH] Aucun token trouvé dans Hive');
      }
    }
    
    if (kDebugMode && token != null) {
      print('🔑 [AUTH] Token récupéré: ${token.substring(0, 20)}...');
    }
    
    return token;
  }

  static Future<void> logout() async {
    if (!Hive.isBoxOpen(_authBoxName)) {
      await Hive.openBox(_authBoxName);
    }
    final authBox = Hive.box(_authBoxName);
    await authBox.delete('jwt_token');
    
    if (kDebugMode) {
      print('🔒 [AUTH] Token supprimé de Hive');
    }
  }
}