class Workout {
  final String id;
  final String name;
  final String day;
  final int duration;
  final List<Exercise> exercises;
  final String type;

  Workout({
    required this.id,
    required this.name,
    required this.day,
    required this.duration,
    required this.exercises,
    required this.type,
  });
}

class ExerciseSet {
  double weight;
  int reps;
  bool completed;
  DateTime? completedAt;

  ExerciseSet({
    this.weight = 0,
    this.reps = 0,
    this.completed = false,
    this.completedAt,
  });
}

class Exercise {
  final String id;
  final String name;
  final int sets;
  final int reps;
  final double weight;
  final String? notes;
  final bool isCompleted;
  final ExerciseType type;
  final List<ExerciseSet> setDetails;

  Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
    this.notes,
    this.isCompleted = false,
    this.type = ExerciseType.weight,
    List<ExerciseSet>? setDetails,
  }) : setDetails = setDetails ??
            List.generate(
              sets,
              (_) => ExerciseSet(weight: weight, reps: reps),
            );

  // Keeps the original API intact while exposing per-set tracking.
  double get averageWeight => setDetails.isEmpty
      ? weight
      : setDetails.map((s) => s.weight).reduce((a, b) => a + b) / setDetails.length;
}

enum ExerciseType {
  weight,
  cardio,
  bodyweight,
  time,
  abs,
}

class MuscleGroup {
  final String name;
  final String icon;
  final String status;
  final int currentReps;
  final int targetIncrease;
  final int totalReps;
  final double progress;

  MuscleGroup({
    required this.name,
    required this.icon,
    required this.status,
    required this.currentReps,
    required this.targetIncrease,
    required this.totalReps,
    required this.progress,
  });
}

class UserStats {
  final double bodyWeight; // lbs
  final double heightCm;
  final DateTime lastWeightUpdate;
  final double volumeLifted;
  final String period;
  final Map<DateTime, bool> workoutCalendar;
  final Map<DateTime, double> dailyVolume;

  UserStats({
    required this.bodyWeight,
    this.heightCm = 0,
    required this.lastWeightUpdate,
    required this.volumeLifted,
    required this.period,
    required this.workoutCalendar,
    required this.dailyVolume,
  });

  double? get bmi {
    if (heightCm <= 0 || bodyWeight <= 0) return null;
    final heightM = heightCm / 100;
    final weightKg = bodyWeight * 0.45359237;
    return weightKg / (heightM * heightM);
  }

  String get bmiCategory {
    final value = bmi;
    if (value == null) return 'Enter height and weight';
    if (value < 18.5) return 'Underweight';
    if (value < 25) return 'Healthy range';
    if (value < 30) return 'Overweight';
    return 'Obesity range';
  }
}
