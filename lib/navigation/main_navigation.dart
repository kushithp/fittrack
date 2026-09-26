import 'package:flutter/material.dart';
import '../screens/activities/activities_screen.dart';
import '../screens/analytics/analytics_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/tracking/tracking_tab_screen.dart';
import '../screens/workout/workout_screen.dart';
import '../widgets/responsive_scaffold.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  static const List<NavigationDestinationData> _destinations = [
    NavigationDestinationData(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
    ),
    NavigationDestinationData(
      label: 'Activities',
      icon: Icons.check_circle_outline,
      selectedIcon: Icons.check_circle_rounded,
    ),
    NavigationDestinationData(
      label: 'Tracking',
      icon: Icons.favorite_outline_rounded,
      selectedIcon: Icons.favorite_rounded,
    ),
    NavigationDestinationData(
      label: 'Workout',
      icon: Icons.fitness_center_outlined,
      selectedIcon: Icons.fitness_center_rounded,
    ),
    NavigationDestinationData(
      label: 'Analytics',
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart_rounded,
    ),
    NavigationDestinationData(
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(
        onNavigateToActivities: () {
          setState(() => _currentIndex = 1);
        },
      ),
      const ActivitiesScreen(),
      const TrackingTabScreen(),
      const WorkoutScreen(),
      const AnalyticsScreen(),
      const SettingsScreen(),
    ];

    return ResponsiveScaffold(
      currentIndex: _currentIndex,
      onIndexChanged: (index) {
        setState(() => _currentIndex = index);
      },
      destinations: _destinations,
      pages: pages,
      title: _destinations[_currentIndex].label,
    );
  }
}
