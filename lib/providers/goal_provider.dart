import 'package:flutter/foundation.dart';
import '../data/models/goal.dart';
import '../data/repositories/goal_repository.dart';

class GoalProvider extends ChangeNotifier {
  final GoalRepository _repository;
  List<Goal> _goals = [];
  bool _isLoading = false;
  String? _errorMessage;

  GoalProvider(this._repository);

  List<Goal> get goals => _goals;
  List<Goal> get activeGoals => _goals.where((g) => !g.isCompleted).toList();
  List<Goal> get completedGoals => _goals.where((g) => g.isCompleted).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    _setLoading(true);
    try {
      _goals = await _repository.getAllGoals();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load goals: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> saveGoal(Goal goal) async {
    _setLoading(true);
    try {
      final saved = await _repository.saveGoal(goal);
      final index = _goals.indexWhere((g) => g.id == saved.id);
      if (index >= 0) {
        _goals[index] = saved;
      } else {
        _goals.add(saved);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to save goal: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateGoalProgress(String id, double currentProgress) async {
    try {
      await _repository.updateGoalProgress(id, currentProgress);
      _goals = await _repository.getAllGoals();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update goal progress: $e';
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String id) async {
    _setLoading(true);
    try {
      await _repository.deleteGoal(id);
      _goals.removeWhere((g) => g.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete goal: $e';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
