import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // NÉCESSAIRE
import '../config/app_theme.dart'; // Chemin corrigé
import '../models/contravention_model.dart';
import '../providers/contravention_provider.dart'; // NÉCESSAIRE
import '../providers/agent_auth_provider.dart';
import '../providers/history_provider.dart';
import '../models/resident_model.dart';
import '../services/resident_mock_service.dart';
import '../widgets/gradient_button.dart';
import '../widgets/sync_status_indicator.dart';
import 'contravention_step2.dart';
import 'User_profile.dart';
import '../gen_l10n/app_localizations.dart';
import '../widgets/language_switcher.dart';
// Note: we avoid importing the original `agent_infraction_screen.dart` here
// to prevent the earlier compiler/resolution issue. A local copy of the
// screen and small helper widgets are provided below.

// L'écran doit être un ConsumerStatefulWidget pour utiliser Riverpod avec lifecycle
class AgentHomeScreen extends ConsumerStatefulWidget {
  const AgentHomeScreen({super.key});

  @override
  ConsumerState<AgentHomeScreen> createState() => _AgentHomeScreenState();
}

class _AgentHomeScreenState extends ConsumerState<AgentHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Start auto-refresh of history and stats every 15 seconds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(historyRefreshControllerProvider.notifier).startAutoRefresh();
    });
  }

  @override
  void dispose() {
    // Note: Cannot use 'ref' in dispose() for ConsumerStatefulWidget
    // Async tasks should auto-cancel when widget disposes
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
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
          children: <Widget>[
            // Sync Status Indicator
            const SyncStatusIndicator(),
            const SizedBox(height: 16.0),
            
            // Correction: explicite le type
            // (debug button removed)
            // Cartes Statistiques
            Builder(
              builder: (context) {
                return statsAsync.when(
                  loading:
                      () => Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              count: 0,
                              label: locale!.today,
                              subLabel: "...",
                              startColor: AppTheme.purpleAccent,
                              endColor: AppTheme.cyanAccent,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: StatCard(
                              count: 0,
                              label: locale.thisWeek,
                              subLabel: "...",
                              startColor: AppTheme.pinkAccent,
                              endColor: AppTheme.purpleAccent,
                            ),
                          ),
                        ],
                      ),
                  error:
                      (err, stack) => Center(
                        child: Text(
                          'Erreur Stats: ${err.toString().split(':').last}',
                          style: const TextStyle(
                            color: AppTheme.errorRed,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  data: (stats) {
                    final todayCount = stats['todayCount'] ?? 0;
                    final weekCount = stats['weekCount'] ?? 0;
                    return Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            count: todayCount,
                            label: locale!.today,
                            subLabel: '$todayCount ${locale.infractions}',
                            startColor: AppTheme.purpleAccent,
                            endColor: AppTheme.cyanAccent,
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: StatCard(
                            count: weekCount,
                            label: locale.thisWeek,
                            subLabel: '$weekCount ${locale.infractions}',
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
              locale!.myLatestInfractions,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontSize: 20),
            ),

            const SizedBox(height: 16.0),

            // Liste des Infractions
            Builder(
              builder: (context) {
                return historyAsync.when(
                  loading:
                      () => const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.purpleAccent,
                        ),
                      ),
                  error:
                      (err, stack) => Center(
                        child: Text(
                          'Erreur Historique: ${err.toString().split(':').last}',
                          style: const TextStyle(color: AppTheme.errorRed),
                        ),
                      ),
                  data: (infractions) {
                    if (infractions.isEmpty) {
                      return const Center(
                        child: Text(
                          "Aucune infraction enregistrée.",
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      );
                    }
                    return Column(
                      children:
                          infractions.map((infraction) {
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
  final locale = AppLocalizations.of(context)!;
  return AppBar(
    automaticallyImplyLeading: false,
    title: Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppTheme.borderColor,
          child: Text(
            agentName.isNotEmpty ? agentName[0].toUpperCase() : 'A',
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${locale.hello}, ${agentName.split(' ').first}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
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
                Text(
                  locale.online,
                  style: const TextStyle(
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
    actions: const [LanguageSwitcher()],
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
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            subLabel,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class InfractionListItem extends StatelessWidget {
  final ContraventionModel infraction;

  const InfractionListItem({super.key, required this.infraction});

  @override
  Widget build(BuildContext context) {
    final purpleAccent = AppTheme.purpleAccent;
    final successGreen = AppTheme.successGreen;
    final textSecondary = AppTheme.textSecondary;

    final pres = getStatusPresentation(
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
            color: pres.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(pres.icon, color: pres.color, size: 24),
        ),
        title: Text(
          infraction.titre,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${pres.statusText} | ${infraction.dateHeure} | ${infraction.residentNom}',
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
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AgentInfractionScreenLocal()),
        );
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

            const SizedBox(width: 60),

            _buildNavItem(context, Icons.person, 'Profil', 3, currentIndex),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
    int currentIndex,
  ) {
    final bool isActive = index == currentIndex;
    Color iconColor = isActive ? AppTheme.purpleAccent : AppTheme.textSecondary;
    Color labelColor =
        isActive ? AppTheme.purpleAccent : AppTheme.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: () {
          // Navigation logic based on index
          if (index == 3) {
            // Profile tab
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor),
            Text(label, style: TextStyle(color: labelColor, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

// debugPrintToken removed — token is handled securely by the ApiClient and
// authentication flow. Remove this helper when no longer needed.

// --- Minimal helper widgets used by the local infraction screen ---
class ResidentCard extends StatelessWidget {
  final String fullName;
  final String roomInfo;
  const ResidentCard({
    super.key,
    required this.fullName,
    required this.roomInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.darkBgAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppTheme.purpleAccent,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(roomInfo, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomDropdownField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String hint;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.icon,
    this.value,
    required this.items,
    required this.onChanged,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.darkBgAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          icon: Icon(icon, color: AppTheme.textSecondary),
        ),
        dropdownColor: AppTheme.darkBgAlt,
        items:
            items
                .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class RoomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String hint;
  const RoomInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkBgAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.text,
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          icon: Icon(icon, color: AppTheme.textSecondary),
          hintText: hint,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Local copy of the Infraction screen (temporary, avoids cross-file issues)
// -----------------------------------------------------------------------------
class AgentInfractionScreenLocal extends ConsumerStatefulWidget {
  const AgentInfractionScreenLocal({super.key});

  @override
  ConsumerState<AgentInfractionScreenLocal> createState() =>
      _AgentInfractionScreenLocalState();
}

class _AgentInfractionScreenLocalState
    extends ConsumerState<AgentInfractionScreenLocal> {
  final TextEditingController roomController = TextEditingController();
  ResidentModel? foundResident;
  bool isSearching = false;
  String? selectedBuilding;
  String? selectedMotif;

  @override
  void dispose() {
    roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final motifsAsync = ref.watch(contraventionTypeLabelsProvider);
    const List<String> buildings = [
      'Immeuble A',
      'Immeuble B',
      'Immeuble C',
      'Immeuble D',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Infraction Form'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: 1 / 3,
            backgroundColor: AppTheme.darkBgAlt,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppTheme.purpleAccent,
            ),
          ),
        ),
        actions: const [
          LanguageSwitcher(),
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Étape 1/3',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.darkBgAlt,
                borderRadius: BorderRadius.circular(16),
              ),
              child: motifsAsync.when(
                data: (motifs) {
                  final uniqueMotifs =
                      motifs.toSet().where((e) => e.trim().isNotEmpty).toList();
                  String? motifValue = selectedMotif;
                  if (motifValue == null ||
                      !uniqueMotifs.contains(motifValue)) {
                    motifValue = null;
                  }
                  return CustomDropdownField(
                    label: 'Motif de l\'infraction',
                    icon: Icons.warning_amber,
                    hint: 'Sélectionner un motif',
                    items: uniqueMotifs,
                    value: motifValue,
                    onChanged: (newValue) {
                      setState(() {
                        selectedMotif = newValue;
                      });
                      debugPrint('Motif sélectionné: $newValue');
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Erreur chargement motifs: $e'),
              ),
            ),

            const SizedBox(height: 32.0),

            Text(
              locale!.identifyResident,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),

            RoomInputField(
              controller: roomController,
              label: locale.roomNumber,
              icon: Icons.numbers,
              hint: locale.roomNumber,
            ),
            const SizedBox(height: 16.0),

            CustomDropdownField(
              label: locale.selectProperty,
              icon: Icons.apartment,
              hint: locale.selectProperty,
              items: buildings,
              onChanged: (newValue) {
                setState(() {
                  selectedBuilding = newValue;
                });
                debugPrint('Immeuble sélectionné: $newValue');
              },
            ),

            const SizedBox(height: 16.0),

            GradientButton(
              onPressed: () async {
                final query = roomController.text.trim();
                if (query.isEmpty) return;
                setState(() {
                  isSearching = true;
                  foundResident = null;
                });

                ResidentModel? r;
                if (selectedBuilding != null &&
                    selectedBuilding!.trim().isNotEmpty) {
                  r = await ResidentMockService.findByRoom(
                    query,
                    building: selectedBuilding,
                  );
                } else {
                  final all = await ResidentMockService.findAllByRoom(query);
                  if (all.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Aucun résident trouvé pour ce numéro'),
                      ),
                    );
                  } else if (all.length > 1) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Plusieurs résidents trouvés: précisez l\'immeuble',
                        ),
                      ),
                    );
                    r = null;
                  } else {
                    r = all.first;
                  }
                }

                setState(() {
                  foundResident = r;
                  isSearching = false;
                });
              },
              text: isSearching ? '${locale.search}...' : locale.search,
              height: 55,
              radius: 12,
            ),

            const SizedBox(height: 20.0),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Résident inconnu / Non identifié',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                Switch(
                  value: false,
                  onChanged: (bool value) {
                    debugPrint('Résident inconnu: $value');
                  },
                  activeColor: AppTheme.purpleAccent,
                  inactiveThumbColor: AppTheme.borderColor,
                ),
              ],
            ),
            const SizedBox(height: 12.0),

            if (foundResident != null)
              ResidentCard(
                fullName: foundResident!.fullName,
                roomInfo:
                    '${foundResident!.batiment} - Chambre ${foundResident!.numeroChambre}',
              ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GradientButton(
          onPressed: () {
            // Require motif selection before navigating to step 2
            if (selectedMotif == null || selectedMotif!.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Le choix du motif est obligatoire pour continuer',
                  ),
                ),
              );
              return;
            }

            // LOGIQUE DE NAVIGATION ICI
            Navigator.push(
              context,
              MaterialPageRoute(
                // La destination est la page de connexion
                builder:
                    (context) => ContraventionStep2Screen(
                      motif: selectedMotif,
                      resident: foundResident,
                    ),
              ),
            );
          },
          text: locale.next,
          height: 60,
        ),
      ),
    );
  }
}
