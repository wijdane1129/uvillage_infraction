import '../services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../models/resident_model.dart';
import '../providers/contravention_provider.dart';
import '../providers/history_provider.dart';
import '../providers/agent_auth_provider.dart';

class InfractionConfirmationScreen extends ConsumerWidget {

    // Debug: Test /contraventions/debug/whoami endpoint
    Future<void> testWhoAmI(BuildContext context) async {
      try {
        final response = await ApiClient.dio.get('/contraventions/debug/whoami');
        print('✅ [WHOAMI] ${response.data}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('WHOAMI: ${response.data}')),
        );
      } catch (e) {
        print('❌ [WHOAMI] Erreur: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur WHOAMI: $e')),
        );
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
              Text('Étape 3: Confirmation', style: TextStyle(color: AppTheme.textSecondary)),
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
                  border: Border.all(color: AppTheme.borderColor.withOpacity(0.7)),
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
                    _buildLine(context, 'Résident', resident != null ? resident!.fullName : 'Non renseigné'),
                    const SizedBox(height: 12),
                    Text('Description', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
                    const SizedBox(height: 8),
                    Text(description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textPrimary)),
                  // DEBUG BUTTON: Test /contraventions/debug/whoami
                  SizedBox(height: 16),
                    // ElevatedButton(
                    //   onPressed: () => testWhoAmI(context),
                    //   child: Text('Test WHOAMI (debug)'),
                    // ),
                    const SizedBox(height: 12),
                    Divider(color: AppTheme.borderColor.withOpacity(0.6)),
                    const SizedBox(height: 6),
                    Text('${mediaUrls.length} preuves attachées', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Thumbnails
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: mediaUrls.isEmpty ? 3 : mediaUrls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final url = mediaUrls.isEmpty
                        ? 'https://picsum.photos/seed/${index + 1}/200/200'
                        : mediaUrls[index];
                    return _buildThumbnail(context, url, index == 0);
                  },
                ),
              ),

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
                        builder: (_) => const Center(child: CircularProgressIndicator()));

                    await service.createContravention(
                      description: description,
                      typeLabel: motif,
                      userAuthorId: agentRowid,
                      tiersId: resident == null ? null : int.tryParse(resident?.id ?? ''),
                      mediaUrls: mediaUrls,
                    );

                    Navigator.of(context).pop(); // remove loading

                    // Invalidate history so dashboard refreshes
                    ref.invalidate(agentHistoryProvider(agentRowid));

                    // Show success and pop back to previous screen
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Infraction créée')));
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } catch (e) {
                    Navigator.of(context).pop(); // remove loading
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
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
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context, String url, bool highlighted) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
        boxShadow: highlighted
            ? [
                BoxShadow(
                  color: AppTheme.purpleAccent.withOpacity(0.35),
                  blurRadius: 18,
                  spreadRadius: 1,
                )
              ]
            : [],
        border: Border.all(color: AppTheme.borderColor.withOpacity(0.7)),
      ),
    );
  }
}
