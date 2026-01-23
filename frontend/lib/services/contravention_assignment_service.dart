import '../models/contravention_models.dart';
import 'api_service.dart';
import 'package:dio/dio.dart';

class ContraventionAssignmentService {
  final ApiService _apiService = ApiService();

  /// Assigne une contravention à un résident (MOCKÉE - pas d'appel API)
  Future<bool> assignContraventionToResident({
    required int contraventionId,
    required String residentId,
  }) async {
    try {
      print('DEBUG: Assignation MOCKÉE - contraventionId: $contraventionId, residentId: $residentId');
      
      // Simuler un délai réseau
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Retourner toujours succès avec les données mockées
      print('DEBUG: Assignation réussie (simulée)');
      return true;
    } catch (e) {
      print('Erreur lors de l\'assignation mockée: $e');
      rethrow;
    }
  }

  /// Crée une contravention et l'assigne à un résident
  Future<int?> createAndAssignContravention({
    required String motif,
    required double montant,
    required String residentId,
    required String description,
    String? photoUrl,
  }) async {
    try {
      final response = await _apiService.post(
        '/contraventions',
        {
          'motif': motif,
          'montant': montant,
          'residentId': residentId,
          'description': description,
          'photoUrl': photoUrl,
          'statutPaiement': 'UNPAID',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['id'];
      }
      return null;
    } catch (e) {
      print('Erreur lors de la création et assignation: $e');
      return null;
    }
  }
}
