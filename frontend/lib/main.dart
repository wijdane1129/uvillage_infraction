import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as p;
import 'providers/dashboard_provider.dart';
import 'screens/create_account_screen.dart';
import 'screens/verification_code_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/create_password_screen.dart';
import 'screens/contravention_step2.dart';
import 'screens/User_profile.dart';
import 'screens/dashboard_screen.dart';
import 'screens/dashboard_responsable_screen.dart';
import 'screens/contravention_details_screen.dart';
import 'models/contravention_models.dart';
import 'screens/accepter_contravention_screen.dart';
import 'screens/classer_sans_suite_screen.dart';
import 'screens/responsable_home_screen.dart';

void main() {
  // Wrap the app with ProviderScope so Riverpod providers work
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Infractions App',
      theme: ThemeData.dark(),
      home: const ResponsableHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
