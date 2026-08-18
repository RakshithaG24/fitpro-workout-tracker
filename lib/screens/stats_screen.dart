import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/muscle_group_card.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    final stats = provider.userStats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats'),
        actions: [
          IconButton(
            tooltip: 'Edit body metrics',
            onPressed: () => _showBodyMetricsDialog(context, provider),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final padding = constraints.maxWidth > 700 ? 32.0 : 20.0;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(padding, 8, padding, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBmiCard(context, stats),
                const SizedBox(height: 16),
                _buildVolumeChart(stats),
                const SizedBox(height: 16),
                _buildBodyMetricsCard(context, stats),
                const SizedBox(height: 24),
                const Text(
                  'Muscle groups',
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: provider.muscleGroups.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, index) => MuscleGroupCard(muscleGroup: provider.muscleGroups[index]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBmiCard(BuildContext context, dynamic stats) {
    final double? bmi = stats?.bmi as double?;
    final hasMetrics = bmi != null;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.card(radius: 18),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.15), shape: BoxShape.circle),
            child: const Icon(Icons.monitor_weight_outlined, color: AppTheme.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('BMI', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  hasMetrics ? bmi.toStringAsFixed(1) : 'Not calculated',
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.w800),
                ),
                Text(
                  hasMetrics ? stats.bmiCategory : 'Enter your current weight and height',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          FilledButton.tonal(
            onPressed: () => _showBodyMetricsDialog(context, context.read<WorkoutProvider>()),
            child: Text(hasMetrics ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyMetricsCard(BuildContext context, dynamic stats) {
    final weight = stats?.bodyWeight as double? ?? 0;
    final height = stats?.heightCm as double? ?? 0;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.card(radius: 16),
      child: Row(
        children: [
          Expanded(
            child: _editableMetric(
              context,
              'Weight',
              weight > 0 ? '${weight.toStringAsFixed(1)} lb' : 'Not set',
            ),
          ),
          Expanded(
            child: _editableMetric(
              context,
              'Height',
              height > 0 ? '${height.toStringAsFixed(0)} cm' : 'Not set',
            ),
          ),
          IconButton(
            tooltip: 'Edit weight and height',
            onPressed: () => _showBodyMetricsDialog(context, context.read<WorkoutProvider>()),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
    );
  }

  Widget _editableMetric(BuildContext context, String title, String value) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: AppTheme.textTertiary, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
      );

  Widget _buildVolumeChart(dynamic stats) {
    final dailyVolume = (stats?.dailyVolume as Map<DateTime, double>?) ?? <DateTime, double>{};
    final now = DateTime.now();
    final days = List.generate(7, (index) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - index));
      return date;
    });
    final maxVolume = days.fold<double>(0, (max, day) => (dailyVolume[day] ?? 0) > max ? (dailyVolume[day] ?? 0) : max);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.card(radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Volume lifted', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  SizedBox(height: 4),
                  Text('Actual completed sets', style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(20)),
                child: Text(
                  '${(stats?.volumeLifted ?? 0).toStringAsFixed(1)} kg',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 130,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: days.map((day) {
                final value = dailyVolume[day] ?? 0;
                final factor = maxVolume == 0 ? 0.0 : value / maxVolume;
                return _Bar(heightFactor: factor, label: _dayLabel(day), value: value);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _dayLabel(DateTime date) {
    const labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return labels[date.weekday % 7];
  }

  Future<void> _showBodyMetricsDialog(BuildContext context, WorkoutProvider provider) async {
    final stats = provider.userStats;
    final result = await showDialog<_BodyMetricsResult>(
      context: context,
      builder: (_) => _BodyMetricsDialog(
        initialWeight: stats?.bodyWeight ?? 0,
        initialHeight: stats?.heightCm ?? 0,
      ),
    );

    if (!context.mounted || result == null) return;
    provider.updateBodyMetrics(weight: result.weight, heightCm: result.heightCm);
  }
}

class _BodyMetricsResult {
  final double weight;
  final double heightCm;

  const _BodyMetricsResult({required this.weight, required this.heightCm});
}

class _BodyMetricsDialog extends StatefulWidget {
  final double initialWeight;
  final double initialHeight;

  const _BodyMetricsDialog({required this.initialWeight, required this.initialHeight});

  @override
  State<_BodyMetricsDialog> createState() => _BodyMetricsDialogState();
}

class _BodyMetricsDialogState extends State<_BodyMetricsDialog> {
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.initialWeight > 0 ? widget.initialWeight.toStringAsFixed(1) : '',
    );
    _heightController = TextEditingController(
      text: widget.initialHeight > 0 ? widget.initialHeight.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _save() {
    final weight = double.tryParse(_weightController.text.trim());
    final height = double.tryParse(_heightController.text.trim());
    if (weight == null || weight <= 0 || weight > 700) {
      setState(() => _error = 'Enter a valid current weight in lb.');
      return;
    }
    if (height == null || height <= 0 || height > 300) {
      setState(() => _error = 'Enter a valid current height in cm.');
      return;
    }
    Navigator.of(context).pop(_BodyMetricsResult(weight: weight, heightCm: height));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Your body metrics'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _weightController,
              autofocus: true,
              textInputAction: TextInputAction.next,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Current weight (lb)',
                hintText: 'Enter your current weight',
                prefixIcon: Icon(Icons.monitor_weight_outlined),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _heightController,
              textInputAction: TextInputAction.done,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onSubmitted: (_) => _save(),
              decoration: const InputDecoration(
                labelText: 'Current height (cm)',
                hintText: 'Enter your current height',
                prefixIcon: Icon(Icons.height),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Calculate BMI')),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final double heightFactor;
  final String label;
  final double value;

  const _Bar({required this.heightFactor, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Tooltip(
          message: '${value.toStringAsFixed(1)} kg',
          child: Container(
            width: 24,
            height: 100 * (heightFactor == 0 ? 0.02 : heightFactor),
            decoration: BoxDecoration(
              color: heightFactor > 0 ? AppTheme.accent : AppTheme.surfaceAlt,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: AppTheme.textTertiary, fontSize: 11)),
      ],
    );
  }
}
