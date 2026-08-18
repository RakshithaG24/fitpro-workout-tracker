import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout.dart';
import '../providers/workout_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/exercise_progress_item.dart';

class WorkoutInProgressScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutInProgressScreen({
    super.key,
    required this.workout,
  });

  @override
  State<WorkoutInProgressScreen> createState() => _WorkoutInProgressScreenState();
}

class _WorkoutInProgressScreenState extends State<WorkoutInProgressScreen> {
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _elapsedTime = _elapsedTime + const Duration(seconds: 1));
      context.read<WorkoutProvider>().updateWorkoutDuration(_elapsedTime);
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final exercises = widget.workout.exercises;
    final completed = exercises.where((e) => e.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout.name),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: () {
                context.read<WorkoutProvider>().finishWorkout();
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: AppTheme.accent),
              child: const Text('Finish'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Column(
                children: [
                  Text(
                    _formatDuration(_elapsedTime),
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.workout.type} · $completed/${exercises.length} done',
                    style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                itemCount: exercises.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  return ExerciseProgressItem(
                    exercise: exercise,
                    onTap: () {
                      context.read<WorkoutProvider>().toggleExerciseCompletion(exercise.id);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
