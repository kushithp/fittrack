import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/notes_provider.dart';
import '../../notes/notes_screen.dart';
import '../../notes/widgets/add_edit_note_dialog.dart';

/// Spotlight card on the Dashboard showing today's reflection / daily note.
class TodayNoteSpotlight extends StatelessWidget {
  const TodayNoteSpotlight({super.key});

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final todayNote = notesProvider.todayNote;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Reflection",
              style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotesScreen()),
                );
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text("All Notes"),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (todayNote == null)
          _EmptyNoteBanner(
            onWriteNote: () {
              showDialog(
                context: context,
                builder: (_) => AddEditNoteDialog(
                  defaultDate: DateTime.now(),
                  onSave: (note) => notesProvider.saveNote(note),
                ),
              );
            },
          )
        else
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AddEditNoteDialog(
                  initialNote: todayNote,
                  defaultDate: todayNote.date,
                  onSave: (updated) => notesProvider.saveNote(updated),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF30363D) : const Color(0xFFE9ECEF),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _RatingPill(
                            label: 'Energy',
                            score: todayNote.energyRating,
                            icon: Icons.bolt_rounded,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 8),
                          _RatingPill(
                            label: 'Mood',
                            score: todayNote.moodRating,
                            icon: Icons.sentiment_satisfied_rounded,
                            color: Colors.teal,
                          ),
                          const SizedBox(width: 8),
                          _RatingPill(
                            label: 'Recovery',
                            score: todayNote.recoveryRating,
                            icon: Icons.hotel_rounded,
                            color: Colors.deepPurpleAccent,
                          ),
                        ],
                      ),
                      Icon(
                        Icons.edit_rounded,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                  if (todayNote.textNotes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      todayNote.textNotes,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (todayNote.tags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: todayNote.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '#$tag',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _RatingPill extends StatelessWidget {
  final String label;
  final int score;
  final IconData icon;
  final Color color;

  const _RatingPill({
    required this.label,
    required this.score,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '$score/10',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyNoteBanner extends StatelessWidget {
  final VoidCallback onWriteNote;

  const _EmptyNoteBanner({required this.onWriteNote});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF30363D) : const Color(0xFFE9ECEF),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF009688).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.draw_rounded,
              color: Color(0xFF009688),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "No Daily Reflection Yet",
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Log today's workout feedback, energy, mood & recovery.",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color
                        ?.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          FilledButton.tonal(
            onPressed: onWriteNote,
            child: const Text("Write Note"),
          ),
        ],
      ),
    );
  }
}
