import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  final String username;

  const DashboardPage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      body: Center(
        child: Text("Welcome, $username!"),
      ),
    );
  }
}
