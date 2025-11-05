import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/verification_code_screen.dart';

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
      home: const VerificationCodeScreen(email: 'wijdane@gmail.com',), // or other screen you want to preview
    );
  }
}
