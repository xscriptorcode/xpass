import 'package:flutter/material.dart';
import 'package:xpass/screens/add_password_screen.dart';
import 'package:xpass/services/secure_storage_service.dart';
import 'package:xpass/screens/login_screen.dart';

class PasswordListScreen extends StatefulWidget {
  @override
  _PasswordListScreenState createState() => _PasswordListScreenState();
}

class _PasswordListScreenState extends State<PasswordListScreen> {
  List<String> _passwords = [];

  @override
  void initState() {
    super.initState();
    _loadPasswords();
  }

  Future<void> _loadPasswords() async {
    final passwords = await SecureStorageService.getAllPasswords();
    setState(() {
      _passwords = passwords;
    });
  }

  Future<void> _logout() async {
    await SecureStorageService.setSessionStatus(false); // Cierra la sesión
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Passwords"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _passwords.length,
        itemBuilder: (context, index) {
          final password = _passwords[index];
          return ListTile(
            title: Text(password),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                await SecureStorageService.deletePassword(password);
                _loadPasswords();
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPasswordScreen()),
          );
          _loadPasswords();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
