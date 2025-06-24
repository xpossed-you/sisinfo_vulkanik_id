import 'package:flutter/material.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'register_page.dart';

void main() {
  runApp(VulcaNesiaApp());
}

class VulcaNesiaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VulcaNesia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color.fromARGB(255, 26, 26, 26),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFD72638), // Lava Red
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFF5700), // Magma Orange
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}
