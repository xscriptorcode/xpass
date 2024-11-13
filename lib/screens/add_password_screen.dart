import 'package:flutter/material.dart';
import 'package:xpass/services/secure_storage_service.dart';

class AddPasswordScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: "Enter Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await SecureStorageService.savePassword("new_label", _controller.text);
                Navigator.pop(context);
              },
              child: Text("Save Password"),
            ),
          ],
        ),
      ),
    );
  }
}
