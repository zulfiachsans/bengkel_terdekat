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
  double? _selectedBengkelDistance;
  Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = "bengkel"; // Default pencarian adalah "bengkel"

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  // Fungsi untuk mendapatkan lokasi pengguna dan langsung load tempat terdekat
  Future<void> _initializeMap() async {
    await _getCurrentLocation();
    await _loadNearbyPlaces(
        _searchKeyword); // langsung load tempat berdasarkan keyword
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

  // Fungsi untuk memuat tempat terdekat berdasarkan keyword pencarian
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
        final distance = _calculateDistance(lat, lng);

        // Menambahkan marker untuk setiap tempat yang ditemukan
        newMarkers.add(Marker(
          markerId: MarkerId(name),
          position: position,
          infoWindow: InfoWindow(title: name),
          onTap: () {
            setState(() {
              _selectedBengkel = position;
              _selectedBengkelName = name;
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
        SnackBar(content: Text("Gagal memuat data tempat. Coba lagi.")),
      );
    }
  }

  // Fungsi untuk menghitung jarak antara lokasi pengguna dan tempat
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

  // Fungsi untuk menghapus pencarian dan kembali ke "bengkel"
  void _clearSearch() {
    setState(() {
      _searchKeyword = "bengkel";
      _searchController.clear();
    });
    _loadNearbyPlaces(_searchKeyword); // Kembali mencari bengkel terdekat
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
                      decoration: InputDecoration(
                        hintText: "Cari tempat...",
                        border: InputBorder.none,
                        icon: Icon(Icons.search),
                      ),
                      onSubmitted: (value) {
                        setState(() {
                          _searchKeyword = value;
                        });
                        _loadNearbyPlaces(
                            _searchKeyword); // Cari berdasarkan keyword
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(_searchKeyword == "bengkel"
                        ? Icons.search
                        : Icons.clear),
                    onPressed: _searchKeyword == "bengkel"
                        ? null
                        : _clearSearch, // Tombol silang untuk kembali ke pencarian bengkel
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
