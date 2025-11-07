import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'config/app_theme.dart';
import 'screens/startup_screen.dart';
import 'screens/create_account_screen.dart';
import 'screens/verification_code_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/welcome_screen.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and open the authentication box
  await Hive.initFlutter();
  await Hive.openBox('authBox');

  // Run the app wrapped with ProviderScope for Riverpod
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusGuard',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,

      // 🔹 The first screen checks login state before navigating
      home: const WelcomeScreen(),

      // Optional: define named routes for quick navigation
      routes: {
        '/create-account': (_) => const SignUpScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
      },
    );
  }
}
