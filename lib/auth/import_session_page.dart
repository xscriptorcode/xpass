import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:xpass/crypto/polynomial.dart';
import 'package:xpass/utils/file_manager.dart';
import 'package:xpass/utils/encryption_utils.dart';
import 'package:xpass/crypto/coefficients_codec.dart';
import 'package:xpass/crypto/kyber_keypair.dart';
import 'package:xpass/crypto/kyber_logic.dart' as kyber;
import 'package:xpass/utils/bd/database_helper.dart';
import 'package:xpass/pages/password/password.dart';

class ImportSessionPage extends StatefulWidget {
  final String loginCode;
  final String loginPassword;

  const ImportSessionPage({super.key, required this.loginCode, required this.loginPassword});

  @override
  State<ImportSessionPage> createState() => _ImportSessionPageState();
}

class _ImportSessionPageState extends State<ImportSessionPage> {
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

  Future<void> _importSessionFile() async {
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa una contraseña.')),
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
      final fileContent = await _selectedFile!.readAsString();

      // Dividir el archivo en las dos partes: datos cifrados y contraseña cifrada
      final parts = fileContent.split('|');
      if (parts.length != 2) {
        throw Exception('Archivo corrupto. Formato inesperado.');
      }

      final base64EncryptedData = parts[0];
      final base64Password = parts[1];

      // Verificar la contraseña
      final storedPassword = utf8.decode(base64Decode(base64Password));
      if (_passwordController.text != storedPassword) {
        throw Exception('Contraseña incorrecta.');
      }

      // Decodificar los datos cifrados
      final encryptedData = utf8.decode(base64Decode(base64EncryptedData));

      // Decodificar el JSON del archivo y validar las claves
      final jsonData = jsonDecode(encryptedData);
      if (!jsonData.containsKey('encryptedData') ||
          !jsonData.containsKey('publicKey') ||
          !jsonData.containsKey('privateKey')) {
        throw Exception('Archivo inválido o corrupto.');
      }

      // Extraer claves y datos cifrados
      final sessionEncryptedData = jsonData['encryptedData'] as String;
      final publicKey = Polynomial(decodeCoefficients(jsonData['publicKey'] as String));
      final privateKey = Polynomial(decodeCoefficients(jsonData['privateKey'] as String));

      // Crear la clave compartida con las claves del archivo
      final keyPair = KyberKeyPair.fromPolynomials(publicKey, privateKey);
      final sharedKey = kyber.createSharedKey(keyPair, publicKey, 3329);

      // Descifrar datos de sesión
      final decryptedData = decryptSession(sessionEncryptedData, sharedKey, 3329);
      final combinedData = jsonDecode(decryptedData);

      if (!combinedData.containsKey('session') || !combinedData.containsKey('passwords')) {
        throw Exception('Archivo inválido o datos incompletos.');
      }

      // Validar la sesión con el código y la contraseña del usuario
      final sessionData = combinedData['session'] as String;
      final sessionParts = sessionData.split(':');
      if (sessionParts.length != 2) {
        throw Exception('Formato de sesión inválido.');
      }

      final importedPassword = sessionParts[0];
      final importedCode = sessionParts[1];

      // Verificar que coincidan los datos del inicio de sesión
      if (importedPassword != widget.loginPassword || importedCode != widget.loginCode) {
        throw Exception('Código o contraseña de inicio de sesión incorrectos.');
      }

      // Restaurar contraseñas en la base de datos
      final passwords = combinedData['passwords'] as List<dynamic>;
      final dbHelper = DatabaseHelper();

      for (var pwData in passwords) {
        final passwordEntry = Password(
          id: pwData['id'],
          name: pwData['name'],
          user: pwData['user'],
          password: pwData['password'],
          lastUpdated: DateTime.parse(pwData['lastUpdated']),
        );
        await dbHelper.insertPassword(passwordEntry, await generateSecretKey());
      }

      // Guardar sesión restaurada en el sistema
      final fileManager = FileManager();
      String sessionFilePath = await fileManager.getVerificationFilePath();
      await File(sessionFilePath).writeAsString(sessionData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Archivo importado exitosamente.')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al importar el archivo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importar Sesión'),
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
                labelText: 'Contraseña del archivo',
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
              onPressed: _importSessionFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Importar Archivo'),
            ),
          ],
        ),
      ),
    );
  }
}
