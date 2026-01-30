# Offline Feature - Quick Start

## What's New

✅ **Create contraventions offline** - No internet? No problem!  
✅ **Automatic sync** - When connection restored, data syncs automatically  
✅ **Manual sync** - Force sync with a button tap  
✅ **Sync status UI** - See pending items and sync progress  
✅ **Error handling** - Graceful fallback if sync fails  

## For Users/Agents

### Creating Offline
1. Open app (online or offline - doesn't matter!)
2. Create infraction as usual
3. Tap "Envoyer" to submit
4. If no connection:
   - Orange notification appears: "Infraction créée en mode hors ligne"
   - Infraction saved locally
5. When internet comes back:
   - **Automatic sync** happens in background
   - Green notification: "X synchronisé(s)"

### Manual Sync
- If auto-sync doesn't happen, tap **"Synchroniser X"** button on home screen
- See real-time sync progress
- View any sync errors

## For Developers

### Key Services

| Service | Purpose |
|---------|---------|
| `OfflineStorageService` | Save/load contraventions from Hive |
| `ConnectivityService` | Monitor network status |
| `SyncManager` | Upload media and sync data |
| `SyncStatusIndicator` | UI widget showing sync status |

### Using Offline Features

```dart
// Check pending contraventions
final pending = await ref.read(offlineStorageProvider)
    .getPendingContraventions();

// Trigger sync manually
ref.read(syncTriggerProvider.notifier).triggerSync();

// Watch pending count
final count = ref.watch(pendingCountProvider);
```

### File Locations

```
lib/
├── models/
│   └── offline_contravention_model.dart     ← Data model
├── services/
│   ├── offline_storage_service.dart         ← Local storage
│   ├── connectivity_service.dart            ← Network monitor
│   └── sync_manager.dart                    ← Sync logic
├── providers/
│   └── offline_provider.dart                ← Riverpod providers
└── widgets/
    └── sync_status_indicator.dart           ← Status UI
```

### Generate Hive Adapter

```bash
cd frontend
flutter pub run build_runner build
```

This creates `offline_contravention_model.g.dart`

## Architecture Diagram

```
┌─────────────────────────────────────────┐
│     Infraction Creation Screen          │
└─────────────────────┬───────────────────┘
                      │
                      ▼
         ┌────────────────────────┐
         │ ContraventionService   │
         └────────┬───────────────┘
                  │
        ┌─────────┴─────────┐
        │                   │
    Online?            Offline?
        │                   │
        ▼                   ▼
   Send to Backend    Save to Hive
   (OfflineStorage)
        │
        └──────────┬──────────┐
                   │          │
            Success?    No Connection?
                ✅           │
                        ┌────▼────┐
                        │Hive Db  │
                        │(pending)│
                        └────┬────┘
                             │
                        Connection
                        Restored?
                             │
                             ▼
                        ┌──────────────┐
                        │ SyncManager  │
                        │ (Upload +    │
                        │  Sync Data)  │
                        └──────────────┘
```

## Status Indicators

| Indicator | Meaning | Action |
|-----------|---------|--------|
| 🟠 Orange badge | X items offline | Wait for connection |
| 🔴 Red warning | No connection | Check WiFi/data |
| 🔵 Blue progress | Syncing... | Wait for completion |
| 🟢 Green check | X synced | Done! |

## Testing Checklist

- [ ] Create infraction while online - syncs immediately
- [ ] Create infraction while offline - saves locally
- [ ] Restore connection - automatic sync works
- [ ] Tap sync button - manual sync works
- [ ] Check Hive database contains offline contraventions
- [ ] Media files upload correctly
- [ ] Error messages show if sync fails

## Important Notes

⚠️ **Media Files**: Local file paths stored in Hive. Must exist on device for sync.

⚠️ **Hive Box**: Data persists even after app close. Manual cleanup available via `clearAll()`.

⚠️ **UUID**: Each offline contravention gets unique UUID. Backend assigns actual ID on sync.

⚠️ **Retry Logic**: Max 3 sync attempts before giving up. Manual sync can retry unlimited times.

## Quick Debug Commands

```dart
// View all offline contraventions
final all = await ref.read(offlineStorageProvider).getAllContraventions();
print(all);

// View only pending
final pending = await ref.read(offlineStorageProvider).getPendingContraventions();
print('Pending: ${pending.length}');

// Clear all offline data
await ref.read(offlineStorageProvider).clearAll();

// Check connectivity
final hasConn = await ref.read(connectivityServiceProvider).hasConnection();
print('Connected: $hasConn');
```

## Sync Response Example

```dart
{
  'id': '550e8400-e29b-41d4-a716-446655440000',  // UUID or backend ID
  'status': 'pending',                             // pending or success
  'offline': true,                                 // offline created?
  'message': 'Contravention créée en mode hors ligne',
  'syncedCount': 0,                               // If synced
  'failedCount': 0,                               // If sync failed
}
```

---

**Need help?** Check `OFFLINE_FUNCTIONALITY.md` for detailed documentation.
