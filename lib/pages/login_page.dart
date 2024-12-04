import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart'; 
import 'package:xpass/components/my_button.dart';
import 'package:xpass/components/my_textfield.dart';
import 'package:xpass/auth/login_manager.dart';

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
  final LocalAuthentication _auth = LocalAuthentication(); // Instancia para autenticación biométrica

  bool _isBiometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
  }

  // Verifica si la autenticación biométrica está disponible
  Future<void> _checkBiometricSupport() async {
    final isAvailable = await _auth.canCheckBiometrics;
    setState(() {
      _isBiometricAvailable = isAvailable;
    });
  }

  // Método para iniciar sesión
  void login(BuildContext context) {
    _loginManager.login(context, _codeController.text, _passwordController.text);
  }

  // Método para autenticación biométrica
  Future<void> _loginWithBiometrics(BuildContext context) async {
    try {
      final didAuthenticate = await _auth.authenticate(
        localizedReason: 'Por favor, autentícate para iniciar sesión',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (didAuthenticate) {
        // Autenticación exitosa, iniciar sesión
        _loginManager.loginWithBiometrics(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Autenticación fallida.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al autenticar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
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
                    if (_isBiometricAvailable) ...[
                      const SizedBox(height: 20),
                      MyButton(
                        text: "Iniciar sesión con huella",
                        onTap: () => _loginWithBiometrics(context),
                      ),
                    ],
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
                          onTap: widget.onTap,
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
