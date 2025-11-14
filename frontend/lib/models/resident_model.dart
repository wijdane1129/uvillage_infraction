class ResidentModel {
  final String id;
  final String nom;
  final String prenom;
  final String sexe;
  final String filiere;
  final String batiment;
  final String numeroChambre;

  ResidentModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.sexe,
    required this.filiere,
    required this.batiment,
    required this.numeroChambre,
  });

  String get fullName => '$prenom $nom';

  factory ResidentModel.fromCsvRow(List<String> row) {
    // Expected columns (based on sample CSV):
    // 0: ID Étudiant, 1: Nom, 2: Prénom, 3: Sexe, 4: Filière, 5: Bâtiment, 6: Numéro Cha
    return ResidentModel(
      id: row.length > 0 ? row[0].trim() : '',
      nom: row.length > 1 ? row[1].trim() : '',
      prenom: row.length > 2 ? row[2].trim() : '',
      sexe: row.length > 3 ? row[3].trim() : '',
      filiere: row.length > 4 ? row[4].trim() : '',
      batiment: row.length > 5 ? row[5].trim() : '',
      numeroChambre: row.length > 6 ? row[6].trim() : '',
    );
  }
}
