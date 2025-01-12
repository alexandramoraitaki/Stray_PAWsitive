import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'menu_screen.dart';
import 'user_profile_screen.dart';
import 'bot_screen.dart';

class FeedingSpawtProfileScreen extends StatelessWidget {
  final String documentId; // Το ID του εγγράφου στη Firestore

  const FeedingSpawtProfileScreen({Key? key, required this.documentId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // Για να μην εξαφανίζεται το TextField όταν ανοίγει το πληκτρολόγιο
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF5F5F5),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('feeding_spawts')
            .doc(documentId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Feeding spot not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final imageUrl = data['image_url'] as String?;
          final location = data['location'] as String?;
          final description = data['description'] as String?;
          final date = data['date'] as String?;

          return Stack(
            children: [
              /// Χρησιμοποιούμε Column → Expanded για το κύριο περιεχόμενο
              /// ώστε, όταν ανοίγει το πληκτρολόγιο, να γίνεται σωστό scrolling.
              Column(
                children: [
                  // Θα κάνουμε το περιεχόμενο scrollable με Expanded + SingleChildScrollView
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 80.0),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Τίτλος
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
                                  'Feeding sPAWt',
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
                            if (imageUrl != null)
                              Container(
                                width: screenWidth * 0.8,
                                height: 200,
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
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.error,
                                        color: Colors.red,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),

                            // Location
                            if (location != null)
                              _buildProfileField('Location: $location'),
                            const SizedBox(height: 20),

                            // Ημερομηνία
                            if (date != null)
                              _buildProfileField(
                                  'Date: ${date.substring(0, 10)}'),
                            const SizedBox(height: 30),

                            // Περιγραφή
                            if (description != null)
                              _buildProfileField('Description: $description'),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
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

              // Logo πάνω δεξιά
              Positioned(
                top: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MenuScreen()),
                    );
                  },
                  child: Image.asset(
                    'assets/logo/logo.png',
                    height: 60,
                  ),
                ),
              ),

              // Βελάκι πίσω πάνω αριστερά
              Positioned(
                top: 20,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.pinkAccent),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MenuScreen()),
                      (route) =>
                          false, // Αφαιρεί όλες τις προηγούμενες οθόνες από τη στοίβα
                    );
                  },
                ),
              ),

              // Bot κάτω δεξιά
              Positioned(
                bottom: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BotScreen()),
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
}
