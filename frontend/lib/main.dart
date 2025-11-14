import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'config/app_theme.dart';
import 'screens/startup_screen.dart';
import 'services/api_client.dart'; // API client with JWT

// Clé de navigation globale pour permettre la navigation depuis n'importe où
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Assure que Flutter est prêt pour les appels asynchrones
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Hive et ouverture de la boîte d'authentification
  await Hive.initFlutter();
  await Hive.openBox('authBox');

  // Initialiser l'intercepteur JWT pour l'API
  await ApiClient.init();

  print('✅ [MAIN] Application initialisée avec succès');
  print('   - Hive: OK');
  print('   - API Client avec JWT: OK');

  // Lance l'application, enveloppée par ProviderScope (nécessaire pour Riverpod)
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Clé globale pour navigation
      title: 'CampusGuard',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,

      // Écran de démarrage qui vérifie l'état de connexion
      home: const StartupScreen(),
    );
  }
}
