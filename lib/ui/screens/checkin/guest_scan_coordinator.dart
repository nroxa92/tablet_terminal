// FILE: lib/ui/screens/checkin/guest_scan_coordinator.dart
// VERZIJA: 5.1 - AUTO-SCAN + FIKSNI LAYOUT + SUBCOLLECTION
//
// FEATURES:
// - AUTO-SCAN: Automatsko slikanje svakih 1.5s dok ne prepozna dokument
// - Stražnja kamera + fizičko zrcalo
// - Dropdown za države (umjesto grida)
// - Fiksni layout za 10" tablet (bez scrollanja)
// - SAMO stražnja strana dokumenta (MRZ)
// - ⭐ NOVO: Guests subcollection umjesto array
//
// POLJA:
// - Vrsta dokumenta, Ime, Prezime, Broj dok., Datum rođenja
// - Spol, Državljanstvo, Adresa, OIB (HR)
//
// GDPR: Slike se NE spremaju - brišu se odmah nakon OCR

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:camera/camera.dart';

import 'package:villa_ai_terminal/data/services/ocr_service.dart';
import 'package:villa_ai_terminal/data/services/firestore_service.dart';

// ═══════════════════════════════════════════════════════════════════════════
// GUEST MODEL
// ═══════════════════════════════════════════════════════════════════════════

class Guest {
  String firstName;
  String lastName;
  String dateOfBirth;
  String placeOfBirth;
  String countryOfBirth;
  String sex;
  String nationality;
  String documentType;
  String documentNumber;
  String issuingCountry;
  String residenceCountry;
  String residenceCity;
  String address;
  String oib;
  DateTime? arrivalDateTime;
  DateTime? departureDate;

  Guest({
    this.firstName = '',
    this.lastName = '',
    this.dateOfBirth = '',
    this.placeOfBirth = '',
    this.countryOfBirth = '',
    this.sex = '',
    this.nationality = '',
    this.documentType = '',
    this.documentNumber = '',
    this.issuingCountry = '',
    this.residenceCountry = '',
    this.residenceCity = '',
    this.address = '',
    this.oib = '',
    this.arrivalDateTime,
    this.departureDate,
  });

  bool get isComplete {
    return firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        documentNumber.isNotEmpty;
  }

  double get completionProgress {
    int filled = 0;
    int total = 6;
    if (firstName.isNotEmpty) filled++;
    if (lastName.isNotEmpty) filled++;
    if (dateOfBirth.isNotEmpty) filled++;
    if (documentNumber.isNotEmpty) filled++;
    if (address.isNotEmpty) filled++;
    if (oib.isNotEmpty || issuingCountry != 'HR') filled++;
    return filled / total;
  }

  List<String> get emptyFields {
    List<String> empty = [];
    if (firstName.isEmpty) empty.add('Ime');
    if (lastName.isEmpty) empty.add('Prezime');
    if (documentNumber.isEmpty) empty.add('Broj dokumenta');
    return empty;
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'placeOfBirth': placeOfBirth,
      'countryOfBirth': countryOfBirth,
      'sex': sex,
      'nationality': nationality,
      'documentType': documentType,
      'documentNumber': documentNumber,
      'issuingCountry': issuingCountry,
      'residenceCountry': residenceCountry,
      'residenceCity': residenceCity,
      'address': address,
      'oib': oib,
      'arrivalDateTime':
          arrivalDateTime != null ? Timestamp.fromDate(arrivalDateTime!) : null,
      'departureDate':
          departureDate != null ? Timestamp.fromDate(departureDate!) : null,
      'scannedAt': Timestamp.fromDate(DateTime.now()),
    };
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MAIN COORDINATOR
// ═══════════════════════════════════════════════════════════════════════════

class GuestScanCoordinator extends StatefulWidget {
  final String bookingId;
  final String unitId;

  const GuestScanCoordinator({
    super.key,
    required this.bookingId,
    required this.unitId,
  });

  @override
  State<GuestScanCoordinator> createState() => _GuestScanCoordinatorState();
}

class _GuestScanCoordinatorState extends State<GuestScanCoordinator> {
  int _guestCount = 1;
  DateTime _departureDate = DateTime.now().add(const Duration(days: 7));

  int _currentGuestIndex = 0;
  final List<Guest> _scannedGuests = [];

  String _currentPhase = 'selection';

  Guest _currentGuest = Guest();
  String _selectedDocType = 'ID_CARD';
  String _selectedCountry = 'HR';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookingData();
  }

  Future<void> _loadBookingData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _guestCount = data['guest_count'] ?? 1;
          if (data['end_date'] != null) {
            _departureDate = (data['end_date'] as Timestamp).toDate();
          }
          _isLoading = false;
        });
        debugPrint('📋 Booking: $_guestCount gostiju');
      } else {
        _showError('Booking nije pronađen');
      }
    } catch (e) {
      debugPrint('❌ Load booking error: $e');
      _showError('Greška pri učitavanju: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _onDocumentSelected(String docType, String country) {
    setState(() {
      _selectedDocType = docType;
      _selectedCountry = country;
      _currentGuest = Guest()
        ..documentType = docType
        ..issuingCountry = country
        ..arrivalDateTime = DateTime.now()
        ..departureDate = _departureDate;
      _currentPhase = 'scanning';
    });
  }

  void _onScanUpdate(Guest updatedGuest) {
    setState(() {
      _currentGuest = updatedGuest;
    });
  }

  void _onScanComplete() {
    setState(() {
      _currentPhase = 'confirmation';
    });
  }

  void _onGuestConfirmed(Guest guest) {
    setState(() {
      _scannedGuests.add(guest);
      _currentGuestIndex++;

      if (_currentGuestIndex < _guestCount) {
        _currentPhase = 'selection';
        _currentGuest = Guest();
      } else {
        _currentPhase = 'done';
        _saveAllGuests();
      }
    });
  }

  void _onBackToSelection() {
    setState(() {
      _currentPhase = 'selection';
      _currentGuest = Guest();
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ⭐ NOVA VERZIJA: Sprema goste u SUBCOLLECTION umjesto array
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _saveAllGuests() async {
    try {
      debugPrint('💾 Saving ${_scannedGuests.length} guests to subcollection...');
      
      final guestMaps = _scannedGuests.map((g) => g.toMap()).toList();

      // ⭐ NOVO: Koristi subcollection umjesto array
      await FirestoreService.saveAllGuestsToSubcollection(
        bookingId: widget.bookingId,
        guests: guestMaps,
      );

      debugPrint('✅ Svi gosti spremljeni u subcollection!');
      _navigateToDashboard();
    } catch (e) {
      debugPrint('❌ Save error: $e');
      _showError('Greška: $e');
    }
  }

  void _navigateToDashboard() {
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
        ),
      );
    }

    switch (_currentPhase) {
      case 'selection':
        return _DocumentSelectionWidget(
          guestNumber: _currentGuestIndex + 1,
          totalGuests: _guestCount,
          selectedDocType: _selectedDocType,
          selectedCountry: _selectedCountry,
          onContinue: _onDocumentSelected,
          onBack: () {
            if (_currentGuestIndex > 0) {
              setState(() {
                _scannedGuests.removeLast();
                _currentGuestIndex--;
              });
            } else {
              Navigator.pop(context);
            }
          },
        );

      case 'scanning':
        return _ScanningScreen(
          guest: _currentGuest,
          guestNumber: _currentGuestIndex + 1,
          totalGuests: _guestCount,
          countryCode: _selectedCountry,
          docType: _selectedDocType,
          onUpdate: _onScanUpdate,
          onComplete: _onScanComplete,
          onBack: _onBackToSelection,
        );

      case 'confirmation':
        return _ConfirmationWidget(
          guest: _currentGuest,
          guestNumber: _currentGuestIndex + 1,
          totalGuests: _guestCount,
          countryCode: _selectedCountry,
          onConfirm: _onGuestConfirmed,
          onRescan: () {
            setState(() {
              _currentGuest = Guest()
                ..documentType = _selectedDocType
                ..issuingCountry = _selectedCountry
                ..arrivalDateTime = DateTime.now()
                ..departureDate = _departureDate;
              _currentPhase = 'scanning';
            });
          },
        );

      case 'done':
        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Color(0xFFD4AF37)),
                const SizedBox(height: 24),
                Text(
                  'Spremanje podataka...',
                  style: TextStyle(color: Colors.grey[400], fontSize: 18),
                ),
              ],
            ),
          ),
        );

      default:
        return const SizedBox();
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DOCUMENT SELECTION WIDGET
// ═══════════════════════════════════════════════════════════════════════════

class _DocumentSelectionWidget extends StatefulWidget {
  final int guestNumber;
  final int totalGuests;
  final String selectedDocType;
  final String selectedCountry;
  final Function(String, String) onContinue;
  final VoidCallback onBack;

  const _DocumentSelectionWidget({
    required this.guestNumber,
    required this.totalGuests,
    required this.selectedDocType,
    required this.selectedCountry,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<_DocumentSelectionWidget> createState() =>
      _DocumentSelectionWidgetState();
}

class _DocumentSelectionWidgetState extends State<_DocumentSelectionWidget> {
  late String _docType;
  late String _country;

  static const List<Map<String, String>> _countries = [
    {'code': 'HR', 'name': 'Hrvatska', 'flag': '🇭🇷'},
    {'code': 'DE', 'name': 'Njemačka', 'flag': '🇩🇪'},
    {'code': 'AT', 'name': 'Austrija', 'flag': '🇦🇹'},
    {'code': 'IT', 'name': 'Italija', 'flag': '🇮🇹'},
    {'code': 'SI', 'name': 'Slovenija', 'flag': '🇸🇮'},
    {'code': 'HU', 'name': 'Mađarska', 'flag': '🇭🇺'},
    {'code': 'CZ', 'name': 'Češka', 'flag': '🇨🇿'},
    {'code': 'SK', 'name': 'Slovačka', 'flag': '🇸🇰'},
    {'code': 'PL', 'name': 'Poljska', 'flag': '🇵🇱'},
    {'code': 'GB', 'name': 'V. Britanija', 'flag': '🇬🇧'},
    {'code': 'FR', 'name': 'Francuska', 'flag': '🇫🇷'},
    {'code': 'NL', 'name': 'Nizozemska', 'flag': '🇳🇱'},
    {'code': 'BE', 'name': 'Belgija', 'flag': '🇧🇪'},
    {'code': 'ES', 'name': 'Španjolska', 'flag': '🇪🇸'},
    {'code': 'US', 'name': 'SAD', 'flag': '🇺🇸'},
    {'code': 'OTHER', 'name': 'Ostalo', 'flag': '🌍'},
  ];

  @override
  void initState() {
    super.initState();
    _docType = widget.selectedDocType;
    _country = widget.selectedCountry;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
          child: Row(
            children: [
              // LIJEVA STRANA - Naslov i info
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        IconButton(
                          onPressed: widget.onBack,
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'GOST ${widget.guestNumber} / ${widget.totalGuests}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    const Text(
                      'Odaberite\ndokument',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Vrstu dokumenta i državu izdavanja',
                      style: TextStyle(color: Colors.grey[500], fontSize: 16),
                    ),

                    const Spacer(flex: 2),
                  ],
                ),
              ),

              const SizedBox(width: 48),

              // DESNA STRANA - Forme
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // VRSTA DOKUMENTA
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'VRSTA DOKUMENTA',
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildDocTypeCard(
                            'ID_CARD', 'Osobna iskaznica', Icons.credit_card),
                        const SizedBox(width: 16),
                        _buildDocTypeCard(
                            'PASSPORT', 'Putovnica', Icons.menu_book),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // DRŽAVA - DROPDOWN
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'DRŽAVA IZDAVANJA',
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFD4AF37), width: 2),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _country,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1E1E1E),
                          icon: const Icon(Icons.keyboard_arrow_down,
                              color: Color(0xFFD4AF37)),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                          items: _countries.map((c) {
                            return DropdownMenuItem<String>(
                              value: c['code'],
                              child: Row(
                                children: [
                                  Text(c['flag']!,
                                      style: const TextStyle(fontSize: 24)),
                                  const SizedBox(width: 12),
                                  Text(c['name']!,
                                      style: const TextStyle(fontSize: 18)),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) setState(() => _country = value);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // GUMB
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: () => widget.onContinue(_docType, _country),
                        icon: const Icon(Icons.camera_alt, size: 28),
                        label: const Text(
                          'OTVORI KAMERU',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
    );
  }

  Widget _buildDocTypeCard(String type, String label, IconData icon) {
    bool selected = _docType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _docType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFD4AF37).withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? const Color(0xFFD4AF37) : Colors.white24,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected ? const Color(0xFFD4AF37) : Colors.white54,
                size: 36,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white70,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SCANNING SCREEN - LANDSCAPE LAYOUT + RUČNO SLIKANJE
// ═══════════════════════════════════════════════════════════════════════════

class _ScanningScreen extends StatefulWidget {
  final Guest guest;
  final int guestNumber;
  final int totalGuests;
  final String countryCode;
  final String docType;
  final Function(Guest) onUpdate;
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const _ScanningScreen({
    required this.guest,
    required this.guestNumber,
    required this.totalGuests,
    required this.countryCode,
    required this.docType,
    required this.onUpdate,
    required this.onComplete,
    required this.onBack,
  });

  @override
  State<_ScanningScreen> createState() => _ScanningScreenState();
}

class _ScanningScreenState extends State<_ScanningScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isProcessing = false;

  String _statusMessage = '';
  bool _showSuccess = false;

  late Guest _guest;
  final Map<String, bool> _detectedFields = {};

  // AUTO-SCAN
  Timer? _autoScanTimer;
  bool _autoScanEnabled = true;
  int _scanAttempts = 0;
  static const int _maxAttempts = 30; // Max 30 pokušaja

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _guest = widget.guest;
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    _autoScanTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _setStatus('Kamera nije pronađena');
        return;
      }

      // STRAŽNJA KAMERA - sa fizičkim zrcalom u kućištu
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      debugPrint(
          '📷 Using ${camera.lensDirection == CameraLensDirection.back ? "BACK" : "FRONT"} camera');

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() => _isInitialized = true);
        // Pokreni auto-scan nakon kratke pauze
        Future.delayed(const Duration(milliseconds: 500), _startAutoScan);
      }
    } catch (e) {
      debugPrint('❌ Camera init error: $e');
      _setStatus('Greška kamere: $e');
    }
  }

  void _setStatus(String message) {
    if (mounted) setState(() => _statusMessage = message);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTO-SCAN LOGIKA
  // ═══════════════════════════════════════════════════════════════════════════

  void _startAutoScan() {
    if (!_autoScanEnabled || !mounted) return;

    _autoScanTimer?.cancel();
    _autoScanTimer =
        Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!mounted || !_autoScanEnabled) {
        timer.cancel();
        return;
      }

      if (_scanAttempts >= _maxAttempts) {
        timer.cancel();
        _setStatus('⚠️ Automatsko skeniranje zaustavljeno. Kliknite SLIKAJ.');
        return;
      }

      _autoCapture();
    });

    _setStatus('🔄 Automatsko skeniranje...');
  }

  void _stopAutoScan() {
    _autoScanTimer?.cancel();
    _autoScanEnabled = false;
  }

  Future<void> _autoCapture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isProcessing) return;

    _scanAttempts++;

    setState(() {
      _isProcessing = true;
    });

    try {
      final XFile image = await _controller!.takePicture();

      debugPrint('═══════════════════════════════════════════');
      debugPrint('🤖 AUTO-SCAN #$_scanAttempts: ${image.path}');

      final data = await OCRService.scanDocument(
        imagePath: image.path,
        scanType: 'back',
        flipHorizontal: true,
      );

      // Obriši sliku odmah (GDPR)
      try {
        await File(image.path).delete();
      } catch (_) {}

      // Provjeri uspješnost
      final hasName = data['firstName'] != null || data['lastName'] != null;
      final hasDoc = data['documentNumber'] != null;

      if (hasName && hasDoc) {
        // USPJEH! Zaustavi auto-scan
        _stopAutoScan();
        debugPrint('✅ AUTO-SCAN USPJEŠAN!');
        _processOCRResult(data);
      } else {
        debugPrint('⏳ Auto-scan: Čekam bolji rezultat...');
        if (mounted) {
          setState(() =>
              _statusMessage = '🔄 Skeniram... ($_scanAttempts/$_maxAttempts)');
        }
      }
    } catch (e) {
      debugPrint('❌ Auto-scan error: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  /// RUČNO SLIKANJE
  Future<void> _captureAndProcess() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Obrađujem...';
    });

    try {
      final XFile image = await _controller!.takePicture();

      debugPrint('═══════════════════════════════════════════');
      debugPrint('📸 CAPTURED: ${image.path}');
      debugPrint('🔄 Side: BACK (MRZ)');

      // Pozovi OCR Service - UVIJEK stražnja strana
      // Fizičko zrcalo zrcali sliku → potreban softverski flip
      final data = await OCRService.scanDocument(
        imagePath: image.path,
        scanType: 'back', // Uvijek stražnja strana za MRZ
        flipHorizontal: true, // FIZIČKO ZRCALO = potreban flip!
      );

      // DEBUG
      debugPrint('╔═══════════════════════════════════════════╗');
      debugPrint('║           OCR REZULTATI                  ║');
      debugPrint('╠═══════════════════════════════════════════╣');
      data.forEach((key, value) {
        if (key != 'raw' && key != 'lines' && value != null) {
          debugPrint('║ $key: $value');
        }
      });
      debugPrint('╚═══════════════════════════════════════════╝');

      // Obriši temp sliku (GDPR) - NE SPREMAMO SLIKE!
      try {
        await File(image.path).delete();
        debugPrint('🗑️ Slika obrisana (GDPR)');
      } catch (_) {}

      // Procesiraj rezultate
      _processOCRResult(data);
    } catch (e) {
      debugPrint('❌ Capture error: $e');
      _setStatus('Greška: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _processOCRResult(Map<String, dynamic> data) {
    bool updated = false;

    // STRAŽNJA STRANA - MRZ podaci + adresa
    if (data['firstName'] != null && _guest.firstName.isEmpty) {
      _guest.firstName = data['firstName'].toString();
      _detectedFields['firstName'] = true;
      updated = true;
    }
    if (data['lastName'] != null && _guest.lastName.isEmpty) {
      _guest.lastName = data['lastName'].toString();
      _detectedFields['lastName'] = true;
      updated = true;
    }
    if (data['documentNumber'] != null && _guest.documentNumber.isEmpty) {
      _guest.documentNumber = data['documentNumber'].toString();
      _detectedFields['documentNumber'] = true;
      updated = true;
    }
    if (data['dateOfBirth'] != null && _guest.dateOfBirth.isEmpty) {
      _guest.dateOfBirth = data['dateOfBirth'].toString();
      _detectedFields['dateOfBirth'] = true;
      updated = true;
    }
    if (data['nationality'] != null && _guest.nationality.isEmpty) {
      _guest.nationality = data['nationality'].toString();
      _detectedFields['nationality'] = true;
      updated = true;
    }
    if (data['sex'] != null && _guest.sex.isEmpty) {
      _guest.sex = data['sex'].toString();
      _detectedFields['sex'] = true;
      updated = true;
    }
    if (data['address'] != null && _guest.address.isEmpty) {
      _guest.address = data['address'].toString();
      _detectedFields['address'] = true;
      updated = true;
    }
    if (data['oib'] != null && _guest.oib.isEmpty) {
      _guest.oib = data['oib'].toString();
      _detectedFields['oib'] = true;
      updated = true;
    }
    if (data['residenceCity'] != null && _guest.residenceCity.isEmpty) {
      _guest.residenceCity = data['residenceCity'].toString();
      updated = true;
    }
    // Vrsta dokumenta iz MRZ
    if (data['documentType'] != null && _guest.documentType.isEmpty) {
      _guest.documentType = data['documentType'].toString();
      _detectedFields['documentType'] = true;
      updated = true;
    }

    if (updated) {
      widget.onUpdate(_guest);
      _showSuccessAnimation();
      _setStatus('✅ Podaci prepoznati!');
    } else {
      _setStatus('⚠️ Pokušajte ponovno');
    }

    setState(() {});
  }

  void _showSuccessAnimation() {
    setState(() => _showSuccess = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _showSuccess = false);
    });
  }

  void _goToNextStep() {
    // Samo jedna strana - direktno na potvrdu
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFFD4AF37)),
              const SizedBox(height: 20),
              Text('Pokrećem kameru...',
                  style: TextStyle(color: Colors.grey[400])),
            ],
          ),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final cameraWidth = size.width * 0.65;
    final cameraHeight = size.height;

    // OKVIR ZA DOKUMENT - uži i viši za bolji fit osobne
    final bool isPassport = widget.docType == 'PASSPORT';
    const double frameW = 320.0; // Uži
    final double frameH = isPassport ? 230.0 : 200.0; // Viši ratio

    final frameX = (cameraWidth - frameW) / 2;
    final frameY = (cameraHeight - frameH) / 2;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          // ========== LEFT: CAMERA (65%) ==========
          SizedBox(
            width: cameraWidth,
            height: cameraHeight,
            child: Stack(
              children: [
                // Camera preview - FLIP jer fizičko zrcalo zrcali sliku
                Positioned.fill(
                  child: _controller != null
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.diagonal3Values(-1.0, 1.0, 1.0),
                          child: CameraPreview(_controller!),
                        )
                      : Container(color: Colors.black),
                ),

                // Dark overlay - TOP
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: frameY,
                  child: Container(color: Colors.black.withValues(alpha: 0.85)),
                ),
                // Dark overlay - BOTTOM
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: frameY,
                  child: Container(color: Colors.black.withValues(alpha: 0.85)),
                ),
                // Dark overlay - LEFT
                Positioned(
                  top: frameY,
                  left: 0,
                  width: frameX,
                  height: frameH,
                  child: Container(color: Colors.black.withValues(alpha: 0.85)),
                ),
                // Dark overlay - RIGHT
                Positioned(
                  top: frameY,
                  right: 0,
                  width: frameX,
                  height: frameH,
                  child: Container(color: Colors.black.withValues(alpha: 0.85)),
                ),

                // Frame border
                Positioned(
                  left: frameX,
                  top: frameY,
                  child: Container(
                    width: frameW,
                    height: frameH,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _showSuccess
                            ? Colors.green
                            : const Color(0xFFD4AF37),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        // Corner decorations
                        _buildCorner(true, true),
                        _buildCorner(true, false),
                        _buildCorner(false, true),
                        _buildCorner(false, false),
                        // Label
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'STRAŽNJA STRANA',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Top bar
                Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  child: Row(
                    children: [
                      _buildIconButton(Icons.arrow_back, widget.onBack),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          'GOST ${widget.guestNumber} / ${widget.totalGuests}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _goToNextStep,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Text(
                            'PRESKOČI →',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom status
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      const Text(
                        'Postavite STRAŽNJU stranu dokumenta u okvir',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      if (_statusMessage.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _statusMessage.contains('✅')
                                ? Colors.green.withValues(alpha: 0.3)
                                : Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _statusMessage,
                            style: TextStyle(
                              color: _statusMessage.contains('✅')
                                  ? Colors.green
                                  : Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ========== RIGHT: PANEL (35%) ==========
          Expanded(
            child: Container(
              color: const Color(0xFF1A1A1A),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Row(
                    children: [
                      Icon(
                        Icons.credit_card,
                        color: Color(0xFFD4AF37),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'PODACI S DOKUMENTA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 24),

                  // Fields - SAMO STRAŽNJA STRANA (MRZ)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildFieldRow(
                              'documentType',
                              'Vrsta dokumenta',
                              _guest.documentType == 'PASSPORT'
                                  ? 'Putovnica'
                                  : 'Osobna iskaznica',
                              Icons.badge),
                          _buildFieldRow('firstName', 'Ime', _guest.firstName,
                              Icons.person),
                          _buildFieldRow('lastName', 'Prezime', _guest.lastName,
                              Icons.person_outline),
                          _buildFieldRow('documentNumber', 'Broj dokumenta',
                              _guest.documentNumber, Icons.credit_card),
                          _buildFieldRow('dateOfBirth', 'Datum rođenja',
                              _guest.dateOfBirth, Icons.cake),
                          _buildFieldRow('sex', 'Spol', _guest.sex, Icons.wc),
                          _buildFieldRow('nationality', 'Državljanstvo',
                              _guest.nationality, Icons.flag),
                          _buildFieldRow(
                              'address', 'Adresa', _guest.address, Icons.home),
                          if (widget.countryCode == 'HR')
                            _buildFieldRow(
                                'oib', 'OIB', _guest.oib, Icons.numbers),
                        ],
                      ),
                    ),
                  ),

                  // Progress
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: _guest.completionProgress,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFD4AF37)),
                    minHeight: 6,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_guest.completionProgress * 100).toInt()}% prepoznato',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),

                  const SizedBox(height: 16),

                  // GUMB SLIKAJ
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _captureAndProcess,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.camera_alt, size: 24),
                      label: Text(
                        _isProcessing ? 'OBRAĐUJEM...' : '📸 SLIKAJ',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // GUMB NASTAVI
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _goToNextStep,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'ZAVRŠI SKENIRANJE →',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldRow(String key, String label, String value, IconData icon) {
    final isDetected = _detectedFields[key] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isDetected
            ? Colors.green.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              isDetected ? Colors.green.withValues(alpha: 0.5) : Colors.white12,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isDetected ? Icons.check_circle : icon,
            color: isDetected ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value.isEmpty ? 'Čekam skeniranje...' : value,
                  style: TextStyle(
                    color: value.isEmpty ? Colors.grey : Colors.white,
                    fontSize: 14,
                    fontStyle:
                        value.isEmpty ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildCorner(bool isTop, bool isLeft) {
    return Positioned(
      top: isTop ? 0 : null,
      bottom: isTop ? null : 0,
      left: isLeft ? 0 : null,
      right: isLeft ? null : 0,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? const BorderSide(color: Color(0xFFD4AF37), width: 3)
                : BorderSide.none,
            bottom: isTop
                ? BorderSide.none
                : const BorderSide(color: Color(0xFFD4AF37), width: 3),
            left: isLeft
                ? const BorderSide(color: Color(0xFFD4AF37), width: 3)
                : BorderSide.none,
            right: isLeft
                ? BorderSide.none
                : const BorderSide(color: Color(0xFFD4AF37), width: 3),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CONFIRMATION WIDGET
// ═══════════════════════════════════════════════════════════════════════════

class _ConfirmationWidget extends StatefulWidget {
  final Guest guest;
  final int guestNumber;
  final int totalGuests;
  final String countryCode;
  final Function(Guest) onConfirm;
  final VoidCallback onRescan;

  const _ConfirmationWidget({
    required this.guest,
    required this.guestNumber,
    required this.totalGuests,
    required this.countryCode,
    required this.onConfirm,
    required this.onRescan,
  });

  @override
  State<_ConfirmationWidget> createState() => _ConfirmationWidgetState();
}

class _ConfirmationWidgetState extends State<_ConfirmationWidget> {
  late Guest _guest;
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _docNumberCtrl;
  late TextEditingController _dateOfBirthCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _oibCtrl;

  @override
  void initState() {
    super.initState();
    _guest = widget.guest;
    _firstNameCtrl = TextEditingController(text: _guest.firstName);
    _lastNameCtrl = TextEditingController(text: _guest.lastName);
    _docNumberCtrl = TextEditingController(text: _guest.documentNumber);
    _dateOfBirthCtrl = TextEditingController(text: _guest.dateOfBirth);
    _addressCtrl = TextEditingController(text: _guest.address);
    _oibCtrl = TextEditingController(text: _guest.oib);
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _docNumberCtrl.dispose();
    _dateOfBirthCtrl.dispose();
    _addressCtrl.dispose();
    _oibCtrl.dispose();
    super.dispose();
  }

  void _updateGuest() {
    _guest.firstName = _firstNameCtrl.text.trim();
    _guest.lastName = _lastNameCtrl.text.trim();
    _guest.documentNumber = _docNumberCtrl.text.trim();
    _guest.dateOfBirth = _dateOfBirthCtrl.text.trim();
    _guest.address = _addressCtrl.text.trim();
    _guest.oib = _oibCtrl.text.trim();
  }

  void _onConfirm() {
    _updateGuest();
    if (!_guest.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Popunite: ${_guest.emptyFields.join(", ")}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    widget.onConfirm(_guest);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                        Icons.fact_check,
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
                            'POTVRDA - GOST ${widget.guestNumber}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Provjerite i ispravite podatke',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Vrsta dokumenta i spol (read-only info)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.badge,
                          color: Color(0xFFD4AF37), size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _guest.documentType == 'PASSPORT'
                            ? 'Putovnica'
                            : 'Osobna iskaznica',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      const Icon(Icons.wc, color: Color(0xFFD4AF37), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _guest.sex.isNotEmpty ? _guest.sex : '-',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.flag,
                          color: Color(0xFFD4AF37), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _guest.nationality.isNotEmpty
                            ? _guest.nationality
                            : widget.countryCode,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Fields
                Row(
                  children: [
                    Expanded(
                        child:
                            _buildField(_firstNameCtrl, 'Ime *', Icons.person)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildField(
                            _lastNameCtrl, 'Prezime *', Icons.person_outline)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _buildField(_docNumberCtrl, 'Broj dokumenta *',
                            Icons.credit_card)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildField(
                            _dateOfBirthCtrl, 'Datum rođenja', Icons.cake)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildField(_addressCtrl, 'Adresa', Icons.home),
                if (widget.countryCode == 'HR') ...[
                  const SizedBox(height: 12),
                  _buildField(_oibCtrl, 'OIB', Icons.numbers),
                ],

                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: widget.onRescan,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('PONOVI'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _onConfirm,
                        icon: const Icon(Icons.check, size: 18),
                        label: Text(
                          widget.guestNumber < widget.totalGuests
                              ? 'SPREMI → SLJEDEĆI'
                              : 'ZAVRŠI CHECK-IN',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        prefixIcon: Icon(icon, color: Colors.grey, size: 20),
        filled: true,
        fillColor: Colors.black26,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD4AF37)),
        ),
      ),
    );
  }
}