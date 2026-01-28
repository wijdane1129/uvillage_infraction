import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/resident_provider.dart';
import '../providers/contraventions_provider.dart';
import '../models/resident_models.dart';
import '../gen_l10n/app_localizations.dart';

class ResidentsScreen extends ConsumerWidget {
  const ResidentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final residentsAsync = ref.watch(residentsListProvider);
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.residents),
        backgroundColor: const Color(0xFF1a1a2e),
        elevation: 0,
      ),
      body: residentsAsync.when(
        data: (residents) {
          if (residents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun résident trouvé',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: residents.length,
            itemBuilder: (context, index) {
              final resident = residents[index];

              return ResidentCardWithContraventionsAsync(
                resident: resident,
                locale: locale,
                onTap: () {
                  // Juste afficher les détails dans la carte
                },
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00d4ff)),
          ),
        ),
        error: (error, stack) => Center(
          child: Text('Erreur: $error'),
        ),
      ),
    );
  }
}

/// Version asynchrone qui charge les contraventions depuis l'API ou les mockées
class ResidentCardWithContraventionsAsync extends ConsumerWidget {
  final Resident resident;
  final AppLocalizations locale;
  final VoidCallback onTap;

  const ResidentCardWithContraventionsAsync({
    super.key,
    required this.resident,
    required this.locale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contraventionsAsync =
        ref.watch(residentContraventionsProvider(resident.id));

    return contraventionsAsync.when(
      data: (contraventions) {
        return ResidentCardWithContraventions(
          resident: resident,
          locale: locale,
          contraventions: contraventions,
          onTap: onTap,
        );
      },
      loading: () {
        return _buildLoadingCard();
      },
      error: (error, stack) {
        return ResidentCardWithContraventions(
          resident: resident,
          locale: locale,
          contraventions: [],
          onTap: onTap,
        );
      },
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade700,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resident.fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${resident.batiment}-${resident.numeroChambre}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00d4ff)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Affiche la carte avec les contraventions
class ResidentCardWithContraventions extends StatelessWidget {
  final Resident resident;
  final AppLocalizations locale;
  final List<Map<String, dynamic>> contraventions;
  final VoidCallback onTap;

  const ResidentCardWithContraventions({
    super.key,
    required this.resident,
    required this.locale,
    required this.contraventions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final paymentColor = resident.statutPaiement == 'Payé'
        ? Colors.green
        : Colors.orange;
    final paymentIcon = resident.statutPaiement == 'Payé'
        ? Icons.check_circle
        : Icons.schedule;

    // Calculer les statistiques
    final totalInfractions = contraventions.length;
    final unpaidCount =
        contraventions.where((c) => c['statut'] == 'Impayée').length;
    final totalAmount = contraventions.fold<double>(
        0, (sum, c) => sum + (c['montant'] as num).toDouble());

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF16213e),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade700,
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            // En-tête du résident
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              resident.fullName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${resident.batiment}-${resident.numeroChambre}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: paymentColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              paymentIcon,
                              size: 16,
                              color: paymentColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              resident.statutPaiement,
                              style: TextStyle(
                                fontSize: 12,
                                color: paymentColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Statistiques
                  Row(
                    children: [
                      Expanded(
                        child: _StatBadge(
                          label: 'Infractions',
                          value: totalInfractions.toString(),
                          color: Colors.orange,
                          icon: Icons.warning,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatBadge(
                          label: 'Impayées',
                          value: unpaidCount.toString(),
                          color: Colors.red,
                          icon: Icons.cancel,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatBadge(
                          label: 'Montant Total',
                          value: '€${totalAmount.toStringAsFixed(0)}',
                          color: Colors.red,
                          icon: Icons.euro,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Historique des contraventions
            if (contraventions.isNotEmpty) ...[
              Container(
                height: 1,
                color: Colors.grey.shade700,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${locale.infractions_history} (${contraventions.length})',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: contraventions
                          .asMap()
                          .entries
                          .map((entry) {
                            final infraction = entry.value;
                            final isLast = entry.key == contraventions.length - 1;
                            final statusColor =
                                infraction['statut'] == 'Payée'
                                    ? Colors.green
                                    : Colors.red;

                            return Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Indicateur de statut
                                    Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(top: 6),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: statusColor,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            infraction['motif'],
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            infraction['date'],
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '€${infraction['montant']}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                statusColor.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            infraction['statut'],
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: statusColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (!isLast) ...[
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 18),
                                    child: Container(
                                      height: 1,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ],
                            );
                          })
                          .toList(),
                    ),
                  ],
                ),
              ),
            ] else
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'Aucune contravention',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatBadge({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 13,
                color: color,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
