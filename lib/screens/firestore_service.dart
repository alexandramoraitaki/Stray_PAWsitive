import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadData({
    required String collection, // "PawsitiveFriends" ή "FeedingSpots"
    required String name, // Όνομα του φίλου ή σημείου
    required String description, // Περιγραφή
    required GeoPoint location, // Συντεταγμένες τοποθεσίας
    required String date, // Ημερομηνία
    required List<String> filters, // Φίλτρα (π.χ., "DOG", "FRIENDLY")
    String? imageUrl, // URL εικόνας (προαιρετικό)
  }) async {
    try {
      await _firestore.collection(collection).add({
        'name': name,
        'description': description,
        'location': location,
        'date': date,
        'filters': filters,
        'imageUrl': imageUrl,
      });
      print("Data uploaded successfully!");
    } catch (e) {
      print("Error uploading data: $e");
    }
  }
}
