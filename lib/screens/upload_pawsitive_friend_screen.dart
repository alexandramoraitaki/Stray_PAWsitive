import 'package:flutter/material.dart';
import 'menu_screen.dart';
import 'user_profile_screen.dart';
import 'bot_screen.dart';

class UploadPawsitiveFriendScreen extends StatelessWidget {
  const UploadPawsitiveFriendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
          SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Τίτλος "Registration"
                  Container(
                    width: screenWidth * 0.6,
                    padding: const EdgeInsets.symmetric(vertical: 10),
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
                        'Registration',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Εικόνα
                  Container(
                    width: screenWidth * 0.8,
                    height: 150,
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
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.image,
                            size: 50, color: Colors.grey),
                        onPressed: () {
                          // Λογική για την προσθήκη εικόνας
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Πεδίο "Location"
                  _buildProfileField('Location:'),
                  const SizedBox(height: 20),

                  // Πεδίο "Date"
                  _buildProfileField('Date:'),
                  const SizedBox(height: 20),

                  // Επιλογές για "DOG" και "CAT"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildOptionButton('DOG'),
                      _buildOptionButton('CAT'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Επιλογές για "MALE" και "FEMALE"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildOptionButton('MALE'),
                      _buildOptionButton('FEMALE'),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Επιλογές για "SMALL", "MEDIUM", "LARGE"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildOptionButton('SMALL'),
                      _buildOptionButton('MEDIUM'),
                      _buildOptionButton('LARGE'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Επιλογές για "FRIENDLY" και "NOT FRIENDLY"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildOptionButton('FRIENDLY'),
                      _buildOptionButton('NOT FRIENDLY'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Πεδίο "Description"
                  Container(
                    width: screenWidth * 0.8,
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
                    child: const TextField(
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Description',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
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

  // Μέθοδος για πεδίο Location, Date
  Widget _buildProfileField(String label) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EAFB),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.purple,
        ),
      ),
    );
  }

  // Μέθοδος για τα κουμπιά επιλογών (DOG, CAT, MALE, FEMALE κ.λπ.)
  Widget _buildOptionButton(String label) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF5EAFB),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      onPressed: () {
        // Λογική επιλογής
      },
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.purple,
        ),
      ),
    );
  }
}
