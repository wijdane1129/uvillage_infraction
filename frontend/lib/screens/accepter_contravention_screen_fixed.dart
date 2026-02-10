import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infractions_app/models/contravention_recidive_models.dart';
import '../config/app_theme.dart';
import '../models/contravention_models.dart';
import '../models/motif_model.dart';
import '../services/api_service.dart';
import '../services/resident_mock_service.dart';
import '../providers/motif_provider.dart';

class AccepterContraventionScreen extends ConsumerStatefulWidget {
  final Contravention contravention;
  final ContraventionRecidiveModels? contraventionRecidive;
  final List<Contravention>? history;

  const AccepterContraventionScreen({
    Key? key,
    required this.contravention,
    this.contraventionRecidive,
    this.history,
  }) : super(key: key);

  @override
  ConsumerState<AccepterContraventionScreen> createState() =>
      _AccepterContraventionScreenState();
}

class _AccepterContraventionScreenState
    extends ConsumerState<AccepterContraventionScreen> {
  late ContraventionRecidiveModels _computedRecidive;
  bool _sendEmail = false;
  MockResident? _mockResident;
  bool _isLoadingResident = true;
  Motif? _motif;
  bool _isLoadingMotif = true;

  @override
  void initState() {
    super.initState();
    _loadResidentData();
    _loadMotifData();

    // 1. Logic to determine the Recidive Model
    if (widget.contraventionRecidive != null) {
      _computedRecidive = widget.contraventionRecidive!;
    } else {
      // Calculate from history or default to 1 (First Time)
      int count = 1;
      if (widget.history != null) {
        final motif = widget.contravention.motif.trim().toLowerCase();
        final prevCount =
            widget.history!
                .where((c) => c.motif.trim().toLowerCase() == motif)
                .length;
        count = prevCount + 1;
      }

      // Will be replaced once motif is loaded
      _computedRecidive = ContraventionRecidiveModels(
        label: widget.contravention.motif,
        nombrerecidive: count,
        montant1: 50,
        montant2: 100,
        montant3: 200,
        montant4: 500,
      );
    }
  }

  /// 🎯 Charge le motif depuis le provider et recalcule la récidive
  Future<void> _loadMotifData() async {
    try {
      final motifsAsync = ref.read(motifStateProvider);

      if (motifsAsync is AsyncData) {
        final motifsList = motifsAsync.value;
        if (motifsList == null || motifsList.isEmpty) {
          setState(() {
            _isLoadingMotif = false;
          });
          return;
        }

        final motif = motifsList.firstWhere(
          (m) =>
              m.nom.trim().toLowerCase() ==
              widget.contravention.motif.trim().toLowerCase(),
          orElse:
              () => Motif(
                id: -1,
                nom: widget.contravention.motif,
                montant1: 50,
                montant2: 100,
                montant3: 200,
                montant4: 500,
                dateCreation: DateTime.now(),
                utilisations: 0,
              ),
        );

        if (mounted) {
          setState(() {
            _motif = motif;
            _isLoadingMotif = false;

            // Recalculate recidive with motif montants
            int count = 1;
            if (widget.history != null) {
              final motifStr = widget.contravention.motif.trim().toLowerCase();
              final prevCount =
                  widget.history!
                      .where((c) => c.motif.trim().toLowerCase() == motifStr)
                      .length;
              count = prevCount + 1;
            }

            _computedRecidive = ContraventionRecidiveModels(
              label: widget.contravention.motif,
              nombrerecidive: count,
              montant1: motif.montant1.toInt(),
              montant2: motif.montant2.toInt(),
              montant3: motif.montant3.toInt(),
              montant4: motif.montant4.toInt(),
            );
          });
        }
      }
    } catch (e) {
      print('❌ Erreur chargement motif: $e');
      if (mounted) {
        setState(() {
          _isLoadingMotif = false;
        });
      }
    }
  }

  /// 🎯 Charge les données du résident depuis le CSV
  Future<void> _loadResidentData() async {
    try {
      print(
        '📋 Chargement résident pour contravention ${widget.contravention.ref}',
      );

      final extracted = ResidentMockService.extractRoomAndBuilding(
        widget.contravention.residentAdresse,
      );

      final numeroChambre = extracted['chamber'];
      final batiment = extracted['building'];

      print('🔍 Extracted: Chambre=$numeroChambre, Bâtiment=$batiment');

      if (numeroChambre != null && batiment != null) {
        final resident = await ResidentMockService.findResidentByRoom(
          numeroChambre,
          batiment,
        );

        if (mounted) {
          setState(() {
            _mockResident = resident;
            _isLoadingResident = false;
          });
        }
      } else {
        print('⚠️ Impossible d\'extraire chambre/bâtiment de l\'adresse');
        if (mounted) {
          setState(() {
            _isLoadingResident = false;
          });
        }
      }
    } catch (e) {
      print('❌ Erreur chargement résident: $e');
      if (mounted) {
        setState(() {
          _isLoadingResident = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = _computedRecidive;
    final bool isRecidive = r.nombrerecidive > 1;

    String residentName;
    if (_isLoadingResident) {
      residentName = 'Chargement...';
    } else if (_mockResident != null) {
      residentName = _mockResident!.fullName;
    } else {
      residentName =
          widget.contravention.residentName ?? widget.contravention.userAuthor;
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBgAlt,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: AppTheme.darkBg,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.45),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Confirmer l\'acceptation',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.purpleAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.darkBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.borderColor.withOpacity(0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        'Infraction',
                        '#${widget.contravention.ref}',
                        isBold: true,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Résident', residentName),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Motif',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.contravention.motif,
                              style: const TextStyle(
                                color: Colors.purpleAccent,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                if (isRecidive)
                  _buildRecidiveCard(r)
                else
                  _buildFirstTimeCard(r),

                const SizedBox(height: 20),
                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1DB954),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1DB954).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: _onConfirm,
                      child: const Center(
                        child: Text(
                          'Confirmer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecidiveCard(ContraventionRecidiveModels r) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2220),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 28),
              SizedBox(width: 8),
              Text(
                'Récidive détectée!',
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: TextStyle(color: AppTheme.textSecondary),
              children: [
                TextSpan(text: '${r.nombrerecidive}ème infraction pour '),
                TextSpan(
                  text: '${r.label}.',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildMontantRow('1ère fois:', r.montant1, false),
          const SizedBox(height: 4),
          _buildMontantRow('2ème fois:', r.montant2, r.nombrerecidive == 2),
          const SizedBox(height: 4),
          _buildMontantRow('3ème fois:', r.montant3, r.nombrerecidive == 3),
          const SizedBox(height: 4),
          _buildMontantRow('4ème fois:', r.montant4, r.nombrerecidive >= 4),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(color: Colors.orange.withOpacity(0.3)),
          ),

          const Center(
            child: Text(
              'Montant à facturer',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Center(
            child: Text(
              '${_montantValue(r)} DH',
              style: const TextStyle(
                color: Colors.deepOrangeAccent,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirstTimeCard(ContraventionRecidiveModels r) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline, color: Colors.blueAccent, size: 28),
              SizedBox(width: 8),
              Text(
                'Première fois',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: TextStyle(color: AppTheme.textSecondary),
              children: [
                const TextSpan(text: "Il s'agit de la 1ère infraction pour "),
                TextSpan(
                  text: '${r.label}.',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(color: Colors.blueAccent.withOpacity(0.3)),
          ),

          const Center(
            child: Text(
              'Montant à facturer',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Center(
            child: Text(
              '${r.montant1} DH',
              style: const TextStyle(
                color: Colors.blueAccent,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onConfirm() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.purpleAccent,
                ),
              ),
            ),
      );

      final apiService = ApiService();
      final ref = widget.contravention.ref;

      print('DEBUG: Calling confirm endpoint for ref: $ref');

      final extracted = ResidentMockService.extractRoomAndBuilding(
        widget.contravention.residentAdresse,
      );
      final numeroChambre = extracted['chamber'];
      final batiment = extracted['building'];

      final response = await apiService
          .post('/contraventions/ref/$ref/confirm', {
            if (numeroChambre != null) 'numeroChambre': numeroChambre,
            if (batiment != null) 'batiment': batiment,
          });

      print('DEBUG: Response status: ${response.statusCode}');
      print('DEBUG: Response data: ${response.data}');

      if (mounted) {
        Navigator.of(context).pop();
      }

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✓ Facture PDF générée avec succès!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        throw Exception('Erreur lors de la génération: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG: Error in _onConfirm: $e');

      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  int _montantValue(ContraventionRecidiveModels r) {
    switch (r.nombrerecidive) {
      case 1:
        return r.montant1;
      case 2:
        return r.montant2;
      case 3:
        return r.montant3;
      case 4:
      default:
        return r.montant4;
    }
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppTheme.textSecondary)),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildMontantRow(String label, int value, bool highlighted) {
    return Container(
      decoration:
          highlighted
              ? BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              )
              : null,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: highlighted ? Colors.orangeAccent : AppTheme.textSecondary,
              fontWeight: highlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '$value DH',
            style: TextStyle(
              color: highlighted ? Colors.orangeAccent : AppTheme.textSecondary,
              fontWeight: highlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
