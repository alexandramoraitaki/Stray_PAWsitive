import 'package:flutter/material.dart';

void main() {
  runApp(const StrayPawsitiveApp());
}

class StrayPawsitiveApp extends StatelessWidget {
  const StrayPawsitiveApp({super.key}); // Χρήση του super.key

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stray PAWsitive',
      theme: ThemeData(
        primarySwatch: Colors.pink, // Χρώμα θέματος
      ),
      home: const LoginScreen(), // Ρυθμίζουμε την αρχική οθόνη
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key}); // Χρήση του super.key

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Χρώμα φόντου
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Λογότυπο
            Image.asset(
              'assets/logo.logo.png', // Βάλε το λογότυπο εδώ
              height: 100,
            ),
            const SizedBox(height: 32),

            // Username TextField
            TextField(
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: const TextStyle(color: Colors.purple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Password TextField
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(color: Colors.purple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // GO Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent, // Σωστό όνομα παραμέτρου
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              onPressed: () {
                // Εδώ θα βάλουμε λειτουργικότητα για Login
                debugPrint('Login Pressed');
              },
              child: const Text(
                'GO',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),

            // Sign Up Button
            TextButton(
              onPressed: () {
                // Εδώ θα βάλουμε πλοήγηση προς τη Sign Up οθόνη
                debugPrint('Sign Up Pressed');
              },
              child: const Text(
                'Sign Up',
                style: TextStyle(fontSize: 16, color: Colors.pinkAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
