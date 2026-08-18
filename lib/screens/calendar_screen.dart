import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/workout_provider.dart';
import '../models/workout.dart';
import '../theme/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final userStats = workoutProvider.userStats;

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [
          _buildCalendarHeader(),
          const SizedBox(height: 16),
          _buildCalendarGrid(userStats?.workoutCalendar ?? {}),
          const SizedBox(height: 8),
          const Divider(height: 1),
          Expanded(
            child: _buildWorkoutList(
              workoutProvider.workouts,
              userStats?.workoutCalendar ?? {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat('MMMM yyyy').format(_focusedDay),
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: AppTheme.textSecondary),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(Map<DateTime, bool> workoutCalendar) {
    final daysInMonth = DateUtils.getDaysInMonth(_focusedDay.year, _focusedDay.month);
    final firstDayOffset = DateTime(_focusedDay.year, _focusedDay.month, 1).weekday % 7;
    const weekdayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: weekdayLabels
                .map((d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(color: AppTheme.textTertiary, fontSize: 12),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: daysInMonth + firstDayOffset,
            itemBuilder: (context, index) {
              if (index < firstDayOffset) return const SizedBox.shrink();

              final day = index - firstDayOffset + 1;
              final date = DateTime(_focusedDay.year, _focusedDay.month, day);
              final isSelected = _selectedDay?.year == date.year &&
                  _selectedDay?.month == date.month &&
                  _selectedDay?.day == date.day;

              final hasWorkout = workoutCalendar.entries.any((e) =>
                  e.key.year == date.year &&
                  e.key.month == date.month &&
                  e.key.day == date.day &&
                  e.value);

              return GestureDetector(
                onTap: () => setState(() => _selectedDay = date),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.accent
                        : (hasWorkout ? AppTheme.surfaceAlt : Colors.transparent),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: hasWorkout && !isSelected
                          ? AppTheme.accent.withOpacity(0.4)
                          : Colors.transparent,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      day.toString(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                        fontWeight: isSelected || hasWorkout ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutList(List<Workout> workouts, Map<DateTime, bool> workoutCalendar) {
    final selected = _selectedDay;
    if (selected == null) return const SizedBox.shrink();

    final completedWorkouts = workouts.where((workout) {
      return workout.exercises.any((exercise) {
        return exercise.setDetails.any((set) {
          final completedAt = set.completedAt;
          return set.completed &&
              completedAt != null &&
              completedAt.year == selected.year &&
              completedAt.month == selected.month &&
              completedAt.day == selected.day;
        });
      });
    }).toList();

    if (completedWorkouts.isEmpty) {
      return const Center(
        child: Text(
          'No workout recorded on this day',
          style: TextStyle(color: AppTheme.textTertiary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: completedWorkouts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final workout = completedWorkouts[index];
        final completedSets = workout.exercises.fold<int>(
          0,
          (total, exercise) => total + exercise.setDetails.where((set) {
            final completedAt = set.completedAt;
            return set.completed &&
                completedAt != null &&
                completedAt.year == selected.year &&
                completedAt.month == selected.month &&
                completedAt.day == selected.day;
          }).length,
        );

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: AppTheme.card(radius: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      workout.name,
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Icon(Icons.check_circle, color: AppTheme.success, size: 20),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '$completedSets completed sets · ${workout.type}',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 14),
              ...workout.exercises.where((exercise) => exercise.setDetails.any((set) {
                final completedAt = set.completedAt;
                return set.completed &&
                    completedAt != null &&
                    completedAt.year == selected.year &&
                    completedAt.month == selected.month &&
                    completedAt.day == selected.day;
              })).map((exercise) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 5, color: AppTheme.accent),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            exercise.name,
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

}
