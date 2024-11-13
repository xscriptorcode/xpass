// permission_manager.dart
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  /// Función para solicitar permisos de almacenamiento
  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Verificar permisos de gestión de almacenamiento para Android 11+
      if (await Permission.manageExternalStorage.isDenied || await Permission.manageExternalStorage.isPermanentlyDenied) {
        final result = await Permission.manageExternalStorage.request();
        if (result.isGranted) {
          return true;
        }
      }

      // Verificar permisos de almacenamiento de lectura y escritura
      if (await Permission.storage.isDenied || await Permission.storage.isPermanentlyDenied) {
        final result = await Permission.storage.request();
        if (result.isGranted) {
          return true;
        }
      }

      // Verificar si el permiso se otorgó correctamente
      return await Permission.storage.isGranted || await Permission.manageExternalStorage.isGranted;
    }

    // Asumir permisos concedidos para otros sistemas operativos
    return true;
  }
}
