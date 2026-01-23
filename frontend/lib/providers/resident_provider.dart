import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/resident_models.dart';
import '../services/resident_service.dart';

final residentServiceProvider = Provider((ref) => ResidentService());

final residentsListProvider = FutureProvider<List<Resident>>((ref) async {
  final service = ref.watch(residentServiceProvider);
  return service.loadResidents();
});

final residentByIdProvider = FutureProvider.family<Resident?, String>((ref, id) async {
  final service = ref.watch(residentServiceProvider);
  return service.getResidentById(id);
});
