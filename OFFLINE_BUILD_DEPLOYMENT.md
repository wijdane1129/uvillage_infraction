# Offline Sync - Build & Deployment Guide

## Quick Start Commands

### Fresh Setup

```bash
cd frontend

# 1. Get all dependencies
flutter pub get

# 2. Generate Hive adapter (CRITICAL!)
flutter pub run build_runner build

# 3. Generate localizations
flutter gen-l10n

# 4. Clean and prepare
flutter clean

# 5. Build APK
flutter build apk --release

# Or build iOS
flutter build ios --release
```

### For Development

```bash
cd frontend

# Run on device/emulator with offline support
flutter run

# Run with verbose logging to see offline operations
flutter run -v

# Watch for changes (hot reload works with offline)
flutter run --debug
```

## Verifying Build Success

After building, verify these files exist:

```bash
# Hive adapter (auto-generated)
ls -la frontend/lib/models/offline_contravention_model.g.dart

# Localizations (if using gen-l10n)
ls -la frontend/lib/gen_l10n/

# Dependencies installed
grep -E "connectivity_plus|uuid" frontend/pubspec.lock
```

## Environment Setup

### Android Permissions

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

Note: Usually auto-added by Flutter.

### iOS Permissions

Add to `ios/Runner/Info.plist`:

```xml
<key>NSLocalNetworkUsageDescription</key>
<string>This app needs access to your local network to work offline</string>
```

### Required App Permissions

The app needs these for offline support:

| Permission | Purpose | Platform |
|-----------|---------|----------|
| INTERNET | Backend sync | All |
| ACCESS_NETWORK_STATE | Connectivity monitoring | Android |
| NSLocalNetwork | Network detection | iOS |

## Backend API Expectations

### Contravention Endpoint

**POST** `/api/v1/contraventions`

Expected request:
```json
{
  "description": "string",
  "typeLabel": "string",
  "userAuthorId": 123,
  "tiersId": 456,              // optional
  "mediaUrls": ["url1", "url2"] // optional
}
```

Expected response:
```json
{
  "id": 789,
  "status": "created",
  "createdAt": "2026-01-30T10:00:00Z"
}
```

### Media Upload Endpoint

**POST** `/api/v1/upload`

Request: `multipart/form-data` with:
- `file`: Binary file data
- `mediaType`: "PHOTO" | "VIDEO" | "AUDIO"

Expected response:
```json
{
  "mediaUrl": "https://storage.example.com/media/uuid.jpg",
  "mediaType": "PHOTO"
}
```

## Debugging Offline Operations

### Enable Logging

The app has built-in debug logging. Look for these prefixes:

```
[OfflineStorage]  - Local storage operations
[Connectivity]    - Network status changes
[SyncManager]     - Sync operations
[CREATE]          - Contravention creation
[STATS]           - Statistics fetch
```

### Monitor Hive Database

```dart
// In debug console, check Hive box contents
final box = Hive.box<OfflineContravention>('offline_contraventions');
print('Total offline: ${box.length}');
print('All: ${box.values.toList()}');

// Check pending only
final pending = box.values.where((c) => !c.isSynced).toList();
print('Pending: ${pending.length}');
```

### Test Connectivity State

```dart
// Force offline state
final connectivity = ConnectivityService();
await connectivity.init();
print('Connected: ${connectivity.isConnected}');

// Watch changes
connectivity.connectivityStream.listen((isConnected) {
  print('Connectivity changed: $isConnected');
});
```

### Manual Sync Trigger

```dart
// In development/debugging
final syncManager = SyncManager(offlineStorage);
final result = await syncManager.syncAll();
print('Sync result: $result');
```

## Testing Offline Scenarios

### Simulate Offline Mode

#### Method 1: DevTools
```
Flutter DevTools Network Tab → Simulate offline
```

#### Method 2: Device Settings
```
Settings → Network & Internet → Turn off WiFi + Mobile Data
```

#### Method 3: Android Emulator
```
Extended Controls → Connectivity → Airplane mode ON
```

#### Method 4: iOS Simulator
```
Simulator menu → Features → Network Link Conditioner
```

### Test Scenarios

#### Scenario 1: Pure Offline
1. Disable network completely
2. Create contravention
3. Verify saved locally
4. Enable network
5. Verify auto-sync

#### Scenario 2: Poor Connection
1. Enable network but with high latency
2. Create contravention (should timeout and save offline)
3. Improve connection
4. Verify sync completes

#### Scenario 3: API Error
1. Enable network but backend offline
2. Create contravention (should save offline)
3. Start backend
4. Verify sync succeeds

#### Scenario 4: Media Upload
1. Go offline
2. Create contravention with images/videos
3. Verify media stored locally
4. Go online and sync
5. Verify media uploaded to backend

## Performance Tuning

### Optimize Sync

```dart
// Increase retry attempts
const maxSyncAttempts = 5; // Default: 3

// Adjust sync timeout
_dio.options.connectTimeout = Duration(seconds: 30);
_dio.options.receiveTimeout = Duration(seconds: 30);
```

### Memory Management

```dart
// Clear old synced items periodically
final storage = OfflineStorageService();
await storage.deleteSyncedContraventions();

// Or clear everything
await storage.clearAll();
```

### Database Optimization

```dart
// Compact Hive box (removes deleted items)
final box = Hive.box<OfflineContravention>('offline_contraventions');
await box.compact();
```

## Monitoring & Analytics

### Log Sync Events

Add to your analytics:

```dart
final stats = await syncManager.getStats();
// Log:
// - totalPending
// - totalSynced
// - pendingWithErrors

// Track in Firebase/Mixpanel/etc
logEvent('offline_sync', {
  'pending': stats.totalPending,
  'synced': stats.totalSynced,
  'errors': stats.pendingWithErrors,
});
```

### Health Checks

```dart
// Daily health check
void checkOfflineHealth() {
  final storage = OfflineStorageService();
  final pending = await storage.getPendingContraventions();
  
  // Alert if too many pending (>100)
  if (pending.length > 100) {
    sendAlert('High pending sync count: ${pending.length}');
  }
  
  // Alert if errors accumulating
  final errors = pending.where((c) => c.syncError != null).length;
  if (errors > 10) {
    sendAlert('High sync error count: $errors');
  }
}
```

## Deployment

### Pre-Deployment Checks

```bash
# 1. Verify all dependencies resolve
flutter pub get

# 2. Check for lint errors
flutter analyze

# 3. Run available tests
flutter test

# 4. Build release version
flutter build apk --release
# OR
flutter build ios --release

# 5. Verify no runtime warnings
flutter run --release
```

### Release Build

```bash
# Android APK
flutter build apk --release --target-platform=android-arm64

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release

# Web
flutter build web --release
```

### Rollout Strategy

1. **Beta**: Deploy to 5% of users
2. **Monitor**: Check sync success rates, error rates, performance
3. **Gradual**: Roll out to 25%, 50%, 100% if metrics good
4. **Hotfix**: Have rollback plan ready

### Monitoring Dashboards

Track these metrics:

- Offline creation rate (% of creations offline)
- Sync success rate (% synced / created)
- Sync latency (time from offline to synced)
- Error rate (% sync failures)
- User retention (offline availability impact)

## Troubleshooting Deployment

### Issue: Hive adapter not found at runtime
```
Fix: Ensure build_runner completed successfully
Run: flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: Connectivity_plus not working on platform X
```
Fix: Check platform-specific permissions
- Android: Check AndroidManifest.xml permissions
- iOS: Check Info.plist permissions
- Windows: Check network access settings
```

### Issue: Sync hanging/slow
```
Fix: Check backend health
- Test endpoint directly: curl /api/v1/contraventions
- Check database performance
- Verify network latency
```

### Issue: Data corruption in Hive
```
Fix: Clear and rebuild
flutter clean
rm -rf build/
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## Production Monitoring

### Key Metrics to Track

```dart
// 1. Offline Usage
final pending = await storage.getPendingContraventions();
track('pending_contraventions', pending.length);

// 2. Sync Success Rate
final result = await syncManager.syncAll();
track('sync_success_rate', result.success ? 1.0 : 0.0);

// 3. Sync Latency
final duration = DateTime.now().difference(contravention.createdAt);
track('sync_latency', duration.inSeconds);

// 4. Network Availability
connectivityService.connectivityStream.listen((isConnected) {
  track('connectivity_status', isConnected ? 'online' : 'offline');
});
```

## Support & Updates

### Check for Issues
- GitHub Issues: Search for "offline", "sync", "connectivity"
- Test on actual devices (not just emulator)
- Report with logs: grep -i "error\|failed" app.log

### Update Dependencies
```bash
# Check for updates
flutter pub outdated

# Update packages
flutter pub upgrade

# Update specific package
flutter pub upgrade connectivity_plus
```

---

**Ready to Deploy**: ✅
**Last Updated**: January 30, 2026
