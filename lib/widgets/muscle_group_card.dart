import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../theme/app_theme.dart';

class MuscleGroupCard extends StatelessWidget {
  final MuscleGroup muscleGroup;

  const MuscleGroupCard({super.key, required this.muscleGroup});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128,
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.card(radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  muscleGroup.name,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                muscleGroup.status == 'Completed'
                    ? Icons.check_circle_outline
                    : muscleGroup.status == 'In progress'
                        ? Icons.timelapse
                        : Icons.radio_button_unchecked,
                color: muscleGroup.status == 'Not started' ? AppTheme.textTertiary : AppTheme.accent,
                size: 14,
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            muscleGroup.status,
            style: TextStyle(
              color: muscleGroup.status == 'Not started' ? AppTheme.textTertiary : AppTheme.accent,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: muscleGroup.progress,
              backgroundColor: AppTheme.surfaceAlt,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${muscleGroup.currentReps}/${muscleGroup.totalReps} reps',
            style: const TextStyle(color: AppTheme.textTertiary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
