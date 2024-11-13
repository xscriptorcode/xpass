// lib/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:xpass/components/my_button.dart';
import 'package:xpass/components/my_textfield.dart';
import 'package:xpass/auth/login_manager.dart';
import 'dart:io';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginManager _loginManager = LoginManager();

  // Método de inicio de sesión
  void login(BuildContext context, {File? selectedFile}) {
    _loginManager.login(context, _codeController.text, _passwordController.text, selectedFile);
  }

  // Método para importar archivo de sesión manualmente
  Future<void> importSessionFile(BuildContext context) async {
    _loginManager.importSessionFile(context, _codeController.text, _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView( // Hacemos todo el contenido scrollable
          padding: const EdgeInsets.all(16), // Espaciado alrededor del contenido
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        'icon.png',
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Bienvenido",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    MyTextField(
                      hintText: "Código de acceso",
                      obscureText: false,
                      controller: _codeController,
                    ),
                    const SizedBox(height: 15),
                    MyTextField(
                      hintText: "Contraseña",
                      obscureText: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 20),
                    MyButton(
                      text: "Iniciar",
                      onTap: () => login(context),
                    ),
                    const SizedBox(height: 10),
                    MyButton(
                      text: "Importar archivo de sesión",
                      onTap: () => importSessionFile(context),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "¿No tienes cuenta?",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.onTap, // Asegura que widget.onTap esté disponible
                          child: Text(
                            " Regístrate",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
