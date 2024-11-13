// lib/pages/password/password.dart
class Password {
  final int? id;
  final String name;           // Título de la entrada de contraseña
  final String user;           // Nombre de usuario asociado
  final String password;       // Contraseña cifrada
  final DateTime lastUpdated;  // Última fecha de actualización

  Password({
    this.id,
    required this.name,
    required this.user,
    required this.password,
    required this.lastUpdated,
  });

  // Convertir un objeto Password en un mapa para la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'user': user,
      'password': password,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  // Convertir un mapa de la base de datos en un objeto Password
  factory Password.fromMap(Map<String, dynamic> map) {
    return Password(
      id: map['id'],
      name: map['name'],
      user: map['user'],
      password: map['password'],
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }
}
