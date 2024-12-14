import 'package:flutter/material.dart';
import 'user_profile_screen.dart';
import 'general_info_screen.dart';
import 'upload_pawsitive_friend_screen.dart';
import 'upload_feeding_spawt_screen.dart';
import 'about_us_screen.dart';
import 'bot_screen.dart';
import 'map_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Λίστα με τίτλους και αντίστοιχες σελίδες
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Upload a PAWsitive friend!',
        'screen': const UploadPawsitiveFriendScreen(),
      },
      {
        'title': 'Upload a Feeding sPAWt!',
        'screen': const UploadFeedingSpawtScreen(),
      },
      {
        'title': 'Search animal/food spot',
        'screen': const MapScreen(),
      },
      {
        'title': 'General info',
        'screen': const GeneralInfoScreen(),
      },
      {
        'title': 'About us',
        'screen': const AboutUsScreen(),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // Logo πάνω δεξιά
          Positioned(
            top: 20,
            right: 20,
            child: Image.asset(
              'assets/logo/logo.png',
              height: 80,
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
            left: 70, // Προσαρμόζουμε την απόσταση από την άκρη
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

          // Περιεχόμενο
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Πλαίσιο "Menu"
                Container(
                  width: screenWidth * 0.8,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                  child: const Center(
                    child: Text(
                      'Menu',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Λίστα κουμπιών
                Container(
                  width: screenWidth * 0.7, // Μειώνουμε το πλάτος του πλαισίου
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                  child: Column(
                    children: menuItems.map(
                      (item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF5EAFB),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => item['screen']),
                              );
                            },
                            child: Text(
                              item['title'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // Χάρτης (Clickable)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MapScreen()),
                    );
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/icons/map_placeholder.png',
                        height: screenHeight * 0.2,
                        width: screenWidth * 0.8,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Text(
                            'Map not available',
                            style: TextStyle(color: Colors.red),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Find nearby stray animal friends!',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
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
