# 🌍 Guide d'Intégration du Système Multilingue

## Vue d'ensemble

Ce guide montre comment intégrer le système multilingue (English/Français) dans votre application Flutter et votre backend Spring Boot.

---

## 📱 FLUTTER - Comment Utiliser les Traductions

### 1️⃣ **Afficher des Chaînes Traduites dans un Widget**

#### Méthode Simple (Pour les widgets sans ConsumerWidget)
```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Obtenir la chaîne traduite
    final appLocalizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations!.appTitle),
      ),
      body: Center(
        child: Text(appLocalizations.welcome),
      ),
    );
  }
}
```

#### Méthode avec ConsumerWidget (Avec Riverpod)
```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations!.appTitle),
      ),
    );
  }
}
```

---

### 2️⃣ **Ajouter de Nouvelles Traductions**

1. **Ouvrez le fichier `lib/l10n/app_en.arb`** (traductions anglaises)
2. **Ajoutez votre clé :**
```json
{
  "hello": "Hello",
  "goodbye": "Goodbye",
  "myNewString": "My new translated string"
}
```

3. **Ouvrez le fichier `lib/l10n/app_fr.arb`** (traductions françaises)
4. **Ajoutez la même clé en français :**
```json
{
  "hello": "Bonjour",
  "goodbye": "Au revoir",
  "myNewString": "Ma nouvelle chaîne traduite"
}
```

5. **Exécutez :**
```bash
cd frontend
flutter pub get
```

Flutter génère automatiquement le code localisé 🎉

6. **Utilisez votre nouvelle chaîne :**
```dart
Text(AppLocalizations.of(context)!.myNewString)
```

---

### 3️⃣ **Changement de Langue (Language Switcher)**

Le language switcher est déjà intégré dans l'AppBar de welcome_screen. Voici comment ça fonctionne:

```dart
// Dans welcome_screen.dart
appBar: AppBar(
  actions: const [
    LanguageSwitcher(),  // ← Bouton de changement de langue
    SizedBox(width: 16),
  ],
),
```

Le `LanguageSwitcher` est défini dans `lib/widgets/language_switcher.dart` et utilise le provider:

```dart
class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider);

    return PopupMenuButton<String>(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(
            locale.languageCode.toUpperCase(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      onSelected: (language) {
        ref.read(languageProvider.notifier).setLanguageCode(language);
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(value: 'en', child: Text('🇬🇧 English')),
        PopupMenuItem(value: 'fr', child: Text('🇫🇷 Français')),
      ],
    );
  }
}
```

---

### 4️⃣ **Exemple Complet: Écran de Connexion Multilingue**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = AppLocalizations.of(context)!;
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.signIn),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Email Field
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: appLocalizations.email,
                hintText: appLocalizations.email,
              ),
            ),
            const SizedBox(height: 16),
            
            // Password Field
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: appLocalizations.password,
                hintText: appLocalizations.password,
              ),
            ),
            const SizedBox(height: 24),
            
            // Sign In Button
            ElevatedButton(
              onPressed: () {
                // Logique de connexion
                print('${appLocalizations.signIn}: ${emailController.text}');
              },
              child: Text(appLocalizations.signIn),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🔙 Backend Spring Boot - Comment Utiliser les Traductions

### 1️⃣ **Récupérer un Message Traduit dans un Service**

```java
import com.uvillage.infractions.util.MessageUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class MyService {
    
    @Autowired
    private MessageUtil messageUtil;
    
    public void doSomething() {
        // Récupérer un message en fonction de la langue Accept-Language
        String successMessage = messageUtil.getMessage("user.login.success");
        
        // Avec des paramètres
        String userNotFoundMessage = messageUtil.getMessage(
            "user.not.found", 
            new Object[]{"john@example.com"}
        );
    }
}
```

### 2️⃣ **Utiliser dans un Contrôleur**

```java
import com.uvillage.infractions.util.MessageUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    
    @Autowired
    private AuthService authService;
    
    @Autowired
    private MessageUtil messageUtil;
    
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        try {
            LoginResponse response = authService.authenticateUser(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            String errorMessage = messageUtil.getMessage("error.internal.server");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(new ErrorResponse(errorMessage));
        }
    }
}
```

### 3️⃣ **Comment le Backend Détecte la Langue**

Le backend utilise automatiquement le header **Accept-Language** de la requête HTTP:

```
GET /api/contraventions HTTP/1.1
Accept-Language: fr
```

**Correspondance des langues :**
- `Accept-Language: en` → Messages du fichier `messages.properties`
- `Accept-Language: fr` → Messages du fichier `messages_fr.properties`
- Pas de header ou langue non supportée → Par défaut `messages.properties` (English)

### 4️⃣ **Ajouter de Nouveaux Messages (Backend)**

1. **Ouvrez `src/main/resources/messages.properties`** (English)
2. **Ajoutez :**
```properties
my.new.message=This is my new message
my.error.message=An error occurred: {0}
```

3. **Ouvrez `src/main/resources/messages_fr.properties`** (Français)
4. **Ajoutez :**
```properties
my.new.message=Ceci est mon nouveau message
my.error.message=Une erreur s'est produite: {0}
```

5. **Utilisez dans votre code :**
```java
String message = messageUtil.getMessage("my.new.message");
String errorMsg = messageUtil.getMessage("my.error.message", new Object[]{"quelque chose"});
```

---

## ✅ Exemple Complet: Intégration Frontend ↔️ Backend

### Client Flutter envoie une requête avec langue:
```dart
final response = await http.post(
  Uri.parse('http://127.0.0.1:8080/api/auth/login'),
  headers: {
    'Content-Type': 'application/json',
    'Accept-Language': locale.languageCode,  // "en" ou "fr"
  },
  body: jsonEncode({
    'email': email,
    'password': password,
  }),
);
```

### Backend retourne un message traduit:
```json
{
  "token": "eyJhbGc...",
  "email": "user@example.com",
  "nomComplet": "Jean Dupont",
  "message": "Connexion réussie"  // Traduit en français!
}
```

---

## 📝 Vérification Checklist

- ✅ L'app Flutter démarre sans erreur
- ✅ Le bouton de langue (EN/FR) apparaît dans l'AppBar
- ✅ Les textes changent quand on change de langue
- ✅ Le backend reçoit le header Accept-Language
- ✅ Les messages API sont en français/anglais selon Accept-Language
- ✅ Les fichiers .arb et .properties sont synchro (mêmes clés)

---

## 🐛 Problèmes Courants et Solutions

### Problème: "AppLocalizations.of(context) returns null"
**Solution:** Assurez-vous que `localizationsDelegates` est configuré dans main.dart:
```dart
localizationsDelegates: const [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
],
supportedLocales: const [
  Locale('en'),
  Locale('fr'),
],
```

### Problème: La langue ne change pas
**Solution:** Assurez-vous que:
1. Vous utilisez `ConsumerWidget` et `ref.watch(languageProvider)`
2. main.dart a `locale: locale` dans MaterialApp
3. Exécutez `flutter pub get` après les changements

### Problème: Les messages du backend sont toujours en anglais
**Solution:** Vérifiez que:
1. MessageUtil est injecté dans votre service
2. Le client Flutter envoie `Accept-Language` header
3. Les clés de message existent dans `messages.properties` et `messages_fr.properties`

---

## 📚 Fichiers Importants

| Fichier | Utilisation |
|---------|------------|
| `lib/l10n/app_en.arb` | Traductions Flutter - Anglais |
| `lib/l10n/app_fr.arb` | Traductions Flutter - Français |
| `lib/providers/language_provider.dart` | État de la langue avec Riverpod |
| `lib/widgets/language_switcher.dart` | UI pour changer de langue |
| `lib/main.dart` | Configuration des locales |
| `src/main/resources/messages.properties` | Traductions Backend - Anglais |
| `src/main/resources/messages_fr.properties` | Traductions Backend - Français |
| `src/main/java/.../config/I18nConfiguration.java` | Config Spring i18n |
| `src/main/java/.../util/MessageUtil.java` | Utilitaire pour récupérer messages |

---

## 🚀 Prochaines Étapes

1. **Appliquer traductions à tous les écrans** (sign_in, sign_up, dashboard, etc.)
2. **Persister la langue** avec Hive (SaveLanguagePreference dans language_provider.dart)
3. **Tester avec différentes locales** navigateur/téléphone
4. **Traduire les messages d'erreur** de validation formulaire
5. **Ajouter plus de langues** (Arabe, Espagnol, etc.) en répétant le pattern

---

**✨ Système multilingue prêt! Bonne chance! 🎉**
