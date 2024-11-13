// auth/relative/alias_logic.dart

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:xpass/crypto/kyber_logic.dart' as kyber;
import 'package:xpass/crypto/kyber_keypair.dart';

/// Función para guardar el alias cifrado
Future<void> saveAlias(String alias, String code) async {
  try {
    // Generamos un par de claves y una clave compartida
    final keyPair = KyberKeyPair.generate();
    final sharedKey = kyber.createSharedKey(keyPair, keyPair.publicKey, 3329);

    // Ciframos el alias con la clave compartida
    String dataToSave = '$alias\n$code';
    String encryptedData = kyber.encryptSession(dataToSave, sharedKey, 3329);

    // Guardamos en un archivo
    Directory? documentsDir = await getExternalStorageDirectory();
    documentsDir ??= await getApplicationDocumentsDirectory();
    String aliasesPath = '${documentsDir.path}/aliases';
    Directory aliasesDir = Directory(aliasesPath);

    if (!await aliasesDir.exists()) {
      await aliasesDir.create(recursive: true);
    }

    File file = File('${aliasesDir.path}/alias_$code.txt');
    await file.writeAsString(encryptedData);
  } catch (e) {
    throw Exception('Error al guardar el alias: $e');
  }
}
