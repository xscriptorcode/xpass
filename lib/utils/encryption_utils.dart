// lib/utils/encryption_utils.dart

import 'package:xpass/crypto/kyber_keypair.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:xpass/crypto/polynomial.dart';

/// Genera una clave secreta para el cifrado
Future<SecretKey> generateSecretKey() async {
  final keyBytes = List<int>.generate(
      32, (i) => i * 3 % 256); // Ejemplo de generación de clave
  return SecretKey(Uint8List.fromList(keyBytes));
}

/// Cifra los datos utilizando AES-GCM con la clave secreta
Future<String> encryptData(String data, SecretKey secretKey) async {
  final algorithm = AesGcm.with256bits();
  final nonce = algorithm.newNonce();
  final secretBox = await algorithm.encrypt(
    utf8.encode(data),
    secretKey: secretKey,
    nonce: nonce,
  );

  // Combina el nonce, los datos cifrados y el MAC en una sola cadena
  final encryptedData =
      base64Encode([...nonce, ...secretBox.cipherText, ...secretBox.mac.bytes]);
  return encryptedData;
}

/// Descifra los datos utilizando AES-GCM con la clave secreta
Future<String> decryptData(String encryptedData, SecretKey secretKey) async {
  final algorithm = AesGcm.with256bits();
  final decodedData = base64Decode(encryptedData);

  // Separa el nonce, el texto cifrado y el MAC
  final nonce = decodedData.sublist(0, algorithm.nonceLength);
  final cipherText =
      decodedData.sublist(algorithm.nonceLength, decodedData.length - 16);
  final mac = Mac(decodedData.sublist(decodedData.length - 16));

  final secretBox = SecretBox(cipherText, nonce: nonce, mac: mac);
  final decryptedData =
      await algorithm.decrypt(secretBox, secretKey: secretKey);
  return utf8.decode(decryptedData);
}

/// Función para crear una clave compartida a partir de una clave pública y privada
Polynomial createSharedKey(
    KyberKeyPair keyPair, Polynomial otherPublicKey, int mod) {
  return keyPair.privateKey.multiply(otherPublicKey, mod);
}

/// Cifra los datos de sesión usando la clave compartida
String encryptSession(String sessionData, Polynomial sharedKey, int mod) {
  List<int> dataBytes = sessionData.codeUnits;
  List<int> encryptedBytes = [];

  for (int i = 0; i < dataBytes.length; i++) {
    int encryptedByte = modMul(dataBytes[i],
        sharedKey.coefficients[i % sharedKey.coefficients.length], mod);
    encryptedBytes.add(encryptedByte);
  }

  
        // Fix: Ensure encrypted data is returned as a valid base64 string
        return base64Encode(utf8.encode(encryptedBytes.join('-')));
         // Convertir a una cadena
}

/// Descifra los datos de sesión usando la clave compartida
String decryptSession(String encryptedData, Polynomial sharedKey, int mod) {
  
        // Fix: Decode the base64 string into its original encrypted byte list
        List<int> encryptedBytes = utf8.decode(base64Decode(encryptedData)).split('-').map(int.parse).toList();
        
  List<int> decryptedBytes = [];

  for (int i = 0; i < encryptedBytes.length; i++) {
    int decryptedByte = modMul(encryptedBytes[i],
        sharedKey.coefficients[i % sharedKey.coefficients.length], mod);
    decryptedBytes.add(decryptedByte);
  }

  return String.fromCharCodes(decryptedBytes);
}

/// Operación modular para multiplicar, usada en cifrado y descifrado
int modMul(int a, int b, int mod) => ((a % mod) * (b % mod)) % mod;