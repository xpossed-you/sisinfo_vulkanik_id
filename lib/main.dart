// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'dart:async';

import 'dart:ui'; 
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'home_page.dart';
import 'dart:io';
import 'login.dart';
import 'dashboard.dart';
import 'maps.dart';


import 'database_aplikasi.dart'; // buat database

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize databaseFactory for desktop or testing environments
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final db = await initializeDatabase();

  // Check if the database is empty
  final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM volcanoes'));
  if (count == 0) {
    await populateDatabase(db);
  }

  runApp(VolcanoApp());
}

class LoginSession extends ValueNotifier<LoginSessionData> {
  LoginSession() : super(LoginSessionData());

  void login(String username) {
    value = LoginSessionData(isLoggedIn: true, username: username);
  }

  void logout() {
    value = LoginSessionData();
  }
}

class LoginSessionData {
  final bool isLoggedIn;
  final String? username;
  LoginSessionData({this.isLoggedIn = false, this.username});
}

final loginSession = LoginSession();

class VolcanoApp extends StatelessWidget {
  const VolcanoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        
        primaryColor: Color(0xFFD72638), // Lava Red
        scaffoldBackgroundColor: Color(0xFF252525), // Charcoal Black
          textTheme: TextTheme(
          bodyMedium: TextStyle(color: Color(0xFFF7F7F7)), // Smoke White
          
        ),
      ),
      home: HomePage(), // Set the new HomePage as the initial page
    );
  }
}

// ignore: use_key_in_widget_constructors
class VolcanoPage extends StatefulWidget {
  @override
  _VolcanoPageState createState() => _VolcanoPageState();
}

class _VolcanoPageState extends State<VolcanoPage> {
  bool isLoggedIn = false;
  String? loggedInUsername;

  List<dynamic> volcanoes = [];
  List<dynamic> filteredVolcanoes = [];
  TextEditingController searchController = TextEditingController();
  ScrollController scrollController = ScrollController(); // Add ScrollController
  String searchQuery = "";
  bool showingFavorites = false; // Tracks whether favorites are being displayed

  void onLoginSuccess(String username) {
    setState(() {
      isLoggedIn = true;
      loggedInUsername = username;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchVolcanoes();
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text.toLowerCase();
        filteredVolcanoes = volcanoes.where((volcano) {
          final name = (volcano['nama_vulkan'] ?? '').toLowerCase();
          return name.contains(searchQuery);
        }).toList();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }

  Future<void> fetchVolcanoes() async {
    try {
      final db = await initializeDatabase();
      final data = await fetchVolcanoesFromDatabase(db);

      setState(() {
        volcanoes = data;
        filteredVolcanoes = data; // Initialize filtered list
      });
    } catch (e) {
      throw Exception('Failed to load volcano data');
    }
  }

  void showVolcanoDetails(BuildContext context, dynamic volcano) async {
    final db = await initializeDatabase();
    final isFavorite = volcano['favorite'] == 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: AlertDialog(
            backgroundColor: Color.fromARGB(159, 168, 168, 168),
            title: Text(
              "Mount ${volcano['nama_vulkan'] ?? 'Tidak Diketahui'}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF252525),
              ),
              textAlign: TextAlign.center,
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "Country: ${volcano['negara'] ?? 'Tidak Diketahui'}\nVolcano Number: ${volcano['nmr_vulkan']}",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),

                  // Responsive card layout using Wrap
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      infoCard(
                        children: [
                          textRow("Volcanic Region", volcano['wilayah_vulkanis']),
                          textRow("Landform", volcano['lahan_vulkanis']),
                          textRow("Last Known Eruption", volcano['erupsi_terakhir']),
                          textRow(
                            "Volcano Type",
                            (volcano['tipe_vulkan'] != null)
                                ? (json.decode(volcano['tipe_vulkan']) as List<dynamic>).join(', ')
                                : 'Tidak Diketahui',
                          ),
                        ],
                      ),
                      infoCard(
                        children: [
                          textRow(
                            "Population (100km)",
                            (volcano['populasi'] != null)
                                ? (json.decode(volcano['populasi'])['Within 100 km'] ?? 'Tidak Diketahui')
                                : 'Tidak Diketahui',
                          ),
                          textRow(
                            "Tectonic Settings",
                            (volcano['pengaturan_tektonik'] != null)
                                ? (json.decode(volcano['pengaturan_tektonik']) as List<dynamic>).join(', ')
                                : 'Tidak Diketahui',
                          ),
                        ],
                      ),
                      infoCard(
                        children: [
                          textRow("Latitudes", volcano['kordinat_lat']),
                          textRow("Longitude", volcano['kordinat_long']),
                          textRow("Rock Type", volcano['tipe_batu']),
                          textRow("Elevation", "${volcano['elevasi']}"),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Image + Summary Responsive Layout
                  if (volcano['image_src'] != null)
                    screenWidth < 600
                        ? Column(
                            children: [
                              Image.network(
                                volcano['image_src'],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 200,
                              ),
                              SizedBox(height: 10),
                              Text(
                                volcano['ringkas'] ?? 'Tidak Diketahui',
                                style: TextStyle(fontSize: 16, color: Color(0xFF252525)),
                                textAlign: TextAlign.justify,
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Flexible(
                                flex: 1,
                                child: Image.network(
                                  volcano['image_src'],
                                  fit: BoxFit.cover,
                                  height: 200,
                                ),
                              ),
                              SizedBox(width: 10),
                              Flexible(
                                flex: 2,
                                child: Text(
                                  volcano['ringkas'] ?? 'Tidak Diketahui',
                                  style: TextStyle(fontSize: 16, color: Color(0xFF252525)),
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                            ],
                          ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Close", style: TextStyle(color: Color(0xFFD72638))),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (isFavorite) {
                    await removeFromFavorites(volcano['nmr_vulkan']);
                  } else {
                    await addToFavorites(volcano['nmr_vulkan']);
                  }
                  Navigator.pop(context); // Close the dialog
                  if (!showingFavorites) {
                    setState(() {
                      fetchVolcanoes(); // Refresh the list only if not showing favorites
                    });
                  }
                },
                child: Text(isFavorite ? "Remove from Favorites" : "Add to Favorites"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> addToFavorites(String volcanoNumber) async {
    final db = await initializeDatabase();
    await db.update(
      'volcanoes',
      {'favorite': 1}, // Set favorite to true
      where: 'nmr_vulkan = ?',
      whereArgs: [volcanoNumber],
    );
  }

  Future<void> removeFromFavorites(String volcanoNumber) async {
    final db = await initializeDatabase();
    await db.update(
      'volcanoes',
      {'favorite': 0}, // Set favorite to false
      where: 'nmr_vulkan = ?',
      whereArgs: [volcanoNumber],
    );

    // Refresh the favorites list if showingFavorites is true
    if (showingFavorites) {
      final favorites = await fetchFavoriteVolcanoes(db);
      setState(() {
        filteredVolcanoes = favorites;
        volcanoes = favorites;
      });
    }
  }

  Widget infoCard({required List<Widget> children}) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Color.fromARGB(57, 255, 255, 255),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black, blurRadius: 4)],
      ),
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget textRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        "$label: ${value ?? 'Tidak Diketahui'}",
        style: TextStyle(fontSize: 14, color: Color.fromARGB(255, 255, 255, 255)), // Charcoal Black
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFD72638), // Lava Red
        title: Text("Volcanoes in Indonesia"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.map),
            tooltip: "Show Map",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapsPage()),
              );
            },
          ),

          IconButton(
            icon: Icon(showingFavorites ? Icons.list : Icons.favorite), // Toggle icon
            tooltip: showingFavorites ? "Show All Volcanoes" : "Show Favorites",
            onPressed: () async {
              final db = await initializeDatabase();
              if (showingFavorites) {
                final data = await fetchVolcanoesFromDatabase(db);
                setState(() {
                  volcanoes = data;
                  filteredVolcanoes = data;
                  showingFavorites = false;
                });
              } else {
                final favorites = await fetchFavoriteVolcanoes(db);
                setState(() {
                  volcanoes = favorites;
                  filteredVolcanoes = favorites;
                  showingFavorites = true;
                });
              }
            },
          ),

          ValueListenableBuilder<LoginSessionData>(
            valueListenable: loginSession,
            builder: (context, session, _) {
              return IconButton(
                icon: Icon(session.isLoggedIn ? Icons.person : Icons.login),
                tooltip: session.isLoggedIn ? "User" : "Login",
                onPressed: () async {
                  if (!session.isLoggedIn) {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  } else {
                    Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardPage(username: session.username ?? ''),
            ),
                    );
                  }
                },
              );
            },
          ),
          
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total Volcanoes: ${volcanoes.length}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Smoke White
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: TextStyle(
                color: Color.fromARGB(255, 252, 252, 252)
              ), // Charcoal Black
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search volcanoes...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredVolcanoes.isEmpty
                ? Center(
                    child: Text(
                      "No results found",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  )
                : Scrollbar(
                    controller: scrollController, // Link ScrollController
                    thumbVisibility: true,
                    thickness: 8.0,
                    radius: Radius.circular(8.0),
                    child: ListView.builder(
                      controller: scrollController, // Assign ScrollController
                      padding: const EdgeInsets.all(16.0),
                      itemCount: filteredVolcanoes.length,
                      itemBuilder: (context, index) {
                        final volcano = filteredVolcanoes[index];
                        return Card(
                          color: Color(0xFFA8A8A8), // Ash Gray
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  volcano['nama_vulkan'] ?? 'Tidak Diketahui',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF252525), // Charcoal Black
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Last Activity: ${volcano['erupsi_terakhir'] ?? 'Tidak Diketahui'}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF6B4226), // Earthy Brown
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Elevation: ${volcano['elevasi'] ?? 'Tidak Diketahui'}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF6B4226), // Earthy Brown
                                  ),
                                ),
                                SizedBox(height: 10),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFFF5700), // Magma Orange
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () =>
                                      showVolcanoDetails(context, volcano),
                                  child: Text("More Info"),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}