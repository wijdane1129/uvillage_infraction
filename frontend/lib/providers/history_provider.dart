import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/history_service.dart'; // Service refactorisé
import '../models/contravention_model.dart';
import '../services/auth_service.dart';     // 👈 CRITIQUE : Pour le getToken()

/// Définition du fournisseur de service (pour éviter "Undefined name")
final historyServiceProvider = Provider<HistoryService>((ref) {
  return HistoryService();
});

/// Le FutureProvider qui déclenche la requête Historique.
final agentHistoryProvider = FutureProvider.family<List<ContraventionModel>, int>(
  (ref, agentRowid) async {
    
    // 🎯 FIX CRITIQUE 403: Attendre le token avant de procéder
    final token = await AuthService.getToken();
    
    if (token == null || token.isEmpty) {
      // Si le token n'est pas stable, lance une erreur explicite.
      throw Exception('Erreur 403: Accès non autorisé. Token manquant ou invalide.');
    }
    
    final historyService = ref.read(historyServiceProvider);
    
    // La requête est lancée après que le token a été validé.
    return await historyService.getAgentHistory(agentRowid);
  },
);