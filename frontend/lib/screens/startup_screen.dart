import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart'; // Importez le service pour getToken()
import './agent_home_screen.dart'; // L'écran de la page d'accueil de l'agent
import './sign_in_screen.dart'; // L'écran de connexion

// Ce fournisseur vérifie de manière asynchrone si un token est stocké.
final startupAuthCheckProvider = FutureProvider<String?>((ref) async {
  // 1. Ouvre la boîte Hive si ce n'est pas déjà fait.
  // NOTE: Hive doit être initialisé dans main() avant runApp().
  
  // 2. Récupère le token JWT stocké.
  final token = await AuthService.getToken();
  
  // 3. Retourne le token (null si non trouvé).
  return token;
});

class StartupScreen extends ConsumerWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Écoute l'état de la vérification asynchrone du token.
    final authCheckAsync = ref.watch(startupAuthCheckProvider);

    return authCheckAsync.when(
      // État de chargement initial (le temps de vérifier le token)
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      
      // Gestion des erreurs (peu probable ici, sauf si Hive n'est pas initialisé)
      error: (err, stack) => Scaffold(
        body: Center(
          child: Text('Erreur de démarrage: $err'),
        ),
      ),
      
      // Données disponibles (le token a été récupéré ou est null)
      data: (token) {
        if (token != null) {
          // Token trouvé: L'utilisateur est considéré comme connecté.
          // Redirige vers l'écran d'accueil de l'agent.
          // NOTE: Le token n'est pas validé ici, la validation sera faite par le premier appel API.
          return const AgentHomeScreen();
        } else {
          // Aucun token trouvé: L'utilisateur doit se connecter.
          // Redirige vers l'écran de connexion.
          return const SignInScreen();
        }
      },
    );
  }
}