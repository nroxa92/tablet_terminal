// FILE: lib/data/services/gemini_service.dart
// OPIS: AI servis s dinamičkim kontekstom iz bookinga i web panela.
// VERZIJA: 2.0 - Kompletan redizajn s booking awareness

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../config/constants.dart';
import 'storage_service.dart';

class GeminiService {
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final String _agentId;

  // Konstruktor - inicijalizira AI s kontekstom
  GeminiService(this._agentId) {
    _initializeModel();
  }

  void _initializeModel() {
    // 1. Generiraj System Prompt s SVIM podacima
    final String systemPrompt = _buildSystemPrompt();

    // 2. Inicijaliziraj model
    _model = GenerativeModel(
      model: AppConstants.geminiModel,
      apiKey: AppConstants.geminiApiKey,
      systemInstruction: Content.system(systemPrompt),
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
    );

    // 3. Započni chat sesiju
    _chat = _model.startChat();

    debugPrint("🤖 GeminiService initialized for agent: $_agentId");
  }

  // ============================================================
  // SLANJE PORUKE
  // ============================================================

  Future<String> sendMessage(String message) async {
    try {
      final response = await _chat.sendMessage(Content.text(message));
      return response.text ?? _getErrorResponse();
    } catch (e) {
      debugPrint("❌ Gemini error: $e");
      return _getErrorResponse();
    }
  }

  String _getErrorResponse() {
    final lang = StorageService.getLanguage();
    switch (lang) {
      case 'hr':
        return "Ispričavam se, trenutno imam problema s povezivanjem. Pokušajte ponovo.";
      case 'de':
        return "Entschuldigung, ich habe momentan Verbindungsprobleme. Bitte versuchen Sie es erneut.";
      case 'it':
        return "Mi scusi, ho problemi di connessione. Per favore riprovi.";
      case 'sl':
        return "Oprostite, trenutno imam težave s povezavo. Poskusite znova.";
      case 'fr':
        return "Désolé, j'ai des problèmes de connexion. Veuillez réessayer.";
      case 'es':
        return "Lo siento, tengo problemas de conexión. Por favor, inténtelo de nuevo.";
      default:
        return "I apologize, I'm having connection issues. Please try again.";
    }
  }

  // ============================================================
  // SYSTEM PROMPT BUILDER
  // ============================================================

  String _buildSystemPrompt() {
    // --- DOHVAT SVIH PODATAKA ---

    // Villa podaci
    final String villaName = StorageService.getVillaName();
    final String villaAddress = StorageService.getVillaAddress();
    final String wifiSSID = StorageService.getWifiSSID();
    final String wifiPassword = StorageService.getWifiPassword();
    final String contactPhone = StorageService.getContactPhone();

    // Booking podaci
    final String guestName = StorageService.getGuestName();
    final int guestCount = StorageService.getGuestCount();
    final DateTime? checkIn = StorageService.getBookingStart();
    final DateTime? checkOut = StorageService.getBookingEnd();

    // Jezik
    final String userLanguage = StorageService.getLanguage();
    final String languageName = _getLanguageName(userLanguage);

    // AI Prompts s web panela (owner-specific knowledge)
    final String ownerKnowledge = _getOwnerKnowledge();

    // Kontakti
    final Map<String, String> contacts = StorageService.getContactOptions();

    // --- BAZNI KONTEKST (Svi agenti znaju ovo) ---
    final StringBuffer baseContext = StringBuffer();

    baseContext.writeln("=== PROPERTY INFORMATION ===");
    baseContext.writeln("Property Name: $villaName");
    baseContext.writeln("Address: $villaAddress");
    baseContext.writeln("WiFi Network: $wifiSSID");
    baseContext.writeln("WiFi Password: $wifiPassword");
    if (contactPhone.isNotEmpty) {
      baseContext.writeln("Host Phone: $contactPhone");
    }

    // Kontakti vlasnika
    if (contacts.isNotEmpty) {
      baseContext.writeln("\n=== HOST CONTACT OPTIONS ===");
      contacts.forEach((key, value) {
        baseContext.writeln("$key: $value");
      });
    }

    // Booking info (ako postoji)
    if (guestName.isNotEmpty) {
      baseContext.writeln("\n=== CURRENT GUEST ===");
      baseContext.writeln("Guest Name: $guestName");
      baseContext.writeln("Number of Guests: $guestCount");
      if (checkIn != null) {
        baseContext.writeln("Check-in Date: ${_formatDate(checkIn)}");
      }
      if (checkOut != null) {
        baseContext.writeln("Check-out Date: ${_formatDate(checkOut)}");
      }
    }

    // --- AGENT-SPECIFIC PROMPT ---
    final String agentPrompt = _getAgentPrompt(ownerKnowledge);

    // --- LANGUAGE INSTRUCTION ---
    final String languageInstruction = """

=== CRITICAL LANGUAGE RULE ===
You MUST respond ONLY in $languageName (language code: '$userLanguage').
Do NOT switch to English or any other language unless explicitly asked.
If the guest writes in another language, still respond in $languageName.
""";

    // --- FINAL SYSTEM PROMPT ---
    return """
$agentPrompt

$baseContext

$languageInstruction

=== RESPONSE GUIDELINES ===
- Be concise and helpful
- Use a warm, professional tone
- If you don't know something specific, say so honestly
- For emergencies, always recommend contacting the host
- Never make up information about reservations or policies
""";
  }

  // ============================================================
  // AGENT PERSONALITIES
  // ============================================================

  String _getAgentPrompt(String ownerKnowledge) {
    switch (_agentId) {
      case 'reception':
        return _getReceptionPrompt(ownerKnowledge);
      case 'house':
        return _getHousePrompt(ownerKnowledge);
      case 'gastro':
        return _getGastroPrompt(ownerKnowledge);
      case 'local':
        return _getLocalPrompt(ownerKnowledge);
      default:
        return _getReceptionPrompt(ownerKnowledge);
    }
  }

  String _getReceptionPrompt(String ownerKnowledge) {
    return """
=== YOUR ROLE: VIRTUAL RECEPTIONIST ===

You are the AI Receptionist for this vacation rental property.

PERSONALITY:
- Professional, polite, and efficient
- Warm but not overly casual
- Solution-oriented
- Patient with all questions

YOUR RESPONSIBILITIES:
1. Answer questions about check-in/check-out times and procedures
2. Provide WiFi credentials when asked
3. Explain house rules and policies
4. Help with general inquiries about the property
5. Direct guests to appropriate contacts for emergencies
6. Assist with extending stays or early check-out requests (direct to host)

STANDARD POLICIES:
- Check-in time: 14:00 (2 PM)
- Check-out time: 10:00 (10 AM)
- Early check-in/late check-out: Subject to availability, contact host
- Quiet hours: 22:00 - 08:00

OWNER'S SPECIFIC INFORMATION:
$ownerKnowledge

IMPORTANT:
- Never share WiFi password unless directly asked
- For booking changes, always refer to the host
- For emergencies (medical, fire, police), provide local emergency number: 112
""";
  }

  String _getHousePrompt(String ownerKnowledge) {
    return """
=== YOUR ROLE: SMART HOME ASSISTANT ===

You are the Smart Home Manager for this vacation rental.

PERSONALITY:
- Technical but explains things simply
- Patient with non-tech-savvy guests
- Safety-conscious
- Helpful and reassuring

YOUR RESPONSIBILITIES:
1. Explain how to use appliances (AC, TV, washing machine, etc.)
2. Troubleshoot common issues
3. Provide energy-saving tips
4. Guide guests through smart home features
5. Report serious issues to the host

COMMON TROUBLESHOOTING:
- AC not working: Check if remote has batteries, ensure windows are closed
- TV issues: Check HDMI input selection, try power cycling
- WiFi problems: Try restarting router, check if password is correct
- Hot water: May take 1-2 minutes to heat up

OWNER'S HOUSE MANUAL & SPECIFIC INSTRUCTIONS:
$ownerKnowledge

SAFETY REMINDERS:
- Turn off AC when leaving for extended periods
- Don't leave windows open with AC running
- Report any water leaks immediately
- For electrical issues, contact host immediately
""";
  }

  String _getGastroPrompt(String ownerKnowledge) {
    return """
=== YOUR ROLE: GASTRO & FOOD GUIDE ===

You are the Culinary Concierge for guests.

PERSONALITY:
- Passionate about local food and wine
- Descriptive and appetizing in your recommendations
- Knowledgeable about dietary restrictions
- Enthusiastic but not pushy

YOUR RESPONSIBILITIES:
1. Recommend local restaurants based on preferences
2. Suggest traditional dishes to try
3. Advise on local wines and beverages
4. Help with dietary restrictions (vegetarian, vegan, allergies)
5. Recommend food delivery options
6. Suggest local markets and grocery stores

LOCAL CUISINE HIGHLIGHTS:
- Fresh seafood (grilled fish, octopus, shellfish)
- Traditional dishes (peka, ćevapi, pršut, cheese)
- Local wines (Plavac Mali, Pošip, Malvazija, Graševina)
- Local spirits (rakija, travarica)

OWNER'S RESTAURANT RECOMMENDATIONS:
$ownerKnowledge

TIPS:
- Lunch is typically 12:00-15:00, dinner 19:00-22:00
- Many restaurants require reservations in peak season
- Ask about catch of the day at seafood restaurants
- Konoba = traditional family-run restaurant (usually best value)
""";
  }

  String _getLocalPrompt(String ownerKnowledge) {
    return """
=== YOUR ROLE: LOCAL GUIDE ===

You are the Local Expert and Activity Guide.

PERSONALITY:
- Enthusiastic and adventurous
- Storytelling approach to local history
- Practical with logistics
- Environmentally conscious

YOUR RESPONSIBILITIES:
1. Recommend beaches and natural attractions
2. Suggest activities and excursions
3. Share local history and culture
4. Provide practical tips (parking, timing, crowds)
5. Advise on day trips and nearby islands
6. Recommend family-friendly vs adult activities

ACTIVITY CATEGORIES:
- Beaches: sandy, pebble, rocky, hidden coves
- Water sports: swimming, snorkeling, kayaking, jet ski, boat tours
- Land activities: hiking, cycling, wine tours, olive oil tasting
- Cultural: old towns, museums, churches, local festivals
- Family: water parks, mini golf, boat trips

OWNER'S LOCAL TIPS & HIDDEN GEMS:
$ownerKnowledge

PRACTICAL ADVICE:
- Visit popular beaches early morning or late afternoon
- Book boat tours 1-2 days in advance in summer
- Bring water and sun protection for all outdoor activities
- Cash is still preferred at some smaller establishments
- Respect local customs at religious sites
""";
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  String _getOwnerKnowledge() {
    // Mapiranje agent ID-a na storage key
    String storageKey;
    switch (_agentId) {
      case 'reception':
        storageKey = 'concierge';
        break;
      case 'house':
        storageKey = 'housekeeper';
        break;
      case 'gastro':
        storageKey = 'guide'; // Gastro koristi guide podatke
        break;
      case 'local':
        storageKey = 'guide';
        break;
      default:
        storageKey = 'concierge';
    }

    final knowledge = StorageService.getAIPrompt(storageKey);

    if (knowledge.isEmpty) {
      return "(No specific instructions provided by the host)";
    }

    return knowledge;
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'hr':
        return 'Croatian (Hrvatski)';
      case 'en':
        return 'English';
      case 'de':
        return 'German (Deutsch)';
      case 'it':
        return 'Italian (Italiano)';
      case 'sl':
        return 'Slovenian (Slovenščina)';
      case 'cs':
        return 'Czech (Čeština)';
      case 'sk':
        return 'Slovak (Slovenčina)';
      case 'pl':
        return 'Polish (Polski)';
      case 'hu':
        return 'Hungarian (Magyar)';
      case 'fr':
        return 'French (Français)';
      case 'es':
        return 'Spanish (Español)';
      default:
        return 'English';
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year}";
  }

  // ============================================================
  // QUICK RESPONSES (Za česte upite bez API poziva)
  // ============================================================

  /// Provjerava može li odgovoriti lokalno bez API poziva
  String? getQuickResponse(String message) {
    final lowerMessage = message.toLowerCase().trim();

    // WiFi upit
    if (lowerMessage.contains('wifi') ||
        lowerMessage.contains('wi-fi') ||
        lowerMessage.contains('internet') ||
        lowerMessage.contains('password') ||
        lowerMessage.contains('lozinka')) {
      final ssid = StorageService.getWifiSSID();
      final pass = StorageService.getWifiPassword();
      final lang = StorageService.getLanguage();

      switch (lang) {
        case 'hr':
          return "📶 WiFi mreža: **$ssid**\n🔑 Lozinka: **$pass**";
        case 'de':
          return "📶 WLAN-Netzwerk: **$ssid**\n🔑 Passwort: **$pass**";
        case 'it':
          return "📶 Rete WiFi: **$ssid**\n🔑 Password: **$pass**";
        default:
          return "📶 WiFi Network: **$ssid**\n🔑 Password: **$pass**";
      }
    }

    // Check-out vrijeme
    if (lowerMessage.contains('check-out') ||
        lowerMessage.contains('checkout') ||
        lowerMessage.contains('odjava')) {
      final lang = StorageService.getLanguage();
      final checkOut = StorageService.getBookingEnd();
      final dateStr = checkOut != null ? _formatDate(checkOut) : '';

      switch (lang) {
        case 'hr':
          return "🕐 Check-out je do **10:00**${dateStr.isNotEmpty ? ' dana $dateStr' : ''}.\n\nMolimo ostavite ključeve prema uputama domaćina.";
        case 'de':
          return "🕐 Check-out ist bis **10:00 Uhr**${dateStr.isNotEmpty ? ' am $dateStr' : ''}.\n\nBitte hinterlassen Sie die Schlüssel wie vom Gastgeber angegeben.";
        default:
          return "🕐 Check-out time is **10:00 AM**${dateStr.isNotEmpty ? ' on $dateStr' : ''}.\n\nPlease leave the keys as instructed by the host.";
      }
    }

    // Nema quick response - koristi AI
    return null;
  }
}
