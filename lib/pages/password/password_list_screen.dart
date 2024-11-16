import 'package:flutter/material.dart';
import 'package:xpass/pages/password/add_password_screen.dart';
import 'package:xpass/pages/password/export_passwords_page.dart';
import 'package:xpass/pages/password/import_passwords_page.dart';
import 'package:xpass/utils/bd/database_helper.dart';
import 'package:xpass/utils/encryption_utils.dart';
import 'package:xpass/pages/password/password.dart';
import 'package:xpass/pages/password/passwords_screen.dart';
import 'package:xpass/pages/settings/settings_page.dart';
import 'package:xpass/pages/password/export_passwords_page.dart'; // Nueva página para exportar contraseñas
import 'package:xpass/pages/password/import_passwords_page.dart'; // Nueva página para importar contraseñas
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xpass/auth/login_or_register.dart';
import 'package:flutter/services.dart'; // Para el portapapeles
import 'package:cryptography/cryptography.dart'; // Importa cryptography para SecretKey

class PasswordListScreen extends StatefulWidget {
  const PasswordListScreen({super.key});

  @override
  _PasswordListScreenState createState() => _PasswordListScreenState();
}

class _PasswordListScreenState extends State<PasswordListScreen> {
  final _dbHelper = DatabaseHelper();
  List<Password> _passwords = [];

  @override
  void initState() {
    super.initState();
    _loadPasswords(); // Llama a la carga de contraseñas al iniciar
  }

  // Cargar y descifrar las contraseñas de la base de datos
  Future<void> _loadPasswords() async {
    final secretKey = await generateSecretKey(); // Genera la clave secreta para descifrar
    final passwords = await _dbHelper.getPasswords(secretKey); // Obtiene la lista de contraseñas cifradas

    // Desencripta cada contraseña antes de mostrarla
    final decryptedPasswords = await Future.wait(passwords.map((password) async {
      final decryptedPassword = await decryptData(password.password, secretKey);
      return Password(
        id: password.id,
        name: password.name,
        user: password.user,
        password: decryptedPassword,
        lastUpdated: password.lastUpdated,
      );
    }));

    // Actualiza el estado con la lista de contraseñas descifradas
    setState(() {
      _passwords = decryptedPasswords;
    });
  }

  // Método para copiar la contraseña original al portapapeles
  void _copyPassword(String originalPassword) {
    Clipboard.setData(ClipboardData(text: originalPassword));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contraseña copiada al portapapeles')),
    );
  }

  // Método para mostrar la contraseña parcialmente oculta, manteniendo los últimos dos caracteres
  String _obscurePassword(String password) {
    if (password.length <= 2) {
      return password; // Si la contraseña es corta, la muestra sin modificar
    }
    return '*' * (password.length - 2) + password.substring(password.length - 2);
  }

  // Método para navegar a la pantalla de detalles de la contraseña seleccionada
  void _openPasswordDetails(Password password) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PasswordsScreen(password: password),
      ),
    );
  }

  // Método para editar la contraseña seleccionada
  void _editPassword(Password password) async {
    final secretKey = await generateSecretKey(); // Genera la clave secreta
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPasswordScreen(
          isEditing: true,
          password: password,
          onSave: (updatedPassword) async {
            await _dbHelper.updatePassword(updatedPassword, secretKey); // Pasa la clave como segundo argumento
            _loadPasswords(); // Recarga la lista después de la actualización
          },
        ),
      ),
    );
  }

  // Método para eliminar una contraseña
  Future<void> _deletePassword(int id) async {
    await _dbHelper.deletePassword(id);
    _loadPasswords(); // Recarga la lista de contraseñas después de eliminar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contraseña eliminada')),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Nueva Contraseña'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddPasswordScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Exportar Contraseñas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExportPasswordsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Importar Contraseñas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ImportPasswordsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Ajustes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar Sesión'),
              onTap: () {
                Navigator.pop(context);
                _handleLogout();
              },
            ),
          ],
        );
      },
    );
  }

  void _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginOrRegister()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contraseñas'),
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        itemCount: _passwords.length,
        itemBuilder: (context, index) {
          final password = _passwords[index];
          return ListTile(
            title: Text(
              password.name,
              style: const TextStyle(fontSize: 18),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Usuario: ${password.user}'),
                const SizedBox(height: 4),
                Text(
                  'Última Actualización: ${password.lastUpdated}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      onPressed: () => _copyPassword(password.password),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                      onPressed: () => _editPassword(password),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                      onPressed: () {
                        _deletePassword(password.id!);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Contraseña en asteriscos debajo de los íconos, asegurando que esté visible
                Text(
                  _obscurePassword(password.password),
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            onTap: () => _openPasswordDetails(password),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showOptionsMenu,
        child: const Icon(Icons.add),
      ),
    );
  }
}
