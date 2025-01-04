import 'package:flutter/material.dart';
import 'menu_screen.dart';
import 'user_profile_screen.dart';
import 'bot_screen.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

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
            left: 270,
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
                  color: Colors.white,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Τίτλος
                Container(
                  width: screenWidth * 0.7,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE4E1),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: const Center(
                    child: Text(
                      'About Us',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Πλαίσιο πληροφοριών
                Container(
                  width: screenWidth * 0.8,
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
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Text(
                        '''Καλώς ήρθες στη Stray PAWsitive! 🐾

Είμαστε μια ομάδα φοιτητών με μεγάλη αγάπη για τα ζώα και ένα κοινό όραμα: να δημιουργήσουμε έναν κόσμο όπου κάθε αδέσποτο ζώο θα έχει τη φροντίδα και την αγάπη που του αξίζει! 
Η ιδέα για την εφαρμογή μας γεννήθηκε από τη βαθιά επιθυμία μας να κάνουμε για αυτά κάτι ουσιαστικό. Βλέποντάς τα να περιπλανιούνται στους δρόμους, αναζητώντας φαγητό, ζεστασιά και λίγη στοργή, νιώσαμε ότι δεν μπορούσαμε να μείνουμε απλοί παρατηρητές. Γνωρίζαμε ότι δεν μπορούσαμε να τα βοηθήσουμε όλα, αλλά είχαμε τη δύναμη να ξεκινήσουμε μια αλλαγή!
Έτσι, δημιουργήσαμε τη Stray PAWsitive: μια εφαρμογή που ενώνει την κοινότητα των φιλόζωων για έναν κοινό σκοπό – να δώσουμε στα αδέσποτα μια φωνή και μια ευκαιρία για ένα καλύτερο μέλλον!

Ελπίζουμε η Stray PAWsitive να γίνει και για σένα πηγή έμπνευσης, όπως ήταν για εμάς το ταξίδι της δημιουργίας της! Μαζί, μπορούμε να κάνουμε τη διαφορά!

Σ’ ευχαριστούμε που είσαι εδώ. Ας κάνουμε κάτι όμορφο, παρέα!''',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
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
