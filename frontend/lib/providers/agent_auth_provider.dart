// Fichier : lib/providers/agent_auth_provider.dart (Code Final Corrigé)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart'; // Importez le service d'authentification

// --- Notifiers (Classes de Gestion d'État) ---

// 1. Gestion de l'ID de l'Agent (RowID)
class AgentIdNotifier extends StateNotifier<int> {
  // Initialisation à 0 (valeur par défaut pour non connecté/erreur)
  AgentIdNotifier() : super(0); 

  void setAgentId(int id) {
    state = id;
  }
}

// 2. Fournisseur de l'ID de l'agent
final currentAgentIdProvider = StateNotifierProvider<AgentIdNotifier, int>((ref) {
  return AgentIdNotifier();
});

// 3. Gestion du Nom de l'Agent
class AgentNameNotifier extends StateNotifier<String> {
  // Nom par défaut
  AgentNameNotifier() : super('Agent Inconnu'); 

  void setAgentName(String name) {
    state = name;
  }
}

// 4. Fournisseur du Nom de l'agent
final agentNameProvider = StateNotifierProvider<AgentNameNotifier, String>((ref) {
  return AgentNameNotifier();
});

// --- Contrôleur d'Authentification ---

// 5. Fournisseur du contrôleur
final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

class AuthController {
  final Ref _ref;
  // Injection du service Dio
  final AuthService _authService = AuthService(); 

  AuthController(this._ref);

  Future<void> signIn(String email, String password) async {
    try {
      final response = await _authService.login(email, password);
      
      // 🚨 CORRECTION 1: Utilisation de '?? 0' pour convertir 'int?' en 'int'
      _ref.read(currentAgentIdProvider.notifier).setAgentId(
        response.agentRowid ?? 0 
      );
      
      // 🚨 CORRECTION 2: Utilisation de '??' pour convertir 'String?' en 'String'
      _ref.read(agentNameProvider.notifier).setAgentName(
        response.nomComplet ?? 'Agent Inconnu'
      );
      
    } catch (e) {
      // Propagation de l'erreur pour affichage dans l'écran de connexion
      rethrow;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();  // Appel de la méthode statique
    _ref.read(currentAgentIdProvider.notifier).setAgentId(0);
    _ref.read(agentNameProvider.notifier).setAgentName('Agent Inconnu');
  }
}