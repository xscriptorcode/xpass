import 'package:xpass/auth/login_or_register.dart';
import 'package:xpass/themes/light_mode.dart';
import 'package:flutter/material.dart';
import 'package:xpass/themes/theme_provider.dart';
import 'package:xpass/themes/dark_mode.dart'; 
import 'package:provider/provider.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginOrRegister(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
