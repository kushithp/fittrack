import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/goal_provider.dart';
import '../../../providers/notes_provider.dart';
import '../../../providers/reminder_provider.dart';
import '../../../providers/workout_provider.dart';
import '../../goals/goals_screen.dart';
import '../../notes/notes_screen.dart';
import '../../records/personal_records_screen.dart';
import '../../reminders/reminders_screen.dart';

/// Quick Hub providing instant one-tap access to Goals, Daily Notes, PRs, and Reminders.
class DashboardQuickHub extends StatelessWidget {
  const DashboardQuickHub({super.key});

  @override
  Widget build(BuildContext context) {
    final goalProvider = Provider.of<GoalProvider>(context);
    final notesProvider = Provider.of<NotesProvider>(context);
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final reminderProvider = Provider.of<ReminderProvider>(context);

    final activeGoalsCount = goalProvider.activeGoals.length;
    final hasNoteToday = notesProvider.todayNote != null;
    final prCount = workoutProvider.personalRecords.length;
    final remindersCount = reminderProvider.enabledReminders.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Quick Access",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isWide ? 4 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: isWide ? 1.6 : 1.8,
              children: [
                _QuickHubCard(
                  title: 'Goals',
                  subtitle: activeGoalsCount == 0
                      ? 'No active'
                      : '$activeGoalsCount active',
                  icon: Icons.flag_rounded,
                  color: const Color(0xFF3F51B5),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GoalsScreen()),
                    );
                  },
                ),
                _QuickHubCard(
                  title: 'Daily Notes',
                  subtitle: hasNoteToday ? 'Logged today' : 'Not logged',
                  icon: Icons.edit_note_rounded,
                  color: const Color(0xFF009688),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotesScreen()),
                    );
                  },
                ),
                _QuickHubCard(
                  title: 'Records',
                  subtitle: prCount == 0 ? 'No PRs yet' : '$prCount records',
                  icon: Icons.emoji_events_rounded,
                  color: const Color(0xFFFFB300),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PersonalRecordsScreen()),
                    );
                  },
                ),
                _QuickHubCard(
                  title: 'Reminders',
                  subtitle: remindersCount == 0
                      ? 'None set'
                      : '$remindersCount active',
                  icon: Icons.alarm_rounded,
                  color: const Color(0xFF8E24AA),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RemindersScreen()),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _QuickHubCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickHubCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: theme.cardTheme.color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF30363D) : const Color(0xFFE9ECEF),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
