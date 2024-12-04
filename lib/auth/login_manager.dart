// lib/auth/login_manager.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:xpass/utils/file_manager.dart';
import 'package:xpass/utils/permission_manager.dart';
import 'package:xpass/pages/password/password_list_screen.dart';
import 'package:xkyber_crypto/kyber_logic.dart';
import 'package:xkyber_crypto/kyber_keypair.dart';
import 'package:xkyber_crypto/polynomial.dart';
import 'package:xkyber_crypto/coefficients_codec.dart';
import 'package:xpass/auth/import_session_page.dart';

Uint8List decodeFromBase64(String base64Str) {
  List<int> coefficients = decodeCoefficients(base64Str);
  return Uint8List.fromList(coefficients);
}

class LoginManager {
  final PermissionManager permissionManager = PermissionManager();
  final FileManager fileManager = FileManager();

  Future<void> loginWithBiometrics(BuildContext context) async {
  try {
    String filePath = await fileManager.getVerificationFilePath();
    File file = File(filePath);

    if (!await file.exists()) {
      _showSnackBar(context, 'No se encontraron datos de registro.');
      return;
    }

    final fileContent = await file.readAsString();
    final Map<String, dynamic> jsonData = jsonDecode(fileContent);

    if (!jsonData.containsKey('encryptedData') || !jsonData.containsKey('publicKey') || !jsonData.containsKey('privateKey')) {
      _showSnackBar(context, 'Datos de registro corruptos: faltan campos.');
      return;
    }

    final encryptedData = jsonData['encryptedData'] as String;
    final keyPair = KyberKeyPair.fromPolynomials(
      Polynomial(decodeCoefficients(jsonData['publicKey'] as String)),
      Polynomial(decodeCoefficients(jsonData['privateKey'] as String)),
    );

    if (keyPair.publicKey.coefficients.isEmpty || keyPair.privateKey.coefficients.isEmpty) {
      _showSnackBar(context, 'Claves cargadas están vacías.');
      return;
    }

    final sharedKey = createSharedKey(keyPair, keyPair.publicKey, 3329);
    if (sharedKey.coefficients.isEmpty || encryptedData.isEmpty) {
      _showSnackBar(context, 'Datos de registro corruptos: clave compartida inválida.');
      return;
    }

    final decryptedData = decryptSession(encryptedData, sharedKey, 3329);
    final savedData = decryptedData.split(':');

    if (savedData.length != 2) {
      _showSnackBar(context, 'Datos de registro corruptos: formato inválido.');
      return;
    }

    final savedPassword = savedData[0];
    final savedCode = savedData[1];

    // Asume que la autenticación biométrica ya fue exitosa, inicia sesión directamente
    _showSnackBar(context, 'Inicio de sesión exitoso con biometría');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PasswordListScreen()),
    );
  } catch (e) {
    _showSnackBar(context, 'Error al iniciar sesión con biometría: $e');
  }
}


  void login(BuildContext context, String code, String password, [File? selectedFile]) async {
    try {
      String filePath = await fileManager.getVerificationFilePath();
      File file = selectedFile ?? File(filePath);

      if (!await file.exists()) {
        _showSnackBar(context, 'No se encontraron datos de registro');
        return;
      }

      final fileContent = await file.readAsString();
      final Map<String, dynamic> jsonData = jsonDecode(fileContent);

      if (!jsonData.containsKey('encryptedData') || !jsonData.containsKey('publicKey') || !jsonData.containsKey('privateKey')) {
        _showSnackBar(context, 'Datos de registro corruptos: faltan campos.');
        return;
      }

      final encryptedData = jsonData['encryptedData'] as String;
      final keyPair = KyberKeyPair.fromPolynomials(
        Polynomial(decodeCoefficients(jsonData['publicKey'] as String)),
        Polynomial(decodeCoefficients(jsonData['privateKey'] as String)),
      );

      if (keyPair.publicKey.coefficients.isEmpty || keyPair.privateKey.coefficients.isEmpty) {
        _showSnackBar(context, 'Claves cargadas están vacías.');
        return;
      }

      final sharedKey = createSharedKey(keyPair, keyPair.publicKey, 3329);
      if (sharedKey.coefficients.isEmpty || encryptedData.isEmpty) {
        _showSnackBar(context, 'Datos de registro corruptos: clave compartida inválida.');
        return;
      }

      final decryptedData = decryptSession(encryptedData, sharedKey, 3329);
      final savedData = decryptedData.split(':');

      if (savedData.length != 2) {
        _showSnackBar(context, 'Datos de registro corruptos: formato inválido.');
        return;
      }

      final savedPassword = savedData[0];
      final savedCode = savedData[1];

      if (password == savedPassword && code == savedCode) {
        _showSnackBar(context, 'Inicio de sesión exitoso');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PasswordListScreen()),
        );
      } else {
        _showSnackBar(context, 'Código o contraseña incorrectos');
      }
    } catch (e) {
      _showSnackBar(context, 'Error al iniciar sesión: $e');
    }
  }

  // Navegar a la página de importar sesión y pasar el código y contraseña de inicio de sesión
  void navigateToImportSession(BuildContext context, String code, String password) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImportSessionPage(
          loginCode: code,
          loginPassword: password,
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
