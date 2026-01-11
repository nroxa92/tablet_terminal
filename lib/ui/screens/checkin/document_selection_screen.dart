// FILE: lib/ui/screens/checkin/document_selection_screen.dart
// OPIS: Odabir tipa dokumenta i države izdavanja prije skeniranja.
// VERZIJA: 2.1 - Landscape layout s OCR prezentacijom

import 'package:flutter/material.dart';
import 'package:flag/flag.dart';
import 'package:animate_do/animate_do.dart';

import '../../../data/services/storage_service.dart';
import '../../../utils/translations/translations.dart';

/// Konfiguracija države: kod, ime, treba li skenirati obje strane osobne
class CountryConfig {
  final String code;
  final String name;
  final bool idHasTwoSides;

  const CountryConfig(this.code, this.name, {this.idHasTwoSides = true});
}

class DocumentSelectionScreen extends StatefulWidget {
  const DocumentSelectionScreen({super.key});

  @override
  State<DocumentSelectionScreen> createState() =>
      _DocumentSelectionScreenState();
}

class _DocumentSelectionScreenState extends State<DocumentSelectionScreen> {
  late List<CountryConfig> _allCountries;
  CountryConfig? _selectedCountry;
  String? _selectedDocType;

  // Booking info
  int _guestCount = 1;

  @override
  void initState() {
    super.initState();
    _initCountries();
    _loadBookingInfo();
  }

  void _loadBookingInfo() {
    setState(() {
      _guestCount = StorageService.getGuestCount();
    });
  }

  void _initCountries() {
    _allCountries = const [
      // PRIORITETNE (Jadran turizam)
      CountryConfig('HR', 'Croatia', idHasTwoSides: true),
      CountryConfig('DE', 'Germany', idHasTwoSides: true),
      CountryConfig('AT', 'Austria', idHasTwoSides: true),
      CountryConfig('SI', 'Slovenia', idHasTwoSides: true),
      CountryConfig('IT', 'Italy', idHasTwoSides: true),
      CountryConfig('CZ', 'Czech Republic', idHasTwoSides: true),
      CountryConfig('PL', 'Poland', idHasTwoSides: true),
      CountryConfig('HU', 'Hungary', idHasTwoSides: true),
      CountryConfig('SK', 'Slovakia', idHasTwoSides: true),

      // ZAPADNA EUROPA
      CountryConfig('FR', 'France', idHasTwoSides: true),
      CountryConfig('NL', 'Netherlands', idHasTwoSides: true),
      CountryConfig('BE', 'Belgium', idHasTwoSides: true),
      CountryConfig('CH', 'Switzerland', idHasTwoSides: true),
      CountryConfig('GB', 'United Kingdom', idHasTwoSides: false),
      CountryConfig('IE', 'Ireland', idHasTwoSides: false),

      // SKANDINAVIJA
      CountryConfig('SE', 'Sweden', idHasTwoSides: true),
      CountryConfig('NO', 'Norway', idHasTwoSides: true),
      CountryConfig('DK', 'Denmark', idHasTwoSides: true),
      CountryConfig('FI', 'Finland', idHasTwoSides: true),

      // JUŽNA EUROPA
      CountryConfig('ES', 'Spain', idHasTwoSides: true),
      CountryConfig('PT', 'Portugal', idHasTwoSides: true),
      CountryConfig('GR', 'Greece', idHasTwoSides: true),

      // ISTOČNA EUROPA
      CountryConfig('RO', 'Romania', idHasTwoSides: true),
      CountryConfig('BG', 'Bulgaria', idHasTwoSides: true),
      CountryConfig('RS', 'Serbia', idHasTwoSides: true),
      CountryConfig('BA', 'Bosnia', idHasTwoSides: true),
      CountryConfig('ME', 'Montenegro', idHasTwoSides: true),
      CountryConfig('MK', 'North Macedonia', idHasTwoSides: true),
      CountryConfig('AL', 'Albania', idHasTwoSides: true),

      // BALTIK
      CountryConfig('LT', 'Lithuania', idHasTwoSides: true),
      CountryConfig('LV', 'Latvia', idHasTwoSides: true),
      CountryConfig('EE', 'Estonia', idHasTwoSides: true),

      // OSTALO
      CountryConfig('US', 'USA', idHasTwoSides: true),
      CountryConfig('CA', 'Canada', idHasTwoSides: false),
      CountryConfig('AU', 'Australia', idHasTwoSides: false),
      CountryConfig('RU', 'Russia', idHasTwoSides: true),
      CountryConfig('UA', 'Ukraine', idHasTwoSides: true),
      CountryConfig('TR', 'Turkey', idHasTwoSides: true),
      CountryConfig('IL', 'Israel', idHasTwoSides: true),
    ];

    _selectedCountry = _allCountries.first;
  }

  void _onStartScanning() {
    if (_selectedCountry == null || _selectedDocType == null) return;

    bool needsBackSide = (_selectedDocType == 'ID_CARD')
        ? _selectedCountry!.idHasTwoSides
        : false;

    Navigator.pushNamed(context, '/camera', arguments: {
      'needsBackSide': needsBackSide,
      'docType': _selectedDocType,
      'countryCode': _selectedCountry!.code,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Row(
          children: [
            // ═══════════════════════════════════════════════════════════
            // LIJEVA STRANA - OCR PREZENTACIJA
            // ═══════════════════════════════════════════════════════════
            Expanded(
              flex: 4,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A1A1A),
                      Color(0xFF0D0D0D),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Dekorativni krug
                    Positioned(
                      top: -50,
                      left: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFD4AF37).withValues(alpha: 0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(35),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Back button
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.1),
                            ),
                          ),

                          const Spacer(),

                          // OCR Ikona
                          FadeInLeft(
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFD4AF37),
                                    Color(0xFFB8941F)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFD4AF37)
                                        .withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.document_scanner,
                                size: 35,
                                color: Colors.black,
                              ),
                            ),
                          ),

                          const SizedBox(height: 25),

                          // Naslov
                          FadeInLeft(
                            delay: const Duration(milliseconds: 100),
                            child: Text(
                              _getLeftTitle(),
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Podnaslov
                          FadeInLeft(
                            delay: const Duration(milliseconds: 150),
                            child: Text(
                              _getLeftSubtitle(),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Feature 1 - Brzina
                          FadeInLeft(
                            delay: const Duration(milliseconds: 200),
                            child: _buildFeatureRow(
                              icon: Icons.bolt,
                              title: _getFeature1Title(),
                              subtitle: _getFeature1Subtitle(),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Feature 2 - Sigurnost
                          FadeInLeft(
                            delay: const Duration(milliseconds: 250),
                            child: _buildFeatureRow(
                              icon: Icons.shield_outlined,
                              title: _getFeature2Title(),
                              subtitle: _getFeature2Subtitle(),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Feature 3 - Privatnost
                          FadeInLeft(
                            delay: const Duration(milliseconds: 300),
                            child: _buildFeatureRow(
                              icon: Icons.auto_delete_outlined,
                              title: _getFeature3Title(),
                              subtitle: _getFeature3Subtitle(),
                            ),
                          ),

                          const Spacer(),

                          // eVisitor badge
                          FadeInUp(
                            delay: const Duration(milliseconds: 350),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.green.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.verified,
                                    color: Colors.green,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _getEvisitorBadge(),
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
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
            ),

            // ═══════════════════════════════════════════════════════════
            // DESNA STRANA - ODABIR DOKUMENTA
            // ═══════════════════════════════════════════════════════════
            Expanded(
              flex: 5,
              child: Container(
                color: const Color(0xFF121212),
                padding: const EdgeInsets.all(35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Guest count badge (top right)
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                const Color(0xFFD4AF37).withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.person,
                              color: Color(0xFFD4AF37),
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getGuestBadge(),
                              style: const TextStyle(
                                color: Color(0xFFD4AF37),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- 1. VRSTA DOKUMENTA ---
                    FadeInRight(
                      child: Text(
                        Translations.t('doc_type'),
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    FadeInRight(
                      delay: const Duration(milliseconds: 100),
                      child: Row(
                        children: [
                          _buildDocTypeCard(
                            title: Translations.t('doc_id_card'),
                            icon: Icons.credit_card,
                            type: 'ID_CARD',
                            subtitle: _selectedCountry?.idHasTwoSides == true
                                ? Translations.t('doc_id_sub')
                                : "Front only",
                          ),
                          const SizedBox(width: 15),
                          _buildDocTypeCard(
                            title: Translations.t('doc_passport'),
                            icon: Icons.menu_book,
                            type: 'PASSPORT',
                            subtitle: Translations.t('doc_passport_sub'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // --- 2. DRŽAVA IZDAVANJA ---
                    FadeInRight(
                      delay: const Duration(milliseconds: 150),
                      child: Text(
                        Translations.t('issuing_country'),
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    FadeInRight(
                      delay: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<CountryConfig>(
                            value: _selectedCountry,
                            dropdownColor: const Color(0xFF1E1E1E),
                            isExpanded: true,
                            menuMaxHeight: 300,
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFFD4AF37),
                            ),
                            items: _allCountries.map((country) {
                              return DropdownMenuItem(
                                value: country,
                                child: Row(
                                  children: [
                                    Flag.fromString(
                                      country.code,
                                      height: 20,
                                      width: 30,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        country.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    if (!country.idHasTwoSides)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green
                                              .withValues(alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          "1 side",
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) =>
                                setState(() => _selectedCountry = value),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // --- GUMB ZA KAMERU ---
                    FadeInUp(
                      delay: const Duration(milliseconds: 250),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _selectedDocType != null
                              ? _onStartScanning
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4AF37),
                            disabledBackgroundColor: Colors.grey[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: _selectedDocType != null ? 8 : 0,
                            shadowColor:
                                const Color(0xFFD4AF37).withValues(alpha: 0.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                color: _selectedDocType != null
                                    ? Colors.black
                                    : Colors.grey[600],
                              ),
                              const SizedBox(width: 10),
                              Text(
                                Translations.t('open_camera'),
                                style: TextStyle(
                                  color: _selectedDocType != null
                                      ? Colors.black
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Skip
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/dashboard',
                            (route) => false,
                          );
                        },
                        child: Text(
                          Translations.t('skip_btn'),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // WIDGETI
  // ═══════════════════════════════════════════════════════════

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFFD4AF37), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocTypeCard({
    required String title,
    required IconData icon,
    required String type,
    required String subtitle,
  }) {
    final bool isSelected = _selectedDocType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDocType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 100,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFD4AF37)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? const Color(0xFFD4AF37) : Colors.white10,
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    )
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.black : Colors.white,
                size: 26,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: isSelected ? Colors.black87 : Colors.grey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // PRIJEVODI - OCR TEMA
  // ═══════════════════════════════════════════════════════════

  String _getLeftTitle() {
    final lang = StorageService.getLanguage();
    if (lang == 'hr') return "Pametno\nskeniranje";
    return "Smart\nScanning";
  }

  String _getLeftSubtitle() {
    final lang = StorageService.getLanguage();
    if (lang == 'hr') return "AI tehnologija za brzu prijavu";
    return "AI technology for quick registration";
  }

  String _getFeature1Title() {
    final lang = StorageService.getLanguage();
    if (lang == 'hr') return "Očitavanje u sekundi";
    return "Read in seconds";
  }

  String _getFeature1Subtitle() {
    final lang = StorageService.getLanguage();
    if (lang == 'hr') return "OCR automatski prepoznaje sve podatke";
    return "OCR automatically recognizes all data";
  }

  String _getFeature2Title() {
    final lang = StorageService.getLanguage();
    if (lang == 'hr') return "Sigurna obrada";
    return "Secure processing";
  }

  String _getFeature2Subtitle() {
    final lang = StorageService.getLanguage();
    if (lang == 'hr') return "Šifrirani prijenos, GDPR sukladnost";
    return "Encrypted transfer, GDPR compliant";
  }

  String _getFeature3Title() {
    final lang = StorageService.getLanguage();
    if (lang == 'hr') return "Privatnost zajamčena";
    return "Privacy guaranteed";
  }

  String _getFeature3Subtitle() {
    final lang = StorageService.getLanguage();
    if (lang == 'hr') return "Slike se brišu odmah nakon očitanja";
    return "Images deleted immediately after reading";
  }

  String _getEvisitorBadge() {
    final lang = StorageService.getLanguage();
    if (lang == 'hr') return "eVisitor kompatibilno";
    return "eVisitor compatible";
  }

  String _getGuestBadge() {
    final lang = StorageService.getLanguage();
    if (lang == 'hr') return "GOST 1/$_guestCount";
    return "GUEST 1/$_guestCount";
  }
}
