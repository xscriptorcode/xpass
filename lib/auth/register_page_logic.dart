import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:xpass/utils/file_manager.dart';
import 'package:xkyber_crypto/kyber_keypair.dart';
import 'package:xkyber_crypto/kyber_logic.dart';
import 'package:xkyber_crypto/coefficients_codec.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:xpass/utils/encryption_utils.dart' as encrut;
import 'package:xpass/utils/bd/database_helper.dart';

Future<void> clearPreviousSession() async {
  final fileManager = FileManager();
  final dbHelper = DatabaseHelper();

  // 1. Reinicia la base de datos para eliminar cualquier dato residual
  await dbHelper.resetDatabase();

  // 2. Eliminar archivo de sesión si existe
  String sessionFilePath = await fileManager.getVerificationFilePath();
  final sessionFile = File(sessionFilePath);
  if (await sessionFile.exists()) {
    await sessionFile.delete();
  }

  // 3. Eliminar el archivo de perfil `profile.enc` si existe
  String xSessionsPath = await fileManager.getXSessionsPath();
  String profileFilePath = '$xSessionsPath/profile.enc';
  final profileFile = File(profileFilePath);
  if (await profileFile.exists()) {
    await profileFile.delete();
  }
}

Future<void> saveSessionWithKeys(String dataToSave, KyberKeyPair keyPair, [String? alias]) async {
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

Future<void> saveAlias(String alias) async {
  final fileManager = FileManager();
  final secretKey = await encrut.generateSecretKey();
  String encryptedAlias = await encrut.encryptData(alias, secretKey);

  String xSessionsPath = await fileManager.getXSessionsPath();
  File profileFile = File('$xSessionsPath/profile.enc');
  await profileFile.writeAsString(encryptedAlias);
}

void register(
  BuildContext context,
  String password,
  String confirmPassword,
  String code,
  String? alias,
  void Function()? onTap,
) async {
  if (password != confirmPassword) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Las contraseñas no coinciden')),
    );
    return;
  }

  if (Platform.isAndroid) {
    var status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permiso de almacenamiento denegado')),
      );
      return;
    }
  }

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
