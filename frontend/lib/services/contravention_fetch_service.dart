import '../models/contravention_models.dart';
import 'api_service.dart';

class ContraventionService {
  final ApiService _apiService = ApiService();

  /// Récupère toutes les contraventions d'un résident depuis l'API
  Future<List<Map<String, dynamic>>> getContraventionsByResident(String residentId) async {
    try {
      final response = await _apiService.get('/contraventions/resident/$residentId');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data ?? [];
        return data.map((contravention) {
          return {
            'id': contravention['id'],
            'motif': contravention['motif'] ?? 'Sans motif',
            'date': contravention['dateCreation'] ?? 'N/A',
            'montant': contravention['montant'] ?? 0,
            'statut': contravention['statutPaiement'] == 'PAID' ? 'Payée' : 'Impayée',
            'description': contravention['description'] ?? '',
          };
        }).toList();
      }
      return [];
    } catch (e) {
      print('Erreur lors du chargement des contraventions: $e');
      // Retourner une liste vide au lieu de lancer l'exception
      return [];
    }
  }

  /// Récupère une seule contravention par ID
  Future<Map<String, dynamic>?> getContraventionById(int id) async {
    try {
      final response = await _apiService.get('/contraventions/$id');
      
      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'id': data['id'],
          'motif': data['motif'] ?? 'Sans motif',
          'date': data['dateCreation'] ?? 'N/A',
          'montant': data['montant'] ?? 0,
          'statut': data['statutPaiement'] == 'PAID' ? 'Payée' : 'Impayée',
          'description': data['description'] ?? '',
        };
      }
      return null;
    } catch (e) {
      print('Erreur lors du chargement de la contravention: $e');
      return null;
    }
  }
}
