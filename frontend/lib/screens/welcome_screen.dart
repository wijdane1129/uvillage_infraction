import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../widgets/language_switcher.dart';
import '../providers/language_provider.dart';
import '../gen_l10n/app_localizations.dart';
import 'package:infractions_app/screens/sign_in_screen.dart';
import 'package:infractions_app/screens/create_account_screen.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          LanguageSwitcher(),
          SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        // Utiliser SafeArea pour éviter les encoches et la barre de statut
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // --- 1. Logo/Shield Icon (gradient-filled with glow) ---
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // Soft glow behind the icon
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.purpleAccent.withOpacity(0.35),
                            blurRadius: 30,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: Center(
                        // ShaderMask paints a gradient into the icon shape
                        child: ShaderMask(
                          shaderCallback:
                              (bounds) =>
                                  AppTheme.buttonGradient.createShader(bounds),
                          blendMode: BlendMode.srcIn,
                          child: const Icon(
                            Icons.shield_outlined,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15), // Réduit l'espace vertical
                  // --- 2. Titre Principal ---
                  Text(
                    'CampusGuard',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 5),

                  // --- 3. Sous-titre ---
                  Text(
                    'Professional Infraction Management',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  // Petit espace fixe avant l'illustration (simule l'espacement dans l'image)
                  const SizedBox(height: 50),

                  // --- 4. Illustration (Image intégrée) ---
                  Image.asset(
                    'assets/images/illustration.png',
                    // Hauteur fixée pour correspondre au design
                    height: 200,
                    fit: BoxFit.contain,
                  ),

                  // Espace flexible pour créer l'espace visible entre l'image et les boutons
                  const SizedBox(height: 40),

                  // --- 5. Bouton Sign In ---
                  GradientButton(
                    text: locale!.signIn,
                    onPressed: () {
                      // LOGIQUE DE NAVIGATION ICI
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          // La destination est la page de connexion
                          builder: (context) => const SignInScreen(),
                        ),
                      );
                    },
                    isPrimary: true,
                  ),

                  // --- 6. Bouton Create Account ---
                  GradientButton(
                    text: locale.createAccount,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                    isPrimary: false,
                  ),

                  const SizedBox(height: 20), // Petit espace fixe à la fin (marge)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
