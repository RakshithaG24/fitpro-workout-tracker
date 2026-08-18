import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../theme/app_theme.dart';

class ExerciseProgressItem extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;

  const ExerciseProgressItem({
    super.key,
    required this.exercise,
    required this.onTap,
  });

  IconData get _icon {
    if (exercise.isCompleted) return Icons.check;
    switch (exercise.type) {
      case ExerciseType.cardio:
        return Icons.directions_run;
      case ExerciseType.bodyweight:
        return Icons.accessibility_new;
      case ExerciseType.time:
        return Icons.timer_outlined;
      case ExerciseType.abs:
        return Icons.accessibility_new;
      case ExerciseType.weight:
        return Icons.fitness_center;
    }
  }

  @override
  Widget build(BuildContext context) {
    final done = exercise.isCompleted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppTheme.card(radius: 12).copyWith(
          color: done ? AppTheme.surfaceAlt : AppTheme.surface,
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: done ? AppTheme.success.withOpacity(0.15) : AppTheme.surfaceAlt,
                shape: BoxShape.circle,
                border: Border.all(color: done ? AppTheme.success : AppTheme.border),
              ),
              child: Icon(
                _icon,
                color: done ? AppTheme.success : AppTheme.textSecondary,
                size: 17,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: TextStyle(
                      color: done ? AppTheme.textTertiary : AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (exercise.notes != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      exercise.notes!,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}
