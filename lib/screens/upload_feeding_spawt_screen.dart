import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'menu_screen.dart';
import 'user_profile_screen.dart';
import 'bot_screen.dart';
import 'feeding_spawt_profile_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'google_maps_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';

import 'package:intl/intl.dart';



class UploadFeedingSpawtScreen extends StatefulWidget {
  const UploadFeedingSpawtScreen({super.key});

  @override
  State<UploadFeedingSpawtScreen> createState() =>
      _UploadFeedingSpawtScreenState();
}

class _UploadFeedingSpawtScreenState extends State<UploadFeedingSpawtScreen> {
  File? image;
  String? location;
  DateTime? selectedDate;
 final TextEditingController descriptionController = TextEditingController();



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
    // TextEditingController για την περιγραφή
final TextEditingController descriptionController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              // Logo πάνω δεξιά
              Positioned(
                top: 20,
                left: 270,
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
                    height: 80,
                  ),
                ),
              ),

              // Βελάκι πάνω αριστερά για επιστροφή στο Menu
              Positioned(
                top: 20,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.pinkAccent),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MenuScreen()),
                    );
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 100), // Κενό από το πάνω μέρος

                    // Τίτλος "Registration" με κουμπιά "Χ" και "✓"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MenuScreen()),
                            );
                          },
                        ),
                        Container(
                          width: screenWidth * 0.5,
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
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            if (image == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Please select an image!")),
                              );
                            } else if (location == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Please select a location!")),
                              );
                            } else if (selectedDate == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Please select a date!")),
                              );
                            } else {
                                  // Συνδυασμός ημερομηνίας και ώρας
    final selectedDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
  
    );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FeedingSpawtProfileScreen(
                                    image: image!,
                                    location: location!,
                                    date: selectedDate.toString(),
                                    description: descriptionController.text,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Εικόνα
                    GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Container(
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
                              ? const Icon(Icons.image,
                                  size: 50, color: Colors.grey)
                              : Image.file(image!, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Τοποθεσία
                    GestureDetector(
                      onTap: () async {
                        // Εντοπισμός τοποθεσίας χρήστη
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
                            permission = await Geolocator.requestPermission();
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
                            SnackBar(
                                content: Text("Failed to get location: $e")),
                          );
                          return;
                        }

                        // Μεταβείτε στην οθόνη GoogleMapsScreen για επιλογή τοποθεσίας
                        final LatLng? selectedLocation = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GoogleMapsScreen(
                              initialLocation: LatLng(
                                  position!.latitude, position.longitude),
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
                      child:  TextField(
                         controller: descriptionController,
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

              // Εικονίδιο Bot κάτω δεξιά
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
          ),
        ),
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
}
