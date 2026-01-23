class Motif {
  final int id;
  final String nom;
  final double montant1;
  final double montant2;
  final double montant3;
  final double montant4;
  final DateTime dateCreation;
  final int utilisations;
  final bool supprime;

  Motif({
    required this.id,
    required this.nom,
    required this.montant1,
    required this.montant2,
    required this.montant3,
    required this.montant4,
    required this.dateCreation,
    required this.utilisations,
    this.supprime = false,
  });

  factory Motif.fromJson(Map<String, dynamic> json) {
    return Motif(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      montant1: (json['montant1'] ?? 0.0).toDouble(),
      montant2: (json['montant2'] ?? 0.0).toDouble(),
      montant3: (json['montant3'] ?? 0.0).toDouble(),
      montant4: (json['montant4'] ?? 0.0).toDouble(),
      dateCreation: json['dateCreation'] != null
          ? DateTime.parse(json['dateCreation'])
          : DateTime.now(),
      utilisations: json['utilisations'] ?? 0,
      supprime: json['supprime'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'montant1': montant1,
      'montant2': montant2,
      'montant3': montant3,
      'montant4': montant4,
      'dateCreation': dateCreation.toIso8601String(),
      'utilisations': utilisations,
      'supprime': supprime,
    };
  }

  Motif copyWith({
    int? id,
    String? nom,
    double? montant1,
    double? montant2,
    double? montant3,
    double? montant4,
    DateTime? dateCreation,
    int? utilisations,
    bool? supprime,
  }) {
    return Motif(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      montant1: montant1 ?? this.montant1,
      montant2: montant2 ?? this.montant2,
      montant3: montant3 ?? this.montant3,
      montant4: montant4 ?? this.montant4,
      dateCreation: dateCreation ?? this.dateCreation,
      utilisations: utilisations ?? this.utilisations,
      supprime: supprime ?? this.supprime,
    );
  }
}
