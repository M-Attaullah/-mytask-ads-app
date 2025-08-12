import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/task_model.dart';

class NoteDatabase {
  static final NoteDatabase _instance = NoteDatabase._internal();
  static Database? _database;

  NoteDatabase._internal();

  factory NoteDatabase() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getDatabasesPath();
    final path = join(documentsDirectory, 'notes.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        date INTEGER NOT NULL,
        color TEXT NOT NULL
      )
    ''');
  }

  // Insert a new note
  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  // Get all notes
  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final maps = await db.query('notes', orderBy: 'date DESC');

    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }

  // Get a specific note by id
  Future<Note?> getNote(int id) async {
    final db = await database;
    final maps = await db.query('notes', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Note.fromMap(maps.first);
    }
    return null;
  }

  // Update a note
  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // Delete a note
  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
