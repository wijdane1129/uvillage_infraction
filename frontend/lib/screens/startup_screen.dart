import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import './agent_home_screen.dart';
import './responsable_home_screen.dart';
import './welcome_screen.dart';

/// Provider that checks auth state: returns {'token': ..., 'role': ...} or null
final startupAuthCheckProvider = FutureProvider<Map<String, String?>?>((
  ref,
) async {
  final token = await AuthService.getToken();
  if (token == null || token.isEmpty) return null;

  // Get stored role
  final authBox =
      Hive.isBoxOpen('authBox')
          ? Hive.box('authBox')
          : await Hive.openBox('authBox');
  final role = authBox.get('role') as String?;

  return {'token': token, 'role': role};
});

class StartupScreen extends ConsumerWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authCheckAsync = ref.watch(startupAuthCheckProvider);

    return authCheckAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (err, stack) =>
              Scaffold(body: Center(child: Text('Erreur de démarrage: $err'))),
      data: (authData) {
        if (authData != null && authData['token'] != null) {
          // Inject token into ApiClient for future requests
          try {
            ApiClient.dio.options.headers['Authorization'] =
                'Bearer ${authData['token']}';
          } catch (_) {}

          // Route based on role
          final role = authData['role']?.toUpperCase();
          if (role == 'RESPONSABLE') {
            return const ResponsableHomeScreen();
          } else {
            return const AgentHomeScreen();
          }
        } else {
          // No token found: show welcome screen
          return const WelcomeScreen();
        }
      },
    );
  }
}
