import 'package:flutter/material.dart';
import 'map_screen.dart';
import 'user_profile_screen.dart';
import 'bot_screen.dart';
import 'menu_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PawsitiveFriendProfileScreen extends StatefulWidget {
  final String documentId;
  const PawsitiveFriendProfileScreen({super.key, required this.documentId});

  @override
  State<PawsitiveFriendProfileScreen> createState() => _PawsitiveFriendProfileScreenState();
}

class _PawsitiveFriendProfileScreenState extends State<PawsitiveFriendProfileScreen> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final documentId = widget.documentId;

    return Scaffold (
      backgroundColor: const Color(0xFFF5F5F5),
      body: FutureBuilder<DocumentSnapshot>(
        // 1. Φέρνουμε τα δεδομένα από τη συλλογή 'pawsitive_friends'
        future: FirebaseFirestore.instance
            .collection('pawsitive_friends')
            .doc(documentId)
            .get(),
        builder: (context, snapshot) {
          // 2. Έλεγχος κατάστασης
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Pawsitive Friend not found"));
          }

          // 3. Παίρνουμε τα δεδομένα ως Map
          final data = snapshot.data!.data() as Map<String, dynamic>;

          // 4. Εξαγωγή πεδίων από το data
          final imageUrl = data['image_url'];       // Θα έχει το downloadURL
          final location = data['location'];
          final date = data['date'];
          final animal = data['animal'];
          final gender = data['gender'];
          final size = data['size'];
          final friendliness = data['friendliness'];
          final description = data['description'];
          
      
      
          return Stack(
              children: [
                // 1. Βάλε το SingleChildScrollView πρώτο, ώστε να είναι "κάτω"
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Τίτλος "Pawsitive Friend Profile"
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
                              'Pawsitive Friend Profile',
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
                        if (imageUrl != null && imageUrl != '')
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
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.error, color: Colors.red);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Πεδίο "Location"
                        _buildProfileField('Location: $location'),

                        const SizedBox(height: 20),

                        // Πεδίο "Date"
                        _buildProfileField('Date: $date'),
                        const SizedBox(height: 20),

                        _buildProfileField('Description: $description'), 
                         const SizedBox(height: 20),



                        // Επιλογές (DOG, MALE, SMALL, NOT FRIENDLY)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                           _buildOptionButton(animal ?? ''),
                          _buildOptionButton(gender ?? ''),
                          _buildOptionButton(size ?? ''),
                          _buildOptionButton(friendliness ?? ''),

                          ],
                        ),
                        const SizedBox(height: 20),

                        // Περιοχή σχολίων με δυνατότητα swipe up
                        GestureDetector(
                          onVerticalDragUpdate: (details) {
                            if (details.delta.dy < 0) {
                              // Swipe up
                              setState(() {
                                isExpanded = true;
                              });
                            } else if (details.delta.dy > 0) {
                              // Swipe down
                              setState(() {
                                isExpanded = false;
                              });
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: screenWidth * 0.9,
                            height: isExpanded ? screenHeight * 0.4 : 100,
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
                              maxLines: null,
                              expands: true,
                              decoration: InputDecoration(
                                hintText: 'Comments',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                  // 2. Τοποθέτησε τα Positioned widgets "πάνω" από το περιεχόμενο
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
                  Positioned(
                    top: 20,
                    left: 20,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.pinkAccent),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const MapScreen()),
                        );
                      },
                    ),
                  ),
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
          );
        },
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

  // Μέθοδος για τα κουμπιά επιλογών
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
