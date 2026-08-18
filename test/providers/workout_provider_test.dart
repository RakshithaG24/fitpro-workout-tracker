import 'package:flutter_test/flutter_test.dart';
import 'package:fitpro/providers/workout_provider.dart';

void main() {
  group('WorkoutProvider Tests', () {
    late WorkoutProvider provider;

    setUp(() {
      provider = WorkoutProvider();
    });

    test('Provider initializes with sample data', () {
      expect(provider.workouts, isNotEmpty);
      expect(provider.muscleGroups, isNotEmpty);
      expect(provider.userStats, isNotNull);
      expect(provider.isWorkoutInProgress, false);
      expect(provider.currentWorkout, isNull);
    });

    test('Provider has correct number of sample workouts', () {
      expect(provider.workouts.length, 5);
      expect(provider.workouts[0].name, 'Chest + Triceps');
      expect(provider.workouts[1].name, 'Back + Biceps');
      expect(provider.workouts[2].name, 'Glutes + Hamstrings');
      expect(provider.workouts[3].name, 'Shoulders + Forearms');
      expect(provider.workouts[4].name, 'Quads + Calves');
    });

    test('Provider has correct muscle groups', () {
      expect(provider.muscleGroups.length, 4);
      expect(provider.muscleGroups[0].name, 'Chest');
      expect(provider.muscleGroups[1].name, 'Back');
      expect(provider.muscleGroups[2].name, 'Legs');
      expect(provider.muscleGroups[3].name, 'Shoulders');
    });

    test('User stats are initialized correctly', () {
      final userStats = provider.userStats!;
      expect(userStats.bodyWeight, 190.0);
      expect(userStats.volumeLifted, 3200.0);
      expect(userStats.period, 'Last 7 days');
      expect(userStats.workoutCalendar, isNotEmpty);
    });

    test('Start workout sets current workout and progress state', () {
      final workout = provider.workouts[0];

      provider.startWorkout(workout);

      expect(provider.currentWorkout, workout);
      expect(provider.isWorkoutInProgress, true);
    });

    test('Finish workout clears current workout and progress state', () {
      final workout = provider.workouts[0];
      provider.startWorkout(workout);

      provider.finishWorkout();

      expect(provider.currentWorkout, isNull);
      expect(provider.isWorkoutInProgress, false);
    });

    test('Update workout duration updates the duration', () {
      final duration = const Duration(minutes: 5, seconds: 30);

      provider.updateWorkoutDuration(duration);

      expect(provider.workoutDuration, duration);
    });

    test('Toggle exercise completion works correctly', () {
      final workout = provider.workouts[0];
      provider.startWorkout(workout);

      final exercise = workout.exercises[0];
      expect(exercise.isCompleted, false);

      provider.toggleExerciseCompletion(exercise.id);

      final updatedExercise = provider.currentWorkout!.exercises[0];
      expect(updatedExercise.isCompleted, true);
    });
  });
}
