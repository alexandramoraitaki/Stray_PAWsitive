import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Πρόσθεσε αυτό το import
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'signup_screen.dart';
import 'menu_screen.dart';
import 'user_profile_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool showPassword = false;

  // Μέθοδος για hashing password με SHA-256
  String hashPassword(String password) {
    final bytes = utf8.encode(password); // Μετατροπή password σε bytes
    final digest = sha256.convert(bytes); // Δημιουργία hash με SHA-256
    return digest.toString(); // Επιστροφή του hash ως string
  }

  Future<void> _login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    // 1. Έλεγχος αν είναι κενά
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both username and password.'),
        ),
      );
      return;
    }

    try {
      // 2. Αναζήτηση χρήστη με το συγκεκριμένο username
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Δεν βρέθηκε τέτοιος χρήστης
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
        return;
      }

      // 3. Παίρνουμε το πρώτο έγγραφο
      final userDoc = querySnapshot.docs.first;
      final userData = userDoc.data();
      final storedHashedPassword = userData['password'] ?? '';

      final hashedInputPassword = hashPassword(password);

      // 4. Έλεγχος password
      if (hashedInputPassword == storedHashedPassword) {
        // Επιτυχής σύνδεση
        // Αποθήκευση του username στα SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_user', username);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MenuScreen(),
          ),
        );
      } else {
        // Λάθος password
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wrong password')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),

                // Logo
                Image.asset(
                  'assets/logo/logo.png',
                  height: 100,
                ),
                const SizedBox(height: 40),

                // Τίτλος "Login"
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent,
                  ),
                ),
                const SizedBox(height: 16),

                // Username TextField
                TextField(
                  controller: usernameController,
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

                // Password TextField with Show/Hide
                TextField(
                  controller: passwordController,
                  obscureText: !showPassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Colors.purple),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: Icon(
                        showPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          showPassword = !showPassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // GO Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  onPressed: _login,
                  child: const Text(
                    'GO',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),

                // Sign Up Button
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 16, color: Colors.pinkAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
