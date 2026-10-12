import 'package:flutter/material.dart';

class DailyScoreCard extends StatelessWidget {
  final double score;
  final VoidCallback onConfigure;

  const DailyScoreCard({
    super.key,
    required this.score,
    required this.onConfigure,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clampedScore = score.clamp(0.0, 100.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6C5CE7),
            theme.colorScheme.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'DAILY FITNESS SCORE',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    clampedScore.round().toString(),
                    style: theme.textTheme.displayMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const Text(' / 100', style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Based on your custom weights',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
              ),
            ],
          ),
          IconButton.filledTonal(
            icon: const Icon(Icons.tune_rounded, color: Colors.white),
            style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.25)),
            tooltip: 'Configure Score Weights',
            onPressed: onConfigure,
          ),
        ],
      ),
    );
  }
}
