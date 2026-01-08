// FILE: lib/ui/widgets/place_card.dart
// OPIS: Kartica restorana/mjesta za Chat ekran.
// FIX: Popravljen URL za otvaranje Google Mapa. Sada koristi koordinate (ako postoje) ili Place ID.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:villa_ai_terminal/data/models/place.dart';
import 'package:villa_ai_terminal/data/services/places_service.dart';

class PlaceCard extends StatelessWidget {
  final Place place;

  const PlaceCard({super.key, required this.place});

  // Funkcija za otvaranje Google Mapsa
  Future<void> _openMap() async {
    // Konstruiramo robustan Google Maps URL
    final Uri url;

    if (place.latitude != null && place.longitude != null) {
      // Ako imamo koordinate (iz Taska 10), koristimo ih za najveću preciznost
      url = Uri.parse(
          "https://www.google.com/maps/search/?api=1&query=${place.latitude},${place.longitude}&query_place_id=${place.placeId}");
    } else {
      // Fallback: Tražimo po imenu i ID-u
      url = Uri.parse(
          "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(place.name)}&query_place_id=${place.placeId}");
    }

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint("Could not launch map for ${place.name}");
      }
    } catch (e) {
      debugPrint("Error launching map: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 15, bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. SLIKA
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 140,
              width: double.infinity,
              child: place.photoReference != null
                  ? Image.network(
                      PlacesService.getPhotoUrl(place.photoReference!),
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, _, __) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
          ),

          // 2. DETALJI
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "${place.rating} (${place.userRatingsTotal})",
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                    const Spacer(),
                    Text(
                      place.isOpen ? "OPEN" : "CLOSED",
                      style: TextStyle(
                        color: place.isOpen ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton.icon(
                    onPressed: _openMap,
                    icon: const Icon(Icons.map, size: 16),
                    label: const Text("Take me there"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.white.withValues(alpha: 0.1),
      child: const Center(
        child: Icon(Icons.location_on, color: Colors.grey, size: 40),
      ),
    );
  }
}
