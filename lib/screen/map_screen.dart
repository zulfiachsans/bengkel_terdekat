import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/places_service.dart'; // pastikan path ini sesuai dengan struktur folder kamu

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentPosition;
  LatLng? _selectedBengkel;
  String? _selectedBengkelName;
  String? _selectedBengkelPhoto;
  double? _selectedBengkelRating;
  double? _selectedBengkelDistance;
  Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  // Fungsi untuk mendapatkan lokasi pengguna dan langsung load tempat terdekat
  Future<void> _initializeMap() async {
    await _getCurrentLocation();
    await _loadNearbyPlaces("bengkel"); // langsung load bengkel terdekat
  }

  // Mendapatkan lokasi pengguna
  Future<void> _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final latLng = LatLng(position.latitude, position.longitude);
    setState(() {
      _currentPosition = latLng;
    });
    final GoogleMapController mapController = await _controller.future;
    mapController.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
  }

  // Fungsi untuk memuat bengkel terdekat
  Future<void> _loadNearbyPlaces([String keyword = "bengkel"]) async {
    if (_currentPosition == null) return;

    try {
      final places =
          await PlacesService.getNearbyPlaces(_currentPosition!, keyword);

      Set<Marker> newMarkers = {};

      for (var place in places) {
        final lat = place['geometry']['location']['lat'];
        final lng = place['geometry']['location']['lng'];
        final name = place['name'];
        final position = LatLng(lat, lng);

        // Menambahkan marker untuk setiap bengkel
        newMarkers.add(Marker(
          markerId: MarkerId(name),
          position: position,
          infoWindow: InfoWindow(title: name),
          onTap: () async {
            final photo = place['photos'] != null
                ? place['photos'][0]['photo_reference']
                : null;
            final rating = place['rating'];
            final distance = _calculateDistance(lat, lng);

            setState(() {
              _selectedBengkel = position;
              _selectedBengkelName = name;
              _selectedBengkelPhoto = photo != null
                  ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=$photo&key=AIzaSyBAV_KvG9QbQP0tlpA213my_3fluqmqs1A'
                  : null;
              _selectedBengkelRating = rating;
              _selectedBengkelDistance = distance;
            });
          },
        ));
      }

      setState(() {
        _markers = newMarkers;
      });
    } catch (e) {
      print("Error fetching places: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat data bengkel. Coba lagi.")),
      );
    }
  }

  // Fungsi untuk menghitung jarak antara lokasi pengguna dan bengkel
  double _calculateDistance(double lat, double lng) {
    if (_currentPosition == null) return 0.0;

    final distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      lat,
      lng,
    );
    return distance / 1000; // Convert to kilometers
  }

  // Membuka navigasi ke bengkel
  void _openNavigation() async {
    if (_selectedBengkel != null) {
      final url =
          "https://www.google.com/maps/dir/?api=1&destination=${_selectedBengkel!.latitude},${_selectedBengkel!.longitude}&travelmode=driving";
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition!,
              zoom: 15,
            ),
            myLocationEnabled: true, // Untuk menampilkan lokasi pengguna
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: _markers,
          ),

          // Search Bar
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: "Cari bengkel...",
                        border: InputBorder.none,
                        icon: Icon(Icons.search),
                      ),
                      onSubmitted: (value) => _loadNearbyPlaces(value),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      final query = _searchController.text.trim();
                      if (query.isNotEmpty) {
                        _loadNearbyPlaces(query);
                      }
                    },
                  )
                ],
              ),
            ),
          ),

          // Bottom Sheet Info
          if (_selectedBengkel != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_selectedBengkelName ?? "",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    if (_selectedBengkelPhoto != null)
                      Image.network(
                        _selectedBengkelPhoto!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    if (_selectedBengkelRating != null)
                      Text(
                        "Rating: ${_selectedBengkelRating}/5",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    if (_selectedBengkelDistance != null)
                      Text(
                        "Jarak: ${_selectedBengkelDistance!.toStringAsFixed(2)} km",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    const SizedBox(height: 8),
                    Text("Lihat petunjuk arah",
                        style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.navigation),
                      label: const Text("Mulai Petunjuk"),
                      onPressed: _openNavigation,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
