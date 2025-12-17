# API Configuration Guide

## Overview
The dashboard provider is configured to support both **mock data** (for development) and **real CRM API** (when available).

## Current Setup

### 📍 Files Involved
- **Frontend Configuration**: `lib/config/api_config.dart` - Central configuration file
- **API Service**: `lib/services/api_service.dart` - Handles API calls
- **Dashboard Provider**: `lib/providers/dashboard_provider.dart` - Fetches and manages dashboard data
- **Mock Data**: `lib/providers/dashboard_provider.dart` - Contains mock dataset based on CSV

---

## 🔄 Switching Between Mock Data and Real CRM API

### Option 1: Use Mock Data (Current - For Development)

**File**: `lib/config/api_config.dart`

```dart
class ApiConfig {
  static const bool USE_MOCK_DATA = true;  // ✅ Mock data enabled
}
```

**When to use**: 
- During frontend development
- UI/UX testing
- When CRM API is not ready yet

---

### Option 2: Switch to Real CRM API (When Available)

**Step 1**: Update `lib/config/api_config.dart`

```dart
class ApiConfig {
  // Change this to false when CRM API is ready
  static const bool USE_MOCK_DATA = false;  // ❌ Mock data disabled
  
  // Update with actual CRM API URL when available
  // Examples:
  // static const String CRM_API_URL = 'http://192.168.1.100:3000';
  // static const String CRM_API_URL = 'https://crm.example.com';
  static const String CRM_API_URL = 'http://localhost:3000';
  
  // Keep this endpoint or update based on CRM's actual endpoint
  static const String CRM_DASHBOARD_ENDPOINT = '/api/crm/dashboard/stats';
}
```

**Step 2**: The app will automatically:
1. Try to fetch from CRM API first (`http://localhost:3000/api/crm/dashboard/stats`)
2. If CRM API fails, fall back to backend API (`http://localhost:8080/api/dashboard/stats`)
3. Return mock data if both fail in development mode

---

## 📊 Expected CRM API Response Format

When the CRM API is ready, it should return JSON with this structure:

```json
{
  "totalInfractions": 15,
  "resolvedInfractions": 8,
  "monthlyInfractions": {
    "1": 2,
    "2": 1,
    "3": 0,
    "7": 3,
    "8": 2,
    "9": 4,
    "10": 1
  },
  "typeDistribution": [
    { "type": "Simple", "count": 8 },
    { "type": "Double", "count": 7 }
  ],
  "zoneInfractions": {
    "Bâtiment A": 3,
    "Bâtiment B": 3,
    "Bâtiment C": 2,
    "Bâtiment D": 2,
    "Autre": 5
  }
}
```

---

## 🔗 Current API Endpoints

### Backend (Infraction Service)
- **Base URL**: `http://localhost:8080`
- **Dashboard Stats**: `GET /api/dashboard/stats`
- **Currently**: Returns 0 infractions (mock data used instead for UI development)

### CRM (Future)
- **Base URL**: Update in `api_config.dart` when available
- **Dashboard Stats**: `GET /api/crm/dashboard/stats` (or update endpoint as needed)
- **Status**: Not yet available

---

## 🔐 Authentication

### Backend API
- Uses JWT token-based authentication
- Token automatically included in all requests via interceptor
- Token stored in `flutter_secure_storage`

### CRM API
- Currently no authentication configured
- Add authentication if CRM requires it by updating `_setupCrmInterceptor()` in `api_service.dart`

---

## 🧪 Testing the Configuration

### Test Mock Data
```bash
# In lib/config/api_config.dart
static const bool USE_MOCK_DATA = true;

# Run Flutter
flutter run -d edge
# Dashboard should show mock data without any API calls
```

### Test Real API
```bash
# In lib/config/api_config.dart
static const bool USE_MOCK_DATA = false;
static const String CRM_API_URL = 'http://your-crm-server:port';

# Make sure backend is running
cd backend && mvn spring-boot:run

# Run Flutter
flutter run -d edge
# Dashboard will try CRM API first, then fallback to backend
```

---

## 📝 Mock Data Details

Based on `campus_euromed_chambres.csv`:
- **Total Infractions**: 15 records
- **Resolved**: 8 (estimated based on payment status)
- **Monthly Distribution**: Primarily in months 7, 8, 9 (September peak)
- **Type Distribution**: Simple (8) vs Double (7) chambers
- **Zone Distribution**: 5 buildings (Bâtiment A-D + Others)

---

## ⚠️ Fallback Strategy

The API service implements a smart fallback:

```
If USE_MOCK_DATA = false:
  ↓
  Try CRM API
  ↓
  If fails → Try Backend API
  ↓
  If fails → Return error to UI
```

This ensures robustness when transitioning from development to production.

---

## 🚀 Migration Checklist

When CRM API becomes available:

- [ ] Get CRM API URL from professor/team
- [ ] Confirm CRM endpoint returns data in expected format
- [ ] Update `ApiConfig.CRM_API_URL` in `api_config.dart`
- [ ] Update `ApiConfig.CRM_DASHBOARD_ENDPOINT` if endpoint differs
- [ ] Change `USE_MOCK_DATA = false`
- [ ] Add any required authentication headers if needed
- [ ] Test with `flutter run -d edge`
- [ ] Verify fallback works if CRM is temporarily down

---

## 📞 Contact

For questions about the CRM API integration, ask your professor about:
1. CRM API base URL
2. Dashboard endpoint path
3. Authentication method (if required)
4. Expected response format
