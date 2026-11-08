import 'dart:async';
import 'package:flutter/material.dart';

/// In-workout countdown rest timer between exercise sets.
class RestTimerWidget extends StatefulWidget {
  final int initialSeconds;
  final VoidCallback onDismiss;

  const RestTimerWidget({
    super.key,
    this.initialSeconds = 90,
    required this.onDismiss,
  });

  @override
  State<RestTimerWidget> createState() => _RestTimerWidgetState();
}

class _RestTimerWidgetState extends State<RestTimerWidget> {
  late int _totalSeconds;
  late int _secondsLeft;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.initialSeconds;
    _secondsLeft = widget.initialSeconds;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _timer?.cancel();
        setState(() => _isRunning = false);
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer(int seconds) {
    _timer?.cancel();
    setState(() {
      _totalSeconds = seconds;
      _secondsLeft = seconds;
    });
    _startTimer();
  }

  void _addTime(int seconds) {
    setState(() {
      _secondsLeft += seconds;
      if (_secondsLeft > _totalSeconds) {
        _totalSeconds = _secondsLeft;
      }
    });
  }

  String get _formattedTime {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _totalSeconds > 0
        ? (_secondsLeft / _totalSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 4,
                      backgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _secondsLeft <= 10
                            ? Colors.red
                            : theme.colorScheme.primary,
                      ),
                    ),
                    Center(
                      child: Icon(
                        _isRunning
                            ? Icons.hourglass_top_rounded
                            : Icons.pause_rounded,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'REST TIMER',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      _formattedTime,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: _secondsLeft <= 10 ? Colors.red : null,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                icon: Icon(
                  _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                ),
                onPressed: _isRunning ? _pauseTimer : _startTimer,
                tooltip: _isRunning ? 'Pause' : 'Resume',
              ),
              const SizedBox(width: 6),
              IconButton.outlined(
                icon: const Icon(Icons.add_rounded),
                onPressed: () => _addTime(30),
                tooltip: '+30s',
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: widget.onDismiss,
                tooltip: 'Dismiss Timer',
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _PresetChip(
                  label: '30s',
                  onTap: () => _resetTimer(30),
                  isSelected: _totalSeconds == 30,
                ),
                const SizedBox(width: 6),
                _PresetChip(
                  label: '60s',
                  onTap: () => _resetTimer(60),
                  isSelected: _totalSeconds == 60,
                ),
                const SizedBox(width: 6),
                _PresetChip(
                  label: '90s',
                  onTap: () => _resetTimer(90),
                  isSelected: _totalSeconds == 90,
                ),
                const SizedBox(width: 6),
                _PresetChip(
                  label: '120s',
                  onTap: () => _resetTimer(120),
                  isSelected: _totalSeconds == 120,
                ),
                const SizedBox(width: 6),
                _PresetChip(
                  label: '180s',
                  onTap: () => _resetTimer(180),
                  isSelected: _totalSeconds == 180,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  const _PresetChip({
    required this.label,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? theme.colorScheme.primary : null,
          ),
        ),
      ),
    );
  }
}
