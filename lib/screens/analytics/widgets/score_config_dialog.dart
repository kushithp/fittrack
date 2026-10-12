import 'package:flutter/material.dart';
import '../../../data/models/score_config.dart';

class ScoreConfigDialog extends StatefulWidget {
  final ScoreConfig currentConfig;
  final ValueChanged<ScoreConfig> onSave;

  const ScoreConfigDialog({
    super.key,
    required this.currentConfig,
    required this.onSave,
  });

  @override
  State<ScoreConfigDialog> createState() => _ScoreConfigDialogState();
}

class _ScoreConfigDialogState extends State<ScoreConfigDialog> {
  late double _steps;
  late double _workout;
  late double _water;
  late double _sleep;
  late double _habits;

  @override
  void initState() {
    super.initState();
    _steps = widget.currentConfig.stepsWeight;
    _workout = widget.currentConfig.workoutWeight;
    _water = widget.currentConfig.waterWeight;
    _sleep = widget.currentConfig.sleepWeight;
    _habits = widget.currentConfig.habitsWeight;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configure Daily Score Weights'),
      content: SingleChildScrollView(
        child: Container(
          width: 450,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSliderRow('Steps Target', _steps, (v) => setState(() => _steps = v)),
              _buildSliderRow('Gym Workout', _workout, (v) => setState(() => _workout = v)),
              _buildSliderRow('Water Intake', _water, (v) => setState(() => _water = v)),
              _buildSliderRow('Sleep Hours', _sleep, (v) => setState(() => _sleep = v)),
              _buildSliderRow('Other Habits', _habits, (v) => setState(() => _habits = v)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            widget.onSave(ScoreConfig(
              stepsWeight: _steps,
              workoutWeight: _workout,
              waterWeight: _water,
              sleepWeight: _sleep,
              habitsWeight: _habits,
            ));
            Navigator.pop(context);
          },
          child: const Text('Save Weights'),
        ),
      ],
    );
  }

  Widget _buildSliderRow(String title, double val, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('${val.toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          ],
        ),
        Slider(
          value: val,
          min: 0,
          max: 50,
          divisions: 10,
          label: '${val.toInt()}%',
          onChanged: onChanged,
        ),
      ],
    );
  }
}
