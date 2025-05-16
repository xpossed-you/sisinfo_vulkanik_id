
import 'main.dart';
import 'package:flutter/material.dart';

class MapsPage extends StatelessWidget {
  const MapsPage({Key? key}) : super(key: key);

  void _navigateToVolcanoApp(BuildContext context) {
    Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VolcanoPage()),
                );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maps'),
        actions: [
          IconButton(
            icon: const Icon(Icons.local_fire_department),
            tooltip: 'Go to VolcanoApp',
            onPressed: () => _navigateToVolcanoApp(context),
          ),
        ],
      ),
      body: Container(),
      );
    }
}