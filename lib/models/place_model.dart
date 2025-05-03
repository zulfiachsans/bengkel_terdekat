class Place {
  final String name;
  final double lat;
  final double lng;
  final String address;

  Place({
    required this.name,
    required this.lat,
    required this.lng,
    required this.address,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      name: json['name'],
      lat: json['geometry']['location']['lat'],
      lng: json['geometry']['location']['lng'],
      address: json['vicinity'] ?? '',
    );
  }
}
