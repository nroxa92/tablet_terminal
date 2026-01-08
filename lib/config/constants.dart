// FILE: lib/config/constants.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AppConstants {
  // Prazno na početku, puni se iz baze
  static String geminiApiKey = "";
  static String googleMapsApiKey = "";

  // Model (možeš ga mijenjati u bazi ako dodaš polje 'gemini_model')
  static String geminiModel = "gemini-pro";

  static Future<void> loadFromFirebase() async {
    try {
      debugPrint("🔑 Loading API keys from Firestore...");

      final doc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('api_keys')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;

        // PAZI: Imena polja moraju biti ISTA kao na tvojoj slici!
        geminiApiKey = data['gemini_api_key'] ?? "";
        googleMapsApiKey =
            data['Maps_api_key'] ?? ""; // Veliko M, kako je u bazi

        if (data.containsKey('gemini_model')) {
          geminiModel = data['gemini_model'];
        }

        debugPrint("✅ API Keys loaded successfully!");
      } else {
        debugPrint("⚠️ API Config document 'api_keys' not found!");
      }
    } catch (e) {
      debugPrint("❌ Error loading API keys: $e");
    }
  }
}
