import 'package:flutter/services.dart' show rootBundle;
import '../models/resident_model.dart';

class ResidentMockService {
  // Load the CSV from assets and parse into ResidentModel list
  static Future<List<ResidentModel>> loadFromAsset(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final lines = raw.split(RegExp(r'\r?\n'));
    if (lines.isEmpty) return [];

    // First line assumed to be header; skip it
    final dataLines = lines.skip(1).where((l) => l.trim().isNotEmpty).toList();

    final List<ResidentModel> list = [];
    for (final line in dataLines) {
      // Simple CSV split on comma. Works for simple CSV without quoted commas.
      final cols = line.split(',');
      // Trim whitespace and remove possible surrounding quotes
      final normalized = cols.map((c) => c.replaceAll('"', '').trim()).toList();
      list.add(ResidentModel.fromCsvRow(normalized));
    }
    return list;
  }

  // Simple search by room number (exact match)
  // Find first resident by room number; if `building` provided it matches both
  static Future<ResidentModel?> findByRoom(String roomNumber, {String? building}) async {
    final list = await loadFromAsset('assets/data/compus_euromed_chambres.csv');
    if (building != null && building.trim().isNotEmpty) {
      // Normalize building to single letter if necessary (e.g. 'Immeuble B' -> 'B')
      final b = _normalizeBuilding(building);
      try {
        return list.firstWhere((r) => r.numeroChambre == roomNumber && r.batiment == b);
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

  // Return all residents with given room number (useful to detect ambiguous matches)
  static Future<List<ResidentModel>> findAllByRoom(String roomNumber) async {
    final list = await loadFromAsset('assets/data/compus_euromed_chambres.csv');
    return list.where((r) => r.numeroChambre == roomNumber).toList();
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
