// light_mode.dart
import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: const Color.fromARGB(255, 255, 255, 255),
    primary: const Color.fromARGB(255, 136, 136, 136),
    secondary: const Color.fromARGB(255, 240, 240, 240),
    tertiary: const Color.fromARGB(255, 222, 222, 222),
    inversePrimary: Colors.grey.shade900,
  ),
);