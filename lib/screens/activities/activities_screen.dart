import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/activity.dart';
import '../../providers/activity_provider.dart';
import '../../widgets/empty_state.dart';
import 'widgets/activity_tile.dart';
import 'widgets/add_edit_activity_dialog.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  ActivityCategory? _selectedCategory;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityProvider>(context);
    final theme = Theme.of(context);

    List<Activity> filtered = activityProvider.activities.where((act) {
      final matchesCategory =
          _selectedCategory == null || act.category == _selectedCategory;
      final matchesSearch =
          act.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activities & Habits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset Demo Data',
            onPressed: () => _confirmResetDemoData(context, activityProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddEditDialog(context, activityProvider),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Activity'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SearchBar(
                hintText: 'Search activities...',
                leading: const Icon(Icons.search_rounded),
                onChanged: (val) => setState(() => _searchQuery = val),
                elevation: const WidgetStatePropertyAll(0),
                backgroundColor: WidgetStatePropertyAll(
                  theme.brightness == Brightness.dark
                      ? const Color(0xFF21262D)
                      : const Color(0xFFF1F3F5),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _selectedCategory == null,
                    onSelected: (_) => setState(() => _selectedCategory = null),
                  ),
                  const SizedBox(width: 8),
                  ...ActivityCategory.values.map((cat) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        avatar: Icon(cat.icon, size: 16, color: cat.defaultColor),
                        label: Text(cat.label),
                        selected: _selectedCategory == cat,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? cat : null;
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            const Divider(height: 16, thickness: 1),
            Expanded(
              child: filtered.isEmpty
                  ? EmptyState(
                      title: 'No Activities Found',
                      message: _searchQuery.isNotEmpty || _selectedCategory != null
                          ? 'Try changing your search query or filter.'
                          : 'Create custom habits and fitness targets to start tracking.',
                      icon: Icons.fitness_center_rounded,
                      actionLabel: 'Add Activity',
                      onActionPressed: () => _openAddEditDialog(context, activityProvider),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final act = filtered[index];
                        final log = activityProvider.getLogForActivity(act.id);

                        return ActivityTile(
                          activity: act,
                          log: log,
                          onToggle: () => activityProvider.toggleChecklist(act),
                          onUpdateProgress: (val) =>
                              activityProvider.updateProgressValue(act, val),
                          onEdit: () => _openAddEditDialog(
                            context,
                            activityProvider,
                            activity: act,
                          ),
                          onDelete: () =>
                              _confirmDelete(context, activityProvider, act),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddEditDialog(
    BuildContext context,
    ActivityProvider provider, {
    Activity? activity,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AddEditActivityDialog(
          initialActivity: activity,
          onSave: (saved) {
            provider.saveActivity(saved);
          },
        );
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    ActivityProvider provider,
    Activity activity,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Activity?'),
          content: Text(
            'Are you sure you want to delete "${activity.name}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                provider.deleteActivity(activity.id);
                Navigator.pop(dialogContext);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _confirmResetDemoData(BuildContext context, ActivityProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reset Demo Data'),
          content: const Text(
            'This will re-populate default sample activities and 7 days of historical logs.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                provider.resetDemoData();
                Navigator.pop(dialogContext);
              },
              child: const Text('Reset Data'),
            ),
          ],
        );
      },
    );
  }
}
