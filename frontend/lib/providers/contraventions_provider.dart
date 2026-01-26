import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/contravention_fetch_service.dart';
import 'package:intl/intl.dart';

// Provider pour le service des contraventions
final contraventionFetchServiceProvider = Provider((ref) => ContraventionService());

// StateNotifier pour gérer les assignations mockées
class MockAssignmentsNotifier extends StateNotifier<Map<String, List<Map<String, dynamic>>>> {
  MockAssignmentsNotifier() : super({});

  /// Ajoute une assignation mockée
  void addAssignment(String residentId, Map<String, dynamic> contravention) {
    state = {
      ...state,
      residentId: [
        ...(state[residentId] ?? []),
        contravention,
      ],
    };
  }
}

final mockAssignmentsProvider = StateNotifierProvider<MockAssignmentsNotifier, Map<String, List<Map<String, dynamic>>>>((ref) {
  return MockAssignmentsNotifier();
});

// Données mockées par défaut
final _mockContraventionsByResident = {
  '1001': [
    {
      'motif': 'Bruit nocturne',
      'date': '15 Oct. 2023',
      'montant': 50,
      'statut': 'Impayée',
    },
    {
      'motif': 'Cigarette en chambre',
      'date': '02 Sep. 2023',
      'montant': 100,
      'statut': 'Payée',
    },
  ],
  '1002': [
    {
      'motif': 'Poubelles non sorties',
      'date': '18 Aug. 2023',
      'montant': 25,
      'statut': 'Payée',
    },
  ],
  '1003': [
    {
      'motif': 'Bruit nocturne',
      'date': '20 Dec. 2023',
      'montant': 50,
      'statut': 'Payée',
    },
    {
      'motif': 'Visite non autorisée',
      'date': '10 Dec. 2023',
      'montant': 75,
      'statut': 'Impayée',
    },
    {
      'motif': 'Cigarette en chambre',
      'date': '05 Dec. 2023',
      'montant': 100,
      'statut': 'Payée',
    },
  ],
  '1004': [],
  '1005': [
    {
      'motif': 'Dégradation',
      'date': '25 Jan. 2024',
      'montant': 200,
      'statut': 'Impayée',
    },
  ],
  '1006': [],
  '1007': [
    {
      'motif': 'Bruit nocturne',
      'date': '15 Jan. 2024',
      'montant': 50,
      'statut': 'Payée',
    },
  ],
  '1008': [],
  '1009': [
    {
      'motif': 'Cigarette en chambre',
      'date': '08 Jan. 2024',
      'montant': 100,
      'statut': 'Impayée',
    },
    {
      'motif': 'Bruit nocturne',
      'date': '01 Jan. 2024',
      'montant': 50,
      'statut': 'Payée',
    },
  ],
  '1010': [],
  '1011': [
    {
      'motif': 'Cigarette en chambre',
      'date': '20 Jan. 2024',
      'montant': 100,
      'statut': 'Impayée',
    },
  ],
};

/// Provider qui retourne les contraventions d'un résident
/// Essaie d'abord de charger depuis l'API, sinon utilise les mockées
/// Inclut aussi les assignations mockées dynamiques
final residentContraventionsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, residentId) async {
  final service = ref.watch(contraventionFetchServiceProvider);
  final mockAssignments = ref.watch(mockAssignmentsProvider);

  // Essayer de charger depuis l'API
  final apiContraventions = await service.getContraventionsByResident(residentId);

  // Si l'API retourne des données, les utiliser
  if (apiContraventions.isNotEmpty) {
    return apiContraventions;
  }

  // Sinon, utiliser les données mockées
  final mockData = _mockContraventionsByResident[residentId];
  List<Map<String, dynamic>> result = [];
  
  if (mockData != null) {
    result = List<Map<String, dynamic>>.from(mockData);
  }
  
  // Ajouter les assignations dynamiques mockées
  if (mockAssignments.containsKey(residentId)) {
    result.addAll(mockAssignments[residentId]!);
  }
  
  return result;
});
