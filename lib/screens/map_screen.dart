import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'user_profile_screen.dart';
import 'feeding_spawt_profile_screen.dart';
import 'menu_screen.dart';
import 'bot_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'pawsitive_friend_profile_screen.dart';

class MapScreen extends StatefulWidget {
  final LatLng? currentLocation;

  const MapScreen({Key? key, this.currentLocation}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Λίστα για τα επιλεγμένα φίλτρα
  final Map<String, bool> filters = {
    'Feeding sPAWs': false,
    'VETS': false,
    'DOG': false,
    'CAT': false,
    'MALE': false,
    'FEMALE': false,
    'SMALL': false,
    'MEDIUM': false,
    'LARGE': false,
    'FRIENDLY': false,
    'NOT FRIENDLY': false,
  };

Set<Marker> allMarkers = {};

  // Μάρκερ που θα εμφανίζονται με βάση τα φίλτρα
  Set<Marker> filteredMarkers = {};

  GoogleMapController? _mapController; // Ελεγκτής του Google Map
  LatLng? _currentLocation; // Τρέχουσα τοποθεσία χρήστη
  Marker? _selectedMarker; // Επιλεγμένο marker
  String? _selectedAddress;
  late BitmapDescriptor foodIcon;
  late BitmapDescriptor dogIcon;
  late BitmapDescriptor catIcon;


  @override
  void initState() {
    super.initState();
    if (widget.currentLocation != null) {
      _currentLocation = widget.currentLocation!;
    } else {
      _getCurrentLocation(); // Παίρνουμε την τοποθεσία αν δεν έχει δοθεί
    }
      _loadMarkersFromFirestore();
  }

Future<void> _loadMarkersFromFirestore() async {
  final firestore = FirebaseFirestore.instance;

  try {
     foodIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/icons/LocationFood.png',
     );
      dogIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(48, 48)),
      'assets/icons/dog_marker.png',
      );
      catIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(48, 48)),
      'assets/icons/cat_marker.png',
     );

  

    // Φέρνουμε όλα τα documents από τη συλλογή `feeding_spawts`
final feedingSpawtsSnapshot = await firestore.collection('feeding_spawts').get();

// Φέρνουμε όλα τα documents από τη συλλογή `pawsitive_friends`
final pawsitiveFriendsSnapshot = await firestore.collection('pawsitive_friends').get();


    Set<Marker> markers = {};

    for (var doc in feedingSpawtsSnapshot.docs) {
      final data = doc.data();
      final latitude = data['latitude'];
      final longitude = data['longitude'];
      final documentId = doc.id;
      //final type = data['type'];

      print('Document ID: $documentId, Latitude: $latitude, Longitude: $longitude'); // Debug εκτύπωση
      
        if (latitude != null && longitude != null) {
    markers.add(
      Marker(
        markerId: MarkerId(documentId),
        position: LatLng(latitude, longitude),
        icon: foodIcon, // Αντίστοιχο εικονίδιο για feeding spawts
        infoWindow: InfoWindow(title: data['description'] ?? 'Feeding Spot'),
      ),
    );
  }
}
      // Επεξεργασία των pawsitive friends
for (var doc in pawsitiveFriendsSnapshot.docs) {
  final data = doc.data();
  final latitude = data['latitude'];
  final longitude = data['longitude'];
  final documentId = doc.id;

  if (latitude != null && longitude != null) {
    BitmapDescriptor icon;
    Widget Function(String documentId) screen;
    switch (data['type']) {
      case 'Dog':
        icon = dogIcon;
        screen = (documentId) => PawsitiveFriendProfileScreen(documentId: documentId);
        break;
      case 'Cat':
        icon = catIcon;
        screen = (documentId) => PawsitiveFriendProfileScreen(documentId: documentId);
        break;
      default:
        continue;
    }










        // Δημιουργία marker
        Marker marker = Marker(
          markerId: MarkerId(documentId),
          position: LatLng(latitude, longitude),
          icon: icon, // Χρήση του προσαρμοσμένου εικονιδίου
          infoWindow: InfoWindow(
            title: data['description'] ?? 'Marker',
            snippet: data['location'],
            onTap: () {
              // Άνοιγμα της αντίστοιχης σελίδας με βάση το documentId
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => screen (documentId),
                ),
              );
            },
          ),
        );
        markers.add(marker);
      }
    }

    setState(() {
      filteredMarkers = markers; // Προσθήκη markers στον χάρτη
    });
    print('Markers loaded: ${filteredMarkers.length}'); // Ενημέρωση του αριθμού των markers
  } catch (e) {
    print('Error loading markers: $e');
  }
}


  // Μέθοδος για να πάρουμε την τρέχουσα τοποθεσία του χρήστη
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("Location services are disabled.");
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("Location permissions are denied.");
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      // Μετακινούμε την κάμερα στη θέση του χρήστη
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 14.0,
          ),
        ),
      );
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  Future<void> _setMarkerAndAddress(LatLng position) async {
    try {
      // Λήψη διεύθυνσης από συντεταγμένες
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      String address = placemarks.isNotEmpty
          ? '${placemarks.first.street}, ${placemarks.first.locality}'
          : 'Unknown Address';

      setState(() {
        _selectedMarker = Marker(
          markerId: MarkerId('selectedLocation'),
          position: position,
          infoWindow: InfoWindow(title: address),
        );
        _selectedAddress = address;
      });

      _mapController?.animateCamera(CameraUpdate.newLatLng(position));
    } catch (e) {
      print("Error fetching address: $e");
      setState(() {
        _selectedAddress = 'Address not found';
      });
    }
  }

  // Μέθοδος αναζήτησης τοποθεσίας
  Future<void> _searchLocation(String query) async {
    try {
      // Μετατροπή κειμένου σε συντεταγμένες
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        Location location = locations.first;

        // Δημιουργία νέου marker για την τοποθεσία
        Marker newMarker = Marker(
          markerId: MarkerId(query), // Χρησιμοποίησε το query ως μοναδικό ID
          position: LatLng(location.latitude, location.longitude),
          infoWindow: InfoWindow(title: query),
        );

        setState(() {
          // Προσθήκη του νέου marker στα markers
          filteredMarkers = {newMarker};
        });

        // Μετακίνηση της κάμερας στον νέο προορισμό
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(location.latitude, location.longitude),
              zoom: 17.0,
            ),
          ),
        );
      } else {
        // Αν δεν βρεθεί τοποθεσία, εμφάνιση μηνύματος
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location not found')),
        );
      }
    } catch (e) {
      print('Error searching location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error searching location')),
      );
    }
  }





  // Ενημέρωση markers με βάση τα φίλτρα
  void _applyFilters() {
    setState(() {
      filteredMarkers = allMarkers.where((marker) {
        if (filters['DOG'] == true && marker.markerId.value.contains('dog')) {
          return true;
        }
        if (filters['CAT'] == true && marker.markerId.value.contains('cat')) {
          return true;
        }
      
          if (filters['Feeding sPAWs'] == true && marker.markerId.value.contains('food')) {
          return true;
        }
        return false; // Αν δεν ταιριάζει με κανένα φίλτρο, μην το εμφανίζεις
      }).toSet();
    });
  }

  // Δημιουργία FilterChip
  Widget _buildFilterChip(String label) {
    return FilterChip(
      label: Text(label),
      selected: filters[label] ?? false,
      onSelected: (bool selected) {
        setState(() {
          filters[label] = selected; // Ενημέρωση του φίλτρου
          _applyFilters(); // Εφαρμογή φίλτρων στα markers
        });
      },
      backgroundColor: const Color(0xFFF5EAFB),
      selectedColor: Colors.pinkAccent,
      labelStyle: TextStyle(
        color: filters[label] ?? false ? Colors.white : Colors.purple,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // Google Map
          Positioned.fill(
            child: _currentLocation == null
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentLocation!,
                      zoom: 15,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: true,
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                    markers: {
                      ...filteredMarkers, // Περιλαμβάνει όλα τα markers
                      if (_selectedMarker != null)
                        _selectedMarker!, // Προσθέτει το επιλεγμένο marker αν υπάρχει
                    },
                    onTap: (LatLng position) {
                      setState(() {
                        Marker newMarker = Marker(
                          markerId: MarkerId(position.toString()),
                          position: position,
                          infoWindow: InfoWindow(title: "Selected Location"),
                        );

                        // Ενημερώνει τη λίστα των markers
                        filteredMarkers = {newMarker};
                        _selectedMarker =
                            newMarker; // Ενημερώνει το _selectedMarker
                      });

                      // Εύρεση διεύθυνσης για το νέο marker
                      _setMarkerAndAddress(position);
                    },
                  ),
          ),

          if (_selectedAddress != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  _selectedAddress!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

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

          // Τίτλος "Map"
          Positioned(
            top: 100,
            left: screenWidth * 0.2,
            right: screenWidth * 0.2,
            child: Container(
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
                  'Map',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),

          // Μπάρα Αναζήτησης
          Positioned(
            top: 150,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search location',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (query) async {
                        await _searchLocation(query);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tap for Filters
          Positioned(
            bottom: 80,
            left: screenWidth * 0.3,
            right: screenWidth * 0.3,
            child: GestureDetector(
              onTap: () {
                // Εμφάνιση popup για φίλτρα
                showModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder:
                          (BuildContext context, StateSetter setModalState) {
                        return Container(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Filters',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: filters.keys.map((filter) {
                                  return FilterChip(
                                    label: Text(filter),
                                    selected: filters[filter] ?? false,
                                    onSelected: (bool selected) {
                                      setModalState(() {
                                        filters[filter] = selected;
                                      });
                                      _applyFilters();
                                    },
                                    backgroundColor: const Color(0xFFF5EAFB),
                                    selectedColor: Colors.pinkAccent,
                                    labelStyle: TextStyle(
                                      color: filters[filter] ?? false
                                          ? Colors.white
                                          : Colors.purple,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                    'Tap for filters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Dog Bot κάτω δεξιά
          Positioned(
            bottom: 20,
            left: 290,
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
