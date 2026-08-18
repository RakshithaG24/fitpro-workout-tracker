import 'package:flutter/material.dart';
import '../models/workout.dart';

class WorkoutProvider with ChangeNotifier {
  final List<Workout> _workouts = [];
  List<MuscleGroup> _muscleGroups = [];
  UserStats? _userStats;
  Workout? _currentWorkout;
  bool _isWorkoutInProgress = false;
  Duration _workoutDuration = Duration.zero;

  List<Workout> get workouts => List.unmodifiable(_workouts);
  List<MuscleGroup> get muscleGroups => List.unmodifiable(_muscleGroups);
  UserStats? get userStats => _userStats;
  Workout? get currentWorkout => _currentWorkout;
  bool get isWorkoutInProgress => _isWorkoutInProgress;
  Duration get workoutDuration => _workoutDuration;

  WorkoutProvider() {
    _initializeData();
  }

  List<ExerciseSet> _sets(double weight, int reps, int count) =>
      List.generate(count, (_) => ExerciseSet(weight: weight, reps: reps));

  Exercise _exercise({
    required String id,
    required String name,
    required int sets,
    required int reps,
    double weight = 0,
    ExerciseType type = ExerciseType.weight,
    String? notes,
  }) {
    return Exercise(
      id: id,
      name: name,
      sets: sets,
      reps: reps,
      weight: weight,
      type: type,
      notes: notes,
      setDetails: _sets(weight, reps, sets),
    );
  }

  void _initializeData() {
    _workouts
      ..clear()
      ..addAll([
        Workout(
          id: '1',
          name: 'Chest + Triceps',
          day: 'Monday',
          duration: 60,
          type: 'Push',
          exercises: [
            _exercise(id: '1', name: 'Barbell Bench Press', sets: 4, reps: 8, weight: 0),
            _exercise(id: '2', name: 'Incline Dumbbell Press', sets: 3, reps: 10, weight: 0),
            _exercise(id: '3', name: 'Cable Fly', sets: 3, reps: 12, weight: 0),
            _exercise(id: '4', name: 'Tricep Pushdown', sets: 3, reps: 12, weight: 0),
            _exercise(id: '5', name: 'Overhead Tricep Extension', sets: 3, reps: 10, weight: 0),
          ],
        ),
        Workout(
          id: '2',
          name: 'Back + Biceps',
          day: 'Tuesday',
          duration: 65,
          type: 'Pull',
          exercises: [
            _exercise(id: '6', name: 'Deadlift', sets: 4, reps: 6, weight: 0),
            _exercise(id: '7', name: 'Lat Pulldown', sets: 3, reps: 10, weight: 0),
            _exercise(id: '8', name: 'Seated Cable Row', sets: 3, reps: 10, weight: 0),
            _exercise(id: '9', name: 'Barbell Curl', sets: 3, reps: 10, weight: 0),
            _exercise(id: '10', name: 'Hammer Curl', sets: 3, reps: 12, weight: 0),
          ],
        ),
        Workout(
          id: '3',
          name: 'Glutes + Hamstrings',
          day: 'Wednesday',
          duration: 65,
          type: 'Lower Body',
          exercises: [
            _exercise(id: '11', name: 'Romanian Deadlift', sets: 4, reps: 8, weight: 0),
            _exercise(id: '12', name: 'Hip Thrust', sets: 4, reps: 10, weight: 0),
            _exercise(id: '13', name: 'Leg Curl', sets: 3, reps: 12, weight: 0),
            _exercise(id: '14', name: 'Glute Kickback', sets: 3, reps: 12, weight: 0),
          ],
        ),
        Workout(
          id: '4',
          name: 'Shoulders + Forearms',
          day: 'Thursday',
          duration: 55,
          type: 'Upper Body',
          exercises: [
            _exercise(id: '15', name: 'Overhead Press', sets: 4, reps: 8, weight: 0),
            _exercise(id: '16', name: 'Lateral Raise', sets: 3, reps: 12, weight: 0),
            _exercise(id: '17', name: 'Rear Delt Fly', sets: 3, reps: 12, weight: 0),
            _exercise(id: '18', name: 'Wrist Curl', sets: 3, reps: 15, weight: 0),
          ],
        ),
        Workout(
          id: '5',
          name: 'Quads + Calves',
          day: 'Friday',
          duration: 60,
          type: 'Lower Body',
          exercises: [
            _exercise(id: '19', name: 'Squat', sets: 4, reps: 8, weight: 0),
            _exercise(id: '20', name: 'Leg Press', sets: 3, reps: 10, weight: 0),
            _exercise(id: '21', name: 'Leg Extension', sets: 3, reps: 12, weight: 0),
            _exercise(id: '22', name: 'Standing Calf Raise', sets: 4, reps: 15, weight: 0),
          ],
        ),
      ]);

    // No personal progress, body metrics, or calendar activity is fabricated.
    // Everything below is derived from what the user actually records.
    _userStats = UserStats(
      bodyWeight: 0,
      heightCm: 0,
      lastWeightUpdate: DateTime.now(),
      volumeLifted: 0,
      period: 'Completed sets',
      workoutCalendar: <DateTime, bool>{},
      dailyVolume: <DateTime, double>{},
    );
    _refreshLiveStats();
  }

  void _refreshLiveStats() {
    final calendar = <DateTime, bool>{};
    final dailyVolume = <DateTime, double>{};
    var totalVolume = 0.0;

    for (final workout in _workouts) {
      for (final exercise in workout.exercises) {
        for (final set in exercise.setDetails) {
          if (!set.completed || set.completedAt == null) continue;
          final day = DateTime(
            set.completedAt!.year,
            set.completedAt!.month,
            set.completedAt!.day,
          );
          final volume = set.weight * set.reps;
          calendar[day] = true;
          dailyVolume[day] = (dailyVolume[day] ?? 0) + volume;
          totalVolume += volume;
        }
      }
    }

    final currentWeight = _userStats?.bodyWeight ?? 0;
    final currentHeight = _userStats?.heightCm ?? 0;
    final lastUpdate = _userStats?.lastWeightUpdate ?? DateTime.now();

    _userStats = UserStats(
      bodyWeight: currentWeight,
      heightCm: currentHeight,
      lastWeightUpdate: lastUpdate,
      volumeLifted: totalVolume,
      period: 'Completed sets',
      workoutCalendar: calendar,
      dailyVolume: dailyVolume,
    );
    _refreshMuscleGroups();
  }

  void _refreshMuscleGroups() {
    final definitions = <String, String>{
      'Chest': '💪',
      'Back': '🏋️',
      'Legs': '🦵',
      'Shoulders': '💪',
    };
    final totals = <String, int>{for (final name in definitions.keys) name: 0};
    final completed = <String, int>{for (final name in definitions.keys) name: 0};

    String groupForWorkout(Workout workout) {
      switch (workout.id) {
        case '1': return 'Chest';
        case '2': return 'Back';
        case '3': return 'Legs';
        case '4': return 'Shoulders';
        case '5': return 'Legs';
        default: return 'Legs';
      }
    }

    for (final workout in _workouts) {
      final group = groupForWorkout(workout);
      for (final exercise in workout.exercises) {
        for (final set in exercise.setDetails) {
          totals[group] = (totals[group] ?? 0) + set.reps;
          if (set.completed) {
            completed[group] = (completed[group] ?? 0) + set.reps;
          }
        }
      }
    }

    _muscleGroups = definitions.entries.map((entry) {
      final total = totals[entry.key] ?? 0;
      final done = completed[entry.key] ?? 0;
      final progress = total == 0 ? 0.0 : (done / total).clamp(0.0, 1.0);
      final status = done == 0
          ? 'Not started'
          : done >= total
              ? 'Completed'
              : 'In progress';
      return MuscleGroup(
        name: entry.key,
        icon: entry.value,
        status: status,
        currentReps: done,
        targetIncrease: 0,
        totalReps: total,
        progress: progress,
      );
    }).toList();
  }

  void updateBodyMetrics({required double weight, required double heightCm}) {
    final previous = _userStats;
    _userStats = UserStats(
      bodyWeight: weight,
      heightCm: heightCm,
      lastWeightUpdate: DateTime.now(),
      volumeLifted: previous?.volumeLifted ?? 0,
      period: previous?.period ?? 'Completed sets',
      workoutCalendar: previous?.workoutCalendar ?? <DateTime, bool>{},
      dailyVolume: previous?.dailyVolume ?? <DateTime, double>{},
    );
    notifyListeners();
  }

  void addExercise({
    required String workoutId,
    required String name,
    required int sets,
    required int reps,
    required double weight,
    required ExerciseType type,
  }) {
    final workout = _workouts.firstWhere((w) => w.id == workoutId);
    final id = '${workoutId}-${DateTime.now().microsecondsSinceEpoch}';
    workout.exercises.add(_exercise(
      id: id,
      name: name,
      sets: sets,
      reps: reps,
      weight: weight,
      type: type,
    ));
    _refreshLiveStats();
    notifyListeners();
  }

  void removeExercise(String workoutId, String exerciseId) {
    final workout = _workouts.firstWhere((w) => w.id == workoutId);
    workout.exercises.removeWhere((e) => e.id == exerciseId);
    _refreshLiveStats();
    notifyListeners();
  }

  void addSet(String workoutId, String exerciseId) {
    final exercise = _findExercise(workoutId, exerciseId);
    final source = exercise.setDetails.isNotEmpty ? exercise.setDetails.last : ExerciseSet(weight: exercise.weight, reps: exercise.reps);
    exercise.setDetails.add(ExerciseSet(weight: source.weight, reps: source.reps));
    _refreshLiveStats();
    notifyListeners();
  }

  void removeSet(String workoutId, String exerciseId, int setIndex) {
    final exercise = _findExercise(workoutId, exerciseId);
    if (exercise.setDetails.length > 1 && setIndex >= 0 && setIndex < exercise.setDetails.length) {
      exercise.setDetails.removeAt(setIndex);
      _refreshLiveStats();
      notifyListeners();
    }
  }

  void updateSet(String workoutId, String exerciseId, int setIndex, {double? weight, int? reps, bool? completed}) {
    final workout = _workouts.firstWhere((w) => w.id == workoutId);
    final exerciseIndex = workout.exercises.indexWhere((e) => e.id == exerciseId);
    if (exerciseIndex < 0) return;
    final exercise = workout.exercises[exerciseIndex];
    if (setIndex < 0 || setIndex >= exercise.setDetails.length) return;

    final set = exercise.setDetails[setIndex];
    if (weight != null) set.weight = weight;
    if (reps != null) set.reps = reps;
    if (completed != null) {
      set.completed = completed;
      set.completedAt = completed ? (set.completedAt ?? DateTime.now()) : null;
    }

    final allCompleted = exercise.setDetails.isNotEmpty && exercise.setDetails.every((s) => s.completed);
    workout.exercises[exerciseIndex] = Exercise(
      id: exercise.id,
      name: exercise.name,
      sets: exercise.setDetails.length,
      reps: exercise.reps,
      weight: exercise.weight,
      notes: exercise.notes,
      type: exercise.type,
      isCompleted: allCompleted,
      setDetails: exercise.setDetails,
    );
    _refreshLiveStats();
    notifyListeners();
  }

  Exercise _findExercise(String workoutId, String exerciseId) {
    final workout = _workouts.firstWhere((w) => w.id == workoutId);
    return workout.exercises.firstWhere((e) => e.id == exerciseId);
  }

  void startWorkout(Workout workout) {
    _currentWorkout = workout;
    _isWorkoutInProgress = true;
    _workoutDuration = Duration.zero;
    notifyListeners();
  }

  void finishWorkout() {
    _currentWorkout = null;
    _isWorkoutInProgress = false;
    _workoutDuration = Duration.zero;
    notifyListeners();
  }

  void updateWorkoutDuration(Duration duration) {
    _workoutDuration = duration;
    notifyListeners();
  }

  void toggleExerciseCompletion(String exerciseId) {
    if (_currentWorkout == null) return;
    final workout = _currentWorkout!;
    final index = workout.exercises.indexWhere((e) => e.id == exerciseId);
    if (index < 0) return;
    final exercise = workout.exercises[index];
    final shouldComplete = !exercise.isCompleted;
    final now = DateTime.now();
    for (final set in exercise.setDetails) {
      set.completed = shouldComplete;
      set.completedAt = shouldComplete ? (set.completedAt ?? now) : null;
    }
    workout.exercises[index] = Exercise(
      id: exercise.id,
      name: exercise.name,
      sets: exercise.setDetails.length,
      reps: exercise.reps,
      weight: exercise.weight,
      notes: exercise.notes,
      type: exercise.type,
      isCompleted: shouldComplete,
      setDetails: exercise.setDetails,
    );
    _refreshLiveStats();
    notifyListeners();
  }
}
