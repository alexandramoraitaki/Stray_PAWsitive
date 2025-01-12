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


  // Νέο: Controller για το σχόλιο
  final TextEditingController commentController = TextEditingController();

  // Νέο: Μέθοδος για την προσθήκη σχολίου
  Future<void> _addComment(String text, String docId) async {
    if (text.trim().isEmpty) return;

    // Παίρνουμε το document
    final docRef = FirebaseFirestore.instance
        .collection('pawsitive_friends')
        .doc(docId);

    // Διαβάζουμε τα τρέχοντα σχόλια
    final docSnap = await docRef.get();
    if (!docSnap.exists) return;

    final data = docSnap.data() as Map<String, dynamic>;

    // Παίρνουμε τη λίστα comments (μπορεί να είναι null)
    List<dynamic> currentComments = data['comments'] ?? [];

    // Προσθέτουμε το νέο σχόλιο
    // user: "Guest" (ή αν έχεις auth, βάζεις το uid / displayName)
    // timestamp: DateTime.now().millisecondsSinceEpoch
    final newComment = {
      'user': 'Guest', 
      'text': text,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    currentComments.add(newComment);

    // Κάνουμε update το document
    await docRef.update({'comments': currentComments});

    // Καθαρίζουμε το textfield
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final documentId = widget.documentId;

    return Scaffold (
      backgroundColor: const Color(0xFFF5F5F5),
      body: StreamBuilder<DocumentSnapshot>(
        // 1. Φέρνουμε τα δεδομένα από τη συλλογή 'pawsitive_friends'
        stream: FirebaseFirestore.instance
            .collection('pawsitive_friends')
            .doc(documentId)
            .snapshots(),
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
          final animal = data['type'];
          final gender = data['gender'];
          final size = data['size'];
          final friendliness = data['friendliness'];
          final description = data['description'];
          final List<dynamic> comments = data['comments'] ?? [];
      
      
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
                        _buildProfileField('Date: ${date.substring(0, 10)}'),
                        const SizedBox(height: 30),

                        _buildProfileField('Description: $description'), 
                         const SizedBox(height: 20),



                        // Επιλογές (DOG, MALE, SMALL, NOT FRIENDLY)
                        GridView(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Δύο φίλτρα ανά σειρά
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                          childAspectRatio: 3, // Αναλογία πλάτους-ύψους
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildOptionButton(animal ?? ''),
                          _buildOptionButton(gender ?? ''),
                          _buildOptionButton(size ?? ''),
                          _buildOptionButton(friendliness ?? ''),
                        ],
                      ),
                      const SizedBox(height: 20),

                        // -- ΣΧΟΛΙΑ --
                      const Text(
                        "Comments",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Εμφάνιση της λίστας των σχολίων
                      // (χρησιμοποιούμε ListView.builder μέσα σε Container με fixed height,
                      //  ή shrinkWrap: true)
                      Container(
                        width: screenWidth * 0.9,
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
                        child: comments.isEmpty
                            ? const Center(
                                child: Text("No comments yet."),
                              )
                            : ListView.builder(
                                itemCount: comments.length,
                                itemBuilder: (context, index) {
                                  final c = comments[index] as Map<String, dynamic>;
                                  final user = c['user'] ?? 'Unknown';
                                  final text = c['text'] ?? '';
                                  final ts = c['timestamp'] ?? 0;
                                  // Μετατροπή timestamp σε ημερομηνία
                                  final dateTime = DateTime.fromMillisecondsSinceEpoch(ts);
                                  final dateStr = 
                                      "${dateTime.year}-${dateTime.month.toString().padLeft(2,'0')}-${dateTime.day.toString().padLeft(2,'0')} "
                                      "${dateTime.hour.toString().padLeft(2,'0')}:${dateTime.minute.toString().padLeft(2,'0')}";

                                  return ListTile(
                                    title: Text("$user: $text"),
                                    subtitle: Text(dateStr),
                                  );
                                },
                              ),
                      ),

                      const SizedBox(height: 10),
                      // Πεδίο εισαγωγής νέου σχολίου
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: commentController,
                              decoration: const InputDecoration(
                                hintText: "Add a comment...",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send, color: Colors.pinkAccent),
                            onPressed: () async {
                              // Πατάμε το κουμπί -> προσθήκη σχολίου
                              await _addComment(commentController.text, documentId);
                              //setState(() {}); // Για να ανανεωθεί το FutureBuilder
                            },
                          ),
                        ],
                      ),
                      // -- ΤΕΛΟΣ ΣΧΟΛΙΩΝ --

                      const SizedBox(height: 40),
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
