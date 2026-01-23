import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/resident_models.dart';
import '../providers/resident_provider.dart';
import '../providers/assignment_provider.dart';

class AssignContraventionScreen extends ConsumerStatefulWidget {
  final int contraventionId;
  final String motif;

  const AssignContraventionScreen({
    super.key,
    required this.contraventionId,
    required this.motif,
  });

  @override
  ConsumerState<AssignContraventionScreen> createState() =>
      _AssignContraventionScreenState();
}

class _AssignContraventionScreenState
    extends ConsumerState<AssignContraventionScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedResident = ref.watch(selectedResidentProvider);
    final filteredResidents = ref.watch(filteredResidentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Assigner: ${widget.motif}'),
        backgroundColor: const Color(0xFF1a1a2e),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barre de recherche
            TextField(
              controller: _searchController,
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: 'Rechercher un résident...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF00d4ff)),
                filled: true,
                fillColor: const Color(0xFF0f3460),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade700,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade700,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF00d4ff),
                    width: 2,
                  ),
                ),
                hintStyle: TextStyle(color: Colors.grey.shade500),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),

            // Liste des résidents
            Text(
              'Sélectionner un résident',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            filteredResidents.when(
              data: (residents) {
                if (residents.isEmpty) {
                  return Center(
                    child: Text(
                      'Aucun résident trouvé',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                      ),
                    ),
                  );
                }

                return Column(
                  children: residents
                      .map((resident) => _buildResidentCard(resident))
                      .toList(),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Color(0xFF00d4ff)),
                ),
              ),
              error: (error, stack) => Center(
                child: Text('Erreur: $error'),
              ),
            ),
            const SizedBox(height: 24),

            // Résident sélectionné
            if (selectedResident != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213e),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF00d4ff),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Résident sélectionné',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            selectedResident.fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${selectedResident.batiment}-${selectedResident.numeroChambre}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        ref.read(selectedResidentProvider.notifier).state =
                            null;
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red.withOpacity(0.2),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Bouton de confirmation
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleAssignment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9d4edd),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Confirmer l\'assignation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResidentCard(Resident resident) {
    final selectedResident = ref.watch(selectedResidentProvider);
    final isSelected = selectedResident?.id == resident.id;

    return GestureDetector(
      onTap: () {
        ref.read(selectedResidentProvider.notifier).state = resident;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00d4ff).withOpacity(0.1) : const Color(0xFF0f3460),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00d4ff)
                : Colors.grey.shade700,
            width: isSelected ? 2 : 0.5,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade700,
              ),
              child: const Icon(
                Icons.person,
                color: Color(0xFF00d4ff),
                size: 30,
              ),
            ),
            const SizedBox(width: 16),

            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resident.fullName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Chambre ${resident.batiment}-${resident.numeroChambre}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    resident.filiere,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            // Bouton de sélection
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF00d4ff)
                    : const Color(0xFF00d4ff).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isSelected ? '✓ Sélectionné' : 'Sélectionner',
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.black : const Color(0xFF00d4ff),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAssignment() async {
    final selectedResident = ref.read(selectedResidentProvider);

    if (selectedResident == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un résident'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await ref.read(
        assignContraventionProvider({
          'contraventionId': widget.contraventionId,
          'residentId': selectedResident.id,
          'motif': widget.motif,
        }).future,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.motif} assignée à ${selectedResident.fullName}'),
            backgroundColor: Colors.green,
          ),
        );
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pop(context, true);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'assignation: Statut non 200/201'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      String errorMessage = 'Erreur: $e';
      if (e.toString().contains('404')) {
        errorMessage = 'Endpoint non trouvé. Vérifiez le serveur backend.';
      } else if (e.toString().contains('Connection refused')) {
        errorMessage = 'Impossible de se connecter au serveur.';
      } else if (e.toString().contains('400')) {
        errorMessage = 'Requête invalide. Vérifiez les paramètres.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $errorMessage'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
