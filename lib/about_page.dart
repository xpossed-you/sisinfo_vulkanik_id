import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFD72638), // Lava Red
        title: Text("About"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/logo.jpg'), // Replace with your logo path
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 10), // Add spacing between the logo and the text
                  Text(
                    "made by tfk_061",
                    textAlign: TextAlign.center,

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'GTProelium',
                      letterSpacing: 2.0,
                      
                      color: Color.fromARGB(255, 255, 255, 255), // Charcoal Black
                      shadows: [
                        Shadow(
                          color: Color.fromARGB(255, 92, 92, 92),
                          blurRadius: 5,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Text(
              "VulcaNesia",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 145, 71), // Charcoal Black
              ),
            ),
            SizedBox(height: 10),
            Text(
              "VulcaNesia ini dibuat untuk memenuhi tugas Pemrograman Multi-platform. Tujuan aplikasi ini adalah untuk memberikan informasi tentang gunung berapi di Indonesia.",
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 255, 145, 71), // Earthy Brown
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Features:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF252525), // Charcoal Black
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(
                "FAQ",
                style: TextStyle(
                fontSize: 32,
                color: Color.fromARGB(255, 185, 113, 66), // Charcoal Black
                ),
              ),
              SizedBox(height: 10),
              Text(
                "1. Kenapa aplikasi nya bahasa inggris?",
                style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 185, 113, 66), // Charcoal Black
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Karna data yang diambil bukan dari API, tapi data JSON hasil webscraping volcano.si.edu yang berbahasa inggris.",
                style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 255, 157, 92), // Charcoal Black
                ),
              ),

              SizedBox(height: 10),
              Text(
                "2. Kenapa mau buat sistem informasi gunung berapi?",
                style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 185, 113, 66), // Charcoal Black
                ),
              ),
              SizedBox(height: 10),
              Text(
                "karna ya... krg tw jga sih",
                style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 255, 157, 92), // Charcoal Black
                ),
              ),

              SizedBox(height: 10),
              Text(
                "2. Kenapa update pake sqlite?",
                style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 185, 113, 66), // Charcoal Black
                ),
              ),
              SizedBox(height: 10),
              Text(
                "karna disuruh",
                style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 255, 157, 92), // Charcoal Black
                ),
              ),

              ],
            ),


          ],
        ),
      ),
    );
  }
}