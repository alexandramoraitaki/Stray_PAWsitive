import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Βεβαιώσου ότι έχεις αυτό το import

import 'menu_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String username = '...';
  String firstName = '...';
  String lastName = '...';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Διαβάζουμε τον τρέχοντα χρήστη από τα SharedPreferences και στη συνέχεια από το Firestore
  Future<void> _loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? currentUsername = prefs.getString('current_user');

      if (currentUsername == null) {
        // Αν δεν υπάρχει αποθηκευμένο username, εμφανίζουμε μήνυμα σφάλματος
        setState(() {
          username = 'Not logged in';
          firstName = 'N/A';
          lastName = 'N/A';
        });
        return;
      }

      // Αναζήτηση του χρήστη στο Firestore με βάση το username
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: currentUsername)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        setState(() {
          username = data['username'] ?? 'N/A';
          firstName = data['firstName'] ?? 'N/A';
          lastName = data['lastName'] ?? 'N/A';
        });
      } else {
        // Αν δεν βρεθεί χρήστης με αυτό το username
        setState(() {
          username = 'Not found';
          firstName = 'N/A';
          lastName = 'N/A';
        });
      }
    } catch (e) {
      // Σε περίπτωση σφάλματος
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading user data: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Για να αποφύγουμε overflow σε μικρότερες οθόνες, χρησιμοποιούμε SingleChildScrollView
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // Logo πάνω δεξιά
          Positioned(
            top: 20,
            right: 20, // Χρησιμοποίησε right αντί για left για καλύτερη ευθυγράμμιση
            child: GestureDetector(
              onTap: () {
                // Παράδειγμα: Επιστροφή ή μεταφορά στο MenuScreen
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

          // Εικονίδιο bot κάτω δεξιά (π.χ. chatbot)
          Positioned(
            bottom: 20,
            right: 20,
            child: Image.asset(
              'assets/icons/bot.png',
              height: 60,
            ),
          ),

          // Κύριο περιεχόμενο με scroll για μικρότερες οθόνες
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 150), // Περισσότερος χώρος πάνω

                // Τίτλος "User Profile"
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                      'User Profile',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Πλαίσιο με πληροφορίες χρήστη
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildInfoRow('First Name', firstName),
                        const Divider(color: Colors.grey),
                        _buildInfoRow('Last Name', lastName),
                        const Divider(color: Colors.grey),
                        _buildInfoRow('Username', username),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 50),

                // Πλαίσιο με Accomplishments
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: const EdgeInsets.all(12.0),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Accomplishments',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Εικόνες επιτευγμάτων σε μία σειρά
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (var achievement in [
                            'assets/icons/achievement1.png',
                            'assets/icons/achievement2.png',
                            'assets/icons/achievement3.png',
                            'assets/icons/achievement4.png',
                            'assets/icons/achievement5.png',
                          ])
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(color: Colors.pinkAccent, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  achievement,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Βοηθητική συνάρτηση για εμφάνιση πεδίων
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.pinkAccent,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
