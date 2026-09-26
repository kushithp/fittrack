import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/user_settings.dart';
import '../../../providers/theme_provider.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final greeting = AppDateUtils.getGreeting();
    final dateStr = AppDateUtils.formatHeaderDate(DateTime.now());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting, ${themeProvider.userName}',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  dateStr,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
        IconButton.filledTonal(
          icon: Icon(
            themeProvider.themeMode == AppThemeMode.dark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
          ),
          tooltip: 'Toggle Theme',
          onPressed: () {
            final nextMode = themeProvider.themeMode == AppThemeMode.dark
                ? AppThemeMode.light
                : AppThemeMode.dark;
            themeProvider.setThemeMode(nextMode);
          },
        ),
      ],
    );
  }
}
