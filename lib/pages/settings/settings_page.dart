import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:xpass/pages/settings/change_password_page.dart';
import 'package:xpass/pages/settings/export_session_page.dart';
import 'package:xpass/themes/theme_provider.dart';
import 'package:xpass/utils/encryption_utils.dart';
import 'package:xpass/utils/file_manager.dart';
import 'package:file_picker/file_picker.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _alias;
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadAliasAndImage();
  }

  Future<void> _loadAliasAndImage() async {
    try {
      if (Platform.isAndroid) {
        var status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permiso de almacenamiento denegado')),
          );
          return;
        }
      }

      final secretKey = await generateSecretKey();
      String xSessionsPath = await FileManager().getXSessionsPath();
      File profileFile = File('$xSessionsPath/profile.enc');

      if (!await profileFile.exists()) {
        setState(() {
          _alias = 'Usuario';
          _imagePath = null;
        });
        return;
      }

      String encryptedProfileData = await profileFile.readAsString();
      String decryptedProfileData = await decryptData(encryptedProfileData, secretKey);

      List<String> lines = decryptedProfileData.split('\n');
      String alias = lines[0];
      String? imagePath = lines.length > 1 ? lines[1] : null;

      setState(() {
        _alias = alias;
        _imagePath = imagePath;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar el alias y la imagen: $e')),
      );
      setState(() {
        _alias = 'Usuario';
        _imagePath = null;
      });
    }
  }

  Future<void> _saveAliasAndImage(String alias, String? imagePath) async {
    try {
      if (Platform.isAndroid) {
        var status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permiso de almacenamiento denegado')),
          );
          return;
        }
      }

      final secretKey = await generateSecretKey();
      String dataToSave = imagePath != null ? '$alias\n$imagePath' : alias;
      String encryptedData = await encryptData(dataToSave, secretKey);

      String xSessionsPath = await FileManager().getXSessionsPath();
      File profileFile = File('$xSessionsPath/profile.enc');
      await profileFile.writeAsString(encryptedData);

      setState(() {
        _alias = alias;
        _imagePath = imagePath;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alias e imagen actualizados exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el alias y la imagen: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
      if (_alias != null) {
        _saveAliasAndImage(_alias!, pickedFile.path);
      }
    }
  }

  void _navigateToExportSessionPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ExportSessionPage()),
    );
  }

  void _editAlias() {
    final controller = TextEditingController(text: _alias);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Alias'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Nuevo Alias'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Guardar'),
              onPressed: () {
                _saveAliasAndImage(controller.text, _imagePath);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _changePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
    );
  }

  void _toggleTheme() {
    Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuraciones'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _imagePath != null
                    ? FileImage(File(_imagePath!))
                    : null,
                child: _imagePath == null
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text('Alias: $_alias'),
              trailing: const Icon(Icons.edit),
              onTap: _editAlias,
            ),
        //    ListTile(
        //      leading: const Icon(Icons.lock),
        //      title: const Text('Contraseña'),
        //      trailing: const Icon(Icons.arrow_forward),
        //      onTap: _changePassword,
        //    ),
            SwitchListTile(
              title: const Text('Modo Oscuro'),
              value: isDarkMode,
              onChanged: (value) {
                _toggleTheme();
              },
            ),
            const SizedBox(height: 20),
          //  ElevatedButton.icon(
          //    onPressed: _navigateToExportSessionPage,
          //    icon: const Icon(Icons.upload_file),
          //    label: const Text('Exportar Archivo de Sesión'),
          //  ),
          ],
        ),
      ),
    );
  }
}
