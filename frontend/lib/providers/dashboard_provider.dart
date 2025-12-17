import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/dashboard_models.dart';
import '../config/api_config.dart';

enum DashboardState { loading, loaded, error }

class DashboardProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  DashboardStats? _stats;
  DashboardState _state = DashboardState.loading;
  String _errorMessage = '';

  DashboardStats? get stats => _stats;
  DashboardState get state => _state;
  String get errorMessage => _errorMessage;

  /// Mock data generated from the CSV dataset (campus_euromed_chambres.csv)
  /// This is temporary until the CRM API is available
  DashboardStats _generateMockData() {
    // Parse the CSV data to extract statistics
    final mockStats = DashboardStats(
      totalInfractions: 15, // Count of records
      resolvedInfractions: 8, // Estimated based on "Statut Paiement" = "Payé"
      // No reliable infraction date available in the CSV (only entry/exit months),
      // so we leave monthly infractions blank (all zeros) so the chart shows
      // "Aucune donnée" instead of misleading counts.
      monthlyInfractions: {
        '1': 0,
        '2': 0,
        '3': 0,
        '4': 0,
        '5': 0,
        '6': 0,
        '7': 0,
        '8': 0,
        '9': 0,
        '10': 0,
        '11': 0,
        '12': 0,
      },
      typeDistribution: [],
      zoneInfractions: {
        'Bâtiment A': 3,
        'Bâtiment B': 3,
        'Bâtiment C': 2,
        'Bâtiment D': 2,
      },
    );
    return mockStats;
  }

  Future<void> fetchStats() async {
    _state = DashboardState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      if (ApiConfig.USE_MOCK_DATA) {
        // Use mock data for development
        await Future.delayed(const Duration(milliseconds: 500));
        _stats = _generateMockData();
      } else {
        // Use real CRM API when available
        _stats = await _apiService.fetchDashboardStats();
      }
      _state = DashboardState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = DashboardState.error;
    } finally {
      notifyListeners();
    }
  }
}
