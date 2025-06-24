import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String email = '';
  int volcanoCount = 0;
  bool isLoading = true;
  String siStatus = 'Checking...';
  String magmaStatus = 'Checking...';

  @override
  void initState() {
    super.initState();
    loadUserEmail();
    refreshDashboard();
  }

  Future<void> loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email') ?? '';
    });
  }

  Future<void> refreshDashboard() async {
    setState(() {
      isLoading = true;
      siStatus = 'Checking...';
      magmaStatus = 'Checking...';
    });
    await fetchVolcanoCount();
    await checkWebsiteStatus();

    if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dashboard refreshed successfully!'),
        backgroundColor: Colors.green[600],
        duration: Duration(seconds: 2),
      ),
    );
  }
  }

  Future<void> fetchVolcanoCount() async {
    try {
      final response = await http.get(
        Uri.parse('https://xpossed-you.github.io/hasil_webscrap/volcano_data.json'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          volcanoCount = data.length;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load volcano data');
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> checkWebsiteStatus() async {
    final urls = {
      'si': 'https://volcano.si.edu/',
      'magma': 'https://magma.esdm.go.id/',
    };

    for (var entry in urls.entries) {
      try {
        final response = await http.get(Uri.parse(entry.value)).timeout(Duration(seconds: 5));
        if (response.statusCode == 200) {
          setState(() {
            if (entry.key == 'si') siStatus = 'OK';
            if (entry.key == 'magma') magmaStatus = 'OK';
          });
        } else {
          setState(() {
            if (entry.key == 'si') siStatus = 'Offline';
            if (entry.key == 'magma') magmaStatus = 'Offline';
          });
        }
      } catch (e) {
        setState(() {
          if (entry.key == 'si') siStatus = 'Offline';
          if (entry.key == 'magma') magmaStatus = 'Offline';
        });
      }
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Logout successfully!'),
                  backgroundColor: const Color.fromARGB(255, 255, 160, 109),
                  duration: Duration(seconds: 2),
                ),
              );
  }

  Widget statusTile(String title, String status, String url) {
    return Card(
      color: Colors.grey[850],
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(Icons.link, color: Colors.lightBlueAccent),
        title: Text(title, style: TextStyle(color: Colors.white)),
        subtitle: Text(url, style: TextStyle(color: Colors.white70, fontSize: 12)),
        trailing: Text(
          status,
          style: TextStyle(
            color: status == 'OK' ? Colors.greenAccent : Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      appBar: AppBar(
        title: Text('Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: refreshDashboard,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User Info
            Card(
              color: Colors.grey[900],
              margin: EdgeInsets.all(16),
              child: ListTile(
                title: Text('Logged in as', style: TextStyle(color: Colors.white54)),
                subtitle: Text(email, style: TextStyle(color: Colors.white)),
                trailing: IconButton(
                  icon: Icon(Icons.logout, color: Colors.redAccent),
                  onPressed: logout,
                ),
              ),
            ),

            // Volcano Count
            isLoading
                ? Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  )
                : Card(
                    color: Colors.grey[850],
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.public, color: Colors.orange),
                      title: Text('Total Volcanoes', style: TextStyle(color: Colors.white)),
                      trailing: Text('$volcanoCount',
                          style: TextStyle(color: Colors.orangeAccent, fontSize: 20)),
                    ),
                  ),

            // Website Status Widgets
            statusTile('Volcano SI (Smithsonian)', siStatus, 'https://volcano.si.edu/'),
            statusTile('MAGMA Indonesia', magmaStatus, 'https://magma.esdm.go.id/'),
          ],
        ),
      ),
    );
  }
}
