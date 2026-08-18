import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../models/workout.dart';
import '../theme/app_theme.dart';
import '../widgets/workout_card.dart';
import '../widgets/stats_card.dart';
import '../widgets/calendar_card.dart';
import '../widgets/add_workout_card.dart';
import 'workout_detail_screen.dart';

class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<WorkoutProvider>(
          builder: (context, workoutProvider, child) {
            final stats = workoutProvider.userStats;
            final workouts = workoutProvider.workouts;

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                final crossAxisCount = isWide ? 3 : 2;

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'FitPro',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                                letterSpacing: -0.4,
                              ),
                            ),
                            _RoundIconButton(icon: Icons.add, onTap: () => _openWorkout(context, workouts.first)),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.05,
                            children: [
                              if (workouts.isNotEmpty)
                                WorkoutCard(
                                  workout: workouts[0],
                                  onTap: () => _openWorkout(context, workouts[0]),
                                ),
                              StatsCard(
                                title: 'Body weight',
                                value: (stats?.bodyWeight ?? 0) > 0 ? '${(stats?.bodyWeight ?? 0).toStringAsFixed(1)} lb' : 'Not set',
                                subtitle: (stats?.bodyWeight ?? 0) > 0
                                    ? _formatTimeAgo(stats!.lastWeightUpdate)
                                    : 'Add your current weight',
                                icon: Icons.monitor_weight_outlined,
                              ),
                              if (workouts.length > 1)
                                WorkoutCard(
                                  workout: workouts[1],
                                  onTap: () => _openWorkout(context, workouts[1]),
                                ),
                              StatsCard(
                                title: 'Volume lifted',
                                value: '${(stats?.volumeLifted ?? 0).toStringAsFixed(1)} kg',
                                subtitle: 'Completed sets',
                                icon: Icons.bar_chart,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          CalendarCard(
                            workoutCalendar: stats?.workoutCalendar ?? {},
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'All workouts',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...workouts.skip(2).map((w) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _WorkoutRow(
                                  workout: w,
                                  onTap: () => _openWorkout(context, w),
                                ),
                              )),
                          if (workouts.length <= 2) const SizedBox.shrink(),
                          AddWorkoutCard(onTap: workouts.isEmpty ? null : () => _openWorkout(context, workouts.first)),
                          const SizedBox(height: 24),
                        ]),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _openWorkout(BuildContext context, Workout workout) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WorkoutDetailScreen(workout: workout)),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class _WorkoutRow extends StatelessWidget {
  final Workout workout;
  final VoidCallback onTap;

  const _WorkoutRow({required this.workout, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppTheme.card(radius: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.surfaceAlt,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.fitness_center, color: AppTheme.accent, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${workout.day} · ${workout.duration} min',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
                  ),
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

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.border),
        ),
        child: Icon(icon, color: AppTheme.textPrimary, size: 20),
      ),
    );
  }
}
