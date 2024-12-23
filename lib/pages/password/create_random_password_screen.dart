import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xpass/utils/code_generator.dart';

class CreateRandomPasswordScreen extends StatefulWidget {
  const CreateRandomPasswordScreen({super.key});

  @override
  State<CreateRandomPasswordScreen> createState() =>
      _CreateRandomPasswordScreenState();
}

class _CreateRandomPasswordScreenState
    extends State<CreateRandomPasswordScreen> {
  String _generatedPassword = '';

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  void _generatePassword() {
    setState(() {
      _generatedPassword = CodeGenerator.generateAccessCode();
    });
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _generatedPassword));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contraseña copiada al portapapeles')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generar Contraseña Aleatoria'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Caja de texto centrada con la contraseña generada
            Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2.0,
                  ),
                ),
                child: Text(
                  _generatedPassword,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Botón para copiar al portapapeles
            ElevatedButton.icon(
              onPressed: _copyToClipboard,
              icon: const Icon(Icons.copy),
              label: const Text('Copiar al portapapeles'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 12.0),
              ),
            ),
            const SizedBox(height: 20),
            // Botón para generar una nueva contraseña
            ElevatedButton.icon(
              onPressed: _generatePassword,
              icon: const Icon(Icons.refresh),
              label: const Text('Generar Nueva Contraseña'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 12.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
