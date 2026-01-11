// FILE: lib/ui/screens/dashboard_screen.dart
// OPIS: Glavni dashboard za goste s AI agentima.
// VERZIJA: 3.0 - Dodana FAZA 2: OfflineBanner
// DATUM: 2026-01-10

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// Servisi
import '../../data/services/storage_service.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/weather_service.dart';

// Widgets
import '../widgets/offline_indicator.dart';

// Utils
import '../../utils/translations/translations.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Varijable stanja
  String _villaName = "Villa Guest";
  String _wifiSSID = "";
  String _wifiPass = "";
  String _contactPhone = "";
  String _guestName = "";
  int _guestCount = 1;
  DateTime? _checkOutDate;

  // Loading & Weather
  bool _isLoading = true;
  Map<String, dynamic>? _weatherData;
  Timer? _weatherTimer;

  // Stream za sat
  Stream<DateTime> get _timeStream =>
      Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadAllData();
    _fetchWeather();

    // Osvježavaj vrijeme svakih 30 min
    _weatherTimer = Timer.periodic(
      const Duration(minutes: 30),
      (_) => _fetchWeather(),
    );
  }

  @override
  void dispose() {
    _weatherTimer?.cancel();
    super.dispose();
  }

  /// Glavni sync - povlači SVE podatke s Firebase-a
  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);

    try {
      // 1. SYNC SVE S FIREBASE-a (ovo je ključno!)
      await FirestoreService.syncAllData();
      debugPrint("✅ Dashboard: syncAllData completed");
    } catch (e) {
      debugPrint("⚠️ Dashboard sync warning: $e");
    }

    // 2. UČITAJ IZ LOKALNOG STORAGE-a (brzo, offline)
    if (mounted) {
      setState(() {
        _villaName = StorageService.getVillaName();
        _wifiSSID = StorageService.getWifiSSID();
        _wifiPass = StorageService.getWifiPassword();
        _contactPhone = StorageService.getContactPhone();
        _guestName = StorageService.getGuestName();
        _guestCount = StorageService.getGuestCount();
        _checkOutDate = StorageService.getBookingEnd();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchWeather() async {
    try {
      final data = await WeatherService.getCurrentWeather();
      if (mounted) setState(() => _weatherData = data);
    } catch (e) {
      debugPrint("Weather error: $e");
    }
  }

  void _openAgent(String id, String title, IconData icon, Color color) {
    Navigator.pushNamed(
      context,
      '/chat',
      arguments: {
        'id': id,
        'title': title,
        'icon': icon,
        'color': color,
      },
    );
  }

  void _showHelpDialog() {
    final contacts = StorageService.getContactOptions();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.support_agent, color: Color(0xFFD4AF37)),
            const SizedBox(width: 10),
            Text(
              Translations.t('need_help'),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Translations.t('contact_host'),
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Telefon
            if (_contactPhone.isNotEmpty)
              _buildContactOption(
                icon: Icons.phone,
                label: _contactPhone,
                onTap: () => _launchUrl('tel:$_contactPhone'),
              ),

            // WhatsApp
            if (contacts.containsKey('whatsapp') &&
                contacts['whatsapp']!.isNotEmpty)
              _buildContactOption(
                icon: Icons.chat,
                label: 'WhatsApp',
                color: Colors.green,
                onTap: () =>
                    _launchUrl('https://wa.me/${contacts['whatsapp']}'),
              ),

            // Viber
            if (contacts.containsKey('viber') && contacts['viber']!.isNotEmpty)
              _buildContactOption(
                icon: Icons.message,
                label: 'Viber',
                color: Colors.purple,
                onTap: () =>
                    _launchUrl('viber://chat?number=${contacts['viber']}'),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = const Color(0xFFD4AF37),
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 15),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Launch URL error: $e");
    }
  }

  void _handleCheckOut() async {
    // Formatiraj datum ako postoji
    String checkOutInfo = "";
    if (_checkOutDate != null) {
      checkOutInfo =
          "\n\nCheck-out date: ${DateFormat('dd.MM.yyyy').format(_checkOutDate!)}";
    }

    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.logout, color: Colors.redAccent),
            const SizedBox(width: 10),
            Text(
              Translations.t('check_out'),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to check out?$checkOutInfo",
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Check Out",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      Navigator.pushNamed(context, '/feedback');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Loading screen
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFFD4AF37)),
              const SizedBox(height: 20),
              Text(
                "Loading your stay...",
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [
          // ⭐ FAZA 2: OFFLINE BANNER
          const OfflineBanner(),

          // GLAVNI SADRŽAJ
          Expanded(
            child: Stack(
              children: [
                // Pozadina
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1E1E1E), Color(0xFF000000)],
                      ),
                    ),
                  ),
                ),

                SafeArea(
                  child: Row(
                    children: [
                      // ═══════════════════════════════════════════════════════
                      // LIJEVI PANEL (Info, Sat, QR, Gumbi)
                      // ═══════════════════════════════════════════════════════
                      Expanded(
                        flex: 35,
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          decoration: const BoxDecoration(
                            border: Border(
                                right: BorderSide(color: Colors.white10)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Welcome message
                              FadeInDown(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _guestName.isNotEmpty
                                          ? "Welcome,"
                                          : "Welcome to",
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      _guestName.isNotEmpty
                                          ? _guestName
                                          : _villaName,
                                      style: const TextStyle(
                                        color: Color(0xFFD4AF37),
                                        fontSize: 34,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                        height: 1.2,
                                      ),
                                    ),
                                    if (_guestCount > 1)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Text(
                                          "$_guestCount guests",
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 25),

                              // Sat i Datum
                              StreamBuilder<DateTime>(
                                stream: _timeStream,
                                builder: (context, snapshot) {
                                  final now = snapshot.data ?? DateTime.now();
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('HH:mm').format(now),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 56,
                                          fontWeight: FontWeight.w200,
                                          height: 1.0,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('EEEE, d. MMMM').format(now),
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 16,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),

                              const SizedBox(height: 30),

                              // Weather widget
                              _buildWeatherWidget(),

                              const Spacer(),

                              // Check-out datum (ako postoji)
                              if (_checkOutDate != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  margin: const EdgeInsets.only(bottom: 15),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color:
                                          Colors.orange.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.event,
                                        color: Colors.orange,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Check-out: ${DateFormat('dd.MM').format(_checkOutDate!)}",
                                        style: const TextStyle(
                                          color: Colors.orange,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // Check-in status badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.green.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      Translations.t('check_in_complete'),
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // WiFi QR i Info
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  children: [
                                    // QR Code
                                    Container(
                                      color: Colors.white,
                                      padding: const EdgeInsets.all(2),
                                      child: QrImageView(
                                        data:
                                            "WIFI:T:WPA;S:$_wifiSSID;P:$_wifiPass;;",
                                        version: QrVersions.auto,
                                        size: 60.0,
                                        backgroundColor: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    // WiFi info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.wifi,
                                                color: Color(0xFFD4AF37),
                                                size: 16,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  _wifiSSID,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Pass: $_wifiPass",
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Check-out button
                              SizedBox(
                                width: double.infinity,
                                child: TextButton.icon(
                                  onPressed: _handleCheckOut,
                                  icon: const Icon(
                                    Icons.logout,
                                    color: Colors.redAccent,
                                  ),
                                  label: Text(
                                    Translations.t('check_out'),
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Help button
                              Center(
                                child: TextButton(
                                  onPressed: _showHelpDialog,
                                  child: const Text(
                                    "Need Help?",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ═══════════════════════════════════════════════════════
                      // DESNI PANEL (Agenti Grid)
                      // ═══════════════════════════════════════════════════════
                      Expanded(
                        flex: 65,
                        child: Padding(
                          padding: const EdgeInsets.all(30),
                          child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 25,
                            mainAxisSpacing: 25,
                            childAspectRatio: 1.3,
                            children: [
                              _buildAgentCard(
                                title: Translations.t('agent_reception'),
                                desc: "Chat, FAQ, Assistance",
                                icon: Icons.support_agent,
                                color: const Color(0xFFD4AF37),
                                onTap: () => _openAgent(
                                  'reception',
                                  Translations.t('agent_reception'),
                                  Icons.support_agent,
                                  const Color(0xFFD4AF37),
                                ),
                                delay: 100,
                              ),
                              _buildAgentCard(
                                title: Translations.t('agent_house'),
                                desc: "AC, Lights, Pool",
                                icon: Icons.home_filled,
                                color: Colors.blueAccent,
                                onTap: () => _openAgent(
                                  'house',
                                  Translations.t('agent_house'),
                                  Icons.home_filled,
                                  Colors.blueAccent,
                                ),
                                delay: 200,
                              ),
                              _buildAgentCard(
                                title: Translations.t('agent_gastro'),
                                desc: "Restaurants & Delivery",
                                icon: Icons.restaurant_menu,
                                color: Colors.orangeAccent,
                                onTap: () => _openAgent(
                                  'gastro',
                                  Translations.t('agent_gastro'),
                                  Icons.restaurant_menu,
                                  Colors.orangeAccent,
                                ),
                                delay: 300,
                              ),
                              _buildAgentCard(
                                title: Translations.t('agent_local'),
                                desc: "Beaches, Tours, Events",
                                icon: Icons.map_outlined,
                                color: Colors.greenAccent,
                                onTap: () => _openAgent(
                                  'local',
                                  Translations.t('agent_local'),
                                  Icons.map_outlined,
                                  Colors.greenAccent,
                                ),
                                delay: 400,
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
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // HELPER WIDGETS
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildWeatherWidget() {
    if (_weatherData == null) return const SizedBox.shrink();

    double windRotation = 0.0;
    if (_weatherData!['wind_dir'] != null) {
      windRotation = (_weatherData!['wind_dir'] as int).toDouble();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _weatherItem(Icons.thermostat, "${_weatherData!['temp']}°C"),
          _weatherItem(Icons.waves, "${_weatherData!['sea_temp']}°C"),
          Column(
            children: [
              Transform.rotate(
                angle: (windRotation * 3.14159 / 180),
                child: const Icon(
                  Icons.navigation,
                  color: Colors.white70,
                  size: 24,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "${_weatherData!['wind']} km/h",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          _weatherItem(Icons.wb_sunny, "UV: ${_weatherData!['uv']}"),
        ],
      ),
    );
  }

  Widget _weatherItem(IconData icon, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAgentCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required int delay,
  }) {
    return FadeInUp(
      delay: Duration(milliseconds: delay),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(icon, color: color, size: 40),
                ),
                const SizedBox(height: 20),
                Text(
                  title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
