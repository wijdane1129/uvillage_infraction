import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../services/contravention_fetch_service.dart';

// Provider pour le service des contraventions
final contraventionFetchServiceProvider = Provider(
  (ref) => ContraventionService(),
);

/// Provider qui retourne les contraventions d'un résident depuis l'API
/// Auto-refreshes every 30 seconds
final residentContraventionsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      residentId,
    ) async {
      final service = ref.watch(contraventionFetchServiceProvider);
      final result = await service.getContraventionsByResident(residentId);

      // Schedule auto-refresh after 30 seconds
      final timer = Timer(const Duration(seconds: 30), () {
        ref.invalidateSelf();
      });
      ref.onDispose(() => timer.cancel());

      return result;
    });
