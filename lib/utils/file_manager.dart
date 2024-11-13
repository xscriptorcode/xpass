import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

class FileManager {
  /// Obtiene la ruta del archivo de verificación de sesión.
  Future<File> getVerificationFile() async {
    Directory? documentsDir = await getExternalStorageDirectory();
    documentsDir ??= await getApplicationDocumentsDirectory();
    String filePath = '${documentsDir.path}/xsessions/verification.enc';
    return File(filePath);
  }

  /// Obtiene la ruta como cadena del archivo de verificación de sesión.
  Future<String> getVerificationFilePath() async {
    final file = await getVerificationFile();
    return file.path;
  }

  /// Obtiene la ruta del archivo de perfil de sesión.
  Future<String> getProfileFilePath() async {
    Directory? documentsDir = await getExternalStorageDirectory();
    documentsDir ??= await getApplicationDocumentsDirectory();
    String filePath = '${documentsDir.path}/xsessions/profile.enc';
    return filePath;
  }

  /// Obtiene la ruta del directorio xsessions.
  Future<String> getXSessionsPath() async {
    Directory? documentsDir = await getExternalStorageDirectory();
    documentsDir ??= await getApplicationDocumentsDirectory();
    String xSessionsPath = '${documentsDir.path}/xsessions';
    final xSessionsDir = Directory(xSessionsPath);

    // Verifica si el directorio existe; si no, lo crea
    if (!await xSessionsDir.exists()) {
      await xSessionsDir.create(recursive: true);
    }

    return xSessionsPath;
  }

  /// Permite al usuario seleccionar un archivo de sesión de forma manual.
  Future<File?> pickSessionFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withReadStream: true,
      );

      if (result != null && result.files.isNotEmpty) {
        return File(result.files.single.path!);
      }
    } catch (e) {
      print("Error al seleccionar el archivo: $e");
    }
    return null;
  }

  /// Guarda datos cifrados en un archivo con una ruta especificada.
  Future<void> saveDataToFile(String path, String encryptedData) async {
    try {
      File file = File(path);
      await file.writeAsString(encryptedData);
    } catch (e) {
      throw Exception('Error al guardar los datos cifrados: $e');
    }
  }

  /// Lee datos desde un archivo y devuelve el contenido como una cadena.
  Future<String?> readDataFromFile(String path) async {
    try {
      File file = File(path);
      if (await file.exists()) {
        return await file.readAsString();
      } else {
        print("Archivo no encontrado en la ruta especificada: $path");
      }
    } catch (e) {
      throw Exception('Error al leer los datos del archivo: $e');
    }
    return null;
  }
}
