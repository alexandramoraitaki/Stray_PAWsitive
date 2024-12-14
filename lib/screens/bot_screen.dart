import 'package:flutter/material.dart';
import 'user_profile_screen.dart';
import 'menu_screen.dart';

class BotScreen extends StatelessWidget {
  const BotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
                height: 60,
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

          // Εικονίδιο Προφίλ πάνω αριστερά
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
                  size: 28,
                  color: Colors.pinkAccent,
                ),
              ),
            ),
          ),

          // Περιεχόμενο
          Center(
            child: Column(
              children: [
                const SizedBox(height: 100), // Κενό από το πάνω μέρος

                // Τίτλος "Chat Bot"
                Container(
                  width: screenWidth * 0.6,
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
                    'Chat Bot',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Περιοχή συνομιλίας
                Expanded(
                  child: Container(
                    width: screenWidth * 0.9,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView(
                      children: [
                        // Εισερχόμενο μήνυμα (Bot)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/icons/bot.png',
                              height: 40,
                              width: 40,
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5EAFB),
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: const Text(
                                  'Hello! How can I assist you today?',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Εξερχόμενο μήνυμα (Χρήστης)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE4E1),
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: const Text(
                                  'Can you help me with stray animals?',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.pinkAccent,
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Περιοχή εισαγωγής κειμένου
                Container(
                  width: screenWidth * 0.9,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          // Λογική αποστολής μηνύματος
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Colors.purple,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
