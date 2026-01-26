class Resident {
  final String id;
  final String nom;
  final String prenom;
  final String sexe;
  final String filiere;
  final String batiment;
  final String numeroChambre;
  final String typeChambre;
  final String dateEntree;
  final String dateSortie;
  final String statutPaiement;

  Resident({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.sexe,
    required this.filiere,
    required this.batiment,
    required this.numeroChambre,
    required this.typeChambre,
    required this.dateEntree,
    required this.dateSortie,
    required this.statutPaiement,
  });

  String get fullName => '$prenom $nom';
  String get chambre => '$batiment-$numeroChambre';

  factory Resident.fromCsv(List<String> values) {
    return Resident(
      id: values[0],
      nom: values[1],
      prenom: values[2],
      sexe: values[3],
      filiere: values[4],
      batiment: values[5],
      numeroChambre: values[6],
      typeChambre: values[7],
      dateEntree: values[8],
      dateSortie: values[9],
      statutPaiement: values[10],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'sexe': sexe,
      'filiere': filiere,
      'batiment': batiment,
      'numeroChambre': numeroChambre,
      'typeChambre': typeChambre,
      'dateEntree': dateEntree,
      'dateSortie': dateSortie,
      'statutPaiement': statutPaiement,
    };
  }

  factory Resident.fromJson(Map<String, dynamic> json) {
    return Resident(
      id: json['id'] ?? '',
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      sexe: json['sexe'] ?? '',
      filiere: json['filiere'] ?? '',
      batiment: json['batiment'] ?? '',
      numeroChambre: json['numeroChambre'] ?? '',
      typeChambre: json['typeChambre'] ?? '',
      dateEntree: json['dateEntree'] ?? '',
      dateSortie: json['dateSortie'] ?? '',
      statutPaiement: json['statutPaiement'] ?? '',
    );
  }
}
