import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/contravention_fetch_service.dart';

// Provider pour le service des contraventions
final contraventionFetchServiceProvider = Provider(
  (ref) => ContraventionService(),
);

/// Provider qui retourne les contraventions d'un résident depuis l'API
final residentContraventionsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      residentId,
    ) async {
      final service = ref.watch(contraventionFetchServiceProvider);
      return service.getContraventionsByResident(residentId);
    });
