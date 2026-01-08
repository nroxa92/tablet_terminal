// FILE: lib/data/services/places_service.dart
// OPIS: Komunicira s Google Places API-jem.
// FIX: Vraćena metoda 'resetLocation' da se popravi greška u Admin panelu.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../config/constants.dart';
import '../models/place.dart';
import 'storage_service.dart';

class PlacesService {
  // Koordinate su nullable (čekamo geocoding)
  static double? lat;
  static double? lng;

  static bool _isLocationInitialized = false;

  // --- OVO JE FALILO: METODA ZA RESETIRANJE LOKACIJE ---
  // Poziva se iz Admin panela kad se promijeni adresa vile.
  static void resetLocation() {
    lat = null;
    lng = null;
    _isLocationInitialized = false;
    debugPrint(
        "🔄 Lokacija resetirana. Sljedeća pretraga će tražiti nove koordinate.");
  }
  // -----------------------------------------------------

  // 1. INICIJALIZACIJA LOKACIJE
  static Future<void> initializeLocation() async {
    if (_isLocationInitialized && lat != null && lng != null) return;

    final String address = StorageService.getVillaAddress();

    debugPrint("🌍 Pokrećem Geocoding za adresu: $address");

    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=${AppConstants.googleMapsApiKey}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'OK') {
          final location = data['results'][0]['geometry']['location'];
          lat = location['lat'];
          lng = location['lng'];
          _isLocationInitialized = true;
          debugPrint("📍 Uspjeh! Nove koordinate: $lat, $lng");
        } else {
          debugPrint("❌ Geocoding nije uspio: ${data['status']}");
        }
      }
    } catch (e) {
      debugPrint("❌ Greška mreže pri dohvaćanju lokacije: $e");
    }
  }

  // 2. PRETRAGA MJESTA
  static Future<List<Place>> searchNearbyPlaces(String queryCategory) async {
    await initializeLocation();

    if (lat == null || lng == null) {
      debugPrint("⚠️ Prekid pretrage: Lokacija vile nije postavljena.");
      return [];
    }

    debugPrint("🔍 Tražim '$queryCategory' oko $lat, $lng");

    const String baseUrl =
        'https://places.googleapis.com/v1/places:searchNearby';

    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': AppConstants.googleMapsApiKey,
      'X-Goog-FieldMask':
          'places.displayName,places.formattedAddress,places.rating,places.userRatingCount,places.regularOpeningHours,places.id,places.photos,places.location',
    };

    // Mapiranje kategorija
    List<String> includedTypes;
    if (queryCategory.toLowerCase().contains("food") ||
        queryCategory.toLowerCase().contains("gastro")) {
      includedTypes = ["restaurant", "cafe", "bar"];
    } else if (queryCategory.toLowerCase().contains("health") ||
        queryCategory.toLowerCase().contains("pharmacy")) {
      includedTypes = ["pharmacy", "doctor", "hospital"];
    } else {
      includedTypes = [queryCategory.toLowerCase()];
    }

    final body = jsonEncode({
      "includedTypes": includedTypes,
      "locationRestriction": {
        "circle": {
          "center": {"latitude": lat, "longitude": lng},
          "radius": 5000.0 // 5km
        }
      },
      "rankPreference": "POPULARITY"
    });

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['places'] != null) {
          return (data['places'] as List)
              .map((json) => Place.fromJson(json))
              .take(5)
              .toList();
        }
      } else {
        debugPrint("Maps API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("Error fetching places: $e");
    }
    return [];
  }

  static String getPhotoUrl(String photoReference) {
    return 'https://places.googleapis.com/v1/$photoReference/media?key=${AppConstants.googleMapsApiKey}&maxHeightPx=400&maxWidthPx=400';
  }
}
