// lib/pages/password/note.dart
class Note {
  final int? id;
  final int passwordId;       // Id de la contraseña a la que pertenece esta nota
  final String content;       // Contenido de la nota
  final DateTime timestamp;   // Fecha y hora de la nota

  Note({
    this.id,
    required this.passwordId,
    required this.content,
    required this.timestamp,
  });

  // Convertir un objeto Note en un mapa para la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'passwordId': passwordId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Convertir un mapa de la base de datos en un objeto Note
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      passwordId: map['passwordId'],
      content: map['content'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
