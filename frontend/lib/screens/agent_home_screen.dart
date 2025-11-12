import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // NÉCESSAIRE
import '../config/app_theme.dart'; // Chemin corrigé
import '../models/contravention_model.dart';
import '../providers/contravention_provider.dart'; // NÉCESSAIRE
import '../providers/agent_auth_provider.dart';
import '../providers/history_provider.dart';


// L'écran doit être un ConsumerWidget pour utiliser Riverpod
class AgentHomeScreen extends ConsumerWidget {
  const AgentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Dans le Widget build de AgentHomeScreen

// 💡 L'appel est correct car agentNameProvider retourne un String
final agentName = ref.watch(agentNameProvider); 
final agentRowid = ref.watch(currentAgentIdProvider);
final statsAsync = ref.watch(agentStatsProvider);
final historyAsync = ref.watch(agentHistoryProvider(agentRowid));

    return Scaffold(
      appBar: _buildAppBar(agentName, context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[ // Correction: explicite le type
            // (debug button removed)
            // Cartes Statistiques
            Builder(
              builder: (context) {
                return statsAsync.when(
                  loading: () => Row(children: [Expanded(child: StatCard(count: 0, label: "Aujourd'hui", subLabel: "...", startColor: AppTheme.purpleAccent, endColor: AppTheme.cyanAccent)), const SizedBox(width: 16), Expanded(child: StatCard(count: 0, label: "Cette semaine", subLabel: "...", startColor: AppTheme.pinkAccent, endColor: AppTheme.purpleAccent))]),
                  error: (err, stack) => Center(child: Text('Erreur Stats: ${err.toString().split(':').last}', style: const TextStyle(color: AppTheme.errorRed, fontSize: 12))),
                  data: (stats) {
                    final todayCount = stats['todayCount'] ?? 0;
                    final weekCount = stats['weekCount'] ?? 0;
                    return Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            count: todayCount,
                            label: "Aujourd'hui",
                            subLabel: '$todayCount infractions',
                            startColor: AppTheme.purpleAccent,
                            endColor: AppTheme.cyanAccent,
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: StatCard(
                            count: weekCount,
                            label: "Cette semaine",
                            subLabel: '$weekCount infractions',
                            startColor: AppTheme.pinkAccent,
                            endColor: AppTheme.purpleAccent,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 32.0),

            // Titre de l'historique
            Text(
              'Mes dernières infractions',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20),
            ),

            const SizedBox(height: 16.0),

            // Liste des Infractions
            Builder(
              builder: (context) {
                return historyAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.purpleAccent)),
                  error: (err, stack) => Center(child: Text('Erreur Historique: ${err.toString().split(':').last}', style: const TextStyle(color: AppTheme.errorRed))),
                  data: (infractions) {
                    if (infractions.isEmpty) {
                      return const Center(child: Text("Aucune infraction enregistrée.", style: TextStyle(color: AppTheme.textSecondary)));
                    }
                    return Column(
                      children: infractions.map((infraction) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: InfractionListItem(infraction: infraction),
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AgentBottomNavBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildNewInfractionButton(context),
    );
  }
}

// Les composants (StatCard, InfractionListItem, etc.) sont les mêmes que précédemment
// pour éviter la répétition excessive du code, veuillez les réutiliser du code fourni
// dans la réponse précédente (`AgentHomeScreen` en mode simulation) et ajouter 
// l'argument `icon: Icons.XXX` manquant à `StatCard`. 

// --- APPARTIENT À agent_home_screen.dart (Les composants) ---

PreferredSizeWidget _buildAppBar(String agentName, BuildContext context) {
  return AppBar(
    automaticallyImplyLeading: false,
    title: Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppTheme.borderColor,
          child: Text(agentName.isNotEmpty ? agentName[0].toUpperCase() : 'A', 
            style: const TextStyle(color: AppTheme.textPrimary)), 
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bonjour, ${agentName.split(' ').first}', 
              style: Theme.of(context).textTheme.bodyLarge),
            Row(
              children: [
                Container(
                  width: 6.0,
                  height: 6.0,
                  decoration: const BoxDecoration(
                    color: AppTheme.successGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4.0),
                const Text(
                  'En ligne',
                  style: TextStyle(
                    color: AppTheme.successGreen,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.notifications_none),
        onPressed: () {},
      ),
    ],
  );
}

class StatCard extends StatelessWidget {
  // L'icône est retirée du corps, mais conservée pour éviter des erreurs si un 
  // appel l'utilise. Cependant, le count est affiché.
  final IconData? icon; 
  final int count;
  final String label;
  final String subLabel;
  final Color startColor;
  final Color endColor;

  const StatCard({
    super.key,
    this.icon, // Optionnel car l'image affiche le count
    required this.count,
    required this.label,
    required this.subLabel,
    required this.startColor,
    required this.endColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppTheme.darkBgAlt, 
        border: Border.all(color: startColor.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: [startColor, endColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const Spacer(),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            subLabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class InfractionListItem extends StatelessWidget {
  final ContraventionModel infraction;

  const InfractionListItem({
    super.key,
    required this.infraction,
  });

  @override
  Widget build(BuildContext context) {
    final purpleAccent = AppTheme.purpleAccent;
    final successGreen = AppTheme.successGreen;
    final textSecondary = AppTheme.textSecondary;

    final (color, icon, statusText) = getStatusPresentation(
      infraction.statut, 
      purpleAccent: purpleAccent, 
      successGreen: successGreen, 
      textSecondary: textSecondary,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkBgAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          infraction.titre,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$statusText | ${infraction.dateHeure} | ${infraction.residentNom}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: AppTheme.textSecondary,
          size: 16,
        ),
        onTap: () {
          // Logique de navigation
        },
      ),
    );
  }
}

Widget _buildNewInfractionButton(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      gradient: AppTheme.buttonGradient, 
      boxShadow: [
        BoxShadow(
          color: AppTheme.purpleAccent.withOpacity(0.5),
          blurRadius: 10,
          spreadRadius: 1,
        ),
      ],
    ),
    child: FloatingActionButton.extended(
      onPressed: () {
        // Logique pour la création
      },
      label: const Text('Nouvelle Infraction'),
      icon: const Icon(Icons.add),
      backgroundColor: Colors.transparent, 
      foregroundColor: AppTheme.textPrimary,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    ),
  );
}

class AgentBottomNavBar extends StatelessWidget {
  const AgentBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    const int currentIndex = 0; 
    return BottomAppBar(
      color: AppTheme.darkBg,
      surfaceTintColor: Colors.transparent, 
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        height: 60.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(context, Icons.home, 'Home', 0, currentIndex),
            _buildNavItem(context, Icons.list_alt, 'Infractions', 1, currentIndex),
            const SizedBox(width: 60), 
            _buildNavItem(context, Icons.bar_chart, 'Statistiques', 2, currentIndex),
            _buildNavItem(context, Icons.person, 'Profil', 3, currentIndex),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index, int currentIndex) {
    final bool isActive = index == currentIndex;
    Color iconColor = isActive ? AppTheme.purpleAccent : AppTheme.textSecondary;
    Color labelColor = isActive ? AppTheme.purpleAccent : AppTheme.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: () {
          // Logique de navigation 
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor),
            Text(
              label,
              style: TextStyle(color: labelColor, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

// debugPrintToken removed — token is handled securely by the ApiClient and
// authentication flow. Remove this helper when no longer needed.