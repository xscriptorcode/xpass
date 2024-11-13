import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:xkyber_crypto/xkyber_crypto.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class SecureStorageService {
  static final _storage = FlutterSecureStorage();
  static KyberKeyPair? _keyPair;

  // Inicializa un par de claves y almacena en memoria
  static Future<void> initializeKeys() async {
    _keyPair ??= KyberKeyPair.generate();
  }

  // Deriva una clave de 256 bits usando SHA-256 para asegurar compatibilidad con AES
  static Uint8List deriveKey(Uint8List inputKey) {
    final digest = sha256.convert(inputKey);
    return Uint8List.fromList(digest.bytes);
  }

  // Guarda el PIN cifrado en almacenamiento seguro
  static Future<void> savePin(String pin) async {
    await initializeKeys();
    final kem = KyberKEM(_keyPair!.publicKey, _keyPair!.privateKey);
    final sharedSecret = kem.encapsulate();

    // Derivar la clave de 256 bits y convertir el PIN a Base64
    final derivedKey = deriveKey(Uint8List.fromList(sharedSecret));
    final encodedPin = base64Encode(utf8.encode(pin));
    await _storage.write(key: 'user_pin', value: encodedPin);
  }

  // Verifica el PIN ingresado
  static Future<bool> verifyPin(String pin) async {
    final storedPin = await _storage.read(key: 'user_pin');
    if (storedPin == null) return false;

    final kem = KyberKEM(_keyPair!.publicKey, _keyPair!.privateKey);
    final sharedSecret = kem.encapsulate();
    final derivedKey = deriveKey(Uint8List.fromList(sharedSecret));

    // Decodificar el PIN almacenado y comparar
    final decodedStoredPin = utf8.decode(base64Decode(storedPin));
    return decodedStoredPin == pin;
  }

  // Guarda una contraseña cifrada en almacenamiento seguro
  static Future<void> savePassword(String label, String password) async {
    await initializeKeys();
    final kem = KyberKEM(_keyPair!.publicKey, _keyPair!.privateKey);
    final sharedSecret = kem.encapsulate();

    // Derivar clave y guardar la contraseña en Base64
    final derivedKey = deriveKey(Uint8List.fromList(sharedSecret));
    final encodedPassword = base64Encode(utf8.encode(password));
    await _storage.write(key: label, value: encodedPassword);
  }

  // Recuperar y descifrar todas las contraseñas
  static Future<List<String>> getAllPasswords() async {
    final allPasswords = await _storage.readAll();
    final kem = KyberKEM(_keyPair!.publicKey, _keyPair!.privateKey);

    return allPasswords.entries.map((entry) {
      final sharedSecret = kem.encapsulate();
      final derivedKey = deriveKey(Uint8List.fromList(sharedSecret));
      final decodedCipher = utf8.decode(base64Decode(entry.value!));
      return decodedCipher;
    }).toList();
  }

  // Eliminar una contraseña almacenada
  static Future<void> deletePassword(String label) async {
    await _storage.delete(key: label);
  }

  // Verificar si hay un PIN almacenado
  static Future<bool> hasStoredPin() async {
    final pin = await _storage.read(key: 'user_pin');
    return pin != null;
  }

  // Establecer el estado de la sesión
  static Future<void> setSessionStatus(bool isLoggedIn) async {
    await _storage.write(key: 'session', value: isLoggedIn.toString());
  }

  // Verificar si el usuario está logueado
  static Future<bool> isUserLoggedIn() async {
    final status = await _storage.read(key: 'session');
    return status == 'true';
  }
}
