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
  static const String CRM_API_URL = 'http://192.168.68.100:3000';

  /// CRM Dashboard endpoint
  static const String CRM_DASHBOARD_ENDPOINT = '/api/crm/dashboard/stats';

  /// Full CRM dashboard URL (computed property)
  static String get crmDashboardUrl => '$CRM_API_URL$CRM_DASHBOARD_ENDPOINT';

  /// Backend Infraction API URL (used when CRM is not available)
  /// Use 192.168.68.100 for network access from devices
  static const String BACKEND_API_URL = 'http://192.168.68.100:8080';

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
