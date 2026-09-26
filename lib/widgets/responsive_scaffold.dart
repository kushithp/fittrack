import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/user_settings.dart';
import '../providers/theme_provider.dart';

class NavigationDestinationData {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const NavigationDestinationData({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

/// Adaptive scaffold switching between BottomNavigationBar on small screens
/// and NavigationRail on desktop/laptop/tablet displays.
class ResponsiveScaffold extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final List<Widget> pages;
  final List<NavigationDestinationData> destinations;
  final String title;
  final List<Widget>? actions;

  const ResponsiveScaffold({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.pages,
    required this.destinations,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // Responsive Navigation Rail Sidebar
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: onIndexChanged,
              extended: MediaQuery.of(context).size.width >= 900,
              minExtendedWidth: 200,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.fitness_center_rounded,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                    ),
                    if (MediaQuery.of(context).size.width >= 900) ...[
                      const SizedBox(width: 12),
                      Text(
                        'FitTrack',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              trailing: Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: IconButton(
                      icon: Icon(
                        themeProvider.themeMode == AppThemeMode.dark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                      ),
                      tooltip: 'Toggle Theme',
                      onPressed: () {
                        final next = themeProvider.themeMode == AppThemeMode.dark
                            ? AppThemeMode.light
                            : AppThemeMode.dark;
                        themeProvider.setThemeMode(next);
                      },
                    ),
                  ),
                ),
              ),
              destinations: destinations.map((d) {
                return NavigationRailDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: Text(d.label),
                );
              }).toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: IndexedStack(
                index: currentIndex,
                children: pages,
              ),
            ),
          ],
        ),
      );
    }

    // Small Screens / Mobile Scaffold
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onIndexChanged,
        destinations: destinations.map((d) {
          return NavigationDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selectedIcon),
            label: d.label,
          );
        }).toList(),
      ),
    );
  }
}
