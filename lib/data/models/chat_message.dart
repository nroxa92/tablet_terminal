// FILE: lib/data/models/chat_message.dart
// OPIS: Model jedne poruke u chatu.
// NADOGRADNJA: Dodana podrška za listu mjesta (kartice restorana).

import 'place.dart';

class ChatMessage {
  final String text;
  final bool isUser; // true = Gost, false = AI
  final DateTime timestamp;

  // NOVO: Opcionalna lista mjesta (za Gastro agenta)
  final List<Place>? places;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.places, // Nije obavezno
  });
}
