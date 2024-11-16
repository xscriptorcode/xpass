import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:crypto/crypto.dart'; // Para SHA-256
import 'package:xpass/utils/encryption_utils.dart';
import 'package:xpass/utils/bd/database_helper.dart';
import 'package:xpass/pages/password/password.dart';
import 'package:cryptography/cryptography.dart'; // Importa cryptography para SecretKey

class ImportPasswordsPage extends StatefulWidget {
  const ImportPasswordsPage({super.key});

  @override
  State<ImportPasswordsPage> createState() => _ImportPasswordsPageState();
}

class _ImportPasswordsPageState extends State<ImportPasswordsPage> {
  final TextEditingController _passwordController = TextEditingController();
  File? _selectedFile;

  Future<void> _selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  SecretKey deriveKey(String password) {
    final hash = sha256.convert(utf8.encode(password)).bytes;
    return SecretKey(hash);
  }

  Future<void> _importPasswords() async {
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa la contraseña.')),
      );
      return;
    }
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un archivo.')),
      );
      return;
    }

    try {
      // Leer el contenido del archivo seleccionado
      final encryptedContent = await _selectedFile!.readAsString();

      // Derivar clave secreta de la contraseña proporcionada
      final passwordSecretKey = deriveKey(_passwordController.text);

      // Descifrar el contenido del archivo
      final decryptedContent = await decryptData(encryptedContent, passwordSecretKey);

      // Decodificar las contraseñas desde el JSON
      final List<dynamic> passwordList = jsonDecode(decryptedContent);

      // Restaurar las contraseñas en la base de datos
      final dbHelper = DatabaseHelper();
      for (var pwData in passwordList) {
        final passwordEntry = Password(
          id: pwData['id'],
          name: pwData['name'],
          user: pwData['user'],
          password: pwData['password'],
          lastUpdated: DateTime.parse(pwData['lastUpdated']),
        );
        await dbHelper.insertPassword(passwordEntry, await generateSecretKey());
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseñas importadas exitosamente.')),
      );

      Navigator.pop(context); // Regresar después de la importación exitosa
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al importar contraseñas: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Importar Contraseñas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña para descifrar',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _selectFile,
              icon: const Icon(Icons.folder),
              label: const Text('Seleccionar Archivo'),
            ),
            if (_selectedFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Archivo seleccionado: ${_selectedFile!.path}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _importPasswords,
              icon: const Icon(Icons.download),
              label: const Text('Importar Contraseñas'),
            ),
          ],
        ),
      ),
    );
  }
}
