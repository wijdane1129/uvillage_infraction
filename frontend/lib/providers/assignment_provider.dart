import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/resident_models.dart';
import '../services/contravention_assignment_service.dart';
import 'resident_provider.dart';
import 'contraventions_provider.dart';

final assignmentServiceProvider = Provider(
  (ref) => ContraventionAssignmentService(),
);

/// État pour gérer la sélection de résident
final selectedResidentProvider = StateProvider<Resident?>((ref) => null);

/// État pour la recherche
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Résidents filtrés selon la recherche
final filteredResidentsProvider = FutureProvider<List<Resident>>((ref) async {
  final residents = await ref.watch(residentsListProvider.future);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();

  if (searchQuery.isEmpty) {
    return residents;
  }

  return residents
      .where(
        (resident) =>
            resident.fullName.toLowerCase().contains(searchQuery) ||
            resident.chambre.toLowerCase().contains(searchQuery) ||
            resident.numeroChambre.toLowerCase().contains(searchQuery),
      )
      .toList();
});

/// Assigne une contravention à un résident
final assignContraventionProvider = FutureProvider.family<
  bool,
  Map<String, dynamic>
>((ref, params) async {
  final service = ref.watch(assignmentServiceProvider);

  final contraventionId = params['contraventionId'] as int;
  final residentId = params['residentId'] as String;

  try {
    final success = await service.assignContraventionToResident(
      contraventionId: contraventionId,
      residentId: residentId,
    );

    if (success) {
      // Invalider la liste des contraventions du résident pour forcer le rechargement
      ref.invalidate(residentContraventionsProvider);
    }

    return success;
  } catch (e) {
    print('Provider error in assignContraventionProvider: $e');
    rethrow;
  }
});
