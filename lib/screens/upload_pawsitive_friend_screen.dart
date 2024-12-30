import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'pawsitive_friend_profile_screen.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'google_maps_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';



class UploadPawsitiveFriendScreen extends StatefulWidget {
  const UploadPawsitiveFriendScreen({super.key});

  @override
  State<UploadPawsitiveFriendScreen> createState() => _UploadPawsitiveFriendScreenState();
}

class _UploadPawsitiveFriendScreenState extends State<UploadPawsitiveFriendScreen> {
  File? image; // Η επιλεγμένη εικόνα
  DateTime? selectedDate;
  String? location;
  String? selectedAnimal; // "DOG" ή "CAT"
  String? selectedGender; // Για Male/Female
  String? selectedSize;   // Για Small/Medium/Large
  String? selectedFriendliness; // Για Friendly/Not Friendly

   // Μέθοδος για μετατροπή γεωγραφικού πλάτους και μήκους σε διεύθυνση
Future<void> _getAddressFromCoordinates(LatLng position) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

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

 void _handleGoogleMapsSelection(Uri uri) {
  if (uri.scheme == 'straypaws') {
    // Διαβάζουμε τη διεύθυνση από το deeplink
    final lat = uri.queryParameters['lat'];
    final lng = uri.queryParameters['lng'];

    if (lat != null && lng != null) {
      setState(() {
        location = 'Latitude: $lat, Longitude: $lng';
      });
    }
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 80),
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
                    child: image == null
                        ? IconButton(
                            icon: const Icon(Icons.image, size: 50, color: Colors.grey),
                            onPressed: _showImageSourceDialog,
                          )
                        : Image.file(image!, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 20),

                // Πεδίο "Location"
                GestureDetector(
                  onTap: () async {
                     // Εντοπισμός τοποθεσίας χρήστη
                    Position? position;
                   try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location services are disabled.")),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permission denied.")),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission permanently denied.")),
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

     // Μεταβείτε στην οθόνη GoogleMapsScreen για επιλογή τοποθεσίας
    final LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoogleMapsScreen(
          initialLocation: LatLng(position!.latitude, position!.longitude),
        ),
      ),
    );

    // Αν ο χρήστης επιλέξει τοποθεσία, ενημερώνεται το πεδίο location
    if (selectedLocation != null) {
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


                // Ημερομηνία
                GestureDetector(
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                        print('Selected date: $pickedDate');
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

                // Επιλογές για "DOG" και "CAT"
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

                // Επιλογές για "MALE" και "FEMALE"
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

                // Επιλογές για "SMALL", "MEDIUM", "LARGE"
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

                // Επιλογές για "FRIENDLY" και "NOT FRIENDLY"
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

        // Κουμπί "X" (Close)
        Positioned(
          top: 20,
          left: screenWidth * 0.1,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () {
              Navigator.pop(context); // Επιστροφή στην προηγούμενη σελίδα
            },
          ),
        ),

        // Κουμπί "✓" (Check)
        Positioned(
          top: 20,
          right: screenWidth * 0.1,
          child: IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () {
              if (image == null) {
                // Ειδοποίηση ότι δεν έχει επιλεγεί εικόνα
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please select an image!")),
                );
              } else {
                // Προχωράει στην επόμενη σελίδα
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PawsitiveFriendProfileScreen(),
                  ),
                );
              }
            },
          ),
        ),

        
      ],
    ),
  );
}


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


  Widget _buildFilterButton({
  required String label,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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