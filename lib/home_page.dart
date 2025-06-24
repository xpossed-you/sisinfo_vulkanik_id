import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'volcano_page.dart';
import 'about_page.dart';
import 'dashboard.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoggedIn = false;
  String username = '';

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      username = prefs.getString('username') ?? '';
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    setState(() {
      isLoggedIn = false;
      username = '';
    });

                  ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Logout successfully!'),
                  backgroundColor: const Color.fromARGB(255, 255, 158, 106),
                  duration: Duration(seconds: 2),
                ),
              );
  }

  Widget buildButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 50),
          backgroundColor: Color(0xFFFF5700),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(text, style: TextStyle(fontSize: 18)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      appBar: AppBar(
        title: Text('VulcaNesia'),
        centerTitle: true,
        backgroundColor: Color(0xFFD72638),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo_aplikasi.png',
              height: 240,
            ),
            SizedBox(height: 32),
            buildButton('Explore Volcanoes!', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => VolcanoPage()));
            }),
            buildButton('About', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AboutPage()));
            }),
            isLoggedIn
                ? Column(
                    children: [
                      buildButton('Dashboard', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DashboardPage())
                        );
                      }),
                      buildButton('Logout', logout),
                    ],
                  )
                : Column(
                    children: [
                      buildButton('Login', () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage()))
                            .then((_) => checkLoginStatus());
                      }),
                      buildButton('Register', () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterPage()));
                      }),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
