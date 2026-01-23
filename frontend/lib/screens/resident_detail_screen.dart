import 'package:flutter/material.dart';
import '../models/resident_models.dart';
import 'resident_infraction_history_screen.dart';

class ResidentDetailScreen extends StatelessWidget {
  final Resident resident;

  const ResidentDetailScreen({
    super.key,
    required this.resident,
  });

  @override
  Widget build(BuildContext context) {
    final paymentColor = resident.statutPaiement == 'Payé'
        ? Colors.green
        : Colors.orange;

    return Scaffold(
      appBar: AppBar(
        title: Text(resident.fullName),
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
            // En-tête avec infos principales
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            resident.fullName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Chambre ${resident.batiment}-${resident.numeroChambre}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: paymentColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: paymentColor,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          resident.statutPaiement,
                          style: TextStyle(
                            fontSize: 14,
                            color: paymentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Informations personnelles
            _Section(
              title: 'Informations personnelles',
              children: [
                _InfoRow(label: 'Prénom', value: resident.prenom),
                _InfoRow(label: 'Nom', value: resident.nom),
                _InfoRow(label: 'Sexe', value: resident.sexe),
                _InfoRow(label: 'Filière', value: resident.filiere),
              ],
            ),
            const SizedBox(height: 24),

            // Informations de logement
            _Section(
              title: 'Logement',
              children: [
                _InfoRow(label: 'Bâtiment', value: resident.batiment),
                _InfoRow(label: 'Numéro Chambre', value: resident.numeroChambre),
                _InfoRow(label: 'Type de chambre', value: resident.typeChambre),
              ],
            ),
            const SizedBox(height: 24),

            // Dates
            _Section(
              title: 'Dates',
              children: [
                _InfoRow(label: 'Date d\'entrée', value: resident.dateEntree),
                _InfoRow(label: 'Date de sortie', value: resident.dateSortie),
              ],
            ),
            const SizedBox(height: 24),

            // Actions
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ResidentInfractionHistoryScreen(resident: resident),
                    ),
                  );
                },
                icon: const Icon(Icons.history),
                label: const Text('Voir l\'historique des infractions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00d4ff),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
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
            children: children,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
