import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/contravention_models.dart';

import '../services/contravention_service.dart';
import '../services/auth_service.dart';
import 'agent_auth_provider.dart';

// ===============================
//       FORM DATA NOTIFIER
// ===============================
class ContraventionFormDataNotifier extends StateNotifier<ContraventionFormData> {
  ContraventionFormDataNotifier() : super(ContraventionFormData());

  void setStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  void addMedia(ContraventionMediaDetail mediaDetail) {
    final newMediaList = [...state.media, mediaDetail];
    state = state.copyWith(media: newMediaList);
  }

  void removeMedia(int mediaId) {
    final newMediaList = state.media.where((m) => m.id != mediaId).toList();
    state = state.copyWith(media: newMediaList);
  }

  void updateMedia(ContraventionMediaDetail updateMedia) {
    final newMediaList = state.media.map((m) {
      if (m.id == updateMedia.id) return updateMedia;
      return m;
    }).toList();

    state = state.copyWith(media: newMediaList);
  }
}

// Provider for FormData
final contraventionFormDataProvider =
    StateNotifierProvider<ContraventionFormDataNotifier, ContraventionFormData>(
        (ref) {
  return ContraventionFormDataNotifier();
});

// ===============================
//        SERVICE PROVIDER
// ===============================
final contraventionServiceProvider = Provider<ContraventionService>((ref) {
  return ContraventionService();
});

// ===============================
//         AGENT STATS
// ===============================
final agentStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  // 1. Get token (fixes 403 errors)
  final token = await AuthService.getToken();

  if (token == null || token.isEmpty) {
    throw Exception('Accès non autorisé (403). Token manquant ou invalide.');
  }

  // 2. Get current agent ID — required by backend
  final agentRowid = ref.watch(currentAgentIdProvider);

  if (agentRowid == 0) {
    throw Exception('ID agent non défini.');
  }

  final contraventionService = ref.read(contraventionServiceProvider);

  // 3. Fetching statistics for this specific agent
  return await contraventionService.fetchStats(agentRowid);
});
