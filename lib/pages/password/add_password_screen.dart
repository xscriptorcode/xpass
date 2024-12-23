// lib/pages/password/add_password_screen.dart

import 'package:flutter/material.dart';
import 'package:xpass/utils/bd/database_helper.dart';
import 'package:xpass/pages/password/password.dart';
import 'package:xpass/pages/password/password_list_screen.dart';
import 'package:xpass/utils/encryption_utils.dart';

class AddPasswordScreen extends StatefulWidget {
  final bool isEditing;
  final Password? password;
  final Function(Password)? onSave;

  const AddPasswordScreen({
    Key? key,
    this.isEditing = false,
    this.password,
    this.onSave,
  }) : super(key: key);

  @override
  _AddPasswordScreenState createState() => _AddPasswordScreenState();
}

class _AddPasswordScreenState extends State<AddPasswordScreen> {
  final _nameController = TextEditingController();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.password != null) {
      _nameController.text = widget.password!.name;
      _userController.text = widget.password!.user;
      _passwordController.text = widget.password!.password;
    }
  }

  Future<void> _savePassword() async {
    final name = _nameController.text.trim();
    final user = _userController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre y la contraseña son obligatorios')),
      );
      return;
    }

    try {
      // Genera la clave secreta y cifra la contraseña
      final secretKey = await generateSecretKey();
      final encryptedPassword = await encryptData(password, secretKey);

      final newPassword = Password(
        id: widget.password?.id, // Mantener el ID si es una edición
        name: name,
        user: user,
        password: encryptedPassword,
        lastUpdated: DateTime.now(),
      );

      if (widget.isEditing && widget.onSave != null) {
        widget.onSave!(newPassword); // Llamar a la función de guardar en modo de edición
      } else {
        await _dbHelper.insertPassword(newPassword, secretKey);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PasswordListScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la contraseña: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Contraseña' : 'Agregar Nueva Contraseña'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 400,
            maxHeight: 400,
          ),
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nombre del sitio o aplicación'),
                  ),
                  TextField(
                    controller: _userController,
                    decoration: const InputDecoration(labelText: 'Nombre de usuario (opcional)'),
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  IconButton(
                    onPressed: _savePassword,
                    icon: const Icon(Icons.save),
                    tooltip: 'Guardar',
                    iconSize: 32,
                    color: Theme.of(context).primaryColorDark,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
