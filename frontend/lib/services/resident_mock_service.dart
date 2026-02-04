import 'package:flutter/services.dart' show rootBundle;
import '../models/resident_model.dart';

/// Classe pour stocker les informations du résident trouvé
class MockResident {
  final String fullName;
  final String adresse;
  final String? email;
  final String? telephone;

  MockResident({
    required this.fullName,
    required this.adresse,
    this.email,
    this.telephone,
  });
}

/// Service pour charger et rechercher des résidents depuis le fichier CSV mocké
class ResidentMockService {
  // Cache pour éviter de recharger le CSV à chaque fois
  static List<ResidentModel>? _cachedResidents;

  /// Charge les résidents depuis le fichier CSV
  static Future<List<ResidentModel>> loadFromAsset(String assetPath) async {
    // Utiliser le cache si disponible
    if (_cachedResidents != null) {
      return _cachedResidents!;
    }

    final raw = await rootBundle.loadString(assetPath);
    final lines = raw.split(RegExp(r'\r?\n'));
    if (lines.isEmpty) return [];

    // First line assumed to be header; skip it
    final dataLines = lines.skip(1).where((l) => l.trim().isNotEmpty).toList();

    final List<ResidentModel> list = [];
    for (final line in dataLines) {
      // Simple CSV split on comma
      final cols = line.split(',');
      // Trim whitespace and remove possible surrounding quotes
      final normalized = cols.map((c) => c.replaceAll('"', '').trim()).toList();
      list.add(ResidentModel.fromCsvRow(normalized));
    }

    // Mettre en cache
    _cachedResidents = list;
    return list;
  }

  /// 🎯 MÉTHODE CLÉE - Trouve un résident par numéro de chambre et bâtiment
  /// Retourne null si non trouvé
  static Future<MockResident?> findResidentByRoom(
    String? numeroChambre,
    String? batiment,
  ) async {
    if (numeroChambre == null || batiment == null) {
      print('⚠️ findResidentByRoom: chambre ou bâtiment null');
      return null;
    }

    try {
      final residents = await loadFromAsset(
        'assets/data/compus_euromed_chambres.csv',
      );

      // Normaliser le bâtiment (enlever "Immeuble " si présent)
      final normalizedBatiment = _normalizeBuilding(batiment);
      final normalizedChambre = numeroChambre.trim();

      print(
        '🔍 Recherche résident: Chambre=$normalizedChambre, Bâtiment=$normalizedBatiment',
      );

      // Chercher le résident
      final resident = residents.firstWhere((r) {
        final match =
            r.numeroChambre.trim() == normalizedChambre &&
            r.batiment.toUpperCase() == normalizedBatiment.toUpperCase();
        if (match) {
          print('✅ Résident trouvé: ${r.fullName}');
        }
        return match;
      }, orElse: () => throw Exception('Not found'));

      return MockResident(
        fullName: resident.fullName,
        adresse: 'Chambre $normalizedChambre, Bâtiment $normalizedBatiment',
        email: null, // Pas dans le CSV actuel
        telephone: null, // Pas dans le CSV actuel
      );
    } catch (e) {
      print(
        '⚠️ Résident non trouvé pour Chambre $numeroChambre, Bâtiment $batiment: $e',
      );
      return null;
    }
  }

  /// Simple search by room number (exact match)
  /// Find first resident by room number; if `building` provided it matches both
  static Future<ResidentModel?> findByRoom(
    String roomNumber, {
    String? building,
  }) async {
    final list = await loadFromAsset('assets/data/compus_euromed_chambres.csv');
    if (building != null && building.trim().isNotEmpty) {
      // Normalize building to single letter if necessary (e.g. 'Immeuble B' -> 'B')
      final b = _normalizeBuilding(building);
      try {
        return list.firstWhere(
          (r) => r.numeroChambre == roomNumber && r.batiment == b,
        );
      } catch (_) {
        return null;
      }
    }

    // No building provided: return first by room
    try {
      return list.firstWhere((r) => r.numeroChambre == roomNumber);
    } catch (_) {
      return null;
    }
  }

  /// Return all residents with given room number (useful to detect ambiguous matches)
  static Future<List<ResidentModel>> findAllByRoom(String roomNumber) async {
    final list = await loadFromAsset('assets/data/compus_euromed_chambres.csv');
    return list.where((r) => r.numeroChambre == roomNumber).toList();
  }

  /// Extrait le numéro de chambre et le bâtiment à partir d'une adresse
  /// Supporte différents formats:
  /// - "Chambre 312, Bâtiment B"
  /// - "B - Chambre 312"
  /// - "312"
  /// - "B"
  static Map<String, String?> extractRoomAndBuilding(String? adresse) {
    if (adresse == null || adresse.isEmpty) {
      return {'chamber': null, 'building': null};
    }

    String? chamber;
    String? building;

    // Format: "Chambre XXX, Bâtiment Y"
    final chambreMatch = RegExp(
      r'(?:Chambre|chambre)\s+(\d+)',
      caseSensitive: false,
    ).firstMatch(adresse);
    final batimentMatch = RegExp(
      r'(?:Bâtiment|batiment)\s+([A-Z])',
      caseSensitive: false,
    ).firstMatch(adresse);

    if (chambreMatch != null) {
      chamber = chambreMatch.group(1);
    }

    if (batimentMatch != null) {
      building = batimentMatch.group(1)?.toUpperCase();
    }

    // Format: "B - Chambre 312" ou "B - 312"
    if (chamber == null || building == null) {
      final altMatch = RegExp(
        r'([A-Z])\s*-\s*(?:(?:Chambre|chambre)\s+)?(\d+)',
        caseSensitive: false,
      ).firstMatch(adresse);
      if (altMatch != null) {
        if (building == null) building = altMatch.group(1)?.toUpperCase();
        if (chamber == null) chamber = altMatch.group(2);
      }
    }

    return {'chamber': chamber?.trim(), 'building': building?.trim()};
  }

  static String _normalizeBuilding(String raw) {
    final trimmed = raw.trim();
    // If it's like 'Immeuble B' or 'immeuble B', take last token
    final parts = trimmed.split(RegExp(r'\s+'));
    final last = parts.isNotEmpty ? parts.last : trimmed;
    // If last is a single letter, return as uppercase; else return trimmed uppercase first char
    if (last.length == 1) return last.toUpperCase();
    return last.toUpperCase();
  }
}
