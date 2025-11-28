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
import 'screens/contravention_details_screen.dart';
import 'models/contravention_models.dart';
import 'screens/accepter_contravention_screen.dart';
import 'screens/classer_sans_suite_screen.dart';

void main() {
  // Wrap the app with ProviderScope so Riverpod providers work
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample contravention to show the details screen when launching the app
    final sample = Contravention(
      rowid: 1,
      description: 'Stationnement interdit sur trottoir',
      media: [
        ContraventionMediaModels(
          id: 1,
          mediaUrl: 'https://via.placeholder.com/300',
          mediaType: 'image',
        ),
        ContraventionMediaModels(
          id: 2,
          mediaUrl:
              'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
          mediaType: 'video',
        ),
      ],
      status: 'SOUS_VERIFICATION',
      dateTime: DateTime.now().toIso8601String(),
      ref: 'REF-12345',
      userAuthor: 'agent@example.com',
      tiers: 'Resident A',
      motif: 'Obstruction de la voie',
    );

    return MaterialApp(
      title: 'Infractions App',
      theme: ThemeData.dark(),
      home: ContraventionDetailsScreen(contravention: sample),
    );
  }
}
