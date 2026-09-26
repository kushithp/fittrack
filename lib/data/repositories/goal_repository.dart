import 'package:uuid/uuid.dart';
import '../models/goal.dart';
import '../services/database_service.dart';

class GoalRepository {
  final IDatabaseService _db;
  final Uuid _uuid = const Uuid();

  GoalRepository(this._db);

  Future<List<Goal>> getAllGoals() async {
    return await _db.getAllGoals();
  }

  Future<Goal> saveGoal(Goal goal) async {
    final goalToSave = goal.id.isEmpty
        ? goal.copyWith(id: _uuid.v4(), createdAt: DateTime.now())
        : goal.copyWith(updatedAt: DateTime.now());
    await _db.saveGoal(goalToSave);
    return goalToSave;
  }

  Future<void> updateGoalProgress(String goalId, double currentProgress) async {
    final goals = await _db.getAllGoals();
    final index = goals.indexWhere((g) => g.id == goalId);
    if (index >= 0) {
      final goal = goals[index];
      final isCompleted = currentProgress >= goal.target;
      final updated = goal.copyWith(
        currentProgress: currentProgress,
        isCompleted: isCompleted,
        updatedAt: DateTime.now(),
      );
      await _db.saveGoal(updated);
    }
  }

  Future<void> deleteGoal(String id) async {
    await _db.deleteGoal(id);
  }
}
