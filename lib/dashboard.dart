import 'package:flutter/material.dart';
import 'main.dart'; 
import 'database_aplikasi.dart';
import 'maps.dart';
import 'home_page.dart';

class DashboardPage extends StatelessWidget {
  final String username;
  const DashboardPage({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Color(0xFFD72638),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              loginSession.logout();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFD72638),
              ),
              child: Text(
                'Hello, $username!',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.public),
              title: Text('Volcanoes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VolcanoPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text('Maps'),
              onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => MapsPage()),
              );
              },
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Profile'),
              onTap: () async {
                final db = await initializeDatabase();
                final user = await getUserByUsername(db, username);

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('User Profile'),
                    content: user == null
                        ? Text('User not found.')
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Username: ${user['nama']}', style: TextStyle(color: Colors.black)),
                              Text('Email: ${user['email']}', style: TextStyle(color: Colors.black)),
                              Text('ID Pengguna: ${user['id_pengguna']}', style: TextStyle(color: Colors.black)),
                              Text('Tanggal Lahir: ${user['tgl_lahir']}', style: TextStyle(color: Colors.black)),
                              Text('Password: ${'*' * user['password'].length}', style: TextStyle(color: Colors.black)),
                            ],
                          ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
      body: Center(
        child: Text('Welcome, $username!', style: TextStyle(fontSize: 24),
        ),

      ),
    );
  }
}