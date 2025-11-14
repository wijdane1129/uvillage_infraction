import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../widgets/gradient_button.dart';
// Note: Le SingleChildScrollView n'est pas nécessaire si l'on gère bien les spacers
// mais je le laisse par sécurité pour le développement multi-écran.
import 'package:infractions_app/screens/sign_in_screen.dart'; 

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea( // Utiliser SafeArea pour éviter les encoches et la barre de statut
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Espace flexible TRES grand en haut pour pousser le contenu vers le centre-bas
              const Spacer(flex: 10), 

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
                      shaderCallback: (bounds) =>
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
                height: 220, 
                fit: BoxFit.contain,
              ),
              
              // Espace flexible MOYEN pour créer l'espace visible entre l'image et les boutons
              const Spacer(flex: 8), 

              // --- 5. Bouton Sign In ---
              GradientButton(
                text: 'Sign In',
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
                text: 'Create Account',
                onPressed: () {
                  // TODO: Naviguer vers SignUpScreen
                },
                isPrimary: false, 
              ),
              
              const Spacer(flex: 3), // Petit espace flexible à la fin (marge)
            ],
          ),
        ),
      ),
    );
  }
}