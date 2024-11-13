// lib/pages/register_page.dart

import 'package:flutter/material.dart';
import 'package:xpass/components/my_button.dart';
import 'package:xpass/components/my_textfield.dart';
import 'package:xpass/utils/code_generator.dart';
import 'package:xpass/auth/register_page_logic.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController = TextEditingController();
  final TextEditingController _aliasController = TextEditingController(); // Controlador para Alias

  @override
  void initState() {
    super.initState();
    _generateAccessCode();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmpasswordController.dispose();
    _aliasController.dispose(); // Liberar el controlador
    super.dispose();
  }

  void _generateAccessCode() {
    _codeController.text = CodeGenerator.generateAccessCode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView( // Para evitar desbordamiento en pantallas pequeñas
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    IconButton(
                      icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.primary),
                      onPressed: _generateAccessCode,
                      tooltip: "Generar nuevo código",
                    ),
                    const SizedBox(height: 10),
                    MyTextField(
                      hintText: "Alias (opcional)",
                      obscureText: false,
                      controller: _aliasController,
                    ),
                    const SizedBox(height: 15),
                    MyTextField(
                      hintText: "Contraseña",
                      obscureText: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 15),
                    MyTextField(
                      hintText: "Confirma la Contraseña",
                      obscureText: true,
                      controller: _confirmpasswordController,
                    ),
                    const SizedBox(height: 20),
                    MyButton(
                      text: "Registrar",
                      onTap: () => register(
                        context,
                        _passwordController.text,
                        _confirmpasswordController.text,
                        _codeController.text,
                        _aliasController.text.isEmpty ? null : _aliasController.text,
                        widget.onTap,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "¿Ya tienes una cuenta?",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.onTap, // Asegura que widget.onTap esté disponible
                          child: Text(
                            " Inicia sesión",
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
