import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/motif_model.dart';
import '../config/api_config.dart';

class MotifService {
  Future<List<Motif>> fetchMotifs() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/motifs'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Motif.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des motifs');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Motif> createMotif(String nom, double montant1, double montant2, double montant3, double montant4) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/motifs'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nom': nom,
          'montant1': montant1,
          'montant2': montant2,
          'montant3': montant3,
          'montant4': montant4,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Motif.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Erreur lors de la création du motif');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Motif> updateMotif(int id, String nom, double montant1, double montant2, double montant3, double montant4) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/motifs/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nom': nom,
          'montant1': montant1,
          'montant2': montant2,
          'montant3': montant3,
          'montant4': montant4,
        }),
      );

      if (response.statusCode == 200) {
        return Motif.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Erreur lors de la mise à jour du motif');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMotif(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/motifs/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Erreur lors de la suppression du motif');
      }
    } catch (e) {
      rethrow;
    }
  }
}

