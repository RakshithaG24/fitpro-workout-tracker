import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

/// Compact activity overview: a 3-month dot grid plus the current streak.
class CalendarCard extends StatelessWidget {
  final Map<DateTime, bool> workoutCalendar;

  const CalendarCard({
    super.key,
    required this.workoutCalendar,
  });

  int get _currentStreak {
    var streak = 0;
    var day = DateTime.now();
    final today = DateTime(day.year, day.month, day.day);
    if (workoutCalendar[today] != true) {
      day = today.subtract(const Duration(days: 1));
    }
    while (true) {
      final key = DateTime(day.year, day.month, day.day);
      if (workoutCalendar[key] == true) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = [
      DateTime(now.year, now.month - 2),
      DateTime(now.year, now.month - 1),
      now,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.card(radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Activity',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_currentStreak > 0)
                Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: AppTheme.warning, size: 15),
                    const SizedBox(width: 4),
                    Text(
                      '$_currentStreak day streak',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: months.map((month) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('MMM').format(month),
                        style: const TextStyle(color: AppTheme.textTertiary, fontSize: 11),
                      ),
                      const SizedBox(height: 8),
                      _MonthGrid(month: month, workoutCalendar: workoutCalendar),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final DateTime month;
  final Map<DateTime, bool> workoutCalendar;

  const _MonthGrid({required this.month, required this.workoutCalendar});

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 3,
      runSpacing: 3,
      children: List.generate(daysInMonth, (i) {
        final date = DateTime(month.year, month.month, i + 1);
        final hasWorkout = workoutCalendar[date] ?? false;
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: hasWorkout ? AppTheme.accent : AppTheme.surfaceAlt,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
