import 'package:flutter/material.dart';
import 'package:xpass/screens/password_list_screen.dart';
import 'package:xpass/services/secure_storage_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final isLoggedIn = await SecureStorageService.isUserLoggedIn();
    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PasswordListScreen()),
      );
    }
  }

  Future<void> _authenticateWithPin() async {
    final pin = _pinController.text;
    final isValidPin = await SecureStorageService.verifyPin(pin);

    if (isValidPin) {
      await SecureStorageService.setSessionStatus(true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PasswordListScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Incorrect PIN'),
      ));
    }
  }

  Future<void> _saveNewPin() async {
    final pin = _pinController.text;
    await SecureStorageService.savePin(pin);
    await SecureStorageService.setSessionStatus(true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PasswordListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _pinController,
              decoration: InputDecoration(labelText: "Enter PIN"),
              obscureText: true,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final hasStoredPin = await SecureStorageService.hasStoredPin();
                if (hasStoredPin) {
                  _authenticateWithPin();
                } else {
                  _saveNewPin();
                }
              },
              child: Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
