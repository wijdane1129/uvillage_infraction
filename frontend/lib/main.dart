import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart' as p;

import 'config/app_theme.dart';
import 'services/api_client.dart';
import 'providers/language_provider.dart';
import 'gen_l10n/app_localizations.dart';

// Providers
import 'providers/dashboard_provider.dart';

// Screens
import 'screens/startup_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/create_account_screen.dart';
import 'screens/verification_code_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/create_password_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/dashboard_responsable_screen.dart';
import 'screens/responsable_home_screen.dart';
import 'screens/user_profile.dart';
import 'screens/contravention_step2.dart';
import 'screens/contravention_details_screen.dart';
import 'screens/accepter_contravention_screen.dart';
import 'screens/classer_sans_suite_screen.dart';
import 'screens/assign_contravention_screen.dart';
import 'screens/configuration_motifs_screen.dart';
import 'screens/resident_detail_screen.dart';
import 'screens/residents_screen.dart';

// Models
import 'models/contravention_models.dart';

// Global navigation key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive initialization
  await Hive.initFlutter();
  await Hive.openBox('authBox');

  // API client (JWT)
  await ApiClient.init();

  debugPrint('✅ App initialized successfully');

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider);

    return p.MultiProvider(
      providers: [
        p.ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Infractions App',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        
        // ✅ Support multilingue
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('fr'),
          Locale('ar'),
        ],

        initialRoute: '/welcome',
        routes: {
          '/welcome': (_) => const WelcomeScreen(),
          '/signin': (_) => const SignInScreen(),
          '/signup': (_) => const SignUpScreen(),
          '/forgot-password': (_) => const ForgotPasswordScreen(),
          '/dashboard': (_) => const DashboardScreen(),
          '/dashboard-responsable': (_) =>
              (Hive.box('authBox').get('role') == 'RESPONSABLE'
                  ? const DashboardResponsableScreen()
                  : const DashboardScreen()),
          '/responsable-home': (_) => (Hive.box('authBox').get('role') == 'RESPONSABLE'
              ? const ResponsableHomeScreen()
              : const DashboardScreen()),
          '/configration_motif': (_) => (Hive.box('authBox').get('role') == 'RESPONSABLE'
              ? const ConfigurationMotifsScreen()
              : const DashboardScreen()),
          '/residents_screen': (_) => (Hive.box('authBox').get('role') == 'RESPONSABLE'
              ? const ResidentsScreen()
              : const DashboardScreen()),
        },
        onGenerateRoute: (settings) {
          // Handle routes that require arguments
          switch (settings.name) {
            case '/classer-sans-suite':
              if (settings.arguments is Contravention) {
                // Only responsable can access classification screen
                final isResp = Hive.box('authBox').get('role') == 'RESPONSABLE';
                if (!isResp) return MaterialPageRoute(builder: (_) => const DashboardScreen());
                return MaterialPageRoute(
                  builder: (_) => ClasserSansSuiteScreen(
                    contravention: settings.arguments as Contravention,
                  ),
                );
              }
              break;
            case '/accepter-contravention':
              if (settings.arguments is Contravention) {
                final isResp = Hive.box('authBox').get('role') == 'RESPONSABLE';
                if (!isResp) return MaterialPageRoute(builder: (_) => const DashboardScreen());
                return MaterialPageRoute(
                  builder: (_) => AccepterContraventionScreen(
                    contravention: settings.arguments as Contravention,
                  ),
                );
              }
              break;
            case '/assign-contravention':
              if (settings.arguments is Map) {
                final args = settings.arguments as Map;
                final isResp = Hive.box('authBox').get('role') == 'RESPONSABLE';
                if (!isResp) return MaterialPageRoute(builder: (_) => const DashboardScreen());
                return MaterialPageRoute(
                  builder: (_) => AssignContraventionScreen(
                    contraventionId: args['contraventionId'],
                    motif: args['motif'],
                  ),
                );
              }
              break;
            case '/contravention-details':
              if (settings.arguments is Contravention) {
                return MaterialPageRoute(
                  builder: (_) => ContraventionDetailsScreen(
                    contravention: settings.arguments as Contravention,
                  ),
                );
              }
              break;
            case '/resident_details':
              if (settings.arguments != null) {
                return MaterialPageRoute(
                  builder: (_) => ResidentDetailScreen(
                    resident: settings.arguments as dynamic,
                  ),
                );
              }
              break;
          }
          return null;
        },
      ),
    );
  }
}
