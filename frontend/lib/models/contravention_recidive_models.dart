import 'dart:io';

class ContraventionRecidiveModels {
  final String label;
  final int nombrerecidive;
  final int montant1;
  final int montant2;
  final int montant3;
  final int montant4;
  ContraventionRecidiveModels({
    required this.label,
    required this.nombrerecidive,
    required this.montant1,
    required this.montant2,
    required this.montant3,
    required this.montant4,
  });
  Map<String, dynamic> toJson() {
    return {
      'labal': label,
      'nombrerexcidive': nombrerecidive,
      'montant1': montant1,
      'montant2': montant2,
      'montant3': montant3,
      'montant4': montant4,
    };
  }
}
