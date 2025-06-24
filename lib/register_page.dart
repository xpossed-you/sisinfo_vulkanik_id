import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String errorMessage = '';
  bool isLoading = false;

  Future<void> registerUser() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse('http://localhost/volcano_api/register.php'),
      body: {
        'name': nameController.text,
        'email': emailController.text,
        'password': passwordController.text,
      },
    );

    try {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        setState(() {
          errorMessage = data['error'] ?? 'Registration failed.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Invalid response from server.';
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: Color(0xFFD72638),
        title: Text('Register'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.orangeAccent),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: emailController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.orangeAccent),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.orangeAccent),
                ),
              ),
              SizedBox(height: 24),
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: TextStyle(color: Colors.redAccent),
                ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: isLoading ? null : registerUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF5700),
                  foregroundColor: Colors.white,
                ),
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
