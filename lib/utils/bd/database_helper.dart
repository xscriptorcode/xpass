import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:xpass/pages/password/note.dart';
import 'package:xpass/pages/password/password.dart';
import 'package:xpass/utils/encryption_utils.dart';
import 'package:cryptography/cryptography.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database == null || !_database!.isOpen) {
      _database = await _initDatabase();
    }
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'password_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE passwords (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        user TEXT,
        password TEXT NOT NULL,
        lastUpdated TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        passwordId INTEGER,
        content TEXT,
        timestamp TEXT,
        FOREIGN KEY (passwordId) REFERENCES passwords (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> closeDatabase() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }

  Future<void> resetDatabase() async {
    await closeDatabase();
    String path = join(await getDatabasesPath(), 'password_database.db');
    await deleteDatabase(path);
    _database = await _initDatabase();
  }

  Future<int> insertPassword(Password passwordEntry, SecretKey encryptionKey) async {
    final db = await database;
    final encryptedPassword = await encryptData(passwordEntry.password, encryptionKey);
    final encryptedPasswordEntry = Password(
      id: passwordEntry.id,
      name: passwordEntry.name,
      user: passwordEntry.user,
      password: encryptedPassword,
      lastUpdated: passwordEntry.lastUpdated,
    );
    return await db.insert('passwords', encryptedPasswordEntry.toMap());
  }

  Future<List<Password>> getPasswords(SecretKey decryptionKey) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('passwords');

    List<Password> decryptedPasswords = [];
    for (var map in maps) {
      final decryptedPassword = await decryptData(map['password'], decryptionKey);
      decryptedPasswords.add(Password(
        id: map['id'],
        name: map['name'],
        user: map['user'],
        password: decryptedPassword,
        lastUpdated: DateTime.parse(map['lastUpdated']),
      ));
    }
    return decryptedPasswords;
  }

  Future<int> updatePassword(Password passwordEntry, SecretKey encryptionKey) async {
    final db = await database;
    final encryptedPassword = await encryptData(passwordEntry.password, encryptionKey);
    final updatedPasswordEntry = Password(
      id: passwordEntry.id,
      name: passwordEntry.name,
      user: passwordEntry.user,
      password: encryptedPassword,
      lastUpdated: passwordEntry.lastUpdated,
    );
    return await db.update(
      'passwords',
      updatedPasswordEntry.toMap(),
      where: 'id = ?',
      whereArgs: [passwordEntry.id],
    );
  }

  Future<int> deletePassword(int id) async {
    final db = await database;
    return await db.delete(
      'passwords',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertNoteForPassword(int passwordId, Note note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  Future<List<Note>> getNotesForPassword(int passwordId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'passwordId = ?',
      whereArgs: [passwordId],
    );
    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }

  Future<int> deleteNoteById(int id) async {
    final db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
