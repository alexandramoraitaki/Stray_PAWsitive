// pawsitive_friend_profile_screen.dart
import 'package:flutter/material.dart';
import 'map_screen.dart';
import 'user_profile_screen.dart';
import 'bot_screen.dart';
import 'menu_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Προσθήκη
import 'package:firebase_storage/firebase_storage.dart'; // Προσθήκη

class PawsitiveFriendProfileScreen extends StatefulWidget {
  final String documentId;
  const PawsitiveFriendProfileScreen({super.key, required this.documentId});

  @override
  State<PawsitiveFriendProfileScreen> createState() =>
      _PawsitiveFriendProfileScreenState();
}

class _PawsitiveFriendProfileScreenState
    extends State<PawsitiveFriendProfileScreen> {
  bool isExpanded = false;
  bool isOwner = false; // Νέο πεδίο για να ελέγξει αν ο χρήστης είναι ο ιδιοκτήτης

  // Μέθοδος Διαγραφής της Καταγραφής
  Future<void> _deletePawsitiveFriend(String docId, String imageUrl) async {
    try {
      // 1. Διαγραφή της εικόνας από το Firebase Storage
      if (imageUrl.isNotEmpty) {
        Reference storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
        await storageRef.delete();
      }


      // 2. Διαγραφή του εγγράφου από το Firestore
      await FirebaseFirestore.instance
          .collection('pawsitive_friends')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pawsitive Friend deleted successfully!")),
      );

      // Μεταφορά στο MenuScreen ή άλλο κατάλληλο screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MenuScreen()),
        (route) => false,
      );
    } catch (e) {
      print("Error deleting Pawsitive Friend: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete: $e")),
      );
    }
  }

  // Νέο: Μέθοδος υιοθεσίας
  Future<void> _adoptPet(String docId) async {
    final docRef =
        FirebaseFirestore.instance.collection('pawsitive_friends').doc(docId);
    // Ορίζουμε το adopted = true
    await docRef.update({'adopted': true});
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final documentId = widget.documentId;

    return Scaffold(
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
          final imageUrl = data['image_url']; // Θα έχει το downloadURL
          final location = data['location'];
          final date = data['date'];
          final animal = data['type'];
          final gender = data['gender'];
          final size = data['size'];
          final friendliness = data['friendliness'];
          final description = data['description'];
          // Ανάγνωση του πεδίου "adopted"
          final bool isAdopted = data['adopted'] ?? false;
          final String ownerId = data['owner_id']; // Λήψη του owner_id

          // Λήψη του τρέχοντος χρήστη
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null && currentUser.uid == ownerId) {
            isOwner = true;
          } else {
            isOwner = false;
          }

          return Stack(
            children: [
              // 1. Βάλε το SingleChildScrollView πρώτο, ώστε να είναι "κάτω"
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 80),
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
                                return const Icon(Icons.error,
                                    color: Colors.red);
                              },
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),

                      if (!isAdopted)
                        ElevatedButton.icon(
                          onPressed: () async {
                            // Εμφάνιση παραθύρου επιβεβαίωσης
                            final shouldAdopt = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Confirm Adoption"),
                                  content: const Text("Are you sure you want to adopt this pet?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(false); // Ακύρωση
                                      },
                                      child: const Text("No"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(true); // Επιβεβαίωση
                                      },
                                      child: const Text("Yes"),
                                    ),
                                  ],
                                );
                              },
                            );
                            // Αν ο χρήστης επιβεβαιώσει
                            if (shouldAdopt == true) {
                              await _adoptPet(widget.documentId);
                            }
                          },
                          icon: const Icon(Icons.favorite),
                          label: const Text("Adopt"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        )
                      else
                        // Αν το ζώο είναι ήδη υιοθετημένο, εμφάνιση μηνύματος "Adopted"
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            "Adopted!",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),


                      // Κουμπί Διαγραφής (εμφανίζεται μόνο αν ο χρήστης είναι ο ιδιοκτήτης)
                      if (isOwner)
                        ElevatedButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("Confirm Deletion"),
                                  content: const Text(
                                      "Are you sure you want to delete this Pawsitive Friend?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                      child: const Text("Delete"),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirm == true) {
                              _deletePawsitiveFriend(
                                  widget.documentId, data['image_url']);
                            }
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text("Delete Record"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        )
                      else if (isAdopted)
                        // Αν το ζώο είναι ήδη υιοθετημένο, εμφάνιση μηνύματος "Adopted"
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            "Adopted!",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
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
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
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



  /// Μέθοδος για πεδίο Location, Date
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

  /// Μέθοδος για τα κουμπιά επιλογών
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
