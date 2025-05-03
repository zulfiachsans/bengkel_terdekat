import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class PlacesService {
  static Future<List<dynamic>> getNearbyPlaces(LatLng location,
      [String keyword = "tambal ban"]) async {
    final apiKey = dotenv.env['GOOGLE_API_KEY'];
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=${location.latitude},${location.longitude}'
      '&radius=5000'
      '&keyword=${Uri.encodeComponent(keyword)}'
      '&key=$apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load places');
    }
  }
}
