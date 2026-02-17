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
  final String status;
  final String dateTime;
  final String ref;
  final String userAuthor;
  final String tiers;
  final String motif;
  final String? residentAdresse;
  final String? residentName; // Added to represent mock resident name

  Contravention({
    this.rowid,
    required this.description,
    required this.media,
    required this.status,
    required this.dateTime,
    required this.ref,
    required this.userAuthor,
    required this.tiers,
    required this.motif,
    this.residentAdresse,
    this.residentName, // Added to constructor
  });

  Map<String, dynamic> toJson() {
    return {
      'rowid': rowid,
      'description': description,
      'media': media.map((e) => e.toJson()).toList(),
    };
  }

  factory Contravention.fromJson(Map<String, dynamic> json) {
    // Handle userAuthor: can be a String (from dashboard) or a Map (from API)
    String userAuthorStr = '';
    final rawAuthor = json['userAuthor'];
    if (rawAuthor is String) {
      userAuthorStr = rawAuthor;
    } else if (rawAuthor is Map<String, dynamic>) {
      final prenom = (rawAuthor['prenom'] as String?) ?? '';
      final nom = (rawAuthor['nom'] as String?) ?? '';
      userAuthorStr = '$prenom $nom'.trim();
    }

    // Handle tiers: can be a String (from dashboard) or a Map (from API)
    String tiersStr = '';
    String? residentAdresse = json['residentAdresse'] as String?;
    final rawTiers = json['tiers'];
    if (rawTiers is String) {
      tiersStr = rawTiers;
    } else if (rawTiers is Map<String, dynamic>) {
      final prenom = (rawTiers['prenom'] as String?) ?? '';
      final nom = (rawTiers['nom'] as String?) ?? '';
      tiersStr = '$prenom $nom'.trim();
      // Try to get adresse from tiers if not already set
      if (residentAdresse == null || residentAdresse.isEmpty) {
        residentAdresse = rawTiers['adresse'] as String?;
      }
    }

    // Handle motif: can be a String (from dashboard) or extracted from typeContravention (from API)
    String motifStr = json['motif'] as String? ?? '';
    if (motifStr.isEmpty && json['typeContravention'] != null && json['typeContravention'] is Map) {
      final typeMap = json['typeContravention'] as Map<String, dynamic>;
      motifStr = (typeMap['label'] as String?) ?? (typeMap['nom'] as String?) ?? '';
    }

    // Handle status: backend sends 'statut', dashboard sends 'status'
    String statusStr = (json['status'] as String?) ?? (json['statut'] as String?) ?? '';

    // Handle dateTime: backend sends 'dateHeure', dashboard sends 'dateTime'
    String dateTimeStr = (json['dateTime'] as String?) ?? (json['dateHeure'] as String?) ?? '';

    return Contravention(
      rowid: json['rowid'] as int?,
      description: json['description'] as String? ?? '',
      status: statusStr,
      dateTime: dateTimeStr,
      ref: json['ref'] as String? ?? '',
      userAuthor: userAuthorStr,
      tiers: tiersStr,
      motif: motifStr,
      residentAdresse: residentAdresse,
      residentName: json['residentName'] as String?,
      media: (json['media'] as List<dynamic>? ?? [])
          .map(
            (e) => ContraventionMediaModels.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}
