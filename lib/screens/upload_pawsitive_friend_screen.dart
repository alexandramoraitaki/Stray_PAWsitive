import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'pawsitive_friend_profile_screen.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'google_maps_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'menu_screen.dart';
import 'user_profile_screen.dart';
import 'bot_screen.dart';

class UploadPawsitiveFriendScreen extends StatefulWidget {
  const UploadPawsitiveFriendScreen({Key? key}) : super(key: key);

  @override
  State<UploadPawsitiveFriendScreen> createState() =>
      _UploadPawsitiveFriendScreenState();
}

class _UploadPawsitiveFriendScreenState
    extends State<UploadPawsitiveFriendScreen> {
  File? image;
  DateTime? selectedDate;
  String? location;
  String? selectedAnimal; // "DOG" ή "CAT"
  String? selectedGender; // "MALE" ή "FEMALE"
  String? selectedSize; // "SMALL" / "MEDIUM" / "LARGE"
  String? selectedFriendliness; // "FRIENDLY" ή "NOT FRIENDLY"
  String imageUrl = '';
  String? _documentId;
  final TextEditingController descriptionController = TextEditingController();
  double? selectedLatitude;
  double? selectedLongitude;

  /// Μετατροπή συντεταγμένων σε διεύθυνση
  Future<void> _getAddressFromCoordinates(LatLng position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          location = '${place.street}, ${place.locality}, ${place.country}';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not fetch address: $e")),
      );
    }
  }

  /// Αποθήκευση στο Firestore/Storage
  Future<void> _saveToFirestore() async {
    try {
      // 1. Έλεγχος πεδίων
      if (image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select an image!")),
        );
        return;
      }
      if (location == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a location!")),
        );
        return;
      }
      if (selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a date!")),
        );
        return;
      }
      if (descriptionController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a description!")),
        );
        return;
      }
      if (selectedAnimal == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select an animal type (DOG/CAT)!")),
        );
        return;
      }
      if (selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a gender (MALE/FEMALE)!")),
        );
        return;
      }
      if (selectedSize == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a size (SMALL/MEDIUM/LARGE)!")),
        );
        return;
      }
      if (selectedFriendliness == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select friendliness (FRIENDLY/NOT FRIENDLY)!")),
        );
        return;
      }

      // 2. Ανεβάζουμε εικόνα στο Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('pawsitive_friends/${DateTime.now().millisecondsSinceEpoch}.jpg');
      try {
        final uploadTask = storageRef.putFile(
          image!,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        await uploadTask;
        imageUrl = await storageRef.getDownloadURL();
      } catch (e) {
        print("Upload failed: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image upload failed: $e")),
        );
        return;
      }

      // 3. Αποθήκευση στο Firestore
      final docRef =
          FirebaseFirestore.instance.collection('pawsitive_friends').doc();

      await docRef.set({
        'type': selectedAnimal, // "DOG" ή "CAT"
        'image_url': imageUrl,
        'location': location,
        'latitude': selectedLatitude,
        'longitude': selectedLongitude,
        'date': selectedDate!.toIso8601String(),
        'description': descriptionController.text,
        'created_at': FieldValue.serverTimestamp(),
        'gender': selectedGender!,
        'size': selectedSize!,
        'friendliness': selectedFriendliness!,
      });

      // Αποθηκεύουμε το id
      setState(() {
        _documentId = docRef.id;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pawsitive Friend uploaded successfully!"),
        ),
      );
    } catch (e) {
      print("Error uploading data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload data: $e")),
      );
    }
  }

  /// Επιλογή εικόνας
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Image Source"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
              child: const Text("Camera"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
              child: const Text("Gallery"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Pawsitive Friend'),
      ),
      body: Stack(
        children: [
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

                  // Επιλογή Εικόνας
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
                      child: image == null
                          ? IconButton(
                              icon: const Icon(Icons.image,
                                  size: 50, color: Colors.grey),
                              onPressed: _showImageSourceDialog,
                            )
                          : Image.file(image!, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Επιλογή Τοποθεσίας
                  GestureDetector(
                    onTap: () async {
                      Position? position;
                      try {
                        bool serviceEnabled =
                            await Geolocator.isLocationServiceEnabled();
                        if (!serviceEnabled) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Location services are disabled.")),
                          );
                          return;
                        }

                        LocationPermission permission =
                            await Geolocator.checkPermission();
                        if (permission == LocationPermission.denied) {
                          permission =
                              await Geolocator.requestPermission();
                          if (permission == LocationPermission.denied) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Location permission denied.")),
                            );
                            return;
                          }
                        }

                        if (permission == LocationPermission.deniedForever) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Location permission permanently denied.")),
                          );
                          return;
                        }

                        position = await Geolocator.getCurrentPosition();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Failed to get location: $e")),
                        );
                        return;
                      }

                      final LatLng? selectedLocation = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GoogleMapsScreen(
                            initialLocation:
                                LatLng(position!.latitude, position.longitude),
                          ),
                        ),
                      );

                      if (selectedLocation != null) {
                        setState(() {
                          selectedLatitude = selectedLocation.latitude;
                          selectedLongitude = selectedLocation.longitude;
                        });
                        await _getAddressFromCoordinates(selectedLocation);
                      }
                    },
                    child: Container(
                      width: screenWidth * 0.8,
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
                        location ?? 'Select Location',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Επιλογή Ημερομηνίας
                  GestureDetector(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Container(
                      width: screenWidth * 0.8,
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
                        selectedDate == null
                            ? 'Select Date'
                            : 'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Επιλογές DOG/CAT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFilterButton(
                        label: 'DOG',
                        isSelected: selectedAnimal == 'DOG',
                        onTap: () {
                          setState(() {
                            selectedAnimal = 'DOG';
                          });
                        },
                      ),
                      _buildFilterButton(
                        label: 'CAT',
                        isSelected: selectedAnimal == 'CAT',
                        onTap: () {
                          setState(() {
                            selectedAnimal = 'CAT';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Επιλογές MALE/FEMALE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFilterButton(
                        label: 'MALE',
                        isSelected: selectedGender == 'MALE',
                        onTap: () {
                          setState(() {
                            selectedGender = 'MALE';
                          });
                        },
                      ),
                      _buildFilterButton(
                        label: 'FEMALE',
                        isSelected: selectedGender == 'FEMALE',
                        onTap: () {
                          setState(() {
                            selectedGender = 'FEMALE';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Επιλογές SMALL/MEDIUM/LARGE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFilterButton(
                        label: 'SMALL',
                        isSelected: selectedSize == 'SMALL',
                        onTap: () {
                          setState(() {
                            selectedSize = 'SMALL';
                          });
                        },
                      ),
                      _buildFilterButton(
                        label: 'MEDIUM',
                        isSelected: selectedSize == 'MEDIUM',
                        onTap: () {
                          setState(() {
                            selectedSize = 'MEDIUM';
                          });
                        },
                      ),
                      _buildFilterButton(
                        label: 'LARGE',
                        isSelected: selectedSize == 'LARGE',
                        onTap: () {
                          setState(() {
                            selectedSize = 'LARGE';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Επιλογές FRIENDLY/NOT FRIENDLY
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFilterButton(
                        label: 'FRIENDLY',
                        isSelected: selectedFriendliness == 'FRIENDLY',
                        onTap: () {
                          setState(() {
                            selectedFriendliness = 'FRIENDLY';
                          });
                        },
                      ),
                      _buildFilterButton(
                        label: 'NOT FRIENDLY',
                        isSelected: selectedFriendliness == 'NOT FRIENDLY',
                        onTap: () {
                          setState(() {
                            selectedFriendliness = 'NOT FRIENDLY';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Πεδίο Description
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
                    child: TextField(
                      controller: descriptionController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Description',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Κουμπί "X" 
          Positioned(
            top: 20,
            left: screenWidth * 0.1,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          // Κουμπί "✓" 
          Positioned(
            top: 20,
            right: screenWidth * 0.1,
            child: IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () async {
                // Έλεγχος πεδίων πριν την αποστολή
                if (image == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select an image!")),
                  );
                  return;
                }
                if (location == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select a location!")),
                  );
                  return;
                }
                if (selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select a date!")),
                  );
                  return;
                }
                if (descriptionController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a description!")),
                  );
                  return;
                }
                if (selectedAnimal == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select an animal type (DOG/CAT)!")),
                  );
                  return;
                }
                if (selectedGender == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select a gender (MALE/FEMALE)!")),
                  );
                  return;
                }
                if (selectedSize == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select a size (SMALL/MEDIUM/LARGE)!")),
                  );
                  return;
                }
                if (selectedFriendliness == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select friendliness (FRIENDLY/NOT FRIENDLY)!")),
                  );
                  return;
                }

                await _saveToFirestore();

                if (_documentId == null) {
                  // Κάτι πήγε στραβά
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text("Failed to save data. Please try again."),
                    ),
                  );
                  return;
                }

                // Μεταφορά στο PawsitiveFriendProfileScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PawsitiveFriendProfileScreen(documentId: _documentId!),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Κουμπί-βοηθός για τα φίλτρα
  Widget _buildFilterButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple : const Color(0xFFF5EAFB),
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
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.purple,
          ),
        ),
      ),
    );
  }
}
