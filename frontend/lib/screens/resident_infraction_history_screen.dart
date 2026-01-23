import 'package:flutter/material.dart';
import '../models/resident_models.dart';

class ResidentInfractionHistoryScreen extends StatelessWidget {
  final Resident resident;

  const ResidentInfractionHistoryScreen({
    super.key,
    required this.resident,
  });

  // Données mockées des infractions
  final List<Map<String, dynamic>> _mockInfractions = const [
    {
      'id': 1,
      'motif': 'Bruit nocturne',
      'date': '15 Oct. 2023',
      'heure': '23:45',
      'montant': 50,
      'statut': 'Recidive',
      'paiement': 'Impayée',
      'description': 'Bruit excessif signalé par les voisins',
    },
    {
      'id': 2,
      'motif': 'Cigarette en chambre',
      'date': '02 Sep. 2023',
      'heure': '18:20',
      'montant': 100,
      'statut': 'Recidive',
      'paiement': 'Payée',
      'description': 'Violation du règlement anti-tabac',
    },
    {
      'id': 3,
      'motif': 'Poubelles non sorties',
      'date': '18 Aug. 2023',
      'heure': '09:00',
      'montant': 25,
      'statut': 'Normal',
      'paiement': 'Payée',
      'description': 'Déchets dans le couloir',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique Résident - ${resident.fullName}'),
        backgroundColor: const Color(0xFF1a1a2e),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
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
                border: Border.all(
                  color: Colors.grey[700]!,
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  // Avatar
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
                      child: Icon(
                        resident.sexe == 'M' ? Icons.person : Icons.person,
                        size: 40,
                        color: const Color(0xFF00d4ff),
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
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[400],
                          ),
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

            // Statistiques d'infractions
            _buildStatisticsCards(),
            const SizedBox(height: 24),

            // Récidives par motif
            _buildRecidivesByReason(),
            const SizedBox(height: 24),

            // Timeline des infractions
            Text(
              'Timeline des infractions',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            ..._buildInfractionTimeline(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards() {
    final totalInfractions = _mockInfractions.length;
    final totalFines = _mockInfractions.fold<double>(
      0,
      (sum, inf) => sum + (inf['montant'] as num),
    );
    final paidFines = _mockInfractions
        .where((inf) => inf['paiement'] == 'Payée')
        .fold<double>(0, (sum, inf) => sum + (inf['montant'] as num));
    final unpaidFines = totalFines - paidFines;

    return Row(
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
            value: '€${totalFines.toStringAsFixed(0)}',
            color: Colors.red,
            icon: Icons.euro,
          ),
        ),
      ],
    );
  }

  Widget _buildRecidivesByReason() {
    final recidives = _mockInfractions
        .where((inf) => inf['statut'] == 'Recidive')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Récidives par motif',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: recidives
              .map((inf) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.warning,
                          size: 16,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${inf['motif']} (${recidives.where((r) => r['motif'] == inf['motif']).length}x)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  List<Widget> _buildInfractionTimeline() {
    return _mockInfractions.asMap().entries.map((entry) {
      final index = entry.key;
      final infraction = entry.value;
      final isLast = index == _mockInfractions.length - 1;

      final paymentColor = infraction['paiement'] == 'Payée'
          ? Colors.green
          : Colors.red;
      final paymentIcon = infraction['paiement'] == 'Payée'
          ? Icons.check_circle
          : Icons.cancel;

      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF16213e),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[700]!,
                width: 0.5,
              ),
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
                            infraction['motif'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${infraction['date']} - ${infraction['heure']}',
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
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            infraction['statut'],
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '€${infraction['montant']}',
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
                const SizedBox(height: 12),
                Text(
                  infraction['description'],
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          paymentIcon,
                          size: 18,
                          color: paymentColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          infraction['paiement'],
                          style: TextStyle(
                            fontSize: 13,
                            color: paymentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00d4ff),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Voir détail',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!isLast) ...[
            const SizedBox(height: 12),
          ],
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
        border: Border.all(
          color: Colors.grey[700]!,
          width: 0.5,
        ),
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
              Icon(
                icon,
                size: 20,
                color: color,
              ),
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
