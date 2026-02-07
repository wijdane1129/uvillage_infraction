import 'package:flutter/material.dart';
import 'package:infractions_app/screens/classer_sans_suite_screen.dart';
import '../config/app_theme.dart';
import '../models/contravention_models.dart';
import '../services/resident_mock_service.dart';
import '../services/api_service.dart';
import 'media_viewer.dart';
import 'accepter_contravention_screen.dart';
import 'assign_contravention_screen.dart';

class ContraventionDetailsScreen extends StatefulWidget {
  final Contravention contravention;

  const ContraventionDetailsScreen({Key? key, required this.contravention})
    : super(key: key);

  @override
  State<ContraventionDetailsScreen> createState() =>
      _ContraventionDetailsScreenState();
}

class _ContraventionDetailsScreenState
    extends State<ContraventionDetailsScreen> {
  MockResident? _mockResident;
  bool _isLoadingResident = true;

  @override
  void initState() {
    super.initState();
    _loadResidentData();
  }

  /// 🎯 MÉTHODE CLÉE - Charge les données du résident depuis le CSV
  Future<void> _loadResidentData() async {
    try {
      print(
        '📋 Chargement résident pour contravention ${widget.contravention.ref}',
      );

      // Extraire chambre et bâtiment depuis la contravention
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

        setState(() {
          _mockResident = resident;
          _isLoadingResident = false;
        });
      } else {
        print('⚠️ Impossible d\'extraire chambre/bâtiment de l\'adresse');
        setState(() {
          _isLoadingResident = false;
        });
      }
    } catch (e) {
      print('❌ Erreur chargement résident: $e');
      setState(() {
        _isLoadingResident = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Infraction #${widget.contravention.ref}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppTheme.buttonGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.purpleAccent.withOpacity(0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                widget.contravention.status,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: AppTheme.darkBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoCard(context),
            const SizedBox(height: 16),
            _personCard(context),
            const SizedBox(height: 16),
            _mediaSection(context),
            const SizedBox(height: 24),
            // Bouton Assigner à un résident
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00d4ff),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => AssignContraventionScreen(
                            contraventionId: widget.contravention.rowid ?? 0,
                            motif: widget.contravention.motif,
                          ),
                    ),
                  );
                },
                child: const Text(
                  'Assigner à un Résident',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      final result = await Navigator.of(context).push<Map<String, dynamic>>(
                        MaterialPageRoute(
                          builder:
                              (_) => ClasserSansSuiteScreen(
                                contravention: widget.contravention,
                              ),
                        ),
                      );

                      if (result != null) {
                        final motif = result['motif'] as String? ?? '';
                        try {
                          final apiService = ApiService();
                          await apiService.put(
                            '/contravention/classer-sans-suite/${widget.contravention.ref}',
                            {'motif': motif},
                          );
                          
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Contravention classée sans suite'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.of(context).pop();
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erreur: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Text('Classer sans suite'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (_) => AccepterContraventionScreen(
                                contravention: widget.contravention,
                              ),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Text('Accepter'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkBgAlt,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.borderColor.withOpacity(0.6),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Date & heure', style: TextStyle(color: Colors.white70)),
              Text(
                widget.contravention.dateTime,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Motif: ', style: TextStyle(color: Colors.white70)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.purpleAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.contravention.motif,
                  style: const TextStyle(
                    color: AppTheme.purpleAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 👤 AGENT QUI A DÉCLARÉ
          Row(
            children: [
              Icon(Icons.person, color: Colors.blueAccent, size: 20),
              const SizedBox(width: 8),
              Text('Agent: ', style: TextStyle(color: Colors.white70)),
              Text(
                widget.contravention.userAuthor,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white12),
          const SizedBox(height: 8),
          Text(
            widget.contravention.description,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _personCard(BuildContext context) {
    // 🎯 UTILISER LES DONNÉES CHARGÉES DU CSV
    String residentName;
    String residentAdresse;

    if (_isLoadingResident) {
      residentName = 'Chargement...';
      residentAdresse = '';
    } else if (_mockResident != null) {
      // ✅ Données trouvées dans le CSV
      residentName = _mockResident!.fullName;
      residentAdresse = _mockResident!.adresse;
    } else {
      // ⚠️ Pas trouvé dans le CSV - utiliser les données de base
      residentName = widget.contravention.residentName ?? 'Résident inconnu';
      residentAdresse =
          widget.contravention.residentAdresse ?? 'Adresse inconnue';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkBgAlt,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.borderColor.withOpacity(0.6),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.cyanAccent.withOpacity(0.2),
                  AppTheme.purpleAccent.withOpacity(0.2),
                ],
              ),
            ),
            child: const CircleAvatar(
              radius: 28,
              child: Icon(Icons.person, size: 28),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  residentName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  residentAdresse,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppTheme.borderColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              // TODO: Naviguer vers l'historique du résident
            },
            child: const Text('Historique'),
          ),
        ],
      ),
    );
  }

  Widget _mediaSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Médias',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${widget.contravention.media.length} éléments',
              style: const TextStyle(color: Colors.white54),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: widget.contravention.media.length,
          itemBuilder: (context, index) {
            final media = widget.contravention.media[index];
            final url = media.mediaUrl;
            final isVideo = media.mediaType.toLowerCase().contains('video');

            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MediaViewer(url: url, isVideo: isVideo),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (!isVideo)
                      Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Container(color: Colors.grey),
                      )
                    else
                      Container(
                        color: Colors.black54,
                        child: const Center(
                          child: Icon(
                            Icons.videocam,
                            size: 48,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    if (isVideo)
                      const Center(
                        child: Icon(
                          Icons.play_circle_fill,
                          size: 56,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
