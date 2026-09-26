import 'package:uuid/uuid.dart';
import '../models/activity_log.dart';
import '../models/daily_note.dart';
import '../services/database_service.dart';

class NotesRepository {
  final IDatabaseService _db;
  final Uuid _uuid = const Uuid();

  NotesRepository(this._db);

  Future<List<DailyNote>> getAllDailyNotes() async {
    final notes = await _db.getAllDailyNotes();
    notes.sort((a, b) => b.date.compareTo(a.date));
    return notes;
  }

  Future<DailyNote?> getNoteForDate(DateTime date) async {
    final dateKey = ActivityLog.formatDateKey(date);
    return await _db.getDailyNoteForDate(dateKey);
  }

  Future<DailyNote> saveDailyNote(DailyNote note) async {
    final noteToSave = note.id.isEmpty
        ? note.copyWith(id: _uuid.v4(), createdAt: DateTime.now())
        : note.copyWith(updatedAt: DateTime.now());
    await _db.saveDailyNote(noteToSave);
    return noteToSave;
  }

  Future<void> deleteDailyNote(String id) async {
    await _db.deleteDailyNote(id);
  }

  Future<List<DailyNote>> searchNotes({String? query, String? tag}) async {
    final all = await getAllDailyNotes();
    return all.where((note) {
      final matchesQuery = query == null ||
          query.isEmpty ||
          note.textNotes.toLowerCase().contains(query.toLowerCase());
      final matchesTag = tag == null || tag.isEmpty || note.tags.contains(tag);
      return matchesQuery && matchesTag;
    }).toList();
  }
}
