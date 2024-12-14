   import 'package:flutter/material.dart';
   import 'screens/login_screen.dart'; // Κάνουμε import την οθόνη

   void main() {
     runApp(const MyApp());
   }

   class MyApp extends StatelessWidget {
     const MyApp({super.key});

     @override
     Widget build(BuildContext context) {
       return MaterialApp(
         debugShowCheckedModeBanner: false, // Αφαιρεί την ένδειξη Debug
         title: 'Stray PAWsitive',
         theme: ThemeData(
           primarySwatch: Colors.pink, // Θέμα της εφαρμογής
         ),
         home: const LoginScreen(), // Αρχική οθόνη
       );
     }
   }
