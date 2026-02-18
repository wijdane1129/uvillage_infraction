import '../models/contravention_models.dart';
import 'api_service.dart';

class ContraventionService {
  final ApiService _apiService = ApiService();

  /// Récupère toutes les contraventions d'un résident depuis l'API
  Future<List<Map<String, dynamic>>> getContraventionsByResident(
    String residentId,
  ) async {
    try {
      final response = await _apiService.get(
        '/contraventions/resident/$residentId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data ?? [];

        // D'abord, construire la liste brute avec le motif
        final List<Map<String, dynamic>> rawList = [];
        for (final contravention in data) {
          final typeContravention = contravention['typeContravention'];
          final motif =
              (typeContravention is Map ? typeContravention['nom'] : null) ??
              'Sans motif';

          // Extraire les 4 paliers de montant
          final montant1 =
              (typeContravention is Map
                  ? typeContravention['montant1']
                  : null) ??
              0;
          final montant2 =
              (typeContravention is Map
                  ? typeContravention['montant2']
                  : null) ??
              montant1;
          final montant3 =
              (typeContravention is Map
                  ? typeContravention['montant3']
                  : null) ??
              montant2;
          final montant4 =
              (typeContravention is Map
                  ? typeContravention['montant4']
                  : null) ??
              montant3;

          // Si le backend renvoie déjà le montant facturé, l'utiliser en priorité
          final montantFacture = contravention['montant'];

          // Statut de paiement
          final statut = contravention['statut'] ?? '';
          final facturePdfUrl = contravention['facturePdfUrl'];
          String statutPaiement;
          if (statut == 'ACCEPTEE' && facturePdfUrl != null) {
            statutPaiement = 'Payée';
          } else if (statut == 'ACCEPTEE') {
            statutPaiement = 'Impayée';
          } else {
            statutPaiement = statut;
          }

          rawList.add({
            'id': contravention['rowid'],
            'ref': contravention['ref'] ?? '',
            'motif': motif,
            'date': contravention['dateHeure'] ?? 'N/A',
            'montantFacture': montantFacture,
            'montant1': montant1,
            'montant2': montant2,
            'montant3': montant3,
            'montant4': montant4,
            'statut': statutPaiement,
            'description': contravention['description'] ?? '',
          });
        }

        // Calculer l'occurrence (récidive) par motif et attribuer le bon montant
        final Map<String, int> motifOccurrenceCount = {};
        for (final item in rawList) {
          final motif = item['motif'] as String;
          motifOccurrenceCount[motif] = (motifOccurrenceCount[motif] ?? 0) + 1;
          final occurrence = motifOccurrenceCount[motif]!;

          // Utiliser le montant facturé si disponible, sinon calculer selon l'occurrence
          num montant;
          if (item['montantFacture'] != null) {
            montant = item['montantFacture'] as num;
          } else {
            switch (occurrence) {
              case 1:
                montant = item['montant1'] as num;
                break;
              case 2:
                montant = item['montant2'] as num;
                break;
              case 3:
                montant = item['montant3'] as num;
                break;
              default:
                montant = item['montant4'] as num;
                break;
            }
          }

          item['montant'] = montant;
          item['occurrence'] = occurrence;
          // Label récidive lisible
          if (occurrence > 1) {
            item['recidiveLabel'] = 'Récidive ${occurrence}x';
          }
        }

        return rawList;
      }
      return [];
    } catch (e) {
      print('Erreur lors du chargement des contraventions: $e');
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
