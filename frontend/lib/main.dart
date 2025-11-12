import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/app_theme.dart'; 
import 'screens/startup_screen.dart';
import 'services/api_client.dart'; // ✅ AJOUT CRITIQUE

// Clé de navigation globale pour permettre la navigation depuis n'importe où
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // 1. Assure que Flutter est prêt pour les appels asynchrones
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // 2. Initialisation de Hive et ouverture de la boîte d'authentification
  await Hive.initFlutter();
  await Hive.openBox('authBox'); 
  
  // 3. ✅ CRITIQUE: Initialiser l'intercepteur JWT pour l'API
  await ApiClient.init();
  
  print('✅ [MAIN] Application initialisée avec succès');
  print('   - Hive: OK');
  print('   - API Client avec JWT: OK');
  
  // 4. Lance l'application, enveloppée par ProviderScope (NÉCESSAIRE pour Riverpod)
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Ajout de la clé de navigation globale
      title: 'CampusGuard',
      // Votre thème sombre
      theme: AppTheme.darkTheme, 
      debugShowCheckedModeBanner: false,
      
      // L'écran de démarrage qui vérifie l'état de connexion.
      // Cet écran déterminera si on va vers Login ou Dashboard.
      home: const StartupScreen(), 
    );
  }
}