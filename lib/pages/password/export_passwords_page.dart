import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:crypto/crypto.dart'; // Para SHA-256
import 'package:xpass/utils/encryption_utils.dart';
import 'package:xpass/utils/bd/database_helper.dart';
import 'package:xpass/pages/password/password.dart';
import 'package:cryptography/cryptography.dart'; // Importa cryptography para SecretKey

class ExportPasswordsPage extends StatefulWidget {
  const ExportPasswordsPage({super.key});

  @override
  State<ExportPasswordsPage> createState() => _ExportPasswordsPageState();
}

class _ExportPasswordsPageState extends State<ExportPasswordsPage> {
  final TextEditingController _passwordController = TextEditingController();
  String? _outputDirectory;

  Future<void> _selectDirectory() async {
    final directoryPath = await FilePicker.platform.getDirectoryPath();
    if (directoryPath != null) {
      setState(() {
        _outputDirectory = directoryPath;
      });
    }
  }

  SecretKey deriveKey(String password) {
    final hash = sha256.convert(utf8.encode(password)).bytes;
    return SecretKey(hash);
  }

  Future<void> _exportPasswords() async {
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa una contraseña.')),
      );
      return;
    }
    if (_outputDirectory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un directorio.')),
      );
      return;
    }

    try {
      final dbHelper = DatabaseHelper();
      final passwords = await dbHelper.getPasswords(await generateSecretKey());

      // Crear una lista de contraseñas en formato legible
      final passwordList = passwords.map((password) {
        return {
          'id': password.id,
          'name': password.name,
          'user': password.user,
          'password': password.password,
          'lastUpdated': password.lastUpdated.toString(),
        };
      }).toList();

      final jsonPasswords = jsonEncode(passwordList);

      // Derivar clave secreta de la contraseña ingresada
      final passwordSecretKey = deriveKey(_passwordController.text);

      // Cifrar los datos
      final encryptedContent = await encryptData(jsonPasswords, passwordSecretKey);

      // Codificar en Base64 antes de guardar
      final base64EncodedContent = base64Encode(utf8.encode(encryptedContent));

      // Guardar el archivo cifrado
      const fileName = 'exported_passwords.enc';
      final File file = File('$_outputDirectory/$fileName');
      await file.writeAsString(base64EncodedContent);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseñas exportadas exitosamente.')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar contraseñas: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exportar Contraseñas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña para cifrar',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _selectDirectory,
              icon: const Icon(Icons.folder),
              label: const Text('Seleccionar Directorio'),
            ),
            if (_outputDirectory != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Directorio seleccionado: $_outputDirectory',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _exportPasswords,
              icon: const Icon(Icons.upload_file),
              label: const Text('Exportar Contraseñas'),
            ),
          ],
        ),
      ),
    );
  }
}
