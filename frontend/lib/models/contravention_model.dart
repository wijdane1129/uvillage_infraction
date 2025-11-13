import 'package:flutter/material.dart';

enum ContraventionStatus {
  SOUS_VERIFICATION,
  ACCEPTEE,
  CLASSEE_SANS_SUITE,
}

// Small helper class to hold presentation values for a contravention status.
class StatusPresentation {
  final Color color;
  final IconData icon;
  final String statusText;

  StatusPresentation({
    required this.color,
    required this.icon,
    required this.statusText,
  });
}

// Fonction utilitaire pour la présentation visuelle (compatibilité Dart <3)
StatusPresentation getStatusPresentation(ContraventionStatus status, {required Color purpleAccent, required Color successGreen, required Color textSecondary}) {
  String statusText;
  Color color;
  IconData icon;

  switch (status) {
    case ContraventionStatus.SOUS_VERIFICATION:
      statusText = 'Sous vérification';
      color = purpleAccent;
      icon = Icons.access_time_filled;
      break;
    case ContraventionStatus.ACCEPTEE:
      statusText = 'Accepté';
      color = successGreen;
      icon = Icons.check_circle;
      break;
    case ContraventionStatus.CLASSEE_SANS_SUITE:
      statusText = 'Classé';
      color = textSecondary;
      icon = Icons.archive;
      break;
  }
  return StatusPresentation(color: color, icon: icon, statusText: statusText);
}

class ContraventionModel {
  final String ref;
  final String titre; // C'est le 'label' du TypeContravention
  final ContraventionStatus statut;
  final String dateHeure; 
  final String auteurNom; 
  final String residentNom; 

  ContraventionModel({
    required this.ref,
    required this.titre,
    required this.statut,
    required this.dateHeure,
    required this.auteurNom,
    required this.residentNom,
  });

  // Mappage de la réponse JSON du Backend
  factory ContraventionModel.fromJson(Map<String, dynamic> json) {
    final String statusString = json['statut'] as String;
    
    return ContraventionModel(
      ref: json['ref'] as String,
      titre: json['typeContravention']['label'] as String, // Utilise 'label' de votre entité
      statut: ContraventionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == statusString,
      ),
      dateHeure: json['dateHeure'] as String, // Récupère la date formatée
      auteurNom: '${json['userAuthor']['prenom']} ${json['userAuthor']['nom']}',
      residentNom: json['tiers'] != null 
          ? '${json['tiers']['prenom']} ${json['tiers']['nom']}' 
          : 'N/A', 
    );
  }
}