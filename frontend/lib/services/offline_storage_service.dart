import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/offline_contravention_model.dart';

class OfflineStorageService {
  static const String _boxName = 'offline_contraventions';
  late Box<OfflineContravention> _box;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    
    // Register Hive adapter if not already registered
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(OfflineContraventionAdapter());
    }

    _box = await Hive.openBox<OfflineContravention>(_boxName);
    _initialized = true;
    print('✅ [OfflineStorage] Initialized');
  }

  // Save a new offline contravention
  Future<String> saveOfflineContravention({
    required String description,
    required String typeLabel,
    required int userAuthorId,
    int? tiersId,
    required List<String> mediaUrls,
    required List<String> mediaTypes,
  }) async {
    await _ensureInit();
    
    final id = const Uuid().v4();
    final contravention = OfflineContravention(
      id: id,
      description: description,
      typeLabel: typeLabel,
      userAuthorId: userAuthorId,
      tiersId: tiersId,
      mediaUrls: mediaUrls,
      mediaTypes: mediaTypes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
      syncAttempts: 0,
    );

    await _box.put(id, contravention);
    print('💾 [OfflineStorage] Saved contravention: $id');
    return id;
  }

  // Get all offline contraventions
  Future<List<OfflineContravention>> getAllContraventions() async {
    await _ensureInit();
    return _box.values.toList();
  }

  // Get pending (unsynced) contraventions
  Future<List<OfflineContravention>> getPendingContraventions() async {
    await _ensureInit();
    return _box.values.where((c) => !c.isSynced).toList();
  }

  // Get synced contraventions
  Future<List<OfflineContravention>> getSyncedContraventions() async {
    await _ensureInit();
    return _box.values.where((c) => c.isSynced).toList();
  }

  // Get a specific contravention by ID
  Future<OfflineContravention?> getContravention(String id) async {
    await _ensureInit();
    return _box.get(id);
  }

  // Update sync status
  Future<void> updateSyncStatus(
    String id, {
    required bool isSynced,
    String? syncError,
  }) async {
    await _ensureInit();
    final contravention = _box.get(id);
    if (contravention != null) {
      contravention.isSynced = isSynced;
      contravention.syncError = syncError;
      contravention.updatedAt = DateTime.now();
      if (isSynced) {
        contravention.syncAttempts = 0;
      }
      await contravention.save();
      print('🔄 [OfflineStorage] Updated sync status for: $id (synced: $isSynced)');
    }
  }

  // Increment sync attempts
  Future<void> incrementSyncAttempts(String id) async {
    await _ensureInit();
    final contravention = _box.get(id);
    if (contravention != null) {
      contravention.syncAttempts++;
      contravention.updatedAt = DateTime.now();
      await contravention.save();
    }
  }

  // Delete a contravention
  Future<void> deleteContravention(String id) async {
    await _ensureInit();
    await _box.delete(id);
    print('🗑️  [OfflineStorage] Deleted contravention: $id');
  }

  // Delete all synced contraventions
  Future<void> deleteSyncedContraventions() async {
    await _ensureInit();
    final synced = await getSyncedContraventions();
    for (final c in synced) {
      await _box.delete(c.id);
    }
    print('🗑️  [OfflineStorage] Deleted ${synced.length} synced contraventions');
  }

  // Get count of pending contraventions
  Future<int> getPendingCount() async {
    await _ensureInit();
    return _box.values.where((c) => !c.isSynced).length;
  }

  // Clear all contraventions
  Future<void> clearAll() async {
    await _ensureInit();
    await _box.clear();
    print('🗑️  [OfflineStorage] Cleared all contraventions');
  }

  Future<void> _ensureInit() async {
    if (!_initialized) {
      await init();
    }
  }
}
