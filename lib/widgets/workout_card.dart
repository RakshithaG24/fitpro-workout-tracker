import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../theme/app_theme.dart';

class WorkoutCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback onTap;

  const WorkoutCard({
    super.key,
    required this.workout,
    required this.onTap,
  });

  IconData get _icon {
    switch (workout.type.toLowerCase()) {
      case 'cardio':
        return Icons.directions_run;
      case 'pull day':
        return Icons.rowing;
      case 'push day':
        return Icons.fitness_center;
      default:
        return Icons.sports_gymnastics;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.card(radius: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceAlt,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_icon, color: AppTheme.accent, size: 18),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right, color: AppTheme.textTertiary, size: 20),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              workout.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${workout.day} · ${workout.duration} min',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
