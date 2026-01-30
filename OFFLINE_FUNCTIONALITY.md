# Offline Functionality Guide

## Overview

The Infractions App now supports offline-first functionality. When agents are offline, they can create contraventions locally, and when internet connection is restored, the app automatically syncs the data with the backend.

## Architecture

### Key Components

#### 1. **OfflineStorageService** (`lib/services/offline_storage_service.dart`)
- Manages local storage of contraventions using Hive database
- Stores both synced and unsynced contraventions
- Key methods:
  - `saveOfflineContravention()` - Save a new contravention locally
  - `getPendingContraventions()` - Get unsynced contraventions
  - `getSyncedContraventions()` - Get already synced contraventions
  - `updateSyncStatus()` - Mark a contravention as synced
  - `getPendingCount()` - Get count of pending syncs

#### 2. **ConnectivityService** (`lib/services/connectivity_service.dart`)
- Monitors network connectivity status
- Provides real-time stream of connectivity changes
- Methods:
  - `hasConnection()` - Check current connection status
  - `connectivityStream` - Stream that emits connectivity changes

#### 3. **SyncManager** (`lib/services/sync_manager.dart`)
- Handles syncing offline contraventions to the backend
- Uploads media files before syncing contravention data
- Implements retry logic and error handling
- Key methods:
  - `syncAll()` - Sync all pending contraventions
  - `getStats()` - Get sync statistics

#### 4. **OfflineContravention Model** (`lib/models/offline_contravention_model.dart`)
- Hive-compatible model for storing contraventions locally
- Fields include:
  - `id` - UUID for unique identification
  - `description` - Contravention description
  - `typeLabel` - Type/motif of infraction
  - `userAuthorId` - Agent who created it
  - `tiersId` - Resident ID (if applicable)
  - `mediaUrls` - Local paths to media files
  - `mediaTypes` - Types of media (PHOTO, VIDEO, AUDIO)
  - `isSynced` - Sync status
  - `syncError` - Error message if sync failed
  - `syncAttempts` - Number of sync attempts

#### 5. **Riverpod Providers** (`lib/providers/offline_provider.dart`)
- `offlineStorageProvider` - Access to offline storage service
- `connectivityServiceProvider` - Access to connectivity service
- `syncManagerProvider` - Access to sync manager
- `pendingContraventionsProvider` - Watch pending contraventions
- `pendingCountProvider` - Watch count of pending contraventions
- `syncTriggerProvider` - Manage sync state and trigger syncs
- `connectivityStreamProvider` - Stream connectivity changes

#### 6. **SyncStatusIndicator Widget** (`lib/widgets/sync_status_indicator.dart`)
- UI widget showing sync status
- Displays:
  - Pending count when offline
  - No connection warning when disconnected
  - Sync progress during syncing
  - Success message after sync
  - Manual sync button when online

## User Flow

### Creating an Infraction (Offline)

1. **Agent creates infraction** via the normal UI flow
2. **At confirmation screen**: User taps "Envoyer" (Send)
3. **If offline**:
   - Contravention saved to local Hive database
   - User sees orange notification: "Infraction créée en mode hors ligne"
   - Status badge shows "pending"
   - Contravention appears in local storage with `isSynced = false`

### Syncing Contraventions (Online)

1. **Connection restored**: App automatically detects via ConnectivityService
2. **Automatic sync**: SyncManager triggers sync of all pending contraventions
3. **Media upload**: Local media files are uploaded first
4. **Contravention sync**: Then the contravention data is sent to backend
5. **Status update**: Local storage updated with sync status
6. **User notified**: Green notification shows "X synchronisé(s)"

### Manual Sync

- Users can tap "Synchroniser X" button in the SyncStatusIndicator
- Useful if automatic sync fails or needs to be retriggered

## Integration with ContraventionService

The `ContraventionService` now has offline support:

```dart
final result = await service.createContravention(
  description: description,
  typeLabel: motif,
  userAuthorId: agentRowid,
  tiersId: tiersId,
  mediaUrls: mediaUrls,
);

// Response includes:
// {
//   'id': 'uuid-or-response-id',
//   'status': 'pending|success',
//   'offline': true|false,
//   'message': 'Status message',
// }
```

## Error Handling

1. **No Internet**: Automatically saves offline and notifies user
2. **API Error**: Saves offline and shows error message; user can retry when online
3. **Media Upload Failure**: Continues sync with error; user can retry
4. **Sync Failures**: 
   - Retries up to 3 times (configurable)
   - Stores error message in `syncError` field
   - User can view pending syncs and manually trigger retry

## Database

- **Storage Engine**: Hive (local NoSQL database)
- **Box Name**: `offline_contraventions`
- **Type ID**: 1 (for OfflineContravention model)
- **Location**: Device-specific (handled by `hive_flutter`)

## Configuration

### Hive Adapter Generation

The `OfflineContravention` class requires a Hive adapter for serialization. The adapter is generated automatically:

```bash
# Run this command in the frontend directory
flutter pub run build_runner build
```

This generates `offline_contravention_model.g.dart` with the `OfflineContraventionAdapter`.

### Dependencies Added

```yaml
connectivity_plus: ^5.0.0    # Network connectivity monitoring
uuid: ^4.0.0                 # UUID generation for offline contraventions
```

## Testing Offline Functionality

### Simulate Offline Mode

1. **Development**: Use DevTools to disable network
2. **Testing**: Use device settings to toggle WiFi/mobile data
3. **Android**: Use Android Emulator network settings

### Test Scenarios

1. **Create while offline**: Create a contravention with no internet
2. **Restore connection**: Enable internet and watch auto-sync
3. **Manual sync**: Trigger sync manually via button
4. **Failed sync**: Create while offline, simulate API error on sync

## Future Enhancements

1. **Offline analytics**: Track created-offline contraventions
2. **Smart sync scheduling**: Sync during off-peak hours
3. **Data compression**: Compress media before uploading
4. **Conflict resolution**: Handle conflicts if contravention modified while offline
5. **Offline search**: Search through cached contraventions
6. **Sync history**: View history of synced items

## Troubleshooting

### Sync not triggering
- Check internet connection in settings
- Manually tap "Synchroniser" button
- Restart app (triggers `initState` which calls sync)

### Contraventions stuck in pending
- Check device disk space for media files
- Review error message in app
- Check backend logs for API errors

### Hive database errors
- Clear app data: `adb shell pm clear com.example.infractions_app`
- Verify `flutter pub run build_runner build` was run
- Check that adapter is registered in `main.dart`

## Code Examples

### Manually Check Sync Status

```dart
final storage = ref.read(offlineStorageProvider);
final pending = await storage.getPendingContraventions();
print('Pending: ${pending.length}');
```

### Trigger Manual Sync

```dart
final syncNotifier = ref.read(syncTriggerProvider.notifier);
await syncNotifier.triggerSync();
```

### Listen to Connectivity Changes

```dart
final connectivity = ref.watch(connectivityStreamProvider);
connectivity.when(
  data: (isConnected) {
    print('Connected: $isConnected');
  },
  loading: () => print('Checking connectivity...'),
  error: (err, _) => print('Error: $err'),
);
```

## Files Modified/Created

### New Files
- `lib/models/offline_contravention_model.dart`
- `lib/services/offline_storage_service.dart`
- `lib/services/connectivity_service.dart`
- `lib/services/sync_manager.dart`
- `lib/providers/offline_provider.dart`
- `lib/widgets/sync_status_indicator.dart`

### Modified Files
- `pubspec.yaml` - Added dependencies
- `lib/main.dart` - Initialize offline services
- `lib/services/contravention_service.dart` - Added offline support
- `lib/providers/contravention_provider.dart` - Added offline providers
- `lib/screens/infraction_confirmation_screen.dart` - Handle offline response
- `lib/screens/agent_home_screen.dart` - Display sync status indicator

## Support

For issues or questions about offline functionality, refer to the inline code comments or create a GitHub issue.
