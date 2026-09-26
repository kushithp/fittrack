/// Contract for health platform integrations (Apple Health / HealthKit / Google Health Connect).
/// Currently operates using ManualHealthService until HealthKit native plugin is linked in Stage 7.
abstract class HealthService {
  Future<bool> requestPermissions();
  Future<bool> isAvailable();
  Future<int?> getTodayStepCount();
  Future<double?> getTodayDistanceKm();
  Future<double?> getTodayActiveCalories();
}

/// Fallback / Manual health service implementation.
class ManualHealthService implements HealthService {
  @override
  Future<bool> requestPermissions() async {
    return false; // Manual mode - no permissions needed
  }

  @override
  Future<bool> isAvailable() async {
    return false; // HealthKit integration not yet linked
  }

  @override
  Future<int?> getTodayStepCount() async {
    return null; // Relies on user manual logs
  }

  @override
  Future<double?> getTodayDistanceKm() async {
    return null;
  }

  @override
  Future<double?> getTodayActiveCalories() async {
    return null;
  }
}
