import 'package:flutter/foundation.dart' show kIsWeb;

/// API Configuration
/// Switch between mock data and real backend API
///
/// To use real backend API:
/// 1. Set USE_MOCK_DATA to false
/// 2. Dashboard will automatically fetch from backend /api/dashboard/stats
class ApiConfig {
  /// Set to true to use mock data, false to use real backend API
  /// Change this to false to fetch real data from the backend
  static const bool USE_MOCK_DATA = false;

  /// CRM API Base URL - Update this when CRM API is available
  /// Example: 'http://192.168.1.100:3000' or 'https://crm.example.com'
  static String get CRM_API_URL {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else {
      return 'http://192.168.110.153:3000';
    }
  }

  /// CRM Dashboard endpoint
  static const String CRM_DASHBOARD_ENDPOINT = '/api/crm/dashboard/stats';

  /// Full CRM dashboard URL (computed property)
  static String get crmDashboardUrl => '$CRM_API_URL$CRM_DASHBOARD_ENDPOINT';

  /// Backend Infraction API URL (used when CRM is not available)
  static String get BACKEND_API_URL {
    if (kIsWeb) {
      return 'http://localhost:8080';
    } else {
      return 'http://192.168.110.153:8080';
    }
  }

  /// Backend dashboard endpoint
  static const String BACKEND_DASHBOARD_ENDPOINT = '/api/dashboard/stats';

  /// Full backend dashboard URL
  static String get backendDashboardUrl =>
      '$BACKEND_API_URL$BACKEND_DASHBOARD_ENDPOINT';

  /// Base URL for API (alias for BACKEND_API_URL)
  static String get baseUrl => BACKEND_API_URL;

  /// Get the appropriate dashboard URL based on configuration
  static String getDashboardUrl() {
    if (USE_MOCK_DATA) {
      return 'mock'; // Special indicator for mock data
    }
    // In the future, you can switch to CRM API
    // return crmDashboardUrl;
    return backendDashboardUrl;
  }
}
