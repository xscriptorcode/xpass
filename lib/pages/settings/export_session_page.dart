import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:xpass/utils/file_manager.dart';
import 'package:xpass/utils/encryption_utils.dart' as encryption_utils; // Alias para encryption_utils
import 'package:xpass/crypto/coefficients_codec.dart';
import 'package:xpass/crypto/kyber_keypair.dart';
import 'package:xpass/crypto/kyber_logic.dart' as kyber_logic; // Alias para kyber_logic
import 'package:xpass/utils/bd/database_helper.dart';
import 'package:xpass/pages/password/password.dart';

class ExportSessionPage extends StatefulWidget {
  const ExportSessionPage({super.key});

  @override
  State<ExportSessionPage> createState() => _ExportSessionPageState();
}

class _ExportSessionPageState extends State<ExportSessionPage> {
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

  Future<void> _exportSessionFile() async {
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
      final fileManager = FileManager();
      final dbHelper = DatabaseHelper();

      // Obtener las contraseñas desde la base de datos
      final secretKey = await encryption_utils.generateSecretKey();
      final passwords = await dbHelper.getPasswords(secretKey);

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

      // Leer datos del archivo de sesión existente
      String sessionFilePath = await fileManager.getVerificationFilePath();
      final sessionFile = File(sessionFilePath);

      if (!await sessionFile.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay archivo de sesión para exportar.')),
        );
        return;
      }

      String existingSessionData = await sessionFile.readAsString();

      // Generar un nuevo par de claves Kyber
      final keyPair = KyberKeyPair.generate();

      // Crear clave compartida a partir de la clave privada existente
      final sharedKey = kyber_logic.createSharedKey(keyPair, keyPair.publicKey, 3329);

      // Combinar las contraseñas con los datos de sesión
      final combinedData = {
        'session': existingSessionData,
        'passwords': passwordList,
      };

      // Cifrar los datos combinados
      String encryptedData =
          encryption_utils.encryptSession(jsonEncode(combinedData), sharedKey, 3329);

      // Agregar capa adicional de cifrado basada en la contraseña
      final passwordCifrado = utf8.encode(_passwordController.text);
      final base64EncryptedData = base64Encode(utf8.encode(encryptedData));
      final finalEncryptedContent = "$base64EncryptedData|${base64Encode(passwordCifrado)}";

      // Guardar en un archivo
      String fileName = "exported_session_with_passwords.enc";
      File exportedFile = File('$_outputDirectory/$fileName');

      await exportedFile.writeAsString(finalEncryptedContent);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Archivo exportado exitosamente.')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar el archivo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exportar Sesión Cifrada'),
      ),
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
              onPressed: _exportSessionFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Exportar Archivo'),
            ),
          ],
        ),
      ),
    );
  }
}
