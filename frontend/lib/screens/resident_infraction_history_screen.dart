import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/resident_models.dart';
import '../providers/contraventions_provider.dart';

class ResidentInfractionHistoryScreen extends ConsumerWidget {
  final Resident resident;

  const ResidentInfractionHistoryScreen({super.key, required this.resident});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contraventionsAsync = ref.watch(
      residentContraventionsProvider(resident.id),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Historique - ${resident.fullName}'),
        backgroundColor: const Color(0xFF1a1a2e),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: contraventionsAsync.when(
        data: (contraventions) => _buildBody(context, contraventions),
        loading:
            () => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00d4ff)),
              ),
            ),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Erreur de chargement',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    List<Map<String, dynamic>> contraventions,
  ) {
    final totalInfractions = contraventions.length;
    final totalFines = contraventions.fold<double>(
      0,
      (sum, inf) => sum + ((inf['montant'] as num?)?.toDouble() ?? 0),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête du résident
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF16213e),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[700]!, width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00d4ff),
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[700],
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Color(0xFF00d4ff),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resident.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Chambre ${resident.batiment}-${resident.numeroChambre}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          resident.statutPaiement,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Statistiques
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Total Infractions',
                  value: totalInfractions.toString(),
                  color: Colors.orange,
                  icon: Icons.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Total Amendes',
                  value: '${totalFines.toStringAsFixed(0)} DH',
                  color: Colors.red,
                  icon: Icons.euro,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Timeline des infractions
          const Text(
            'Timeline des infractions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          if (contraventions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 48,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Aucune contravention',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._buildInfractionTimeline(contraventions),
        ],
      ),
    );
  }

  List<Widget> _buildInfractionTimeline(
    List<Map<String, dynamic>> contraventions,
  ) {
    return contraventions.asMap().entries.map((entry) {
      final index = entry.key;
      final infraction = entry.value;
      final isLast = index == contraventions.length - 1;

      final statut = infraction['statut'] as String? ?? '';
      final paymentColor = statut == 'Payée' ? Colors.green : Colors.red;
      final paymentIcon = statut == 'Payée' ? Icons.check_circle : Icons.cancel;

      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF16213e),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[700]!, width: 0.5),
            ),
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
                            infraction['motif'] ?? 'Sans motif',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            infraction['date'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: paymentColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            statut,
                            style: TextStyle(
                              fontSize: 11,
                              color: paymentColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${infraction['montant'] ?? 0} DH',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (infraction['description'] != null &&
                    (infraction['description'] as String).isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    infraction['description'],
                    style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(paymentIcon, size: 18, color: paymentColor),
                    const SizedBox(width: 6),
                    Text(
                      statut,
                      style: TextStyle(
                        fontSize: 13,
                        color: paymentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!isLast) const SizedBox(height: 12),
        ],
      );
    }).toList();
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, size: 20, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
