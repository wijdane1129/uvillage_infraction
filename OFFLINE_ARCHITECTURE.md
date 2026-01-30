# Offline Architecture Reference

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    Flutter UI Layer                             │
│  ┌──────────────────────┐  ┌──────────────────────────────────┐ │
│  │ Infraction Forms     │  │ Agent Home Screen               │ │
│  │ - Create Screen      │  │ - SyncStatusIndicator Widget    │ │
│  │ - Confirmation       │  │ - Shows pending count           │ │
│  │ - Details            │  │ - Manual sync button            │ │
│  └──────────────────────┘  └──────────────────────────────────┘ │
└──────────────────────────────┬──────────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────────┐
│              Riverpod State Management Layer                     │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ offline_provider.dart                                      │ │
│  │ - offlineStorageProvider                                  │ │
│  │ - connectivityServiceProvider                             │ │
│  │ - syncManagerProvider                                     │ │
│  │ - syncTriggerProvider (with SyncNotifier)                │ │
│  │ - pendingCountProvider                                    │ │
│  │ - connectivityStreamProvider                              │ │
│  └────────────────────────────────────────────────────────────┘ │
└────┬──────────────────────────┬──────────────────────────┬───────┘
     │                          │                          │
     ▼                          ▼                          ▼
┌──────────────────┐  ┌─────────────────────┐  ┌──────────────────┐
│  Service Layer   │  │  Service Layer      │  │  Service Layer   │
│                  │  │                     │  │                  │
│OfflineStorage   │  │ Connectivity Service│  │  SyncManager     │
│ Service          │  │                     │  │                  │
│                  │  │- hasConnection()    │  │- syncAll()       │
│- save()          │  │- connectivityStream │  │- _syncContrav..()│
│- load()          │  │- init()             │  │- _uploadMedia()  │
│- getPending()    │  │                     │  │- getStats()      │
│- getSynced()     │  │Uses:                │  │                  │
│- updateStatus()  │  │connectivity_plus    │  │Uses:             │
│- delete()        │  │                     │  │- Dio HTTP client │
│                  │  │                     │  │- OfflineStorage  │
│                  │  │                     │  │                  │
└────────┬─────────┘  └─────────────────────┘  └────────┬─────────┘
         │                                              │
         └──────────────────┬───────────────────────────┘
                            │
         ┌──────────────────▼──────────────────┐
         │                                      │
         ▼                                      ▼
    ┌──────────────┐                  ┌────────────────┐
    │  Hive DB     │                  │  Backend API   │
    │              │                  │                │
    │- offline_    │  ◄────────────── │- POST /        │
    │  contraventions │ (sync data)   │  contraventions│
    │  (Box)       │                  │- POST /upload  │
    │- Stores:    │                  │                │
    │  * Pending  │                  │Response:       │
    │  * Synced   │                  │- Success or    │
    │  * Errors   │                  │  Error message │
    │  * Media    │                  │                │
    │    paths    │                  └────────────────┘
    └──────────────┘
         │
         ▼
    ┌──────────────┐
    │ Device File  │
    │ System       │
    │              │
    │- Media files │
    │- Hive data   │
    └──────────────┘
```

## Data Flow Diagram

### Happy Path: Online → Offline → Online

```
User Creates Infraction
         │
         ▼
   Check Internet?
         │
    ┌────┴────┐
    │          │
   YES        NO
    │          │
    ▼          ▼
Send to    Save to
Backend    Hive DB
    │          │
    ▼          ▼
Success?   Return
    │      Offline
    ▼      ID
Success
Notify
    │
    ▼
Done


LATER: Internet Restored
         │
         ▼
Connectivity Changed
(stream event)
         │
         ▼
SyncManager.syncAll()
         │
    ┌────┴────┬─────┐
    │          │     │
    ▼          ▼     ▼
For each offline contravention:
    │
    ▼
Upload Media Files
    │
    ▼
Send Contravention Data
    │
    ▼
Mark as Synced?
    │
  ┌─┴─┐
  │   │
 YES NO
  │   │
  ▼   ▼
Update Update Error
Synced  Field
  │
  ▼
UI Updates
  │
  ▼
User Sees Results
```

## Component Interaction Diagram

```
                    ┌────────────────────┐
                    │  User Interaction  │
                    └────────┬───────────┘
                             │
                    ┌────────▼───────────┐
                    │ Infraction Screen  │
                    │ (confirms & sends) │
                    └────────┬───────────┘
                             │
                    ┌────────▼────────────────────┐
                    │ ContraventionService        │
                    │ .createContravention()      │
                    └──┬──────────────────────┬───┘
                       │                      │
             ┌─────────▼──┐         ┌────────▼──────┐
             │ Online?    │         │ ConnectivitySvc│
             │ (Check)    │         │ .hasConnection │
             └──┬──┬──────┘         └────────────────┘
         Online │  │ Offline
           (Y)  │  │ (N)
        ┌──────▘   └──────┐
        │                 │
        ▼                 ▼
    ┌────────┐      ┌──────────────┐
    │ Send   │      │ OfflineStorage│
    │ to     │      │ Service       │
    │Backend │      │ .save()       │
    └───┬────┘      └────┬─────────┘
        │                │
        ▼                ▼
    Success         Saved to Hive
    Response        (Local DB)
        │                │
        └────┬───────────┘
             │
             ▼
    Return Response
    (with offline flag)
         │
         ▼
    ┌─────────┐
    │   UI    │
    │ Updates │
    └────┬────┘
         │
    Connected?
    (Monitor)
         │
    ┌────┴─────────────┐
    │                  │
   YES               (Stream)
    │                  │
    ▼                  │
SyncManager         Connectivity
.syncAll()        Stream Listens
    │                  │
    ▼                  ▼
Upload Media      Triggers Sync
+ Data            If Online
    │
    ▼
Update Status
(Hive)
    │
    ▼
UI Reflects
Sync Status
```

## State Management Flow

```
┌──────────────────────────────────────────────────┐
│          Riverpod State Tree                     │
└──────────────────────────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        │             │             │
        ▼             ▼             ▼

offlineStorage    connectivity    syncManager
   Provider          Provider         Provider
        │             │                 │
        │             │                 │
        ▼             ▼                 ▼
   ┌────────────┐ ┌──────────┐  ┌────────────┐
   │ Hive Box   │ │ Network  │  │ Sync Logic │
   │            │ │ Listener │  │            │
   └────────────┘ └──────────┘  └────────────┘
        │             │                 │
        └─────────────┼─────────────────┘
                      │
                      ▼
         ┌────────────────────────┐
         │ syncTriggerProvider    │
         │ (StateNotifier)        │
         │                        │
         │ State:                 │
         │ - isSyncing            │
         │ - message              │
         │ - success              │
         │ - syncedCount          │
         │ - failedCount          │
         └────────┬───────────────┘
                  │
         ┌────────▼────────────┐
         │  Widgets Watch:     │
         │ - SyncStatusWidget  │
         │ - Home Screen       │
         │ - Other Screens     │
         └─────────────────────┘
```

## Error Handling Flow

```
Error Occurs
     │
     ▼
Is it Network Error?
     │
  ┌──┴──┐
  │     │
 YES   NO
  │     │
  ▼     ▼
Save  Throw
Offline Error
  │
  ▼
Update
syncError
Field
  │
  ▼
Increment
syncAttempts
  │
  ▼
Can Retry?
(attempts < 3)
  │
  ┌──┴──┐
  │     │
 YES   NO
  │     │
  ▼     ▼
Log  Give Up
&    (manual
Wait retry)
  │
  ▼
Notify
User
```

## Sync Sequence Diagram

```
Time →

App         Connectivity    SyncManager    Hive        Backend
│                │              │          │             │
│ Online?        │              │          │             │
├─────────────────────►         │          │             │
│ (monitor)      │              │          │             │
│                │ Connected!   │          │             │
│                ├─────────────►│          │             │
│                │              │          │             │
│                │              │ syncAll()
│                │              ├─────────►│             │
│                │              │          │             │
│                │              │ getPending
│                │              │◄─────────┤             │
│                │              │          │             │
│                │              │ [list]   │             │
│                │              │          │             │
│ ┌─────────────────────────────────────────────┐       │
│ │ For each pending contravention:             │       │
│ │ 1. Upload media files                       │       │
│ │ 2. Send contravention data                  │       │
│ │ 3. Update sync status                       │       │
│ └─────────────────────────────────────────────┘       │
│                │              │          │             │
│                │              │ upload()  │             │
│                │              ├──────────────────────►│
│                │              │          │      OK    │
│                │              │          │◄──────────┤
│                │              │          │             │
│                │              │ post()   │             │
│                │              ├──────────────────────►│
│                │              │          │      OK    │
│                │              │          │◄──────────┤
│                │              │          │             │
│                │              │ updateStatus(synced=true)
│                │              ├─────────►│             │
│                │              │          │             │
│                │              │   OK     │             │
│                │              │◄─────────┤             │
│                │              │          │             │
│                │              │ return   │             │
│                │◄─────────────┤          │             │
│                │              │          │             │
│ Sync Complete  │              │          │             │
│ Update UI      │              │          │             │
│                │              │          │             │
```

## Local Storage Schema (Hive)

```
┌─────────────────────────────────────────────────────┐
│ offline_contraventions (Hive Box)                   │
├─────────────────────────────────────────────────────┤
│ TypeId: 1                                           │
│ Model: OfflineContravention                         │
│                                                     │
│ Fields:                                             │
│ ├─ id: String (UUID)                               │
│ ├─ description: String                              │
│ ├─ typeLabel: String                                │
│ ├─ userAuthorId: int                                │
│ ├─ tiersId: int? (nullable)                         │
│ ├─ mediaUrls: List<String>                          │
│ ├─ mediaTypes: List<String>                         │
│ ├─ createdAt: DateTime                              │
│ ├─ updatedAt: DateTime                              │
│ ├─ isSynced: bool (false = pending, true = synced) │
│ ├─ syncError: String? (null = no error)             │
│ └─ syncAttempts: int                                │
│                                                     │
│ Indexes (by Hive):                                  │
│ ├─ Primary: key (UUID)                              │
│ └─ Virtual: isSynced field (for filtering)          │
│                                                     │
│ Example Record:                                     │
│ {                                                   │
│   id: 'a1b2c3d4-e5f6-4a5b-9c8d-7e6f5a4b3c2d',     │
│   description: 'Parking interdit',                  │
│   typeLabel: 'Parking illégal',                     │
│   userAuthorId: 42,                                 │
│   tiersId: 100,                                     │
│   mediaUrls: [                                      │
│     '/data/photo1.jpg',                             │
│     '/data/video1.mp4'                              │
│   ],                                                │
│   mediaTypes: ['PHOTO', 'VIDEO'],                   │
│   createdAt: 2026-01-30 14:30:00,                   │
│   updatedAt: 2026-01-30 14:30:00,                   │
│   isSynced: false,                                  │
│   syncError: null,                                  │
│   syncAttempts: 0                                   │
│ }                                                   │
└─────────────────────────────────────────────────────┘
```

## Connectivity States

```
Connected = true (Online)
     │
     ├─ WiFi connected
     ├─ Mobile data connected
     └─ Other network connected
     
Connected = false (Offline)
     │
     ├─ Airplane mode
     ├─ WiFi disabled
     ├─ Mobile data disabled
     └─ No signal
```

## Key Design Patterns

### 1. **Offline-First Pattern**
- Save locally first
- Sync to backend when possible
- No data loss

### 2. **Event-Driven Architecture**
- Connectivity changes trigger sync
- UI listens to state changes
- Reactive updates

### 3. **Service Layer Pattern**
- Separation of concerns
- Testable components
- Reusable services

### 4. **Notifier Pattern (Riverpod)**
- Centralized state management
- Immutable state
- Clear state transitions

### 5. **Adapter Pattern (Hive)**
- Type-safe serialization
- Auto-generated adapters
- Efficient storage

---

## Deployment Topology

```
┌─────────────────────────────────────────┐
│        Client Device (Flutter App)      │
│  ┌───────────────────────────────────┐  │
│  │ Offline-First Features            │  │
│  │ - Hive Database (Local)           │  │
│  │ - Connectivity Monitoring         │  │
│  │ - Auto Sync on Connection         │  │
│  └───────────────────────────────────┘  │
└──────────────┬──────────────────────────┘
               │ (HTTPS/REST)
               │
┌──────────────▼──────────────────────────┐
│      Backend API Server                 │
│  ┌───────────────────────────────────┐  │
│  │ /api/v1/contraventions            │  │
│  │ /api/v1/upload                    │  │
│  │ /api/v1/contraventions/stats      │  │
│  └───────────────────────────────────┘  │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         Backend Database                │
│  - Contraventions table                 │
│  - Media files (cloud storage)          │
│  - User data                            │
└─────────────────────────────────────────┘
```

---

## Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **UI** | Flutter | Cross-platform mobile |
| **State** | Riverpod | Reactive state management |
| **Local DB** | Hive | NoSQL local storage |
| **Network** | Dio + connectivity_plus | HTTP client + monitoring |
| **ID Generation** | UUID | Unique offline identifiers |
| **Build** | build_runner | Adapter code generation |

---

**Architecture Version**: 1.0  
**Last Updated**: January 30, 2026  
**Status**: Production Ready ✅
