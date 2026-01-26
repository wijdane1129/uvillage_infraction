import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/dashboard_models.dart';

enum ResponsableDashboardState { loading, loaded, error }

class ResponsableDashboardProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  DashboardResponsable? _dashboard;
  ResponsableDashboardState _state = ResponsableDashboardState.loading;
  String _errorMessage = '';

  DashboardResponsable? get dashboard => _dashboard;
  ResponsableDashboardState get state => _state;
  String get errorMessage => _errorMessage;

  Future<void> loadDashboard() async {
    try {
      _state = ResponsableDashboardState.loading;
      notifyListeners();

      final response = await _apiService.get('/dashboard/responsable');
      
      if (response.statusCode == 200) {
        _dashboard = DashboardResponsable.fromJson(response.data);
        _state = ResponsableDashboardState.loaded;
        _errorMessage = '';
      } else {
        _state = ResponsableDashboardState.error;
        _errorMessage = 'Erreur: ${response.statusCode}';
      }
    } catch (e) {
      _state = ResponsableDashboardState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> refreshDashboard() async {
    await loadDashboard();
  }
}
