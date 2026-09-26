import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/daily_note.dart';
import '../../providers/notes_provider.dart';
import '../../widgets/empty_state.dart';
import 'widgets/add_edit_note_dialog.dart';
import 'widgets/note_card.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String _searchQuery = '';
  String? _selectedTag;

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context);
    final theme = Theme.of(context);

    final notesList = notesProvider.filteredNotes;
    final availableTags = notesProvider.availableTags;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Fitness Notes'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddEditDialog(context, notesProvider),
        icon: const Icon(Icons.edit_note_rounded),
        label: const Text('Log Note'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SearchBar(
                hintText: 'Search notes or tags...',
                leading: const Icon(Icons.search_rounded),
                onChanged: (val) {
                  setState(() => _searchQuery = val);
                  notesProvider.filterNotes(query: val);
                },
                elevation: const WidgetStatePropertyAll(0),
                backgroundColor: WidgetStatePropertyAll(
                  theme.brightness == Brightness.dark
                      ? const Color(0xFF21262D)
                      : const Color(0xFFF1F3F5),
                ),
              ),
            ),
            if (availableTags.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All Tags'),
                      selected: _selectedTag == null,
                      onSelected: (_) {
                        setState(() => _selectedTag = null);
                        notesProvider.filterNotes(tag: null);
                      },
                    ),
                    const SizedBox(width: 8),
                    ...availableTags.map((tag) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text('#$tag'),
                          selected: _selectedTag == tag,
                          onSelected: (selected) {
                            final nextTag = selected ? tag : null;
                            setState(() => _selectedTag = nextTag);
                            notesProvider.filterNotes(tag: nextTag);
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            const Divider(height: 16, thickness: 1),
            Expanded(
              child: notesProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : notesList.isEmpty
                      ? EmptyState(
                          title: 'No Notes Found',
                          message: _searchQuery.isNotEmpty || _selectedTag != null
                              ? 'No journal entries match your filter.'
                              : 'Record energy levels, workout notes, and recovery daily.',
                          icon: Icons.note_alt_rounded,
                          actionLabel: 'Write First Note',
                          onActionPressed: () => _openAddEditDialog(context, notesProvider),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: notesList.length,
                          itemBuilder: (context, index) {
                            final note = notesList[index];
                            return NoteCard(
                              note: note,
                              onEdit: () => _openAddEditDialog(
                                context,
                                notesProvider,
                                note: note,
                              ),
                              onDelete: () => _confirmDeleteNote(context, notesProvider, note),
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
    NotesProvider provider, {
    DailyNote? note,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AddEditNoteDialog(
          initialNote: note,
          defaultDate: DateTime.now(),
          onSave: (savedNote) {
            provider.saveNote(savedNote);
          },
        );
      },
    );
  }

  void _confirmDeleteNote(
    BuildContext context,
    NotesProvider provider,
    DailyNote note,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Note?'),
          content: const Text('Are you sure you want to delete this journal note?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                provider.deleteNote(note.id);
                Navigator.pop(dialogContext);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
