import 'package:flutter/material.dart';
import 'menu_screen.dart';
import 'user_profile_screen.dart';
import 'bot_screen.dart';

class GeneralInfoScreen extends StatelessWidget {
  const GeneralInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Φόντο
      body: Stack(
        children: [
          // Logo πάνω δεξιά
          Positioned(
            top: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MenuScreen()),
                );
              },
              child: Image.asset(
                'assets/logo/logo.png',
                height: 80,
              ),
            ),
          ),

          // Πίσω βέλος πάνω αριστερά
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.pinkAccent),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          // Εικονίδιο Προφίλ πάνω αριστερά (χωρίς να πέφτει πάνω στο πίσω βελάκι)
          Positioned(
            top: 20,
            left: 70,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserProfileScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.pinkAccent, width: 2),
                ),
                child: const Icon(
                  Icons.person,
                  size: 36,
                  color: Colors.pinkAccent,
                ),
              ),
            ),
          ),

          // Κύριο περιεχόμενο
          Center(
            child: Column(
              children: [
                const SizedBox(height: 120), // Κενό από το πάνω μέρος

                // Τίτλος "General Info"
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE4E1),
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'General Info',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Κουμπί "DOG"
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFE4E1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  onPressed: () {
                    debugPrint('DOG pressed');
                  },
                  child: const Text(
                    'DOG',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Γκρι πλαίσιο "DOG Info"
                Container(
                  width: screenWidth * 0.9,
                  height: 120, // Ύψος του πλαισίου
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Κουμπί "CAT"
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFE4E1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  onPressed: () {
                    debugPrint('CAT pressed');
                  },
                  child: const Text(
                    'CAT',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Γκρι πλαίσιο "CAT Info"
                Container(
                  width: screenWidth * 0.9,
                  height: 120, // Ύψος του πλαισίου
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Dog Bot κάτω δεξιά
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BotScreen()),
                );
              },
              child: Image.asset(
                'assets/icons/bot.png',
                height: 60,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
