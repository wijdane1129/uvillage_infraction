// Fichier : lib/services/contravention_service.dart

import 'package:dio/dio.dart';
import 'api_client.dart'; // Pour obtenir l'instance Dio

class ContraventionService {
  final Dio _dio = ApiClient.dio;
  
  // Si votre constructeur prend un argument, décommentez ceci :
  // ContraventionService(/* Argument ici */); 
  
  // 🎯 CORRECTION : Définir la méthode fetchStats(agentRowid)
  Future<Map<String, dynamic>> fetchStats(int agentRowid) async {
    try {
      print('📡 [STATS] Requête des statistiques pour agent ID: $agentRowid');
      
      // Backend mapping: @RequestMapping("/api/v1/contraventions") + GET "/stats/{agentRowid}"
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
}