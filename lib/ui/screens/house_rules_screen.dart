// FILE: lib/ui/screens/house_rules_screen.dart
// OPIS: Prikaz kućnih pravila s potpisom gosta.
// VERZIJA: 3.1 - Fixed imports
// NAPOMENA: Potpis se šalje u Firebase Storage, URL u Firestore

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../data/services/storage_service.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/signature_storage_service.dart';
import '../../utils/translations.dart';

class HouseRulesScreen extends StatefulWidget {
  const HouseRulesScreen({super.key});

  @override
  State<HouseRulesScreen> createState() => _HouseRulesScreenState();
}

class _HouseRulesScreenState extends State<HouseRulesScreen> {
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.white,
    exportBackgroundColor: Colors.transparent,
  );

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();

  bool _isLoading = true;
  bool _isSaving = false;
  String _rulesText = "";
  String _villaName = "";
  String? _bookingId; // ⭐ NOVO: Booking ID za povezivanje

  // ═══════════════════════════════════════════════════════
  // UVJETI ZA GUMB
  // ═══════════════════════════════════════════════════════
  bool _hasScrolledToEnd = false;
  bool _timerStarted = false;
  bool _timerCompleted = false;
  int _secondsRemaining = 40;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _loadHouseRules();

    // Slušamo potpis za ažuriranje UI-a
    _signatureController.addListener(() {
      if (mounted) setState(() {});
    });

    // Slušamo scroll za provjeru je li došao do kraja
    _scrollController.addListener(_checkScrollPosition);

    // Slušamo fokus na ime polje - pokreće timer
    _firstNameFocus.addListener(_onNameFocus);
    _lastNameFocus.addListener(_onNameFocus);

    // Prepopuniraj ime gosta ako postoji iz booking-a
    final guestName = StorageService.getGuestName();
    if (guestName.isNotEmpty) {
      final parts = guestName.split(' ');
      if (parts.isNotEmpty) _firstNameController.text = parts.first;
      if (parts.length > 1) {
        _lastNameController.text = parts.sublist(1).join(' ');
      }
    }
  }

  void _onNameFocus() {
    if (_firstNameFocus.hasFocus || _lastNameFocus.hasFocus) {
      _startTimerIfNeeded();
    }
  }

  void _startTimerIfNeeded() {
    if (_timerStarted) return;

    setState(() => _timerStarted = true);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        if (mounted) setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        if (mounted) setState(() => _timerCompleted = true);
      }
    });
  }

  void _checkScrollPosition() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      if (currentScroll >= maxScroll - 20) {
        if (!_hasScrolledToEnd) {
          setState(() => _hasScrolledToEnd = true);
        }
      }
    }
  }

  void _checkIfScrollNeeded() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        if (maxScroll <= 0) {
          setState(() => _hasScrolledToEnd = true);
        }
      }
    });
  }

  Future<void> _loadHouseRules() async {
    _villaName = StorageService.getVillaName();
    
    // ⭐ NOVO: Dohvati booking ID
    _bookingId = StorageService.getBookingId();
    
    // Ako nema u storage-u, probaj dohvatiti iz Firestore
    if (_bookingId == null || _bookingId!.isEmpty) {
      _bookingId = await FirestoreService.getCurrentBookingId();
      if (_bookingId != null) {
        await StorageService.setBookingId(_bookingId!);
      }
    }
    
    debugPrint('📋 House Rules - Booking ID: $_bookingId');

    // Dohvati pravila iz lokalnog storage-a (cached s WEB PANELA)
    final String languageCode = StorageService.getLanguage();
    String rules = StorageService.getHouseRules(languageCode);

    // Ako nema cached pravila, probaj sync
    if (rules.isEmpty) {
      try {
        await FirestoreService.syncAllData();
        rules = StorageService.getHouseRules(languageCode);
      } catch (e) {
        debugPrint("Error syncing house rules: $e");
      }
    }

    // Fallback ako vlasnik nije definirao pravila
    if (rules.isEmpty) {
      rules = _getDefaultRules(languageCode);
    }

    if (mounted) {
      setState(() {
        _rulesText = rules;
        _isLoading = false;
      });
      _checkIfScrollNeeded();
    }
  }

  String _getDefaultRules(String lang) {
    switch (lang) {
      case 'hr':
        return '''
# Kućna Pravila

Dobrodošli! Molimo vas da poštujete sljedeća pravila:

## Noćni mir
- Od 23:00 do 07:00 molimo održavajte tišinu

## Pušenje
- Pušenje je dozvoljeno samo na balkonu/terasi

## Kućni ljubimci
- Molimo kontaktirajte domaćina unaprijed

## Check-out
- Molimo napustite smještaj do 10:00

Hvala vam i ugodan boravak!
''';
      case 'de':
        return '''
# Hausregeln

Willkommen! Bitte beachten Sie folgende Regeln:

## Nachtruhe
- Von 23:00 bis 07:00 Uhr bitte Ruhe bewahren

## Rauchen
- Rauchen nur auf dem Balkon/Terrasse erlaubt

## Haustiere
- Bitte kontaktieren Sie den Gastgeber vorab

## Check-out
- Bitte verlassen Sie die Unterkunft bis 10:00 Uhr

Vielen Dank und angenehmen Aufenthalt!
''';
      default:
        return '''
# House Rules

Welcome! Please respect the following rules:

## Quiet Hours
- From 23:00 to 07:00 please maintain silence

## Smoking
- Smoking is allowed only on the balcony/terrace

## Pets
- Please contact the host in advance

## Check-out
- Please leave the accommodation by 10:00

Thank you and enjoy your stay!
''';
    }
  }

  // ═══════════════════════════════════════════════════════
  // SVI UVJETI MORAJU BITI ISPUNJENI
  // ═══════════════════════════════════════════════════════
  bool get _canProceed {
    return _hasScrolledToEnd &&
        _timerCompleted &&
        _firstNameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty &&
        _signatureController.isNotEmpty;
  }

  String get _fullName {
    return '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
  }

  Future<void> _submitSignature() async {
    if (!_canProceed) return;

    setState(() => _isSaving = true);

    try {
      final signatureBytes = await _signatureController.toPngBytes();
      final guestName = _fullName;

      if (signatureBytes != null) {
        // ⭐ NOVO: Koristi Firebase Storage umjesto base64
        if (_bookingId != null && _bookingId!.isNotEmpty) {
          // Spremi u Storage + Firestore s booking_id
          await SignatureStorageService.saveSignatureWithBooking(
            signatureBytes: signatureBytes,
            bookingId: _bookingId!,
            guestName: guestName,
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            rulesVersion: _rulesText.hashCode.toString(),
          );
        } else {
          // Fallback: ako nema booking_id, koristi staru metodu
          debugPrint('⚠️ No booking ID - using legacy signature save');
          await FirestoreService.saveHouseRulesSignature(signatureBytes);
        }

        // Spremi ime gosta lokalno
        await StorageService.setGuestName(guestName);

        // Označi welcome flow završen
        await StorageService.setWelcomeDone();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(Translations.t('rules_accepted')),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // Idemo na skeniranje dokumenata
          Navigator.pushNamed(context, '/checkin_intro');
        }
      }
    } catch (e) {
      debugPrint("❌ Error saving signature: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${Translations.t('error')}: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _signatureController.dispose();
    _scrollController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      // FIX KEYBOARD OVERFLOW
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Row(
          children: [
            // ═══════════════════════════════════════════════════════
            // LIJEVA STRANA: TEKST PRAVILA (IZ WEB PANELA)
            // ═══════════════════════════════════════════════════════
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.gavel,
                            color: Color(0xFFD4AF37),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Translations.t('house_rules_title'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _villaName,
                                style: const TextStyle(
                                  color: Color(0xFFD4AF37),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Scroll indicator
                    if (!_hasScrolledToEnd)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Colors.orange.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_downward,
                                color: Colors.orange, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              Translations.t('scroll_to_read'),
                              style: const TextStyle(
                                  color: Colors.orange, fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Rules text (scrollable)
                    Expanded(
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFFD4AF37)))
                          : Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _hasScrolledToEnd
                                      ? const Color(0xFFD4AF37)
                                          .withValues(alpha: 0.5)
                                      : Colors.white10,
                                  width: _hasScrolledToEnd ? 2 : 1,
                                ),
                              ),
                              child: Scrollbar(
                                controller: _scrollController,
                                thumbVisibility: true,
                                child: SingleChildScrollView(
                                  controller: _scrollController,
                                  child: MarkdownBody(
                                    data: _rulesText,
                                    styleSheet: MarkdownStyleSheet(
                                      p: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 15,
                                        height: 1.6,
                                      ),
                                      h1: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      h2: const TextStyle(
                                        color: Color(0xFFD4AF37),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      listBullet: const TextStyle(
                                          color: Color(0xFFD4AF37)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),

            // ═══════════════════════════════════════════════════════
            // DESNA STRANA: IME + POTPIS
            // ═══════════════════════════════════════════════════════
            Container(
              width: 380,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                ),
              ),
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Icon(Icons.edit_document,
                          color: Color(0xFFD4AF37), size: 24),
                      const SizedBox(width: 12),
                      Text(
                        Translations.t('guest_signature'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    Translations.t('house_rules_subtitle'),
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),

                  const SizedBox(height: 24),

                  // ⭐ IME (First Name)
                  Text(
                    Translations.t('field_first_name'),
                    style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _firstNameController,
                    focusNode: _firstNameFocus,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: Translations.t('field_first_name'),
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.3),
                      prefixIcon:
                          Icon(Icons.person, color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFFD4AF37)),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 16),

                  // ⭐ PREZIME (Last Name)
                  Text(
                    Translations.t('field_last_name'),
                    style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _lastNameController,
                    focusNode: _lastNameFocus,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: Translations.t('field_last_name'),
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.3),
                      prefixIcon:
                          Icon(Icons.person_outline, color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFFD4AF37)),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),

                  // POTPIS
                  Text(
                    Translations.t('signature'),
                    style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _signatureController.isNotEmpty
                              ? const Color(0xFFD4AF37)
                              : Colors.white24,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: [
                            Signature(
                              controller: _signatureController,
                              backgroundColor: Colors.transparent,
                            ),
                            // Watermark kad je prazan
                            if (_signatureController.isEmpty)
                              Positioned.fill(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.draw,
                                          color: Colors.white
                                              .withValues(alpha: 0.1),
                                          size: 50),
                                      const SizedBox(height: 10),
                                      Text(
                                        Translations.t('sign_here'),
                                        style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.2),
                                            fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Clear button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _signatureController.clear(),
                      icon: const Icon(Icons.clear,
                          color: Colors.grey, size: 16),
                      label: Text(Translations.t('clear'),
                          style: const TextStyle(color: Colors.grey)),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ⭐ Submit button S COUNTDOWN-OM
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: (_canProceed && !_isSaving)
                          ? _submitSignature
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: Colors.grey[800],
                        disabledForegroundColor: Colors.grey[500],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSaving
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.black, strokeWidth: 2)),
                                SizedBox(width: 12),
                                Text("Saving...",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                    _canProceed
                                        ? Icons.check
                                        : Icons.hourglass_empty,
                                    size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  _canProceed
                                      ? Translations.t('agree_continue')
                                      : _getButtonHint(),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                // ⭐ COUNTDOWN BADGE
                                if (_timerStarted && !_timerCompleted) ...[
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.black.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "$_secondsRemaining s",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getButtonHint() {
    if (!_hasScrolledToEnd) {
      return "↓ Scroll first";
    }
    if (!_timerStarted) {
      return Translations.t('enter_name_first');
    }
    if (!_timerCompleted) {
      return "Please wait...";
    }
    if (_firstNameController.text.trim().isEmpty) {
      return Translations.t('field_first_name');
    }
    if (_lastNameController.text.trim().isEmpty) {
      return Translations.t('field_last_name');
    }
    return Translations.t('please_sign');
  }
}