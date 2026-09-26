import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/activity.dart';
import '../../providers/activity_provider.dart';
import '../../widgets/empty_state.dart';
import 'widgets/greeting_header.dart';
import 'widgets/stat_card.dart';
import 'widgets/today_progress_card.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback? onNavigateToActivities;

  const DashboardScreen({
    super.key,
    this.onNavigateToActivities,
  });

  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityProvider>(context);
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 900 ? 4 : (screenWidth > 600 ? 3 : 2);

    if (activityProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final activities = activityProvider.enabledActivities;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await activityProvider.loadLogsForSelectedDate();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GreetingHeader(),
                const SizedBox(height: 20),
                TodayProgressCard(
                  percentage: activityProvider.todayCompletionPercentage,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Daily Metrics",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: onNavigateToActivities,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text("View All"),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (activities.isEmpty)
                  EmptyState(
                    title: "No Activities Configured",
                    message: "Create your daily fitness targets and habits to begin tracking.",
                    actionLabel: "Add Activity",
                    onActionPressed: onNavigateToActivities,
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: screenWidth > 600 ? 1.4 : 1.25,
                    ),
                    itemCount: activities.length,
                    itemBuilder: (context, index) {
                      final act = activities[index];
                      final log = activityProvider.getLogForActivity(act.id);
                      final currentVal = log?.value ?? 0.0;

                      return StatCard(
                        title: act.name,
                        currentValue: currentVal,
                        targetValue: act.target,
                        unitSymbol: act.unit.symbol,
                        icon: act.iconData,
                        color: act.color,
                        onTap: () {
                          if (act.unit == ActivityUnit.checkbox) {
                            activityProvider.toggleChecklist(act);
                          } else {
                            _showQuickLogDialog(context, act, currentVal, activityProvider);
                          }
                        },
                      );
                    },
                  ),
                const SizedBox(height: 24),
                Text(
                  "Today's Checklist",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activityProvider.checklistActivities.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final act = activityProvider.checklistActivities[index];
                    final log = activityProvider.getLogForActivity(act.id);
                    final isDone = log?.isCompleted ?? false;

                    return Container(
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.brightness == Brightness.dark
                              ? const Color(0xFF30363D)
                              : const Color(0xFFE9ECEF),
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: CheckboxListTile(
                          value: isDone,
                          onChanged: (_) => activityProvider.toggleChecklist(act),
                          title: Text(
                            act.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              decoration: isDone ? TextDecoration.lineThrough : null,
                              color: isDone
                                  ? theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5)
                                  : theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          subtitle: Text(
                            act.target > 0
                                ? 'Target: ${act.target} ${act.unit.symbol}'
                                : act.category.label,
                            style: theme.textTheme.bodySmall,
                          ),
                          secondary: CircleAvatar(
                            backgroundColor: act.color.withValues(alpha: 0.15),
                            child: Icon(act.iconData, color: act.color, size: 20),
                          ),
                          activeColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showQuickLogDialog(
    BuildContext context,
    Activity act,
    double currentVal,
    ActivityProvider provider,
  ) {
    final controller = TextEditingController(text: currentVal.toString());

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("Log ${act.name}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Target: ${act.target} ${act.unit.symbol}"),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: InputDecoration(
                  labelText: "Current Value (${act.unit.symbol})",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () {
                final val = double.tryParse(controller.text) ?? currentVal;
                provider.updateProgressValue(act, val);
                Navigator.pop(dialogContext);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
