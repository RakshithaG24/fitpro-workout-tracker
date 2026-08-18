import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout.dart';
import '../providers/workout_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/muscle_group_card.dart';
import 'workout_in_progress_screen.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final Workout workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workout.name),
        actions: [
          IconButton(
            tooltip: 'Add exercise',
            onPressed: () => _showAddExercise(context),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: Consumer<WorkoutProvider>(
        builder: (context, provider, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final horizontal = constraints.maxWidth > 700 ? 32.0 : 20.0;
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(horizontal, 4, horizontal, 0),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(workout.day, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                          Text('•', style: const TextStyle(color: AppTheme.textTertiary)),
                          Text(workout.type, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                          const Icon(Icons.access_time, color: AppTheme.textSecondary, size: 14),
                          Text('${workout.duration} min', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 150,
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: horizontal),
                        scrollDirection: Axis.horizontal,
                        itemCount: provider.muscleGroups.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, index) => MuscleGroupCard(muscleGroup: provider.muscleGroups[index]),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(horizontal, 24, horizontal, 12),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text('Exercises & sets', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _showAddExercise(context),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add exercise'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: horizontal),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final exercise = workout.exercises[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ExerciseEditor(workout: workout, exercise: exercise),
                          );
                        },
                        childCount: workout.exercises.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 110)),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<WorkoutProvider>().startWorkout(workout);
                Navigator.push(context, MaterialPageRoute(builder: (_) => WorkoutInProgressScreen(workout: workout)));
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start workout'),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddExercise(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _AddExerciseDialog(workoutId: workout.id),
    );
  }
}

class _ExerciseEditor extends StatelessWidget {
  final Workout workout;
  final Exercise exercise;

  const _ExerciseEditor({required this.workout, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<WorkoutProvider>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.card(radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  exercise.name,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                tooltip: 'Remove exercise',
                onPressed: () => _confirmRemove(context, provider),
                icon: const Icon(Icons.delete_outline, color: Color(0xFFE5484D)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            exercise.type == ExerciseType.weight
                ? 'Adjust weight and reps for every set'
                : 'Track this exercise as ${exercise.type.name}',
            style: const TextStyle(color: AppTheme.textTertiary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          ...List.generate(exercise.setDetails.length, (index) {
            final set = exercise.setDetails[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SetRow(
                setNumber: index + 1,
                set: set,
                showWeight: exercise.type == ExerciseType.weight,
                onWeightChanged: (value) => provider.updateSet(workout.id, exercise.id, index, weight: value),
                onRepsChanged: (value) => provider.updateSet(workout.id, exercise.id, index, reps: value),
                onCompletedChanged: (value) => provider.updateSet(workout.id, exercise.id, index, completed: value),
                onRemove: () => provider.removeSet(workout.id, exercise.id, index),
              ),
            );
          }),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => provider.addSet(workout.id, exercise.id),
                  icon: const Icon(Icons.add, size: 17),
                  label: const Text('Add set'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmRemove(BuildContext context, WorkoutProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove exercise?'),
        content: Text('Remove ${exercise.name} from ${workout.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              provider.removeExercise(workout.id, exercise.id);
              Navigator.pop(context);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  final int setNumber;
  final ExerciseSet set;
  final bool showWeight;
  final ValueChanged<double> onWeightChanged;
  final ValueChanged<int> onRepsChanged;
  final ValueChanged<bool> onCompletedChanged;
  final VoidCallback onRemove;

  const _SetRow({
    required this.setNumber,
    required this.set,
    required this.showWeight,
    required this.onWeightChanged,
    required this.onRepsChanged,
    required this.onCompletedChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 48,
          child: Text('Set $setNumber', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ),
        if (showWeight)
          SizedBox(
            width: 100,
            child: _NumberField(
              value: set.weight,
              suffix: 'kg',
              onChanged: (v) => onWeightChanged(v),
            ),
          ),
        SizedBox(
          width: 100,
          child: _IntField(
            value: set.reps,
            suffix: 'reps',
            onChanged: onRepsChanged,
          ),
        ),
        Checkbox(
          value: set.completed,
          onChanged: (value) => onCompletedChanged(value ?? false),
          visualDensity: VisualDensity.compact,
        ),
        IconButton(
          tooltip: 'Remove set',
          onPressed: onRemove,
          icon: const Icon(Icons.remove_circle_outline, size: 20, color: AppTheme.textTertiary),
        ),
      ],
    );
  }
}

class _NumberField extends StatefulWidget {
  final double value;
  final String suffix;
  final ValueChanged<double> onChanged;

  const _NumberField({required this.value, required this.suffix, required this.onChanged});

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: _format(widget.value));
  }

  String _format(double value) => value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(1);

  @override
  void didUpdateWidget(covariant _NumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && controller.text != _format(widget.value)) {
      controller.text = _format(widget.value);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: widget.suffix, isDense: true),
        onChanged: (text) {
          final value = double.tryParse(text);
          if (value != null) widget.onChanged(value);
        },
      );
}

class _IntField extends StatefulWidget {
  final int value;
  final String suffix;
  final ValueChanged<int> onChanged;

  const _IntField({required this.value, required this.suffix, required this.onChanged});

  @override
  State<_IntField> createState() => _IntFieldState();
}

class _IntFieldState extends State<_IntField> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(covariant _IntField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && controller.text != widget.value.toString()) {
      controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: widget.suffix, isDense: true),
        onChanged: (text) {
          final value = int.tryParse(text);
          if (value != null) widget.onChanged(value);
        },
      );
}

class _AddExerciseDialog extends StatefulWidget {
  final String workoutId;

  const _AddExerciseDialog({required this.workoutId});

  @override
  State<_AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<_AddExerciseDialog> {
  final _name = TextEditingController();
  final _sets = TextEditingController(text: '3');
  final _reps = TextEditingController(text: '10');
  final _weight = TextEditingController(text: '0');
  ExerciseType _type = ExerciseType.weight;

  @override
  void dispose() {
    _name.dispose();
    _sets.dispose();
    _reps.dispose();
    _weight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add exercise'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _name, autofocus: true, decoration: const InputDecoration(labelText: 'Exercise name')),
              const SizedBox(height: 12),
              DropdownButtonFormField<ExerciseType>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: ExerciseType.values
                    .map((type) => DropdownMenuItem(value: type, child: Text(type.name.toUpperCase())))
                    .toList(),
                onChanged: (value) => setState(() => _type = value ?? ExerciseType.weight),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: _sets, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sets'))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: _reps, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Reps'))),
                ],
              ),
              if (_type == ExerciseType.weight) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _weight,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Starting weight (kg)'),
                ),
              ],
              if (_type == ExerciseType.cardio || _type == ExerciseType.time || _type == ExerciseType.abs)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text('You can use reps as rounds/minutes and adjust each set later.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _add,
          child: const Text('Add'),
        ),
      ],
    );
  }

  void _add() {
    final name = _name.text.trim();
    final sets = int.tryParse(_sets.text) ?? 0;
    final reps = int.tryParse(_reps.text) ?? 0;
    final weight = double.tryParse(_weight.text) ?? 0;
    if (name.isEmpty || sets < 1 || reps < 0) return;
    context.read<WorkoutProvider>().addExercise(
          workoutId: widget.workoutId,
          name: name,
          sets: sets,
          reps: reps,
          weight: weight,
          type: _type,
        );
    Navigator.pop(context);
  }
}
