import 'package:flutter/foundation.dart';
import '../data/models/daily_note.dart';
import '../data/repositories/notes_repository.dart';

class NotesProvider extends ChangeNotifier {
  final NotesRepository _repository;
  List<DailyNote> _notes = [];
  String _searchQuery = '';
  String? _selectedTag;
  bool _isLoading = false;
  String? _errorMessage;

  NotesProvider(this._repository);

  List<DailyNote> get notes => _notes;
  String get searchQuery => _searchQuery;
  String? get selectedTag => _selectedTag;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<String> get availableTags {
    final set = <String>{};
    for (var n in _notes) {
      set.addAll(n.tags);
    }
    return set.toList()..sort();
  }

  Future<void> initialize() async {
    _setLoading(true);
    try {
      _notes = await _repository.getAllDailyNotes();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load notes: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<DailyNote?> getNoteForDate(DateTime date) async {
    return await _repository.getNoteForDate(date);
  }

  Future<void> saveNote(DailyNote note) async {
    _setLoading(true);
    try {
      await _repository.saveDailyNote(note);
      _notes = await _repository.getAllDailyNotes();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to save note: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteNote(String id) async {
    _setLoading(true);
    try {
      await _repository.deleteDailyNote(id);
      _notes.removeWhere((n) => n.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete note: $e';
    } finally {
      _setLoading(false);
    }
  }

  void filterNotes({String? query, String? tag}) {
    _searchQuery = query ?? _searchQuery;
    _selectedTag = tag;
    notifyListeners();
  }

  List<DailyNote> get filteredNotes {
    return _notes.where((note) {
      final matchesQuery = _searchQuery.isEmpty ||
          note.textNotes.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.tags.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()));
      final matchesTag = _selectedTag == null || note.tags.contains(_selectedTag);
      return matchesQuery && matchesTag;
    }).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
