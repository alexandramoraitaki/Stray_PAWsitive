import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'pawsitive_friend_profile_screen.dart';


class UploadPawsitiveFriendScreen extends StatefulWidget {
  const UploadPawsitiveFriendScreen({super.key});

  @override
  State<UploadPawsitiveFriendScreen> createState() => _UploadPawsitiveFriendScreenState();
}

class _UploadPawsitiveFriendScreenState extends State<UploadPawsitiveFriendScreen> {
  File? image; // Η επιλεγμένη εικόνα

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
                _buildProfileField('Location:'),
                const SizedBox(height: 20),

                // Πεδίο "Date"
                _buildProfileField('Date:'),
                const SizedBox(height: 20),

                // Επιλογές για "DOG" και "CAT"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildOptionButton('DOG'),
                    _buildOptionButton('CAT'),
                  ],
                ),
                const SizedBox(height: 20),

                // Επιλογές για "MALE" και "FEMALE"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildOptionButton('MALE'),
                    _buildOptionButton('FEMALE'),
                  ],
                ),
                const SizedBox(height: 40),

                // Επιλογές για "SMALL", "MEDIUM", "LARGE"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildOptionButton('SMALL'),
                    _buildOptionButton('MEDIUM'),
                    _buildOptionButton('LARGE'),
                  ],
                ),
                const SizedBox(height: 20),

                // Επιλογές για "FRIENDLY" και "NOT FRIENDLY"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildOptionButton('FRIENDLY'),
                    _buildOptionButton('NOT FRIENDLY'),
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