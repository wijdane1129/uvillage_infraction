// Fichier : lib/screens/agent_infraction_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_theme.dart';

// Utilisation de ConsumerWidget car il aura besoin de Riverpod pour la soumission des données
class AgentInfractionScreen extends ConsumerWidget {
  const AgentInfractionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Clé pour valider le formulaire (nécessaire si c'est un StatefulWidget, mais on peut l'utiliser ici avec des callbacks)
    // Pour simplifier, nous utilisons un StatelessWidget de base pour l'instant.
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle Contravention'),
        backgroundColor: AppTheme.darkBgAlt,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enregistrer une nouvelle infraction',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // --- Section 1: Informations de base (Date, Réf.) ---
            _buildSectionTitle(context, 'Détails de l\'Infraction'),
            const SizedBox(height: 10),
            
            // Exemple d'un champ de formulaire
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Référence de la Contravention',
                hintText: 'Ex: C0001',
                prefixIcon: Icon(Icons.numbers),
              ),
              // Ici, vous ajouterez le contrôleur pour récupérer la valeur
              // validator: (value) { /* ... */ },
            ),
            const SizedBox(height: 15),

            // --- Section 2: Tiers/Résident Concerné ---
            _buildSectionTitle(context, 'Tiers/Résident'),
            const SizedBox(height: 10),

            // Champ de sélection du résident/tiers
            // TextFormField pour la recherche ou un DropdownButton (DropdownButtonFormField)
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nom du Résident / Tiers',
                hintText: 'Rechercher par nom ou CIN',
                prefixIcon: Icon(Icons.person_search),
              ),
            ),
            const SizedBox(height: 15),

            // --- Section 3: Type de Contravention ---
            _buildSectionTitle(context, 'Type de Contravention'),
            const SizedBox(height: 10),

            // Champ de sélection du type de contravention (Dropdown)
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Sélectionner le Type',
                prefixIcon: Icon(Icons.gavel),
              ),
            ),
            const SizedBox(height: 40),
            
            // Bouton de Soumission
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implémenter la logique de soumission du formulaire
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Formulaire soumis (Logique à implémenter)')),
                  );
                },
                icon: const Icon(Icons.send),
                label: const Text('Enregistrer la Contravention'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: AppTheme.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Fonction utilitaire pour les titres de section
Widget _buildSectionTitle(BuildContext context, String title) {
  return Text(
    title,
    style: Theme.of(context).textTheme.titleLarge?.copyWith(
      color: AppTheme.purpleAccent,
      fontWeight: FontWeight.w600,
    ),
  );
}