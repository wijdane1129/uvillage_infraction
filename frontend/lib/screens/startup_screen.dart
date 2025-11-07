// lib/screens/startup_screen.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'welcome_screen.dart'; 
// import 'dashboard_screen.dart'; // Créez cet écran !

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    final token = await AuthService.getToken(); 
    
    // Pour que l'utilisateur voie quelque chose pendant la vérification
    await Future.delayed(const Duration(milliseconds: 500)); 

    if (!mounted) return;

    if (token != null) {
      // Si connecté : Aller directement au Dashboard
      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(builder: (context) => const DashboardScreen()),
      // );
    } else {
      // Si déconnecté : Aller à l'écran de bienvenue
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Écran de chargement affiché brièvement
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}