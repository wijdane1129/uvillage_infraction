// lib/screens/contravention_step2_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/contravention_models.dart';
import '../models/resident_model.dart';
import '../providers/contravention_provider.dart';
import 'package:infractions_app/widgets/gradient_button.dart';
import '../screens/infraction_confirmation_screen.dart';
import '../gen_l10n/app_localizations.dart';
import '../widgets/language_switcher.dart';

class ContraventionStep2Screen extends ConsumerStatefulWidget {
  final String? motif;
  final ResidentModel? resident;

  const ContraventionStep2Screen({Key? key, this.motif, this.resident}) : super(key: key);

  @override
  ConsumerState<ContraventionStep2Screen> createState() =>
      _ContraventionStep2ScreenState();
}

class _ContraventionStep2ScreenState
    extends ConsumerState<ContraventionStep2Screen> {
  late TextEditingController descriptionController;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    descriptionController = TextEditingController(
      text: ref.read(contraventionFormDataProvider).description,
    );
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia(String mediaType) async {
    try {
      XFile? pickedFile;
      FilePickerResult? filePickerResult;

      if (mediaType == 'PHOTO') {
        pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      } else if (mediaType == 'VIDEO') {
        pickedFile = await _imagePicker.pickVideo(source: ImageSource.gallery);
      } else if (mediaType == 'AUDIO') {
        filePickerResult = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['mp3', 'm4a', 'wav'],
        );
      }

      if (pickedFile != null) {
        _addFileToProvider(pickedFile.path, mediaType, File(pickedFile.path));
      } else if (filePickerResult != null &&
          filePickerResult.files.isNotEmpty) {
        final platformFile = filePickerResult.files.first;
        if (platformFile.path != null) {
          _addFileToProvider(
            platformFile.path!,
            mediaType,
            File(platformFile.path!),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection du média: $e')),
      );
    }
  }

  void _addFileToProvider(String path, String mediaType, File file) {
    final currentMediaCount =
        ref.read(contraventionFormDataProvider).media.length;
    ref
        .read(contraventionFormDataProvider.notifier)
        .addMedia(
          ContraventionMediaDetail(
            id: currentMediaCount + 1,
            mediaType: mediaType,
            mediaUrl: path,
            file: file,
          ),
        );
  }

  void _removeFile(int mediaId) {
    ref.read(contraventionFormDataProvider.notifier).removeMedia(mediaId);
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final formState = ref.watch(contraventionFormDataProvider);

    // Watch the media list specifically for UI updates
    final selectedMedia = formState.media;

    // Dropdown for motif selection
    final labelsAsync = ref.watch(contraventionTypeLabelsProvider);

    return Scaffold(
      appBar: AppBar(
        // Style adjustments for a dark/themed app look based on the image
        title: Text(locale!.infractions_form),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [LanguageSwitcher()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${locale.step} 2: Preuves & Détails',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFFE0B0FF), // Purple/Pink color from image
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildProgressIndicator(formState.currentStep),
            const SizedBox(height: 32),
            _buildMediaUploadSection(selectedMedia),
            const SizedBox(height: 24),
            _buildDescriptionField(),
            const SizedBox(height: 32),
            _buildNavigationButtons(context),
            const SizedBox(height: 16),
            // (Motif selection dropdown removed; motif is now selected only in AgentInfractionScreen)
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int currentStep) {
    return Row(
      children: List.generate(3, (index) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(left: index > 0 ? 8 : 0),
            height: 6,
            decoration: BoxDecoration(
              // Step 1 and 2 are active (index 0 and 1)
              color: index < currentStep ? Colors.cyan : Colors.grey[600],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMediaUploadSection(
    List<ContraventionMediaDetail> selectedMedia,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E2E38), // Dark background color from image
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ajouter des preuves',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMediaButton('Photo', Icons.camera_alt, 'PHOTO'),
              _buildMediaButton('Vidéo', Icons.video_camera_back, 'VIDEO'),
              _buildMediaButton('Audio', Icons.mic, 'AUDIO'),
            ],
          ),
          if (selectedMedia.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildFilePreview(selectedMedia),
          ],
        ],
      ),
    );
  }

  Widget _buildMediaButton(String label, IconData icon, String mediaType) {
    const Color buttonColor = Colors.cyan;
    return GestureDetector(
      onTap: () => _pickMedia(mediaType),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: buttonColor, width: 2),
            ),
            child: Icon(icon, color: buttonColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePreview(List<ContraventionMediaDetail> media) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5, // Adjusted for better visual
      ),
      itemCount: media.length,
      itemBuilder: (context, index) {
        final item = media[index];
        return Stack(
          children: [
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: _getMediaWidget(item),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removeFile(item.id),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _getMediaWidget(ContraventionMediaDetail item) {
    switch (item.mediaType) {
      case 'PHOTO':
        return Image.file(
          item.file,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) =>
                  const Center(child: Icon(Icons.image_not_supported)),
        );
      case 'VIDEO':
        return const Center(
          child: Icon(
            Icons.play_circle_outline,
            color: Colors.white70,
            size: 48,
          ),
        );
      case 'AUDIO':
        return const Center(
          child: Icon(Icons.audiotrack, color: Colors.white70, size: 48),
        );
      default:
        return const Center(child: Icon(Icons.attachment));
    }
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description Détaillée',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: descriptionController,
          builder: (context, value, child) {
            return TextField(
              controller: descriptionController,
              maxLines: 6,
              maxLength: 1500,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText:
                    'Décrivez en détail l\'incident, les personnes impliquées, et le lieu...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.cyan),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[700]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.cyan, width: 2),
                ),
                fillColor: const Color(0xFF2E2E38),
                filled: true,
                // Use counter widget for live update of character count
                counter: Text(
                  '${value.text.length}/1500',
                  style: const TextStyle(color: Colors.grey),
                ),
                counterText: '', // Hide default counter
              ),
              onChanged: (newValue) {
                // Update the provider state
                ref
                    .read(contraventionFormDataProvider.notifier)
                    .setDescription(newValue);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    return Row(
      children: [
        
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Colors.cyan),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Précédent',
              style: TextStyle(color: Colors.cyan),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GradientButton(
            text: locale.next,
            onPressed: () {
              // Get locale again here for the callback
              final currentLocale = AppLocalizations.of(context);
              // Guard: re-check description at time of click
              final isDescriptionValid = descriptionController.text.trim().isNotEmpty;
              if (!isDescriptionValid) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(currentLocale?.loading ?? 'Loading...')),
                );
                return;
              }

              // Enforce motif is provided (passed from previous step)
              if (widget.motif == null || widget.motif!.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Le choix du motif est obligatoire pour continuer')),
                );
                return;
              }

              // Update step and navigate to confirmation screen using direct route
              ref.read(contraventionFormDataProvider.notifier).setStep(3);

              final formState = ref.read(contraventionFormDataProvider);
              final mediaUrls = formState.media.map((m) => m.mediaUrl).toList();
              final desc = descriptionController.text.trim();

              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => InfractionConfirmationScreen(
                  motif: widget.motif!,
                  resident: widget.resident,
                  description: desc,
                  mediaUrls: mediaUrls,
                ),
              ));
            },
          ),
        ),
      ],
    );
  }
}
