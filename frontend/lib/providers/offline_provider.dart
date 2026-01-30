import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/offline_storage_service.dart';
import '../services/connectivity_service.dart';
import '../services/sync_manager.dart';
import '../models/offline_contravention_model.dart';

// Offline Storage Provider
final offlineStorageProvider = Provider<OfflineStorageService>((ref) {
  return OfflineStorageService();
});

// Connectivity Service Provider
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

// Sync Manager Provider
final syncManagerProvider = Provider<SyncManager>((ref) {
  final storage = ref.watch(offlineStorageProvider);
  return SyncManager(storage);
});

// Connectivity Stream Provider
final connectivityStreamProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectivityStream;
});

// Pending Contraventions Provider
final pendingContraventionsProvider =
    FutureProvider<List<OfflineContravention>>((ref) async {
  final storage = ref.watch(offlineStorageProvider);
  return storage.getPendingContraventions();
});

// Synced Contraventions Provider
final syncedContraventionsProvider =
    FutureProvider<List<OfflineContravention>>((ref) async {
  final storage = ref.watch(offlineStorageProvider);
  return storage.getSyncedContraventions();
});

// Pending Count Provider
final pendingCountProvider = FutureProvider<int>((ref) async {
  final storage = ref.watch(offlineStorageProvider);
  return storage.getPendingCount();
});

// Sync Stats Provider
final syncStatsProvider = FutureProvider((ref) async {
  final syncManager = ref.watch(syncManagerProvider);
  return syncManager.getStats();
});

// Manual Sync Trigger
final syncTriggerProvider = StateNotifierProvider<SyncNotifier, SyncState>(
  (ref) {
    final syncManager = ref.watch(syncManagerProvider);
    final connectivity = ref.watch(connectivityServiceProvider);
    return SyncNotifier(syncManager, connectivity);
  },
);

class SyncState {
  final bool isSyncing;
  final String? message;
  final bool? success;
  final int syncedCount;
  final int failedCount;

  const SyncState({
    this.isSyncing = false,
    this.message,
    this.success,
    this.syncedCount = 0,
    this.failedCount = 0,
  });

  SyncState copyWith({
    bool? isSyncing,
    String? message,
    bool? success,
    int? syncedCount,
    int? failedCount,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      message: message ?? this.message,
      success: success ?? this.success,
      syncedCount: syncedCount ?? this.syncedCount,
      failedCount: failedCount ?? this.failedCount,
    );
  }
}

class SyncNotifier extends StateNotifier<SyncState> {
  final SyncManager _syncManager;
  final ConnectivityService _connectivity;

  SyncNotifier(this._syncManager, this._connectivity)
      : super(const SyncState());

  Future<void> triggerSync() async {
    // Check connectivity first
    final hasConnection = await _connectivity.hasConnection();
    if (!hasConnection) {
      state = state.copyWith(
        message: 'No internet connection',
        success: false,
      );
      return;
    }

    state = state.copyWith(isSyncing: true);

    try {
      final result = await _syncManager.syncAll();
      state = state.copyWith(
        isSyncing: false,
        success: result.success,
        message: result.message,
        syncedCount: result.syncedCount,
        failedCount: result.failedCount,
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        success: false,
        message: 'Sync error: $e',
      );
    }
  }

  void reset() {
    state = const SyncState();
  }
}
