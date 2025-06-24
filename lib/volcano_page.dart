import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class VolcanoPage extends StatefulWidget {
  const VolcanoPage({Key? key}) : super(key: key);

  @override
  State<VolcanoPage> createState() => _VolcanoPageState();
}

class _VolcanoPageState extends State<VolcanoPage> {
  List<dynamic> volcanoes = [];
  List<dynamic> filteredVolcanoes = [];
  final TextEditingController searchController = TextEditingController();
  bool showingFavorites = false;
  Set<String> favoriteVolcanoes = {};

  @override
  void initState() {
    super.initState();
    fetchVolcanoData();
  }

  Future<void> fetchVolcanoData() async {
    const url = 'https://xpossed-you.github.io/hasil_webscrap/volcano_data.json';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          volcanoes = data;
          filteredVolcanoes = data;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print("Error fetching volcano data: $e");
    }
  }

  void searchVolcano(String query) {
    setState(() {
      filteredVolcanoes = volcanoes.where((v) {
        final name = v['nama_vulkan']?.toLowerCase() ?? '';
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }

  void toggleFavorite(String id) {
    setState(() {
      if (favoriteVolcanoes.contains(id)) {
        favoriteVolcanoes.remove(id);
      } else {
        favoriteVolcanoes.add(id);
      }
    });
  }

  void showFavorites() {
    setState(() {
      showingFavorites = true;
      filteredVolcanoes = volcanoes.where((v) => favoriteVolcanoes.contains(v['nmr_vulkan'])).toList();
    });
  }

  void showAllVolcanoes() {
    setState(() {
      showingFavorites = false;
      filteredVolcanoes = volcanoes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: Color(0xFFD72638),
        centerTitle: true,
        title: Text('Volcano Explorer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: searchVolcano,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search volcano...',
                hintStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[850],
                prefixIcon: Icon(Icons.search, color: Colors.white),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: showAllVolcanoes,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF5700),
                      foregroundColor: Colors.white,
                    ),
                    child: Text("All Volcanoes"),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: showFavorites,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF8C00),
                      foregroundColor: Colors.white,
                    ),
                    child: Text("Favorites"),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredVolcanoes.length,
                itemBuilder: (context, index) {
                  final volcano = filteredVolcanoes[index];
                  final isFavorite = favoriteVolcanoes.contains(volcano['nmr_vulkan']);
                  return Card(
                    color: Colors.grey[900],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          volcano['image_src'] ?? '',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, color: Colors.white54),
                        ),
                      ),
                      title: Text(
                        volcano['nama_vulkan'] ?? 'Unknown',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Elevation: ${volcano['elevasi'] ?? '-'}", style: TextStyle(color: Colors.white70)),
                          Text("Last Eruption: ${volcano['erupsi_terakhir'] ?? '-'}", style: TextStyle(color: Colors.white70)),
                          Text("Summary: ${volcano['ringkas']?.toString().substring(0, 80)}...", style: TextStyle(color: Colors.white54)),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.white),
                        onPressed: () => toggleFavorite(volcano['nmr_vulkan']),
                      ),
                      onTap: () {
                        // Optional: add detailed page navigation
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
