import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:xpass/utils/file_manager.dart';
import 'package:xkyber_crypto/kyber_keypair.dart';
import 'package:xkyber_crypto/kyber_logic.dart';
import 'package:xkyber_crypto/coefficients_codec.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:xpass/utils/encryption_utils.dart' as encrut;
import 'package:xpass/utils/bd/database_helper.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Limpia cualquier sesión previa eliminando los datos almacenados y reiniciando la base de datos.
Future<void> clearPreviousSession() async {
  final fileManager = FileManager();
  final dbHelper = DatabaseHelper();

  // Reinicia la base de datos
  await dbHelper.resetDatabase();

  // Elimina archivo de sesión si existe
  String sessionFilePath = await fileManager.getVerificationFilePath();
  final sessionFile = File(sessionFilePath);
  if (await sessionFile.exists()) {
    await sessionFile.delete();
  }

  // Elimina el archivo de perfil `profile.enc` si existe
  String xSessionsPath = await fileManager.getXSessionsPath();
  String profileFilePath = '$xSessionsPath/profile.enc';
  final profileFile = File(profileFilePath);
  if (await profileFile.exists()) {
    await profileFile.delete();
  }
}

/// Guarda una nueva sesión encriptada junto con las claves generadas.
Future<void> saveSessionWithKeys(
    String dataToSave, KyberKeyPair keyPair, [String? alias]) async {
  final sharedKey = createSharedKey(keyPair, keyPair.publicKey, 3329);
  String encryptedData = encryptSession(dataToSave, sharedKey, 3329);

  if (encryptedData.isEmpty || sharedKey.coefficients.isEmpty) {
    throw Exception("Error en la generación de claves o cifrado de datos.");
  }

  final fileManager = FileManager();
  String filePath = await fileManager.getVerificationFilePath();

  final file = File(filePath);
  final directory = file.parent;

  if (!(await directory.exists())) {
    await directory.create(recursive: true);
  }

  Map<String, String> sessionData = {
    "encryptedData": encryptedData,
    "publicKey": encodeCoefficients(keyPair.publicKey.coefficients),
    "privateKey": encodeCoefficients(keyPair.privateKey.coefficients),
    if (alias != null) "alias": alias,
  };

  String jsonSessionData = jsonEncode(sessionData);
  await file.writeAsString(jsonSessionData);
}

/// Guarda el alias de usuario de manera encriptada.
Future<void> saveAlias(String alias) async {
  final fileManager = FileManager();
  final secretKey = await encrut.generateSecretKey();
  String encryptedAlias = await encrut.encryptData(alias, secretKey);

  String xSessionsPath = await fileManager.getXSessionsPath();
  File profileFile = File('$xSessionsPath/profile.enc');
  await profileFile.writeAsString(encryptedAlias);
}



Future<void> checkStoragePermission(BuildContext context) async {
  final deviceInfo = DeviceInfoPlugin();
  final androidInfo = await deviceInfo.androidInfo;
  final sdkInt = androidInfo.version.sdkInt;

  // Función auxiliar para mostrar un SnackBar
  void _showPermissionDeniedSnackBar() {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Permiso de almacenamiento denegado.'),
      ),
    );
  }

  if (sdkInt >= 30) {
    // Android 11+ (API 30+): MANAGE_EXTERNAL_STORAGE
    var status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      _showPermissionDeniedSnackBar();
      return;
    }
  } else {
    // Android 10 o anterior: READ/WRITE_EXTERNAL_STORAGE
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      _showPermissionDeniedSnackBar();
      return;
    }
  }
}

/// Realiza el registro del usuario, incluyendo validaciones, manejo de permisos y generación de claves.
void register(
  BuildContext context,
  String password,
  String confirmPassword,
  String code,
  String? alias,
  void Function()? onTap,
) async {
  if (password.isEmpty || confirmPassword.isEmpty || code.isEmpty) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Por favor, completa todos los campos')),
    );
    return;
  }

  if (password != confirmPassword) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Las contraseñas no coinciden')),
    );
    return;
  }

  await checkStoragePermission(context);

  try {
    await clearPreviousSession();

    final keyPair = KyberKeyPair.generate();
    String dataToSave = '$password:$code';

    await saveSessionWithKeys(dataToSave, keyPair, alias ?? "X");
    await saveAlias(alias ?? "X");

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registro exitoso')),
    );

    if (context.mounted && onTap != null) {
      onTap();
    }
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al registrar: $e')),
    );
  }
}
