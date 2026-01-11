// FILE: lib/ui/screens/screensaver_screen.dart
// OPIS: Premium screensaver s vremenskom prognozom, satom i slideshow-om.
// VERZIJA: 2.0 - Koristi servise, weather widget, villa branding

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';

import '../../data/services/firestore_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/weather_service.dart';
import '../../utils/translations/translations.dart';

class ScreensaverScreen extends StatefulWidget {
  const ScreensaverScreen({super.key});

  @override
  State<ScreensaverScreen> createState() => _ScreensaverScreenState();
}

class _ScreensaverScreenState extends State<ScreensaverScreen>
    with SingleTickerProviderStateMixin {
  // Slideshow
  int _currentImageIndex = 0;
  Timer? _sliderTimer;
  List<String> _imageUrls = [];
  bool _isLoadingImages = true;

  // Villa info
  String _villaName = "";

  // Weather
  Map<String, dynamic>? _weatherData;
  Timer? _weatherTimer;

  // Animation
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _loadData();
  }

  void _initAnimation() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
  }

  Future<void> _loadData() async {
    // 1. Villa info
    setState(() {
      _villaName = StorageService.getVillaName();
    });

    // 2. Dohvati slike za slideshow
    await _fetchImages();

    // 3. Dohvati weather
    await _fetchWeather();

    // 4. Refresh weather svakih 30 min
    _weatherTimer = Timer.periodic(
      const Duration(minutes: 30),
      (_) => _fetchWeather(),
    );
  }

  Future<void> _fetchImages() async {
    try {
      final urls = await FirestoreService.getGalleryImages();

      if (mounted) {
        setState(() {
          _imageUrls = urls;
          _isLoadingImages = false;
        });

        if (_imageUrls.isNotEmpty) {
          _startSlider();
        }
      }
    } catch (e) {
      debugPrint("Error fetching screensaver images: $e");
      if (mounted) {
        setState(() => _isLoadingImages = false);
      }
    }
  }

  Future<void> _fetchWeather() async {
    try {
      final data = await WeatherService.getCurrentWeather();
      if (mounted) {
        setState(() => _weatherData = data);
      }
    } catch (e) {
      debugPrint("Weather fetch error: $e");
    }
  }

  void _startSlider() {
    _sliderTimer?.cancel();
    _sliderTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (mounted && _imageUrls.isNotEmpty) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % _imageUrls.length;
        });
      }
    });
  }

  void _wakeUp() {
    // Animiraj izlaz
    _fadeController.reverse().then((_) {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    _weatherTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: _wakeUp,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. BACKGROUND SLIDESHOW
              _buildBackgroundSlideshow(),

              // 2. GRADIENT OVERLAY
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.5),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),

              // 3. CONTENT
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      // TOP BAR - Villa Name & Weather
                      _buildTopBar(),

                      const Spacer(),

                      // CENTER - Clock & Date
                      _buildClock(),

                      const Spacer(),

                      // BOTTOM - Touch to continue
                      _buildBottomHint(),
                    ],
                  ),
                ),
              ),

              // 4. SLIDESHOW INDICATOR
              if (_imageUrls.length > 1)
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: _buildSlideIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundSlideshow() {
    if (_isLoadingImages) {
      return Container(
        color: const Color(0xFF0a0a0a),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFD4AF37),
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_imageUrls.isEmpty) {
      // Fallback - gradient background
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
          ),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(seconds: 2),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      child: Image.network(
        _imageUrls[_currentImageIndex],
        key: ValueKey<String>(_imageUrls[_currentImageIndex]),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD4AF37),
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFF1a1a2e),
          );
        },
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Villa Logo/Name
        FadeInLeft(
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                  ),
                ),
                child: const Icon(
                  Icons.villa,
                  color: Color(0xFFD4AF37),
                  size: 28,
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _villaName.isNotEmpty ? _villaName : "Villa",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      shadows: [
                        Shadow(blurRadius: 10, color: Colors.black),
                      ],
                    ),
                  ),
                  Text(
                    "CONCIERGE",
                    style: TextStyle(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Weather Widget
        if (_weatherData != null)
          FadeInRight(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Temperature
                  const Icon(Icons.thermostat, color: Colors.white70, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    "${_weatherData!['temp']}°C",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 20,
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    color: Colors.white24,
                  ),

                  // Sea Temp
                  const Icon(Icons.waves, color: Colors.lightBlue, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    "${_weatherData!['sea_temp']}°C",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 20,
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    color: Colors.white24,
                  ),

                  // Wind
                  Transform.rotate(
                    angle: ((_weatherData!['wind_dir'] ?? 0) * 3.14159 / 180),
                    child: const Icon(
                      Icons.navigation,
                      color: Colors.white70,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "${_weatherData!['wind']} km/h",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildClock() {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        final now = DateTime.now();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Time
            FadeInDown(
              child: Text(
                DateFormat('HH:mm').format(now),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 120,
                  fontWeight: FontWeight.w100,
                  letterSpacing: 8,
                  height: 1,
                  shadows: [
                    Shadow(
                      blurRadius: 30,
                      color: Colors.black,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            // Date
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  DateFormat('EEEE, d MMMM yyyy').format(now),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomHint() {
    return FadeInUp(
      delay: const Duration(milliseconds: 500),
      child: Column(
        children: [
          // Animated touch icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.touch_app,
                    color: Colors.white70,
                    size: 28,
                  ),
                ),
              );
            },
            onEnd: () {
              // Restart animation
              if (mounted) setState(() {});
            },
          ),
          const SizedBox(height: 15),
          Text(
            Translations.t('touch_to_continue'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 16,
              fontWeight: FontWeight.w300,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlideIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_imageUrls.length, (index) {
        final isActive = index == _currentImageIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFD4AF37)
                : Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
