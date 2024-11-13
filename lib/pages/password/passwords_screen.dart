// lib/pages/password/passwords_screen.dart

import 'package:flutter/material.dart';
import 'package:xpass/utils/bd/database_helper.dart';
import 'package:xpass/utils/encryption_utils.dart';
import 'note.dart';
import 'password.dart';

class PasswordsScreen extends StatefulWidget {
  final Password password;

  const PasswordsScreen({super.key, required this.password});

  @override
  _PasswordsScreenState createState() => _PasswordsScreenState();
}

class _PasswordsScreenState extends State<PasswordsScreen> {
  final _controller = TextEditingController();
  final _dbHelper = DatabaseHelper();
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  // Cargar y descifrar las notas asociadas a la contraseña
  Future<void> _loadNotes() async {
    final secretKey = await generateSecretKey();
    final notes = await _dbHelper.getNotesForPassword(widget.password.id!);
    final decryptedNotes = await Future.wait(notes.map((note) async {
      final decryptedContent = await decryptData(note.content, secretKey);
      return Note(
        id: note.id,
        passwordId: note.passwordId,
        content: decryptedContent,
        timestamp: note.timestamp,
      );
    }));
    setState(() {
      _notes = decryptedNotes;
    });
  }

  // Método para agregar una nueva nota cifrada
  void _addNote() async {
    if (_controller.text.isEmpty) return;

    final secretKey = await generateSecretKey();
    final encryptedContent = await encryptData(_controller.text, secretKey);

    final note = Note(
      passwordId: widget.password.id!,
      content: encryptedContent,
      timestamp: DateTime.now(),
    );

    await _dbHelper.insertNoteForPassword(widget.password.id!, note);
    _controller.clear();
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.password.name), // Título de la contraseña
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return ListTile(
                  title: Text(note.content), // Contenido descifrado de la nota
                  subtitle: Text(note.timestamp.toString()),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Escribe una nota...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addNote,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
