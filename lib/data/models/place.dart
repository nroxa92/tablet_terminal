// FILE: lib/data/models/place.dart
// OPIS: Model koji predstavlja restoran, plažu ili atrakciju.
// NADOGRADNJA: Dodana polja latitude i longitude za preciznu lokaciju.

class Place {
  final String name;
  final String address;
  final double rating;
  final int userRatingsTotal;
  final bool isOpen;
  final String placeId;
  final String? photoReference;

  // --- NOVI PODACI (KOORDINATE) ---
  final double? latitude;
  final double? longitude;

  Place({
    required this.name,
    required this.address,
    required this.rating,
    required this.userRatingsTotal,
    required this.isOpen,
    required this.placeId,
    this.photoReference,
    this.latitude,
    this.longitude,
  });

  // Tvornica koja pretvara Google JSON u naš objekt
  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      name: json['displayName']?['text'] ??
          'Unknown', // Dodan '?' za svaki slučaj
      address: json['formattedAddress'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      userRatingsTotal: json['userRatingCount'] ?? 0,
      isOpen: json['regularOpeningHours']?['openNow'] ?? false,
      placeId: json['id'], // Bitno za link na mapu

      // Uzimamo prvu sliku ako postoji
      photoReference: (json['photos'] != null && json['photos'].isNotEmpty)
          ? json['photos'][0]['name']
          : null,

      // --- ČITANJE KOORDINATA ---
      latitude: json['location']?['latitude'],
      longitude: json['location']?['longitude'],
    );
  }
}
