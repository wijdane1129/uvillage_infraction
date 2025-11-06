import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart'; // Pour les notifications
import '../config/app_theme.dart'; // Import du thème
import '../services/auth_service.dart'; // Import du service

// NOTE: Vous devez créer ce fichier (lib/screens/dashboard_screen.dart)
// import 'dashboard_screen.dart'; 

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  
  // NOUVEL ÉTAT : Pour afficher le CircularProgressIndicator sur le bouton
  bool _isLoading = false; 

  // Instance du service d'authentification
  final AuthService _authService = AuthService(); 

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- LOGIQUE D'AUTHENTIFICATION ---
  void _handleLogin() async {
    // 1. Vérification simple des champs
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showFlushbar(context, "Veuillez remplir tous les champs.", isError: true);
      return;
    }

    // 2. Active l'état de chargement
    setState(() { _isLoading = true; });

    try {
      // 3. Appel au service d'authentification
      final response = await _authService.login(
        _emailController.text,
        _passwordController.text,
      );

      // Si le code atteint ici, la connexion est réussie et le token est stocké
      _showFlushbar(context, "Connexion réussie ! Bienvenue.", isError: false);
      
      // 4. Redirection vers l'écran principal (Dashboard)
      // REMPLACER cette navigation une fois que vous avez créé DashboardScreen
      /*
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
      */
      
    } catch (e) {
      // 5. Affichage de l'erreur
      // Retire le préfixe "Exception: " pour un message plus propre
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      _showFlushbar(context, errorMessage, isError: true);

    } finally {
      // 6. Désactive l'état de chargement, que ce soit un succès ou un échec
      setState(() { _isLoading = false; });
    }
  }

  // Méthode utilitaire pour afficher les notifications
  void _showFlushbar(BuildContext context, String message, {required bool isError}) {
    Flushbar(
      message: message,
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline, 
        color: Colors.white
      ),
      backgroundColor: isError ? Colors.red.shade700 : AppTheme.cyanAccent,
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
    ).show(context);
  }
  // --- FIN DE LOGIQUE D'AUTHENTIFICATION ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 100), 

              // --- 1. Icône avec Effet de Lueur ---
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  alignment: Alignment.center,
                  // NOTE: AppTheme.glowingCircle est supposé exister dans config/app_theme.dart
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                       BoxShadow(
                        color: AppTheme.purpleAccent.withOpacity(0.35),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ), 
                  child: const Icon(
                    Icons.lock_outline,
                    size: 35,
                    color: AppTheme.textPrimary, 
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // --- 2. Titre et Sous-titre ---
              Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.headlineLarge, 
              ),
              const SizedBox(height: 5),
              Text(
                'Log in to manage campus infractions.',
                style: Theme.of(context).textTheme.bodyMedium, 
              ),
              const SizedBox(height: 40),

              // --- 3. Formulaire (Champs de Texte) ---
              Form(
                child: Column(
                  children: [
                    // Champ Email
                    TextFormField(
                      controller: _emailController, 
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'Email Address',
                      ),
                      style: const TextStyle(color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 16),

                    // Champ Mot de Passe
                    TextFormField(
                      controller: _passwordController, 
                      obscureText: !_isPasswordVisible, 
                      decoration: InputDecoration( 
                        hintText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: AppTheme.textSecondary,
                            ),
                            onPressed: () {
                              setState(() { 
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                      ),
                      style: const TextStyle(color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // --- 4. Liens Mot de Passe Oublié et Sécurité ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () { /* TODO: Naviguer vers ForgotPasswordScreen */ },
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(color: AppTheme.purpleAccent),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: AppTheme.cyanAccent, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        'Secure',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.cyanAccent,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // --- 5. Bouton de Connexion (Intégration du chargement et du onPressed) ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // Désactive le bouton si _isLoading est vrai
                  onPressed: _isLoading ? null : _handleLogin, 
                  child: _isLoading
                      // RETRAIT DU MOT-CLÉ CONST ICI (dans le CircularProgressIndicator)
                      ? SizedBox( 
                          width: 24, 
                          height: 24,
                          child: CircularProgressIndicator(
                            // Si AppTheme.backgroundPrimary n'existe pas, il faut le vérifier dans app_theme.dart
                            color: AppTheme.backgroundPrimary, 
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Login'),
                ),
              ),
              const SizedBox(height: 100),

              // --- 6. Pied de Page (Support) ---
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Need help? ',
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Contact Support',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.purpleAccent,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
