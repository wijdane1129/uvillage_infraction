import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'config/app_theme.dart';
import 'screens/startup_screen.dart';
import 'screens/create_account_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'services/api_client.dart';
import 'screens/welcome_screen.dart';
 // API client with JWT

// Global navigation key for navigation from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and open the authentication box
  await Hive.initFlutter();
  await Hive.openBox('authBox');

  // Initialize API client with JWT interceptor
  await ApiClient.init();

  print('✅ [MAIN] Application initialized successfully');
  print('   - Hive: OK');
  print('   - API Client with JWT: OK');

  // Run the app wrapped with ProviderScope for Riverpod
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Global key for navigation
      title: 'CampusGuard',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,

      // Startup screen checks login state before navigating
      home: const WelcomeScreen(),

      // Optional named routes for quick navigation
      routes: {
        '/create-account': (_) => const SignUpScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
      },
    );
  }
}
