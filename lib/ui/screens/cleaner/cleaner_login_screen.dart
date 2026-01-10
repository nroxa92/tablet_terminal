// FILE: lib/ui/screens/cleaner/cleaner_login_screen.dart
// OPIS: PIN pristup za čistačice i admin panel.
// VERZIJA: 4.0 - FAZA 4: Master PIN otvara Admin Menu
// DATUM: 2026-01-10

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/services/sentry_service.dart';
import '../admin/admin_menu_screen.dart'; // 🆕 FAZA 4: Admin Menu

class CleanerLoginScreen extends StatefulWidget {
  const CleanerLoginScreen({super.key});

  @override
  State<CleanerLoginScreen> createState() => _CleanerLoginScreenState();
}

class _CleanerLoginScreenState extends State<CleanerLoginScreen> {
  final _pinController = TextEditingController();
  String _error = "";
  bool _isLoading = false;
  bool _isLockedOut = false;
  String _lockoutTimeRemaining = "";
  Timer? _lockoutTimer;

  // PIN-ovi se čitaju iz Storage (sync-ani iz Firestore Settings)
  late String _cleanerPin;
  late String _masterPin;

  @override
  void initState() {
    super.initState();
    _loadPins();
    _checkLockoutStatus();
  }

  void _loadPins() {
    // Čitamo PIN-ove iz lokalnog storage-a (sync-ani iz Firestore)
    _cleanerPin = StorageService.getCleanerPin();
    _masterPin = StorageService.getMasterPin();

    debugPrint("🔐 Loaded PINs - Cleaner: $_cleanerPin, Master: $_masterPin");
  }

  void _checkLockoutStatus() {
    _isLockedOut = StorageService.isPinLockedOut();

    if (_isLockedOut) {
      _startLockoutTimer();
    }
  }

  void _startLockoutTimer() {
    _lockoutTimer?.cancel();

    _updateLockoutDisplay();

    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      _updateLockoutDisplay();

      if (!StorageService.isPinLockedOut()) {
        timer.cancel();
        setState(() {
          _isLockedOut = false;
          _error = "";
        });
      }
    });
  }

  void _updateLockoutDisplay() {
    if (mounted) {
      setState(() {
        _lockoutTimeRemaining = StorageService.getRemainingLockoutFormatted();
      });
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _lockoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _verifyPin() async {
    // Provjeri lockout PRIJE svega
    if (StorageService.isPinLockedOut()) {
      setState(() {
        _isLockedOut = true;
        _error = "";
      });
      _startLockoutTimer();
      return;
    }

    final pin = _pinController.text.trim();

    if (pin.isEmpty) {
      setState(() => _error = "Please enter PIN");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = "";
    });

    // Kratka pauza za UX
    await Future.delayed(const Duration(milliseconds: 300));

    if (pin == _cleanerPin) {
      // ✅ CLEANER PIN - Uspješno
      await StorageService.resetPinAttempts();
      SentryService.logPinAttempt(success: true, pinType: 'cleaner');

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/cleaner_tasks');
      }
    } else if (pin == _masterPin) {
      // 🆕 FAZA 4: MASTER PIN - Opens Admin Menu (umjesto direktnog reseta)
      await StorageService.resetPinAttempts();
      SentryService.logPinAttempt(success: true, pinType: 'master');

      if (mounted) {
        setState(() => _isLoading = false);
        _pinController.clear();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminMenuScreen()),
        );
      }
    } else {
      // ❌ Krivi PIN - inkrementiraj pokušaje
      await StorageService.incrementPinAttempts();
      SentryService.logPinAttempt(success: false, pinType: 'unknown');

      final attempts = StorageService.getPinAttempts();
      final remaining = StorageService.maxPinAttempts - attempts;

      if (StorageService.shouldLockout()) {
        // Aktiviraj lockout
        await StorageService.setPinLockout();

        // Log security event
        SentryService.captureMessage(
          'PIN brute-force lockout activated',
          level: SentryLevel.warning,
          extras: {
            'attempts': attempts,
            'unit_id': StorageService.getUnitId(),
          },
        );

        setState(() {
          _isLockedOut = true;
          _isLoading = false;
        });
        _pinController.clear();
        _startLockoutTimer();
      } else {
        setState(() {
          _error = "Invalid PIN ($remaining attempts remaining)";
          _isLoading = false;
        });
        _pinController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: FadeInDown(
          duration: const Duration(milliseconds: 500),
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ICON
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: _isLockedOut
                        ? Colors.red.withValues(alpha: 0.1)
                        : const Color(0xFFD4AF37).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isLockedOut
                          ? Colors.red.withValues(alpha: 0.3)
                          : const Color(0xFFD4AF37).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    _isLockedOut ? Icons.lock_clock : Icons.lock_outline,
                    size: 35,
                    color: _isLockedOut ? Colors.red : const Color(0xFFD4AF37),
                  ),
                ),

                const SizedBox(height: 24),

                // TITLE
                Text(
                  _isLockedOut ? "LOCKED" : "STAFF ACCESS",
                  style: TextStyle(
                    color: _isLockedOut ? Colors.red : Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 8),

                // SUBTITLE
                if (_isLockedOut) ...[
                  Text(
                    "Too many failed attempts",
                    style: TextStyle(color: Colors.red[300], fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  // COUNTDOWN TIMER
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          color: Colors.red,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _lockoutTimeRemaining,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Please wait before trying again",
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ] else ...[
                  Text(
                    "Enter your PIN to continue",
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),

                  const SizedBox(height: 35),

                  // PIN INPUT
                  TextField(
                    controller: _pinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    enabled: !_isLoading,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      letterSpacing: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: "• • • •",
                      hintStyle: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 32,
                        letterSpacing: 12,
                      ),
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFFD4AF37),
                          width: 2,
                        ),
                      ),
                      counterText: "",
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                    ),
                    onSubmitted: (_) => _verifyPin(),
                  ),

                  // ERROR MESSAGE
                  if (_error.isNotEmpty)
                    FadeInDown(
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _error,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 30),

                  // UNLOCK BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyPin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: Colors.grey[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.black54,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              "UNLOCK",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                  ),
                ],

                const SizedBox(height: 30),

                // INFO SECTION
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        Icons.cleaning_services,
                        "Cleaner PIN",
                        "Opens cleaning checklist",
                        Colors.blue,
                      ),
                      const Divider(color: Colors.white10, height: 20),
                      _buildInfoRow(
                        Icons.admin_panel_settings, // 🆕 Promijenjena ikona
                        "Master PIN",
                        "Opens Admin Panel", // 🆕 Promijenjen tekst
                        Colors.orange,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // BACK BUTTON
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text("Back to Dashboard"),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String desc, Color color) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
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
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text(
                desc,
                style: TextStyle(color: Colors.grey[600], fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
