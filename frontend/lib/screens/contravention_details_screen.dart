import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/app_theme.dart';
import '../models/contravention_models.dart';
import '../services/resident_mock_service.dart';
import '../services/api_service.dart';
import '../services/api_client.dart';
import 'media_viewer.dart';
import 'accepter_contravention_screen.dart';
import 'assign_contravention_screen.dart';
import 'classer_sans_suite_screen.dart';

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
    _debugPrintMediaInfo();
  }

  /// Debug method to print media information
  void _debugPrintMediaInfo() {
    print('🎯 [DETAILS] Contravention ref: ${widget.contravention.ref}');
    print('🎯 [DETAILS] Media count: ${widget.contravention.media.length}');
    for (var media in widget.contravention.media) {
      print('🎯 [DETAILS] Media URL: ${media.mediaUrl}');
      print('🎯 [DETAILS] Media Type: ${media.mediaType}');
    }
  }

  /// Load resident data from CSV
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

  /// Get full media URL from backend
  String _getMediaUrl(String mediaUrl) {
    // If it's already a full URL, return it
    if (mediaUrl.startsWith('http://') || mediaUrl.startsWith('https://')) {
      return mediaUrl;
    }

    // Otherwise, construct the full URL using the base URL
    final baseUrl = ApiClient.dio.options.baseUrl.replaceAll('/api/v1', '');
    return '$baseUrl/$mediaUrl';
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
            // Action buttons
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
                      final result = await Navigator.of(
                        context,
                      ).push<Map<String, dynamic>>(
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
                                content: Text(
                                  'Contravention classée sans suite',
                                ),
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
    String residentName;
    String residentAdresse;

    if (_isLoadingResident) {
      residentName = 'Chargement...';
      residentAdresse = '';
    } else if (_mockResident != null) {
      residentName = _mockResident!.fullName;
      residentAdresse = _mockResident!.adresse;
    } else {
      residentName =
          widget.contravention.residentName ??
          (widget.contravention.tiers.isNotEmpty
              ? widget.contravention.tiers
              : 'Résident inconnu');
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
              // TODO: Navigate to resident history
            },
            child: const Text('Historique'),
          ),
        ],
      ),
    );
  }

  Widget _mediaSection(BuildContext context) {
    if (widget.contravention.media.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.darkBgAlt,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Aucun média attaché',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ),
      );
    }

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
            final fullUrl = _getMediaUrl(media.mediaUrl);
            final isVideo = media.mediaType.toLowerCase().contains('video');

            print(
              '🖼️ [MEDIA] Displaying media: $fullUrl (type: ${media.mediaType})',
            );

            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MediaViewer(url: fullUrl, isVideo: isVideo),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (!isVideo)
                      CachedNetworkImage(
                        imageUrl: fullUrl,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => Container(
                              color: Colors.grey[800],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                        errorWidget: (context, url, error) {
                          print('❌ [MEDIA] Error loading image: $error');
                          return Container(
                            color: Colors.grey[800],
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  color: Colors.white54,
                                  size: 32,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Erreur de chargement',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
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
