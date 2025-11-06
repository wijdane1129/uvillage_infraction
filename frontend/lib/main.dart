import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Import nécessaire pour l'initialisation
import 'config/app_theme.dart'; 
import 'screens/startup_screen.dart'; // Le premier écran chargé

void main() async {
  // 1. Assure que Flutter est prêt pour les appels asynchrones
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // 2. Initialisation de Hive et ouverture de la boîte d'authentification
  await Hive.initFlutter();
  await Hive.openBox('authBox'); // 'authBox' est utilisé par AuthService pour stocker le JWT
  
  // 3. Lance l'application une fois que tout est initialisé
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusGuard',
      // Votre thème sombre
      theme: AppTheme.darkTheme, 
      debugShowCheckedModeBanner: false,
      
      // Le 'home' est désormais l'écran qui vérifie l'état de connexion.
      home: const StartupScreen(), 
    );
  }
}
