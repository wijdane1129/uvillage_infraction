import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/motif_model.dart';
import '../providers/motif_provider.dart';
import '../gen_l10n/app_localizations.dart';

class ConfigurationMotifsScreen extends ConsumerStatefulWidget {
  const ConfigurationMotifsScreen({super.key});

  @override
  ConsumerState<ConfigurationMotifsScreen> createState() =>
      _ConfigurationMotifsScreenState();
}

class _ConfigurationMotifsScreenState
    extends ConsumerState<ConfigurationMotifsScreen> {
  late TextEditingController _searchController;
  List<Motif> _filteredMotifs = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterMotifs(List<Motif> motifs) {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMotifs = motifs
          .where((motif) =>
              motif.nom.toLowerCase().contains(query) && !motif.supprime)
          .toList();
    });
  }

  void _showAddMotifDialog() {
    final nomController = TextEditingController();
    final montant1Controller = TextEditingController();
    final montant2Controller = TextEditingController();
    final montant3Controller = TextEditingController();
    final montant4Controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Ajouter un motif',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomController,
                decoration: InputDecoration(
                  hintText: 'Nom du motif',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF2D2D44),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF9D4EDD)),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: montant1Controller,
                decoration: InputDecoration(
                  hintText: 'Montant 1 (€)',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF2D2D44),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF9D4EDD)),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: montant2Controller,
                decoration: InputDecoration(
                  hintText: 'Montant 2 (€)',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF2D2D44),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF9D4EDD)),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: montant3Controller,
                decoration: InputDecoration(
                  hintText: 'Montant 3 (€)',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF2D2D44),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF9D4EDD)),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: montant4Controller,
                decoration: InputDecoration(
                  hintText: 'Montant 4 (€)',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF2D2D44),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF9D4EDD)),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
                style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              if (nomController.text.isNotEmpty &&
                  montant1Controller.text.isNotEmpty &&
                  montant2Controller.text.isNotEmpty &&
                  montant3Controller.text.isNotEmpty &&
                  montant4Controller.text.isNotEmpty) {
                ref.read(motifStateProvider.notifier).addMotif(
                      nomController.text,
                      double.parse(montant1Controller.text),
                      double.parse(montant2Controller.text),
                      double.parse(montant3Controller.text),
                      double.parse(montant4Controller.text),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Ajouter',
                style: TextStyle(color: Color(0xFF9D4EDD))),
          ),
        ],
      ),
    );
  }

  void _showEditMotifDialog(Motif motif) {
    final nomController = TextEditingController(text: motif.nom);
    final montant1Controller =
        TextEditingController(text: motif.montant1.toString());
    final montant2Controller =
        TextEditingController(text: motif.montant2.toString());
    final montant3Controller =
        TextEditingController(text: motif.montant3.toString());
    final montant4Controller =
        TextEditingController(text: motif.montant4.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Modifier le motif',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomController,
                decoration: InputDecoration(
                  hintText: 'Nom du motif',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF2D2D44),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF9D4EDD)),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: montant1Controller,
                decoration: InputDecoration(
                  hintText: 'Montant 1 (€)',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF2D2D44),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF9D4EDD)),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: montant2Controller,
                decoration: InputDecoration(
                  hintText: 'Montant 2 (€)',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF2D2D44),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF9D4EDD)),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: montant3Controller,
                decoration: InputDecoration(
                  hintText: 'Montant 3 (€)',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF2D2D44),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF9D4EDD)),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: montant4Controller,
                decoration: InputDecoration(
                  hintText: 'Montant 4 (€)',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF2D2D44),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF9D4EDD)),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
                style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              if (nomController.text.isNotEmpty &&
                  montant1Controller.text.isNotEmpty &&
                  montant2Controller.text.isNotEmpty &&
                  montant3Controller.text.isNotEmpty &&
                  montant4Controller.text.isNotEmpty) {
                ref.read(motifStateProvider.notifier).updateMotif(
                      motif.id,
                      nomController.text,
                      double.parse(montant1Controller.text),
                      double.parse(montant2Controller.text),
                      double.parse(montant3Controller.text),
                      double.parse(montant4Controller.text),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Modifier',
                style: TextStyle(color: Color(0xFF9D4EDD))),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(Motif motif) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Supprimer le motif',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${motif.nom}" ? Cette action est irréversible.',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
                style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              ref.read(motifStateProvider.notifier).deleteMotif(motif.id);
              Navigator.pop(context);
            },
            child: const Text('Supprimer',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final motifsAsync = ref.watch(motifStateProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.configurationMotifs, style: const TextStyle(color: Colors.white)),
            Text(
              AppLocalizations.of(context)!.manageReasons,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FloatingActionButton(
              onPressed: _showAddMotifDialog,
              backgroundColor: const Color(0xFF9D4EDD),
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
      body: motifsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF9D4EDD)),
        ),
        error: (err, stack) => Center(
          child: Text('Erreur: $err', style: const TextStyle(color: Colors.white)),
        ),
        data: (motifs) {
          _filterMotifs(motifs);

          final totalMotifs = motifs.where((m) => !m.supprime).length;
          final amendeMoyenne = motifs.isEmpty
              ? 0.0
              : motifs
                      .where((m) => !m.supprime)
                      .fold<double>(0, (sum, m) => sum + ((m.montant1 + m.montant2 + m.montant3 + m.montant4) / 4)) /
                  totalMotifs;

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(motifStateProvider.notifier).refresh(),
            color: const Color(0xFF9D4EDD),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Alerte Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2D44),
                        borderRadius: BorderRadius.circular(12),
                        border: const Border(
                          left: BorderSide(
                            color: Color(0xFF9D4EDD),
                            width: 4,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: Color(0xFF9D4EDD), size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Les motifs supprimés ne peuvent pas être restaurés.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Soyez prudent lors de la suppression d\'un motif.',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.expand_more,
                                color: Color(0xFF9D4EDD)),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Statistiques
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Motifs',
                            totalMotifs.toString(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Amende Moyenne',
                            '€${amendeMoyenne.toStringAsFixed(0)}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Barre de recherche
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => _filterMotifs(motifs),
                      decoration: InputDecoration(
                        hintText: 'Rechercher par nom...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF2D2D44),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF9D4EDD),
                            width: 1,
                          ),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 24),

                    // Liste des motifs
                    if (_filteredMotifs.isEmpty)
                      Center(
                        child: Text(
                          _searchController.text.isEmpty
                              ? 'Aucun motif'
                              : 'Aucun motif trouvé',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredMotifs.length,
                        itemBuilder: (context, index) {
                          final motif = _filteredMotifs[index];
                          return _buildMotifCard(motif);
                        },
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF2D2D44)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotifCard(Motif motif) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9D4EDD), Color(0xFFE94560)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.description,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          motif.nom,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Créé le: ${dateFormat.format(motif.dateCreation)}',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    color: const Color(0xFF2D2D44),
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        child: const Text('Modifier',
                            style: TextStyle(color: Colors.white)),
                        onTap: () => _showEditMotifDialog(motif),
                      ),
                      PopupMenuItem(
                        child: const Text('Supprimer',
                            style: TextStyle(color: Colors.red)),
                        onTap: () => _showDeleteConfirmDialog(motif),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert,
                        color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMotifStat('Utilisé: ${motif.utilisations} fois',
                      Icons.history),
                  _buildMotifStat('Montants: €${motif.montant1.toStringAsFixed(0)}-${motif.montant4.toStringAsFixed(0)}',
                      Icons.attach_money),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Montants: ${motif.montant1.toStringAsFixed(0)} € / ${motif.montant2.toStringAsFixed(0)} € / ${motif.montant3.toStringAsFixed(0)} € / ${motif.montant4.toStringAsFixed(0)} €',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMotifStat(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

