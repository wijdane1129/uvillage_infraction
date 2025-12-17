import 'package:dio/dio.dart';
import 'api_client.dart'; // Assurez-vous d'importer votre ApiClient
import '../models/contravention_model.dart';
import 'dart:async'; // Nécessaire pour Future

/// Modèle pour une infraction dans l'historique
// Ancien modèle HistoryItem supprimé: on utilise directement ContraventionModel

/// Service pour gérer l'historique des contraventions
class HistoryService {
  // Utilise l'instance Dio configurée avec l'intercepteur JWT
  final Dio _dio = ApiClient.dio; 

  Future<List<ContraventionModel>> getAgentHistory(int agentRowid) async {
    try {
      print('📡 [HISTORY] Requête historique pour agent ID: $agentRowid');

      final response = await _dio.get('/contraventions/history/$agentRowid');

      if (response.statusCode == 200) {
        final body = response.data;
        if (body is List) {
          print('✅ [HISTORY] Liste reçue (size=${body.length}).');
          return body.map<ContraventionModel>((json) {
            if (json is Map<String, dynamic>) {
              return ContraventionModel.fromJson(json);
            } else if (json is Map) {
              return ContraventionModel.fromJson(json.cast<String, dynamic>());
            } else {
              throw Exception('Format élément inattendu: ${json.runtimeType}');
            }
          }).toList();
        } else if (body is Map) {
          // Certains backends renvoient {"data": [...]} ; gérer ce cas.
          if (body['data'] is List) {
            final list = body['data'] as List;
            print('ℹ️ [HISTORY] Données sous clé data (size=${list.length}).');
            return list.map<ContraventionModel>((json) => ContraventionModel.fromJson((json as Map).cast<String, dynamic>())).toList();
          }
          throw Exception('Format JSON inattendu (Map sans liste).');
        } else {
          throw Exception('Format de réponse inattendu: ${body.runtimeType}');
        }
      } else {
        throw Exception('Statut HTTP inattendu: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ [HISTORY] Erreur Dio: ${e.response?.statusCode}');
      if (e.response != null) {
        print('❌ [HISTORY] Body erreur: ${e.response?.data}');
      }
      rethrow;
    } catch (e) {
      print('❌ [HISTORY] Erreur inattendue: $e');
      rethrow;
    }
  }
}