import 'dart:io';

class ContraventionMediaDetail {
  final int id;
  final String mediaType;
  final String mediaUrl;
  final File file;

  ContraventionMediaDetail({
    required this.id,
    required this.mediaType,
    required this.mediaUrl,
    required this.file,
  });

  @override
  String toString() {
    return 'MediaDetail(id: $id, type: $mediaType, url: $mediaUrl)';
  }
}

class ContraventionFormData {
  final int currentStep;
  final String description;
  final List<ContraventionMediaDetail> media;
  final String? motif;

  ContraventionFormData({
    this.currentStep = 2,
    this.description = '',
    this.media = const [],
    this.motif,
  });

  ContraventionFormData copyWith({
    int? currentStep,
    String? description,
    List<ContraventionMediaDetail>? media,
    String? motif,
  }) {
    return ContraventionFormData(
      currentStep: currentStep ?? this.currentStep,
      description: description ?? this.description,
      media: media ?? this.media,
      motif: motif ?? this.motif,
    );
  }
}

// --- API/Backend Models (for sending/receiving data) ---

// Your existing API model for media (corrected case and List<String> to String)
class ContraventionMediaModels {
  final int? id; // Nullable as it might not be set before upload
  final String mediaUrl;
  final String mediaType;

  ContraventionMediaModels({
    this.id,
    required this.mediaUrl,
    required this.mediaType,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'mediaUrl': mediaUrl, 'mediaType': mediaType};
  }

  factory ContraventionMediaModels.fromJson(Map<String, dynamic> json) {
    return ContraventionMediaModels(
      id: json['id'],
      mediaUrl: json['mediaUrl'],
      mediaType: json['mediaType'],
    );
  }
}

// Your existing API model for Contravention (corrected factory name)
class Contravention {
  final int? rowid;
  final String description;
  final List<ContraventionMediaModels> media;

  Contravention({this.rowid, required this.description, required this.media});

  Map<String, dynamic> toJson() {
    return {
      'rowid': rowid,
      'description': description,
      'media': media.map((e) => e.toJson()).toList(),
    };
  }

  factory Contravention.fromJson(Map<String, dynamic> json) {
    return Contravention(
      rowid: json['rowid'] as int?,
      description: json['description'] as String? ?? '',
      media:
          (json['media'] as List<dynamic>? ?? [])
              .map(
                (e) => ContraventionMediaModels.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList(),
    );
  }
}
