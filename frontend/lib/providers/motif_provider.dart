import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/motif_model.dart';
import '../services/motif_service.dart';

final motifServiceProvider = Provider((ref) => MotifService());

final motifsProvider = FutureProvider<List<Motif>>((ref) async {
  final service = ref.watch(motifServiceProvider);
  return await service.fetchMotifs();
});

final motifStateProvider =
    StateNotifierProvider<MotifNotifier, AsyncValue<List<Motif>>>((ref) {
  final service = ref.watch(motifServiceProvider);
  return MotifNotifier(service);
});

class MotifNotifier extends StateNotifier<AsyncValue<List<Motif>>> {
  final MotifService _service;

  MotifNotifier(this._service) : super(const AsyncValue.loading()) {
    _loadMotifs();
  }

  Future<void> _loadMotifs() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.fetchMotifs());
  }

  Future<void> addMotif(String nom, double montant1, double montant2, double montant3, double montant4) async {
    final currentState = state;
    if (currentState is AsyncData) {
      final currentList = currentState.value ?? [];
      state = AsyncValue.data([
        ...currentList,
        Motif(
          id: DateTime.now().millisecondsSinceEpoch,
          nom: nom,
          montant1: montant1,
          montant2: montant2,
          montant3: montant3,
          montant4: montant4,
          dateCreation: DateTime.now(),
          utilisations: 0,
        ),
      ]);
      await _service.createMotif(nom, montant1, montant2, montant3, montant4);
      await _loadMotifs();
    }
  }

  Future<void> updateMotif(int id, String nom, double montant1, double montant2, double montant3, double montant4) async {
    await _service.updateMotif(id, nom, montant1, montant2, montant3, montant4);
    await _loadMotifs();
  }

  Future<void> deleteMotif(int id) async {
    await _service.deleteMotif(id);
    await _loadMotifs();
  }

  Future<void> refresh() async {
    await _loadMotifs();
  }
}
