import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: AppTheme.darkBg,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            const Text(
              'Create your account',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Minimal form placeholders — the full form (name/email/password) can be implemented later
            const TextField(
              decoration: InputDecoration(labelText: 'Full name'),
            ),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: hook up sign-up logic to AuthService
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sign-up not implemented yet')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.darkBg,
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text('Create account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
