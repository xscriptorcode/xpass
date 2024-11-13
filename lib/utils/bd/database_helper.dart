// lib/utils/bd/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:xpass/pages/password/note.dart';
import 'package:xpass/pages/password/password.dart';
import 'package:xpass/utils/encryption_utils.dart'; // Importa las utilidades de encriptación
import 'package:cryptography/cryptography.dart'; // Importar cryptography para SecretKey

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
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
        name TEXT NOT NULL,        -- Título de la entrada de contraseña
        user TEXT,                 -- Nombre de usuario asociado
        password TEXT NOT NULL,    -- Contraseña cifrada
        lastUpdated TEXT           -- Fecha de última actualización
      )
    ''');

    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        passwordId INTEGER,        -- Id de la contraseña a la que pertenece esta nota
        content TEXT,              -- Contenido de la nota
        timestamp TEXT,            -- Fecha y hora de la nota
        FOREIGN KEY (passwordId) REFERENCES passwords (id) ON DELETE CASCADE
      )
    ''');
  }

  // Método para insertar una contraseña encriptada
  Future<int> insertPassword(Password passwordEntry, SecretKey encryptionKey) async {
    final db = await database;

    // Encripta la contraseña antes de almacenarla en la base de datos
    final encryptedPassword = await encryptData(passwordEntry.password, encryptionKey);

    // Crea una copia de `passwordEntry` con la contraseña encriptada
    final encryptedPasswordEntry = Password(
      id: passwordEntry.id,
      name: passwordEntry.name,
      user: passwordEntry.user,
      password: encryptedPassword,
      lastUpdated: passwordEntry.lastUpdated,
    );

    return await db.insert('passwords', encryptedPasswordEntry.toMap());
  }

  // Método para obtener las contraseñas y desencriptarlas
  Future<List<Password>> getPasswords(SecretKey decryptionKey) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('passwords');

    // Desencripta cada contraseña después de leerla
    List<Password> decryptedPasswords = [];
    for (var map in maps) {
      final decryptedPassword = await decryptData(map['password'], decryptionKey);
      decryptedPasswords.add(Password(
        id: map['id'],
        name: map['name'],
        user: map['user'],
        password: decryptedPassword, // Contraseña desencriptada
        lastUpdated: DateTime.parse(map['lastUpdated']),
      ));
    }

    return decryptedPasswords;
  }

  // Método para actualizar una contraseña encriptada
  Future<int> updatePassword(Password passwordEntry, SecretKey encryptionKey) async {
    final db = await database;

    // Encripta la nueva contraseña antes de almacenarla en la base de datos
    final encryptedPassword = await encryptData(passwordEntry.password, encryptionKey);

    // Crea una copia de `passwordEntry` con la contraseña encriptada
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

  // CRUD para Note
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
