import 'package:flutter/material.dart';
import 'package:xpass/pages/login_page.dart';
import 'package:xpass/pages/register_page.dart';


class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState(); 
}

class _LoginOrRegisterState extends State<LoginOrRegister>{
  //inicialmente, login page es la vista por defecto
  bool showLoginPage = true;

  //funcion para cambiar de vista
  void toggleScreens() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        onTap: toggleScreens,
      );
    } else {
      return RegisterPage(
        onTap: toggleScreens,
      );
    }
  }
}