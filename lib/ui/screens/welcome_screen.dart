// FILE: lib/ui/screens/welcome_screen.dart
// OPIS: Početni ekran za odabir jezika.
// VERZIJA: 2.5 - Dodan hidden kiosk exit trigger
// DATUM: 2025-01-10

import 'package:flutter/material.dart';
import 'package:flag/flag.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/services/storage_service.dart';
import '../widgets/welcome_message_overlay.dart';
import '../widgets/kiosk_exit_dialog.dart'; // 🆕 DODANO

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // SVI JEZICI - SORTIRANI PO ABC
    final List<Map<String, String>> languages = [
      {'code': 'CZ', 'name': 'Čeština', 'locale': 'cs'},
      {'code': 'DE', 'name': 'Deutsch', 'locale': 'de'},
      {'code': 'GB', 'name': 'English', 'locale': 'en'},
      {'code': 'ES', 'name': 'Español', 'locale': 'es'},
      {'code': 'FR', 'name': 'Français', 'locale': 'fr'},
      {'code': 'HR', 'name': 'Hrvatski', 'locale': 'hr'},
      {'code': 'IT', 'name': 'Italiano', 'locale': 'it'},
      {'code': 'HU', 'name': 'Magyar', 'locale': 'hu'},
      {'code': 'PL', 'name': 'Polski', 'locale': 'pl'},
      {'code': 'SK', 'name': 'Slovenčina', 'locale': 'sk'},
      {'code': 'SI', 'name': 'Slovenščina', 'locale': 'sl'},
    ];

    // PopScope: ONEMOGUĆAVA BACK TIPKU (Kiosk Mode)
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          // 🆕 PROMIJENJENO: Stack umjesto Container
          children: [
            // ════════════════════════════════════════════════════════
            // GLAVNI SADRŽAJ (postojeći kod)
            // ════════════════════════════════════════════════════════
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF121212),
                    Color(0xFF1E1E1E),
                  ],
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // HEADER
                      FadeInDown(
                        duration: const Duration(milliseconds: 800),
                        child: Column(
                          children: [
                            // LOGO ICON
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFD4AF37),
                                    Color(0xFFB8941F)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFD4AF37)
                                        .withValues(alpha: 0.3),
                                    blurRadius: 25,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.villa,
                                size: 50,
                                color: Colors.black,
                              ),
                            ),

                            const SizedBox(height: 25),

                            // TITLE
                            Text(
                              "VILLA CONCIERGE",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 4,
                                foreground: Paint()
                                  ..shader = const LinearGradient(
                                    colors: [
                                      Color(0xFFD4AF37),
                                      Color(0xFFFFD700)
                                    ],
                                  ).createShader(
                                      const Rect.fromLTWH(0, 0, 300, 40)),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // SUBTITLE
                            Text(
                              "Please select your language",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 50),

                      // LANGUAGE GRID
                      FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        duration: const Duration(milliseconds: 800),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 900),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            alignment: WrapAlignment.center,
                            children: languages.map((lang) {
                              return _buildLanguageCard(context, lang);
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 50),

                      // FOOTER
                      FadeInUp(
                        delay: const Duration(milliseconds: 600),
                        child: Text(
                          "Powered by VillaOS",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ════════════════════════════════════════════════════════
            // 🆕 HIDDEN KIOSK EXIT TRIGGER (gornji desni kut)
            // ════════════════════════════════════════════════════════
            // 7x tap u kutu otvara PIN dialog
            // Gost ne zna da je tu, ali vlasnik/čistačica znaju
            Positioned(
              top: 0,
              right: 0,
              child: HiddenKioskExitTrigger(
                requiredTaps: 7,
                resetDuration: const Duration(seconds: 3),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.transparent, // Potpuno nevidljivo!
                ),
              ),
            ),

            // ════════════════════════════════════════════════════════
            // 🆕 DRUGI HIDDEN TRIGGER (donji lijevi kut) - backup
            // ════════════════════════════════════════════════════════
            Positioned(
              bottom: 0,
              left: 0,
              child: HiddenKioskExitTrigger(
                requiredTaps: 10, // Više tapova za backup
                resetDuration: const Duration(seconds: 5),
                child: Container(
                  width: 60,
                  height: 60,
                  color: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard(BuildContext context, Map<String, String> lang) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectLanguage(context, lang),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 130,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // FLAG
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: ClipOval(
                  child: Flag.fromString(
                    lang['code']!,
                    height: 45,
                    width: 45,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // NAME
              Text(
                lang['name']!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Dohvaća prevedenu welcome poruku za odabrani jezik
  Future<String> _getWelcomeMessage(String locale) async {
    try {
      final ownerId = StorageService.getOwnerId();
      if (ownerId == null || ownerId.isEmpty) return '';

      final doc = await FirebaseFirestore.instance
          .collection('settings')
          .doc(ownerId)
          .get();

      if (!doc.exists || doc.data() == null) return '';

      final data = doc.data()!;

      // 1. Pokušaj dohvatiti prijevod za odabrani jezik
      final translations =
          data['welcomeMessageTranslations'] as Map<String, dynamic>?;
      if (translations != null && translations.containsKey(locale)) {
        final translated = translations[locale];
        if (translated != null && translated.toString().isNotEmpty) {
          return translated.toString();
        }
      }

      // 2. Fallback na default welcomeMessage
      return data['welcomeMessage']?.toString() ?? '';
    } catch (e) {
      debugPrint("Error loading welcome message: $e");
      return '';
    }
  }

  /// Odabir jezika → prikaži welcome popup → navigacija
  Future<void> _selectLanguage(
      BuildContext context, Map<String, String> lang) async {
    debugPrint("🌍 Language selected: ${lang['name']} (${lang['locale']})");

    final locale = lang['locale']!;

    // 1. SPREMI ODABRANI JEZIK
    await StorageService.setLanguage(locale);

    // 2. OZNAČI DA JE WELCOME ZAVRŠEN
    await StorageService.setWelcomeDone();

    // 3. POSTAVI CHECK-IN STATUS NA PENDING
    await StorageService.setCheckInStatus('pending');

    // 4. DOHVATI PREVEDENU WELCOME MESSAGE
    final welcomeMessage = await _getWelcomeMessage(locale);

    // 5. PRIKAŽI WELCOME MESSAGE POPUP (ako postoji poruka)
    if (welcomeMessage.isNotEmpty && context.mounted) {
      await WelcomeMessageOverlay.show(
        context: context,
        message: welcomeMessage,
        duration: 30,
      );
    }

    // 6. NAVIGACIJA NA KUĆNA PRAVILA
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/house_rules');
    }
  }
}
