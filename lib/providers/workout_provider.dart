import 'package:flutter/foundation.dart';
import '../data/models/exercise.dart';
import '../data/models/personal_record.dart';
import '../data/models/workout_exercise.dart';
import '../data/models/workout_session.dart';
import '../data/models/workout_set.dart';
import '../data/models/workout_template.dart';
import '../data/repositories/workout_repository.dart';

class WorkoutProvider extends ChangeNotifier {
  final WorkoutRepository _repository;

  List<Exercise> _exerciseCatalog = [];
  List<WorkoutSession> _workoutHistory = [];
  List<PersonalRecord> _personalRecords = [];
  List<WorkoutTemplate> _templates = [];

  // Active workout session in progress
  WorkoutSession? _activeSession;

  bool _isLoading = false;
  String? _errorMessage;

  WorkoutProvider(this._repository);

  List<Exercise> get exerciseCatalog => _exerciseCatalog;
  List<WorkoutSession> get workoutHistory => _workoutHistory;
  List<PersonalRecord> get personalRecords => _personalRecords;
  List<WorkoutTemplate> get templates => _templates;
  WorkoutSession? get activeSession => _activeSession;
  bool get isWorkoutInProgress => _activeSession != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    _setLoading(true);
    try {
      _exerciseCatalog = await _repository.getAllExercises();
      _workoutHistory = await _repository.getAllWorkoutSessions();
      _personalRecords = await _repository.getAllPersonalRecords();
      _templates = await _repository.getAllWorkoutTemplates();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load workout data: $e';
    } finally {
      _setLoading(false);
    }
  }

  // --- Exercise Catalog ---
  Future<void> saveExercise(Exercise exercise) async {
    try {
      final saved = await _repository.saveExercise(exercise);
      final index = _exerciseCatalog.indexWhere((e) => e.id == saved.id);
      if (index >= 0) {
        _exerciseCatalog[index] = saved;
      } else {
        _exerciseCatalog.add(saved);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to save exercise: $e';
      notifyListeners();
    }
  }

  Future<void> deleteExercise(String id) async {
    try {
      await _repository.deleteExercise(id);
      _exerciseCatalog.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete exercise: $e';
      notifyListeners();
    }
  }

  // --- Active Workout Logger ---
  void startWorkout(String title) {
    _activeSession = WorkoutSession(
      id: '',
      title: title.isEmpty ? 'CHEST + TRICEPS' : title,
      date: DateTime.now(),
      durationMinutes: 0,
      exercises: [],
    );
    notifyListeners();
  }

  void startWorkoutFromTemplate(WorkoutTemplate template) {
    final exercises = template.exercises.map((te) {
      ExerciseCategory cat = ExerciseCategory.other;
      final match = _exerciseCatalog.where((e) =>
          e.id == te.exerciseId ||
          e.name.toLowerCase() == te.exerciseName.toLowerCase());
      if (match.isNotEmpty) {
        cat = match.first.category;
      }
      final sets = List.generate(
        te.defaultSets,
        (i) => WorkoutSet(
          setNumber: i + 1,
          weightKg: te.defaultWeightKg,
          reps: te.targetReps,
          isCompleted: false,
        ),
      );
      return WorkoutExercise(
        exerciseId: te.exerciseId,
        exerciseName: te.exerciseName,
        category: cat,
        sets: sets,
      );
    }).toList();

    _activeSession = WorkoutSession(
      id: '',
      title: template.title,
      date: DateTime.now(),
      durationMinutes: template.estimatedDurationMinutes,
      exercises: exercises,
    );
    notifyListeners();
  }

  Future<void> saveTemplate(WorkoutTemplate template) async {
    try {
      final saved = await _repository.saveWorkoutTemplate(template);
      final index = _templates.indexWhere((t) => t.id == saved.id);
      if (index >= 0) {
        _templates[index] = saved;
      } else {
        _templates.add(saved);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to save template: $e';
      notifyListeners();
    }
  }

  Future<void> deleteTemplate(String id) async {
    try {
      await _repository.deleteWorkoutTemplate(id);
      _templates.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete template: $e';
      notifyListeners();
    }
  }

  void toggleSetCompleted(int exerciseIndex, int setIndex) {
    if (_activeSession == null ||
        exerciseIndex >= _activeSession!.exercises.length) {
      return;
    }
    final ex = _activeSession!.exercises[exerciseIndex];
    if (setIndex >= ex.sets.length) return;

    final targetSet = ex.sets[setIndex];
    final updatedSet = targetSet.copyWith(isCompleted: !targetSet.isCompleted);
    final updatedSets = List<WorkoutSet>.from(ex.sets);
    updatedSets[setIndex] = updatedSet;

    final updatedExercise = ex.copyWith(sets: updatedSets);
    final updatedExercises =
        List<WorkoutExercise>.from(_activeSession!.exercises);
    updatedExercises[exerciseIndex] = updatedExercise;

    _activeSession = _activeSession!.copyWith(exercises: updatedExercises);
    notifyListeners();
  }

  void removeSetFromExercise(int exerciseIndex, int setIndex) {
    if (_activeSession == null ||
        exerciseIndex >= _activeSession!.exercises.length) {
      return;
    }
    final ex = _activeSession!.exercises[exerciseIndex];
    if (setIndex >= ex.sets.length) return;

    final updatedSets = List<WorkoutSet>.from(ex.sets)..removeAt(setIndex);
    for (int i = 0; i < updatedSets.length; i++) {
      updatedSets[i] = updatedSets[i].copyWith(setNumber: i + 1);
    }

    final updatedExercise = ex.copyWith(sets: updatedSets);
    final updatedExercises =
        List<WorkoutExercise>.from(_activeSession!.exercises);
    updatedExercises[exerciseIndex] = updatedExercise;

    _activeSession = _activeSession!.copyWith(exercises: updatedExercises);
    notifyListeners();
  }

  void removeExerciseFromActiveWorkout(int exerciseIndex) {
    if (_activeSession == null ||
        exerciseIndex >= _activeSession!.exercises.length) {
      return;
    }
    final updatedExercises =
        List<WorkoutExercise>.from(_activeSession!.exercises)
          ..removeAt(exerciseIndex);
    _activeSession = _activeSession!.copyWith(exercises: updatedExercises);
    notifyListeners();
  }

  void addExerciseToActiveWorkout(Exercise exercise) {
    if (_activeSession == null) return;

    final newExercise = WorkoutExercise(
      exerciseId: exercise.id,
      exerciseName: exercise.name,
      category: exercise.category,
      sets: [
        WorkoutSet(setNumber: 1, weightKg: 60.0, reps: 10),
        WorkoutSet(setNumber: 2, weightKg: 60.0, reps: 8),
        WorkoutSet(setNumber: 3, weightKg: 65.0, reps: 6),
      ],
    );

    final updatedExercises = List<WorkoutExercise>.from(_activeSession!.exercises)..add(newExercise);
    _activeSession = _activeSession!.copyWith(exercises: updatedExercises);
    notifyListeners();
  }

  void addSetToExercise(int exerciseIndex) {
    if (_activeSession == null || exerciseIndex >= _activeSession!.exercises.length) return;

    final ex = _activeSession!.exercises[exerciseIndex];
    final lastSet = ex.sets.isNotEmpty ? ex.sets.last : WorkoutSet(setNumber: 0, weightKg: 50.0, reps: 10);
    final newSet = WorkoutSet(
      setNumber: ex.sets.length + 1,
      weightKg: lastSet.weightKg,
      reps: lastSet.reps,
    );

    final updatedSets = List<WorkoutSet>.from(ex.sets)..add(newSet);
    final updatedExercise = ex.copyWith(sets: updatedSets);
    final updatedExercises = List<WorkoutExercise>.from(_activeSession!.exercises);
    updatedExercises[exerciseIndex] = updatedExercise;

    _activeSession = _activeSession!.copyWith(exercises: updatedExercises);
    notifyListeners();
  }

  void updateSet(int exerciseIndex, int setIndex, {double? weightKg, int? reps}) {
    if (_activeSession == null || exerciseIndex >= _activeSession!.exercises.length) return;

    final ex = _activeSession!.exercises[exerciseIndex];
    if (setIndex >= ex.sets.length) return;

    final targetSet = ex.sets[setIndex];
    final updatedSet = targetSet.copyWith(
      weightKg: weightKg ?? targetSet.weightKg,
      reps: reps ?? targetSet.reps,
    );

    final updatedSets = List<WorkoutSet>.from(ex.sets);
    updatedSets[setIndex] = updatedSet;

    final updatedExercise = ex.copyWith(sets: updatedSets);
    final updatedExercises = List<WorkoutExercise>.from(_activeSession!.exercises);
    updatedExercises[exerciseIndex] = updatedExercise;

    _activeSession = _activeSession!.copyWith(exercises: updatedExercises);
    notifyListeners();
  }

  Future<void> finishWorkout({int durationMinutes = 45, String notes = ''}) async {
    if (_activeSession == null) return;

    final completedSession = _activeSession!.copyWith(
      durationMinutes: durationMinutes,
      notes: notes,
      date: DateTime.now(),
    );

    _setLoading(true);
    try {
      await _repository.saveWorkoutSession(completedSession);
      _workoutHistory = await _repository.getAllWorkoutSessions();
      _personalRecords = await _repository.getAllPersonalRecords();
      _activeSession = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to save workout session: $e';
    } finally {
      _setLoading(false);
    }
  }

  void cancelWorkout() {
    _activeSession = null;
    notifyListeners();
  }

  Future<void> deleteWorkoutSession(String id) async {
    try {
      await _repository.deleteWorkoutSession(id);
      _workoutHistory.removeWhere((w) => w.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete workout session: $e';
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
