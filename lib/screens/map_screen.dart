import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'user_profile_screen.dart';
import 'feeding_spawt_profile_screen.dart';
import 'menu_screen.dart';
import 'bot_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pawsitive_friend_profile_screen.dart';

class MapScreen extends StatefulWidget {
  final LatLng? currentLocation;

  const MapScreen({Key? key, this.currentLocation}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Φίλτρα που επιθυμείς: Feeding sPAWs, DOG, CAT
  final Map<String, bool> filters = {
    'Feeding sPAWs': false,
    'DOG': false,
    'CAT': false,
  };

  /// MARKERS
  // Όλοι οι markers
  Set<Marker> allMarkers = {};
  // Αυτοί που περνούν τα φίλτρα
  Set<Marker> filteredMarkers = {};

  GoogleMapController? _mapController;
  LatLng? _currentLocation;

  // Custom icons
  late BitmapDescriptor foodIcon; // Για Feeding sPAWs
  late BitmapDescriptor dogIcon;  // Για DOG
  late BitmapDescriptor catIcon;  // Για CAT

  @override
  void initState() {
    super.initState();
    // Αν έχει δοθεί τρέχουσα τοποθεσία, τη χρησιμοποιούμε
    if (widget.currentLocation != null) {
      _currentLocation = widget.currentLocation;
    } else {
      // Αλλιώς προσπαθούμε να πάρουμε τοποθεσία
      _getCurrentLocation();
    }
    // Φορτώνουμε markers απ' το Firestore
    _loadMarkersFromFirestore();
  }

  /// Παίρνουμε markers για Feeding sPAWs και Pawsitive Friends
  Future<void> _loadMarkersFromFirestore() async {
    final firestore = FirebaseFirestore.instance;
    try {
      // Φορτώνουμε τα custom icons
      foodIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/icons/LocationFood.png',
      );
      dogIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/icons/doglocation.png',
      );
      catIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/icons/catlocation.png',
      );

      Set<Marker> markers = {};

      // 1) Φέρνουμε τα Feeding sPAWs
      final feedingSnap =
          await firestore.collection('feeding_spawts').get();
      for (var doc in feedingSnap.docs) {
        final data = doc.data();
        final lat = data['latitude'];
        final lng = data['longitude'];
        final docId = doc.id;
        final desc = data['description'] ?? 'Feeding sPAW';

        if (lat != null && lng != null) {
          // Δημιουργούμε marker
          Marker m = Marker(
            markerId: MarkerId('feeding_$docId'),
            position: LatLng(lat, lng),
            icon: foodIcon,
            infoWindow: InfoWindow(
              title: desc,
              snippet: 'FeedingSpawt', // για το φιλτράρισμα
              onTap: () {
                // Πατώντας στο infoWindow, ανοίγει το FeedingSpawtProfileScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FeedingSpawtProfileScreen(documentId: docId),
                  ),
                );
              },
            ),
          );
          markers.add(m);
        }
      }

      // 2) Φέρνουμε τα Pawsitive Friends
      final pawsitiveSnap =
          await firestore.collection('pawsitive_friends').get();
      for (var doc in pawsitiveSnap.docs) {
        final data = doc.data();
        final lat = data['latitude'];
        final lng = data['longitude'];
        final docId = doc.id;
        final desc = data['description'] ?? 'Pawsitive Friend';
        final type = data['type']; // "DOG" ή "CAT" (σύμφωνα με upload)

        if (lat != null && lng != null && type != null) {
          // Επιλέγουμε icon και snippet με βάση το type
          BitmapDescriptor icon;
          String snippetType;
          switch (type) {
            case 'DOG':
              icon = dogIcon;
              snippetType = 'DOG';
              break;
            case 'CAT':
              icon = catIcon;
              snippetType = 'CAT';
              break;
            default:
              continue;
          }

          Marker m = Marker(
            markerId: MarkerId('pawsitive_$docId'),
            position: LatLng(lat, lng),
            icon: icon,
            infoWindow: InfoWindow(
              title: desc,
              snippet: snippetType, // "DOG" ή "CAT"
              onTap: () {
                // Πατώντας στο infoWindow, ανοίγει PawsitiveFriendProfileScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PawsitiveFriendProfileScreen(documentId: docId),
                  ),
                );
              },
            ),
          );
          markers.add(m);
        }
      }

      // Τέλος, ενημερώνουμε τα sets
      setState(() {
        allMarkers = markers;
        filteredMarkers = markers;
      });
      print('Markers loaded: ${allMarkers.length}');
    } catch (e) {
      print('Error loading markers: $e');
    }
  }

  /// Παίρνουμε την τρέχουσα τοποθεσία του χρήστη
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
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  /// Μέθοδος αναζήτησης τοποθεσίας
  Future<void> _searchLocation(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        Marker newMarker = Marker(
          markerId: MarkerId(query),
          position: LatLng(location.latitude, location.longitude),
          infoWindow: InfoWindow(title: query),
        );
        setState(() {
          filteredMarkers = {newMarker};
        });
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(location.latitude, location.longitude),
              zoom: 17.0,
            ),
          ),
        );
      } else {
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

  /// Εφαρμογή φίλτρων (DOG, CAT, Feeding sPAWs)
  void _applyFilters() {
    setState(() {
      filteredMarkers = allMarkers.where((marker) {
        final snippet = marker.infoWindow.snippet ?? '';

        // Φίλτρο DOG
        if (filters['DOG'] == true && snippet == 'DOG') {
          return true;
        }
        // Φίλτρο CAT
        if (filters['CAT'] == true && snippet == 'CAT') {
          return true;
        }
        // Φίλτρο Feeding sPAWs
        if (filters['Feeding sPAWs'] == true && snippet == 'FeedingSpawt') {
          return true;
        }

        // Αν δεν ταιριάζει σε κανένα ενεργό φίλτρο, το κρύβουμε
        return false;
      }).toSet();

      // Αν όλα τα φίλτρα είναι off => δείχνουμε όλους τους markers
      if (!filters.values.contains(true)) {
        filteredMarkers = allMarkers;
      }
    });
  }

  /// Δημιουργία FilterChip για το bottom sheet
  Widget _buildFilterChip(String label) {
    return FilterChip(
      label: Text(label),
      selected: filters[label] ?? false,
      onSelected: (selected) {
        setState(() {
          filters[label] = selected;
          _applyFilters();
        });
      },
      backgroundColor: const Color(0xFFF5EAFB),
      selectedColor: Colors.pinkAccent,
      labelStyle: TextStyle(
        color: (filters[label] ?? false) ? Colors.white : Colors.purple,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Αν δεν έχουμε ακόμα τοποθεσία, δείχνουμε loader
    if (_currentLocation == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // Google Map
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLocation!,
                zoom: 15,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              onMapCreated: (controller) => _mapController = controller,
              // Δεν προσθέτουμε marker onTap — άρα δεν εμφανίζεται address container
              markers: filteredMarkers,
            ),
          ),


          // Εικονίδιο Προφίλ πάνω αριστερά (προαιρετικό)
          Positioned(
            top: 20,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserProfileScreen()),
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

          // Τίτλος "Map" (αν θες)
          Positioned(
            top: 100,
            left: screenWidth * 0.3,
            right: screenWidth * 0.3,
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

          // Tap for Filters (εμφανίζει bottom sheet)
          Positioned(
            bottom: 80,
            left: screenWidth * 0.3,
            right: screenWidth * 0.3,
            child: GestureDetector(
              onTap: () {
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
                                children: filters.keys.map((filterKey) {
                                  return FilterChip(
                                    label: Text(filterKey),
                                    selected: filters[filterKey] ?? false,
                                    onSelected: (bool selected) {
                                      setModalState(() {
                                        filters[filterKey] = selected;
                                      });
                                      _applyFilters();
                                    },
                                    backgroundColor: const Color(0xFFF5EAFB),
                                    selectedColor: Colors.pinkAccent,
                                    labelStyle: TextStyle(
                                      color: (filters[filterKey] ?? false)
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
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'Tap for Filters',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bot κάτω δεξιά
          Positioned(
            bottom: 20,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BotScreen()),
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
