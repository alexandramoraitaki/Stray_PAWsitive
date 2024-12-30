import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapsScreen extends StatefulWidget {
  final LatLng initialLocation; // Προσθέτουμε την παράμετρο για την αρχική τοποθεσία

  GoogleMapsScreen({required this.initialLocation}); // Constructor με απαιτούμενη παράμετρο

  @override
  GoogleMapsScreenState createState() => GoogleMapsScreenState();
}

class GoogleMapsScreenState extends State<GoogleMapsScreen> {
  LatLng? _pickedLocation; // Η επιλεγμένη τοποθεσία


  void _selectLocation(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              if (_pickedLocation != null) {
                Navigator.pop(context, _pickedLocation);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please select a location!")),
                );
              }
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition:  CameraPosition(
          target:  widget.initialLocation,
          zoom: 10,
        ),
        onTap: _selectLocation, // Επιλογή τοποθεσίας με tap
        markers: _pickedLocation == null
            ? {}
            : {
                Marker(
                  markerId: const MarkerId('picked-location'),
                  position: _pickedLocation!,
                ),
              },
      ),
    );
  }
}
