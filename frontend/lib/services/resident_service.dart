import 'package:flutter/services.dart';
import '../models/resident_models.dart';

class ResidentService {
  static const String _csvPath = 'data/compus_euromed_chambres.csv';

  Future<List<Resident>> loadResidents() async {
    try {
      final csvData = await rootBundle.loadString(_csvPath);
      final lines = csvData.split('\n');
      
      // Ignorer la première ligne (en-tête)
      final residents = <Resident>[];
      
      for (int i = 1; i < lines.length; i++) {
        if (lines[i].isEmpty) continue;
        
        final values = lines[i].split(',');
        if (values.length >= 11) {
          residents.add(Resident.fromCsv(values));
        }
      }
      
      return residents;
    } catch (e) {
      print('Erreur lors du chargement du CSV: $e');
      return [];
    }
  }

  Future<Resident?> getResidentById(String id) async {
    final residents = await loadResidents();
    try {
      return residents.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }
}
