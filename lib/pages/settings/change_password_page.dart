// lib/pages/settings/change_password_page.dart

import 'package:flutter/material.dart';
import 'dart:convert'; // Importar dart:convert para jsonEncode y jsonDecode
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:xpass/utils/file_manager.dart';
import 'package:xpass/crypto/kyber_keypair.dart';
import 'package:xpass/crypto/kyber_logic.dart';
import 'package:xpass/utils/encryption_utils.dart' as encrut;
import 'package:xpass/crypto/coefficients_codec.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  // Método para cambiar la contraseña
  Future<void> _changePassword(BuildContext context) async {
    try {
      // Verificar que la nueva contraseña coincida con la confirmación
      if (_newPasswordController.text != _confirmNewPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Las contraseñas no coinciden')),
        );
        return;
      }

      // Solicitar permisos si es necesario
      if (Platform.isAndroid) {
        var status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permiso de almacenamiento denegado')),
          );
          return;
        }
      }

      // Cargar la información de la sesión actual desde el archivo
      final fileManager = FileManager();
      String sessionFilePath = await fileManager.getVerificationFilePath();
      File sessionFile = File(sessionFilePath);

      if (!await sessionFile.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró la sesión actual')),
        );
        return;
      }

      // Leer y desencriptar los datos de sesión actuales
      String encryptedSessionData = await sessionFile.readAsString();
      final secretKey = await encrut.generateSecretKey();

      // Decodificar en Base64 antes de desencriptar
      String base64DecodedData = utf8.decode(base64Decode(encryptedSessionData));
      String decryptedData = await encrut.decryptData(base64DecodedData, secretKey);

      // Comparar la contraseña actual ingresada por el usuario con la almacenada
      List<String> dataParts = decryptedData.split(':');
      String storedPassword = dataParts[0];
      String code = dataParts[1];

      if (_currentPasswordController.text != storedPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La contraseña actual es incorrecta')),
        );
        return;
      }

      // Generar un nuevo par de claves Kyber para el cifrado de la nueva contraseña
      final keyPair = KyberKeyPair.generate();
      final sharedKey = createSharedKey(keyPair, keyPair.publicKey, 3329);
      String newDataToSave = '${_newPasswordController.text}:$code';
      String newEncryptedData = encrut.encryptSession(newDataToSave, sharedKey, 3329);

      // Codificar los datos cifrados en Base64 para evitar problemas de caracteres no válidos
      String base64EncryptedData = base64Encode(utf8.encode(newEncryptedData));

      // Guardar los datos de la nueva sesión en el archivo
      Map<String, String> newSessionData = {
        "encryptedData": base64EncryptedData,
        "publicKey": encodeCoefficients(keyPair.publicKey.coefficients),
        "privateKey": encodeCoefficients(keyPair.privateKey.coefficients),
      };
      String jsonSessionData = jsonEncode(newSessionData);
      await sessionFile.writeAsString(jsonSessionData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada exitosamente')),
      );

      // Regresar a la página anterior
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cambiar la contraseña: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar Contraseña'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _currentPasswordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña actual',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _newPasswordController,
              decoration: const InputDecoration(
                labelText: 'Nueva contraseña',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _confirmNewPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirmar nueva contraseña',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _changePassword(context),
              child: const Text('Cambiar Contraseña'),
            ),
          ],
        ),
      ),
    );
  }
}
