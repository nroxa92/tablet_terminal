// FILE: lib/ui/screens/checkin/camera_screen.dart
// VERZIJA: 6.1 - FIXED (bez upozorenja)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../../data/services/ocr_service.dart';
import '../../../data/models/guest_model.dart';

class CameraScreen extends StatefulWidget {
  final String documentType;
  final String issuingCountry;
  final int guestNumber;
  final int totalGuests;
  final DateTime departureDate;
  final Function(Guest) onScanComplete;

  const CameraScreen({
    super.key,
    required this.documentType,
    required this.issuingCountry,
    this.guestNumber = 1,
    this.totalGuests = 1,
    required this.departureDate,
    required this.onScanComplete,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isProcessing = false;

  int _currentStep = 1; // 1 = stražnja, 2 = prednja

  // ignore: prefer_final_fields - mora se mijenjati tijekom skeniranja
  Guest _guest = Guest();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();

      CameraDescription? selectedCamera;
      for (var cam in cameras) {
        if (cam.lensDirection == CameraLensDirection.back) {
          selectedCamera = cam;
          break;
        }
      }
      selectedCamera ??= cameras.first;

      _controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      await _controller!.setFocusMode(FocusMode.auto);
      await _controller!.setFlashMode(FlashMode.off);

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint('❌ Camera init error: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _captureAndProcess() async {
    if (_controller == null || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final XFile image = await _controller!.takePicture();
      debugPrint('📸 Slika snimljena: ${image.path}');

      final scanType = _currentStep == 1 ? 'back' : 'front';
      final result = await OCRService.scanDocument(
        imagePath: image.path,
        scanType: scanType,
        flipHorizontal: true,
      );

      if (_currentStep == 1) {
        _mergeBackSideData(result);

        if (result['success'] == true) {
          setState(() => _currentStep = 2);
          _showSnackBar('✓ Stražnja strana skenirana!', Colors.green);
        } else {
          _showSnackBar('Nije pronađen MRZ. Pokušajte ponovo.', Colors.orange);
        }
      } else {
        _mergeFrontSideData(result);
        _completeScanning();
      }

      try {
        await File(image.path).delete();
      } catch (_) {}
    } catch (e) {
      debugPrint('❌ Capture error: $e');
      _showSnackBar('Greška: $e', Colors.red);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _mergeBackSideData(Map<String, dynamic> data) {
    _guest.firstName = data['firstName'] ?? '';
    _guest.lastName = data['lastName'] ?? '';
    _guest.dateOfBirth = data['dateOfBirth'] ?? '';
    _guest.sex = data['sex'] ?? '';
    _guest.nationality = data['nationality'] ?? '';
    _guest.documentNumber = data['documentNumber'] ?? '';
    _guest.documentType = widget.documentType;
    _guest.issuingCountry = widget.issuingCountry;
    _guest.residenceCity = data['residenceCity'] ?? '';
    _guest.residenceCountry = data['residenceCountry'] ?? '';

    debugPrint('📋 Guest nakon stražnje: $_guest');
  }

  void _mergeFrontSideData(Map<String, dynamic> data) {
    if (data['placeOfBirth'] != null) {
      _guest.placeOfBirth = data['placeOfBirth'];
    }
    if (data['countryOfBirth'] != null) {
      _guest.countryOfBirth = data['countryOfBirth'];
    }

    debugPrint('📋 Guest nakon prednje: $_guest');
  }

  void _completeScanning() {
    _guest.arrivalDateTime = DateTime.now();
    _guest.departureDate = widget.departureDate;
    widget.onScanComplete(_guest);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _skipToManualEntry() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ručni unos'),
        content: const Text(
            'Želite li preskočiti skeniranje i ručno unijeti podatke?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('NE'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _guest.documentType = widget.documentType;
              _guest.issuingCountry = widget.issuingCountry;
              _guest.arrivalDateTime = DateTime.now();
              _guest.departureDate = widget.departureDate;
              widget.onScanComplete(_guest);
            },
            child: const Text('DA, RUČNI UNOS'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildCameraPreview()),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xDD000000),
      child: Column(
        children: [
          Text(
            'Gost ${widget.guestNumber} / ${widget.totalGuests}',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStepIndicator(1, 'STRAŽNJA'),
              Container(
                width: 40,
                height: 2,
                color: _currentStep >= 2 ? Colors.green : Colors.white30,
              ),
              _buildStepIndicator(2, 'PREDNJA'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _currentStep == 1
                ? 'Postavite STRAŽNJU stranu dokumenta\n(MRZ zona s <<<)'
                : 'Postavite PREDNJU stranu dokumenta\n(sa slikom)',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    bool isActive = _currentStep == step;
    bool isDone = _currentStep > step;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? Colors.green
                : (isActive ? Colors.blue : Colors.white30),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    '$step',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white54,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildCameraPreview() {
    if (!_isInitialized || _controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRect(
          child: OverflowBox(
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.previewSize?.height ?? 0,
                height: _controller!.value.previewSize?.width ?? 0,
                child: CameraPreview(_controller!),
              ),
            ),
          ),
        ),
        _buildDocumentFrame(),
        if (_isProcessing)
          Container(
            color: const Color(0x88000000),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Obrada...',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDocumentFrame() {
    return Container(
      width: 440,
      height: 280,
      decoration: BoxDecoration(
        border: Border.all(
          color: _currentStep == 1 ? Colors.orange : Colors.blue,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_currentStep == 1)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0x4DFF9800),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(9),
                  bottomRight: Radius.circular(9),
                ),
              ),
              child: const Text(
                'MRZ ZONA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: const Color(0xDD000000),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton.icon(
            onPressed: _currentStep == 1
                ? () => Navigator.pop(context)
                : () => setState(() => _currentStep = 1),
            icon: Icon(
              _currentStep == 1 ? Icons.arrow_back : Icons.refresh,
              color: Colors.white70,
            ),
            label: Text(
              _currentStep == 1 ? 'NATRAG' : 'PONOVI',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          GestureDetector(
            onTap: _isProcessing ? null : _captureAndProcess,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                color: _isProcessing ? Colors.grey : const Color(0x3DFFFFFF),
              ),
              child: Icon(
                Icons.camera_alt,
                color: _isProcessing ? Colors.grey : Colors.white,
                size: 32,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: _skipToManualEntry,
            icon: const Icon(Icons.edit, color: Colors.white70),
            label: const Text(
              'RUČNO',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
