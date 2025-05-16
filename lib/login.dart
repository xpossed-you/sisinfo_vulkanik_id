import 'package:flutter/material.dart';
import 'main.dart'; // Import the main file if needed
import 'database_aplikasi.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFD72638), // Lava Red
        title: Text("Login Page"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                image: DecorationImage(
                  image: AssetImage('assets/logo_aplikasi.png'), // Replace with your logo path
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
              children: [

                //email
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                  icon: Icon(Icons.person, color: Colors.grey),
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.grey),
                  hintText: 'Enter your email',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(color: Color(0xFFD72638)),
                  ),
                  ),
                  style: TextStyle(color: Color.fromARGB(255, 212, 212, 212)),
                ),

                SizedBox(height: 20),
                
                //password
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                  icon: Icon(Icons.lock, color: Colors.grey),
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.grey),
                  hintText: 'Enter your password',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(color: Color(0xFFD72638)),
                  ),
                  ),
                  style: TextStyle(color: Color.fromARGB(255, 212, 212, 212)),
                ),

                SizedBox(height: 20),

                ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF5700), // Magma Orange
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {

                final db = await initializeDatabase();
                
                String email = emailController.text;
                String password = passwordController.text;
                // checkUser dari database_aplikasi.dart
                final user = await checkUser(db, email, password);
                
                if (user != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Login successful!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  loginSession.login(user['nama']);
                  Navigator.pop(context, user['nama']);
                  
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Login failed! Invalid email or password.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                
              },
              child: Text("Login"),
            ),


              ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}