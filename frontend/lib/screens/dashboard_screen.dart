import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../services/auth_service.dart';
import 'sign_in_screen.dart';
import 'package:another_flushbar/flushbar.dart'; // Pour les notifications

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Méthode utilitaire pour afficher les notifications (copiée de SignInScreen)
  void _showFlushbar(BuildContext context, String message, {required bool isError}) {
    Flushbar(
      message: message,
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline, 
        color: Colors.white
      ),
      backgroundColor: isError ? AppTheme.errorRed : AppTheme.successGreen,
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
    ).show(context);
  }

  // Gère la déconnexion
  void _handleLogout(BuildContext context) async {
    try {
      await AuthService().logout();
      _showFlushbar(context, "Vous avez été déconnecté.", isError: false);
      
      // Redirection vers l'écran de connexion après la déconnexion
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SignInScreen()),
        (Route<dynamic> route) => false, // Retire toutes les routes précédentes
      );
    } catch (e) {
      _showFlushbar(context, "Erreur lors de la déconnexion.", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false, // Pas de bouton retour
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.check_circle_outline,
                color: AppTheme.successGreen,
                size: 80,
              ),
              const SizedBox(height: 20),
              Text(
                'Connexion Réussie !',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                "Vous êtes connecté(e) et pouvez gérer les infractions.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 50),
              // Bouton de Déconnexion
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleLogout(context),
                  icon: const Icon(Icons.logout, color: AppTheme.textPrimary),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.pinkAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
