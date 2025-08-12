import 'package:flutter/foundation.dart';

import '../models/task_model.dart';
import '../databases/task_database.dart';

class NoteViewModel extends ChangeNotifier {
  final NoteDatabase _database = NoteDatabase();
  List<Note> _notes = [];
  bool _isLoading = false;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;

  // Load all notes from database
  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notes = await _database.getAllNotes();
    } catch (e) {
      debugPrint('Error loading notes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new note
  Future<bool> addNote(Note note) async {
    try {
      final id = await _database.insertNote(note);
      if (id > 0) {
        await loadNotes(); // Reload notes to update the UI
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error adding note: $e');
      return false;
    }
  }

  // Update an existing note
  Future<bool> updateNote(Note note) async {
    try {
      final result = await _database.updateNote(note);
      if (result > 0) {
        await loadNotes(); // Reload notes to update the UI
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating note: $e');
      return false;
    }
  }

  // Delete a note
  Future<bool> deleteNote(int id) async {
    try {
      final result = await _database.deleteNote(id);
      if (result > 0) {
        await loadNotes(); // Reload notes to update the UI
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting note: $e');
      return false;
    }
  }

  // Get note by id
  Future<Note?> getNoteById(int id) async {
    try {
      return await _database.getNote(id);
    } catch (e) {
      debugPrint('Error getting note: $e');
      return null;
    }
  }

  // Search notes by title or content
  List<Note> searchNotes(String query) {
    if (query.isEmpty) return _notes;

    return _notes.where((note) {
      return note.title.toLowerCase().contains(query.toLowerCase()) ||
          note.content.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Get notes for today
  List<Note> getTodayNotes() {
    final today = DateTime.now();
    return _notes.where((note) {
      return note.date.year == today.year &&
          note.date.month == today.month &&
          note.date.day == today.day;
    }).toList();
  }
}
