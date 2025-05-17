import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Database> initializeDatabase() async { //buat database
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'vulkanesia.db');

  return openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async { //buat tabel volcano
      await db.execute('''
        CREATE TABLE volcanoes (
          id INTEGER PRIMARY KEY,
          nmr_vulkan TEXT,
          nama_vulkan TEXT,
          negara TEXT,
          wilayah_vulkanis TEXT,
          lahan_vulkanis TEXT,
          erupsi_terakhir TEXT,
          tipe_vulkan TEXT,
          populasi TEXT,
          pengaturan_tektonik TEXT,
          kordinat_lat TEXT,
          kordinat_long TEXT,
          tipe_batu TEXT,
          elevasi INTEGER,
          image_src TEXT,
          ringkas TEXT,
          favorite INTEGER DEFAULT 0
        )
      ''');

      // Buat tabel pengguna
      await db.execute('''
      CREATE TABLE IF NOT EXISTS pengguna (
        id_pengguna INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT,
        password TEXT,
        email TEXT,
        tgl_lahir TEXT
      )
    ''');
    },
  );
}

Future<void> populateDatabase(Database db) async { //ambil data dari webscrap terus simpan ke database
  final response = await http.get(Uri.parse('https://xpossed-you.github.io/hasil_webscrap/volcano_data.json'));
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);

    for (var volcano in data) {
      await db.insert(
        'volcanoes',
        {
          'nmr_vulkan': volcano['nmr_vulkan'],
          'nama_vulkan': volcano['nama_vulkan'],
          'negara': volcano['negara'],
          'wilayah_vulkanis': volcano['wilayah_vulkanis'],
          'lahan_vulkanis': volcano['lahan_vulkanis'],
          'erupsi_terakhir': volcano['erupsi_terakhir'],
          'tipe_vulkan': json.encode(volcano['tipe_vulkan']),
          'populasi': json.encode(volcano['populasi']),
          'pengaturan_tektonik': json.encode(volcano['pengaturan_tektonik']),
          'kordinat_lat': volcano['kordinat_lat'],
          'kordinat_long': volcano['kordinat_long'],
          'tipe_batu': volcano['tipe_batu'],
          'elevasi': volcano['elevasi'],
          'image_src': volcano['image_src'],
          'ringkas': volcano['ringkas'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  } else {
    throw Exception('Failed to load volcano data');
  }
}

Future<List<Map<String, dynamic>>> fetchVolcanoesFromDatabase(Database db) async { //ambil data volcano dari database
  return await db.query('volcanoes');
}

Future<List<Map<String, dynamic>>> fetchFavoriteVolcanoes(Database db) async { //ambil data volcano di database yang field 'favorite' itu 1
  return await db.query(
    'volcanoes',
    where: 'favorite = ?',
    whereArgs: [1],
  );
}


Future<void> addToFavorites(Database db, String volcanoNumber) async { //tambah volcano ke favorit
  await db.update(
    'volcanoes',
    {'favorite': 1}, // Set favorite to true
    where: 'nmr_vulkan = ?',
    whereArgs: [volcanoNumber],
  );
}

Future<void> removeFromFavorites(Database db, String volcanoNumber) async { //hapus volcano dari favorit
  await db.update(
    'volcanoes',
    {'favorite': 0}, // Set favorite to false
    where: 'nmr_vulkan = ?',
    whereArgs: [volcanoNumber],
  ); 
}

Future<void> addUser(Database db, String name, String password, String email, String birthDate) async { //buat daftar akun
  await db.insert(
    'pengguna',
    {
      'nama': name,
      'password': password,
      'email': email,
      'tgl_lahir': birthDate,
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<Map<String, dynamic>?> checkUser(Database db, String email, String password) async { //cek form buat login
  final List<Map<String, dynamic>> result = await db.query(
    'pengguna',
    where: 'email = ? AND password = ?',
    whereArgs: [email, password],
  );
  if (result.isNotEmpty) {
    return result.first;
    
  }
  return null;
}

Future<Map<String, dynamic>?> getUserByUsername(Database db, String username) async { //ambil username dari database
  final result = await db.query(
    'pengguna',
    where: 'nama = ?',
    whereArgs: [username],
  );
  if (result.isNotEmpty) {
    return result.first;
  }
  return null;
}