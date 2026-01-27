import 'package:dio/dio.dart';
import 'dart:convert';
import '../models/motif_model.dart';
import '../config/api_config.dart';
import 'api_client.dart';

class MotifService {
  Future<List<Motif>> fetchMotifs() async {
    try {
      // Use Dio client so the Authorization header interceptor is applied
      final Dio dio = ApiClient.dio;
      final resp = await dio.get('${ApiConfig.baseUrl}/api/motifs');
      if (resp.statusCode == 200) {
        final List<dynamic> data = resp.data ?? [];
        return data.map((json) => Motif.fromJson(json)).toList();
      }
      throw Exception('Erreur lors de la récupération des motifs');
    } catch (e) {
      rethrow;
    }
  }

  Future<Motif> createMotif(String nom, double montant1, double montant2, double montant3, double montant4) async {
    try {
      final Dio dio = ApiClient.dio;
      final resp = await dio.post(
        '${ApiConfig.baseUrl}/api/motifs',
        data: {
          'nom': nom,
          'montant1': montant1,
          'montant2': montant2,
          'montant3': montant3,
          'montant4': montant4,
        },
      );

      if (resp.statusCode == 201 || resp.statusCode == 200) {
        return Motif.fromJson(resp.data);
      }
      throw Exception('Erreur lors de la création du motif');
    } catch (e) {
      rethrow;
    }
  }

  Future<Motif> updateMotif(int id, String nom, double montant1, double montant2, double montant3, double montant4) async {
    try {
      final Dio dio = ApiClient.dio;
      final resp = await dio.put('${ApiConfig.baseUrl}/api/motifs/$id', data: {
        'nom': nom,
        'montant1': montant1,
        'montant2': montant2,
        'montant3': montant3,
        'montant4': montant4,
      });

      if (resp.statusCode == 200) {
        return Motif.fromJson(resp.data);
      }
      throw Exception('Erreur lors de la mise à jour du motif');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMotif(int id) async {
    try {
      final Dio dio = ApiClient.dio;
      final resp = await dio.delete('${ApiConfig.baseUrl}/api/motifs/$id');
      if (resp.statusCode != 204 && resp.statusCode != 200) {
        throw Exception('Erreur lors de la suppression du motif');
      }
    } catch (e) {
      rethrow;
    }
  }
}

