/// Contract for cloud database sync (Firebase / Supabase).
/// Prepared for Stage 8 offline-first replication.
abstract class SyncService {
  Future<bool> isConnected();
  Future<void> syncLocalToCloud();
  Future<void> syncCloudToLocal();
}

/// Offline / Local-Only Sync Service implementation.
class LocalOnlySyncService implements SyncService {
  @override
  Future<bool> isConnected() async => false;

  @override
  Future<void> syncLocalToCloud() async {
    // Local-first: no-op until cloud credentials configured
  }

  @override
  Future<void> syncCloudToLocal() async {
    // Local-first: no-op until cloud credentials configured
  }
}
