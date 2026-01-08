// FILE: lib/data/services/weather_service.dart
// OPIS: Dohvaca vremenske podatke za lokaciju vile.
// FIX: Sada koristi DINAMICKE koordinate iz PlacesService umjesto hardkodiranih!

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'places_service.dart';

class WeatherService {
  // Cache za koordinate
  static double? _cachedLat;
  static double? _cachedLng;

  /// Dohvaca trenutne vremenske podatke za lokaciju vile
  static Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      // 1. DOHVATI KOORDINATE (iz PlacesService ili geocoding)
      await _ensureCoordinates();

      if (_cachedLat == null || _cachedLng == null) {
        debugPrint("Warning: Weather coordinates not available");
        return _fallbackData();
      }

      debugPrint("Weather: Fetching for $_cachedLat, $_cachedLng");

      // 2. ZOVI OPEN-METEO API (Besplatan, ne treba kljuc)
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$_cachedLat'
        '&longitude=$_cachedLng'
        '&current=temperature_2m,relative_humidity_2m,wind_speed_10m,wind_direction_10m,uv_index'
        '&daily=uv_index_max'
        '&timezone=auto'
        '&wind_speed_unit=kmh',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'];

        // 3. IZVUCI PODATKE
        String temp = current['temperature_2m']?.round().toString() ?? '--';
        String windSpeed =
            current['wind_speed_10m']?.round().toString() ?? '--';
        int windDir = (current['wind_direction_10m'] ?? 0).toInt();

        // UV Index - koristimo stvarni iz API-ja ako postoji
        double uvIndex = (current['uv_index'] ?? 0).toDouble();
        String uv = _formatUVIndex(uvIndex);

        // 4. TEMPERATURA MORA (procjena po mjesecu i lokaciji)
        String seaTemp = _estimateSeaTemperature();

        debugPrint("Weather loaded: ${temp}C, Wind: $windSpeed km/h, UV: $uv");

        return {
          'temp': temp,
          'sea_temp': seaTemp,
          'wind': windSpeed,
          'wind_dir': windDir,
          'uv': uv,
        };
      }

      throw "API Error: ${response.statusCode}";
    } catch (e) {
      debugPrint("Weather fetch failed: $e");
      return _fallbackData();
    }
  }

  /// Osigurava da imamo koordinate
  static Future<void> _ensureCoordinates() async {
    // Prvo provjeri cache
    if (_cachedLat != null && _cachedLng != null) return;

    // Probaj iz PlacesService (vec inicijalizirano?)
    if (PlacesService.lat != null && PlacesService.lng != null) {
      _cachedLat = PlacesService.lat;
      _cachedLng = PlacesService.lng;
      debugPrint(
          "Weather using PlacesService coords: $_cachedLat, $_cachedLng");
      return;
    }

    // Inicijaliziraj PlacesService ako nije
    await PlacesService.initializeLocation();

    if (PlacesService.lat != null && PlacesService.lng != null) {
      _cachedLat = PlacesService.lat;
      _cachedLng = PlacesService.lng;
      debugPrint(
          "Weather coords loaded via geocoding: $_cachedLat, $_cachedLng");
    }
  }

  /// Procjena temperature mora po mjesecu (Jadransko more)
  static String _estimateSeaTemperature() {
    final month = DateTime.now().month;

    // Jadransko more - prosjecne temperature
    switch (month) {
      case 1:
        return "12"; // Sijecanj
      case 2:
        return "11"; // Veljaca
      case 3:
        return "12"; // Ozujak
      case 4:
        return "14"; // Travanj
      case 5:
        return "18"; // Svibanj
      case 6:
        return "22"; // Lipanj
      case 7:
        return "25"; // Srpanj
      case 8:
        return "26"; // Kolovoz
      case 9:
        return "24"; // Rujan
      case 10:
        return "20"; // Listopad
      case 11:
        return "17"; // Studeni
      case 12:
        return "14"; // Prosinac
      default:
        return "20";
    }
  }

  /// Formatira UV indeks u citljiv tekst
  static String _formatUVIndex(double uv) {
    if (uv <= 2) return "Low";
    if (uv <= 5) return "Mod";
    if (uv <= 7) return "High";
    if (uv <= 10) return "V.High";
    return "Extreme";
  }

  /// Fallback podaci kad nema interneta
  static Map<String, dynamic> _fallbackData() {
    return {
      'temp': '--',
      'sea_temp': '--',
      'wind': '--',
      'wind_dir': 0,
      'uv': '--',
    };
  }

  /// Reset cache (kad se promijeni adresa vile)
  static void resetCache() {
    _cachedLat = null;
    _cachedLng = null;
    debugPrint("Weather cache reset");
  }
}
