import '../services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../models/resident_model.dart';
import '../providers/contravention_provider.dart';
import '../providers/history_provider.dart';
import '../providers/agent_auth_provider.dart';
import 'agent_home_screen.dart';
import 'media_player_screen.dart';
import 'dart:io';

class InfractionConfirmationScreen extends ConsumerWidget {
  // Debug: Test /contraventions/debug/whoami endpoint
  Future<void> testWhoAmI(BuildContext context) async {
    try {
      final response = await ApiClient.dio.get('/contraventions/debug/whoami');
      print('✅ [WHOAMI] ${response.data}');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('WHOAMI: ${response.data}')));
    } catch (e) {
      print('❌ [WHOAMI] Erreur: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur WHOAMI: $e')));
    }
  }

  final String motif;
  final ResidentModel? resident;
  final String description;
  final List<String> mediaUrls;

  const InfractionConfirmationScreen({
    super.key,
    required this.motif,
    this.resident,
    required this.description,
    required this.mediaUrls,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infraction Form'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24.0),
          child: Column(
            children: const [
              Text(
                'Étape 3: Confirmation',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.darkBgAlt,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppTheme.borderColor.withOpacity(0.7),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Récapitulatif de l'infraction",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 18),

                    _buildLine(context, 'Motif', motif),
                    const Divider(color: Colors.transparent, height: 12),
                    _buildLine(
                      context,
                      'Résident',
                      resident != null ? resident!.fullName : 'Non renseigné',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    // DEBUG BUTTON: Test /contraventions/debug/whoami
                    SizedBox(height: 16),
                    // ElevatedButton(
                    //   onPressed: () => testWhoAmI(context),
                    //   child: Text('Test WHOAMI (debug)'),
                    // ),
                    if (mediaUrls.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Divider(color: AppTheme.borderColor.withOpacity(0.6)),
                      const SizedBox(height: 6),
                      Text(
                        '${mediaUrls.length} preuves attachées',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (mediaUrls.isNotEmpty) ...[
                const SizedBox(height: 20),

                // Thumbnails
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: mediaUrls.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final url = mediaUrls[index];
                      return _buildThumbnail(context, url, index == 0);
                    },
                  ),
                ),
              ],

              const Spacer(),

              // Send button
              GradientButton(
                text: 'Envoyer',
                onPressed: () async {
                  final service = ref.read(contraventionServiceProvider);
                  final agentRowid = ref.read(currentAgentIdProvider);

                  try {
                    // Show a simple loading dialog
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder:
                          (_) =>
                              const Center(child: CircularProgressIndicator()),
                    );

                    final result = await service.createContravention(
                      description: description,
                      typeLabel: motif,
                      userAuthorId: agentRowid,
                      tiersId:
                          resident == null
                              ? null
                              : int.tryParse(resident?.id ?? ''),
                      mediaUrls: mediaUrls,
                    );

                    Navigator.of(context).pop(); // remove loading

                    // Invalidate history so dashboard refreshes
                    ref.invalidate(agentHistoryProvider(agentRowid));

                    // Check if it was created offline or online
                    final isOffline = result['offline'] as bool? ?? false;
                    final message =
                        result['message'] as String? ??
                        (isOffline
                            ? 'Infraction créée en mode hors ligne'
                            : 'Infraction créée');

                    // Show success and navigate to home screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor:
                            isOffline ? Colors.orange : Colors.green,
                      ),
                    );
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const AgentHomeScreen(),
                      ),
                      (route) => false,
                    );
                  } catch (e) {
                    Navigator.of(context).pop(); // remove loading
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                  }
                },
                height: 64,
                radius: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLine(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context, String url, bool highlighted) {
    // Déterminer le type de média depuis l'URL
    final isPhoto =
        url.toLowerCase().endsWith('.jpg') ||
        url.toLowerCase().endsWith('.jpeg') ||
        url.toLowerCase().endsWith('.png') ||
        url.toLowerCase().endsWith('.gif');

    final isVideo =
        url.toLowerCase().endsWith('.mp4') ||
        url.toLowerCase().endsWith('.mov') ||
        url.toLowerCase().endsWith('.avi');

    final isAudio =
        url.toLowerCase().endsWith('.mp3') ||
        url.toLowerCase().endsWith('.m4a') ||
        url.toLowerCase().endsWith('.wav');

    return GestureDetector(
      onTap: () {
        // Ouvrir le lecteur pour vidéo/audio
        if (isVideo || isAudio) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => MediaPlayerScreen(
                    filePath: url,
                    mediaType: isVideo ? 'VIDEO' : 'AUDIO',
                  ),
            ),
          );
        }
        // Pour les photos, on peut ajouter un zoom
        else if (isPhoto) {
          showDialog(
            context: context,
            builder:
                (context) => Dialog(
                  backgroundColor: Colors.transparent,
                  child: InteractiveViewer(child: Image.file(File(url))),
                ),
          );
        }
      },
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor.withOpacity(0.7)),
          boxShadow:
              highlighted
                  ? [
                    BoxShadow(
                      color: AppTheme.purpleAccent.withOpacity(0.35),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ]
                  : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: _buildMediaContent(url, isPhoto, isVideo, isAudio),
        ),
      ),
    );
  }

  Widget _buildMediaContent(
    String url,
    bool isPhoto,
    bool isVideo,
    bool isAudio,
  ) {
    if (isPhoto) {
      // Afficher l'image
      return url.startsWith('http')
          ? Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorWidget();
            },
          )
          : Image.file(
            File(url),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorWidget();
            },
          );
    } else if (isVideo) {
      // Afficher une icône vidéo
      return Container(
        color: Colors.black87,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_circle_fill, color: Colors.white70, size: 48),
            const SizedBox(height: 4),
            const Text(
              'Vidéo',
              style: TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
      );
    } else if (isAudio) {
      // Afficher une icône audio
      return Container(
        color: const Color(0xFF1a1a2e),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.audiotrack, color: Colors.cyan, size: 48),
            const SizedBox(height: 4),
            const Text(
              'Audio',
              style: TextStyle(color: Colors.cyan, fontSize: 10),
            ),
          ],
        ),
      );
    } else {
      return _buildErrorWidget();
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[800],
      child: const Icon(Icons.broken_image, color: Colors.white54, size: 32),
    );
  }

  /// Extraire le nom du fichier depuis le path
  String _getFileName(String path) {
    return path.split('/').last;
  }
}
