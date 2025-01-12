import 'dart:convert';
import 'dart:io';
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
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart'; // Προσθήκη του url_launcher
import 'package:firebase_storage/firebase_storage.dart'; // Προσθήκη για την διαγραφή εικόνων

class MapScreen extends StatefulWidget {
  final LatLng? currentLocation;

  const MapScreen({Key? key, this.currentLocation}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Φίλτρα που επιθυμείς: Feeding sPAWs, DOG, CAT, Vets
  final Map<String, bool> filters = {
    'Feeding sPAWts': false,
    'DOG': false,
    'CAT': false,
    'Vets': false, // Νέο φίλτρο για Κτηνιάτρους
  };

  /// MARKERS
  // Όλοι οι markers
  Set<Marker> allMarkers = {};
  // Αυτοί που περνούν τα φίλτρα
  Set<Marker> filteredMarkers = {};
  // Markers για κτηνιάτρους
  Set<Marker> vetMarkers = {};

  GoogleMapController? _mapController;
  LatLng? _currentLocation;

  // Custom icons
  late BitmapDescriptor foodIcon; // Για Feeding sPAWs
  late BitmapDescriptor dogIcon; // Για DOG
  late BitmapDescriptor catIcon; // Για CAT
  late BitmapDescriptor vetIcon; // Για Κτηνιάτρους

  // Google Places API Key (Βεβαιωθείτε ότι το έχετε προσθέσει σωστά)
  final String googleApiKey = 'AIzaSyBLFrjFY8vqA5QfQnBgx2xiN2-lSm_tr2k';

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
    // Φορτώνουμε τα custom icons
    _loadCustomIcons();
  }

  /// Φορτώνουμε τα custom icons
  Future<void> _loadCustomIcons() async {
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
    vetIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/icons/vetlocation.png',
    );
    setState(() {}); // Ενημερώνουμε το UI αφού φορτώσουν τα icons
  }

  /// Παίρνουμε markers για Feeding sPAWs και Pawsitive Friends
  Future<void> _loadMarkersFromFirestore() async {
    final firestore = FirebaseFirestore.instance;
    try {
      Set<Marker> markers = {};

      // 1) Φέρνουμε τα Feeding sPAWs
      final feedingSnap = await firestore.collection('feeding_spawts').get();
      for (var doc in feedingSnap.docs) {
        final data = doc.data();
        final lat = data['latitude'];
        final lng = data['longitude'];
        final docId = doc.id;
        final desc = data['description'] ?? 'Feeding sPAWt';

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
      final pawsitiveSnap = await firestore.collection('pawsitive_friends').get();
      for (var doc in pawsitiveSnap.docs) {
        final data = doc.data();
        final lat = data['latitude'];
        final lng = data['longitude'];
        final docId = doc.id;
        final desc = data['description'] ?? 'Pawsitive Friend';
        final type = data['type']; // "DOG" ή "CAT" (σύμφωνα με upload

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
                    builder: (_) => PawsitiveFriendProfileScreen(documentId: docId),
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

      if (permission == LocationPermission.deniedForever) {
        throw Exception("Location permissions are permanently denied.");
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print("Error getting location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error getting location: $e")),
      );
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

  /// Εφαρμογή φίλτρων (DOG, CAT, Feeding sPAWs, Vets)
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
        if (filters['Feeding sPAWts'] == true && snippet == 'FeedingSpawt') {
          return true;
        }

        // Αν δεν ταιριάζει σε κανένα ενεργό φίλτρο, το κρύβουμε
        return false;
      }).toSet();

      // Φίλτρο Vets
      if (filters['Vets'] == true) {
        filteredMarkers.addAll(vetMarkers);
      }

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
      onSelected: (bool selected) {
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

  /// Μέθοδος για να βρούμε κτηνιάτρους χρησιμοποιώντας το Google Places API
  Future<void> _findVets() async {
    if (_currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Current location not available")),
      );
      return;
    }

    final double latitude = _currentLocation!.latitude;
    final double longitude = _currentLocation!.longitude;
    final int radius = 5000; // Ράδιο σε μέτρα (5 km)

    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=$radius&type=veterinary_care&key=$googleApiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          List results = data['results'];
          Set<Marker> vets = {};

          for (var place in results) {
            final String placeId = place['place_id'];
            final String name = place['name'];
            final double lat = place['geometry']['location']['lat'];
            final double lng = place['geometry']['location']['lng'];
            final String address = place['vicinity'] ?? '';

            Marker vetMarker = Marker(
              markerId: MarkerId('vet_$placeId'),
              position: LatLng(lat, lng),
              icon: vetIcon,
              infoWindow: InfoWindow(
                title: name,
                snippet: 'Vet',
                onTap: () {
                  // Ανοίγει την τοποθεσία του κτηνιάτρου στο Google Maps για πλοήγηση
                  _navigateToVet(lat, lng);
                },
              ),
            );

            vets.add(vetMarker);
          }

          setState(() {
            vetMarkers = vets;
            filteredMarkers.addAll(vetMarkers);
          });

          _applyFilters();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Found ${vets.length} vets')),
          );
        } else {
          print('Places API Error: ${data['status']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Places API Error: ${data['status']}')),
          );
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('HTTP Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error finding vets: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error finding vets: $e')),
      );
    }
  }

  /// Μέθοδος για να ανοίξουμε την τοποθεσία του κτηνιάτρου στο Google Maps
  Future<void> _navigateToVet(double lat, double lng) async {
    String googleUrl =
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&type=veterinary_care';
    String appleUrl = 'https://maps.apple.com/?daddr=$lat,$lng&dirflg=d';

    Uri uri;
    String urlToLaunch;

    if (Platform.isAndroid) {
      urlToLaunch = googleUrl;
    } else if (Platform.isIOS) {
      urlToLaunch = appleUrl;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Platform not supported')),
      );
      return;
    }

    uri = Uri.parse(urlToLaunch);

    if (await canLaunchUrl(uri)) { // Χρήση canLaunchUrl από url_launcher
      await launchUrl(uri); // Χρήση launchUrl από url_launcher
    } else {
      throw 'Could not launch $urlToLaunch';
    }
  }

  /// Δημιουργία κουμπιού "Find Vets"
  Widget _buildFindVetsButton() {
    return ElevatedButton.icon(
      onPressed: _findVets,
      icon: const Icon(Icons.pets),
      label: const Text('Find Vets'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.pinkAccent, // Αντικατάσταση του 'primary' με 'backgroundColor'
        foregroundColor: Colors.white, // Αντικατάσταση του 'onPrimary' με 'foregroundColor'
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
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
              markers: filteredMarkers,
            ),
          ),

          // Back Arrow πάνω αριστερά
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.pinkAccent),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MenuScreen()),
                );
              },
            ),
          ),

          // Εικονίδιο Προφίλ πάνω αριστερά, πιο εσωτερικά από το back arrow
          Positioned(
            top: 20,
            left: 70, // Μετακίνηση προς τα δεξιά για πιο εσωτερική θέση
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

          // Τίτλος "Map"
          Positioned(
            top: 80, // Προσαρμοσμένο για καλύτερη τοποθέτηση
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
            top: 150, // Αυξήθηκε η απόσταση από τον τίτλο του χάρτη
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

          // Κουμπί "Find Vets" πάνω από τα Filters
          Positioned(
            bottom: 200, // Προσαρμοσμένο για καλύτερη τοποθέτηση
            left: screenWidth * 0.3,
            right: screenWidth * 0.3,
            child: _buildFindVetsButton(),
          ),

          // Tap for Filters (εμφανίζει bottom sheet)
          Positioned(
            bottom: 150, // Προσαρμοσμένο για καλύτερη τοποθέτηση
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
                  color: Color.fromARGB(255, 200, 200, 200),
                  borderRadius: BorderRadius.circular(8.0),
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
