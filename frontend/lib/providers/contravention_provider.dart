import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/contravention_service.dart';
import '../services/auth_service.dart';           // 👈 NÉCESSAIRE
import 'agent_auth_provider.dart';               // 👈 NÉCESSAIRE pour l'ID

// Définition de votre service de contravention (pour éviter Undefined name)
final contraventionServiceProvider = Provider<ContraventionService>((ref) {
  return ContraventionService(); 
});

/// Le FutureProvider qui récupère les statistiques
final agentStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  
  // 1. 🔑 FIX CRITIQUE 403: Attendre le token avant de procéder
  final token = await AuthService.getToken();
  
  if (token == null || token.isEmpty) {
    throw Exception('Accès non autorisé (403). Token manquant ou invalide.');
  }
  
  // 2. Lire l'ID de l'agent (si l'API stats en a besoin, ce qui est probable)
  final agentRowid = ref.watch(currentAgentIdProvider);
  
  if (agentRowid == 0) {
    throw Exception('ID agent non défini.');
  }

  final contraventionService = ref.read(contraventionServiceProvider);

  // Appel avec l'ID de l'agent pour correspondre au backend
  return await contraventionService.fetchStats(agentRowid); 
});