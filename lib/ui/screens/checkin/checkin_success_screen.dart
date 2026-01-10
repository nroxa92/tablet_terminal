// FILE: lib/ui/screens/checkin/checkin_success_screen.dart
// OPIS: Success screen nakon uspješnog check-ina s animacijom i potvrdom
// VERZIJA: 1.0 - FAZA 3.5
// DATUM: 2026-01-10

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/services/sentry_service.dart';

class CheckInSuccessScreen extends StatefulWidget {
  final int guestCount;
  final String guestName;
  final String villaName;
  final Duration checkInDuration;
  final VoidCallback? onContinue;

  const CheckInSuccessScreen({
    super.key,
    required this.guestCount,
    required this.guestName,
    required this.villaName,
    required this.checkInDuration,
    this.onContinue,
  });

  @override
  State<CheckInSuccessScreen> createState() => _CheckInSuccessScreenState();
}

class _CheckInSuccessScreenState extends State<CheckInSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkmarkController;
  late AnimationController _fadeController;
  late Animation<double> _checkmarkAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _showContent = false;
  int _countdown = 10;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();

    // Checkmark animation
    _checkmarkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _checkmarkAnimation = CurvedAnimation(
      parent: _checkmarkController,
      curve: Curves.elasticOut,
    );

    // Fade animation for content
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack),
    );

    // Start animations
    _startAnimations();

    // Log success
    SentryService.addBreadcrumb(
      message: 'Check-in success screen shown',
      category: 'checkin',
      data: {
        'guest_count': widget.guestCount,
        'duration_seconds': widget.checkInDuration.inSeconds,
      },
    );
  }

  void _startAnimations() async {
    // Wait a bit then start checkmark
    await Future.delayed(const Duration(milliseconds: 300));
    _checkmarkController.forward();

    // Then show content
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _showContent = true);
    _fadeController.forward();

    // Start countdown
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
        _navigateToDashboard();
      }
    });
  }

  void _navigateToDashboard() {
    _countdownTimer?.cancel();

    if (widget.onContinue != null) {
      widget.onContinue!();
    } else {
      // Mark check-in as completed
      StorageService.setCheckInStatus('completed');
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _checkmarkController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF121212),
                const Color(0xFF1A1A1A),
                const Color(0xFF0D1F0D).withOpacity(0.3), // Subtle green tint
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ═══════════════════════════════════════════════════════
                // ANIMATED CHECKMARK
                // ═══════════════════════════════════════════════════════
                ScaleTransition(
                  scale: _checkmarkAnimation,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 80,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // ═══════════════════════════════════════════════════════
                // CONTENT (fades in)
                // ═══════════════════════════════════════════════════════
                if (_showContent)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        children: [
                          // Title
                          const Text(
                            'CHECK-IN USPJEŠAN!',
                            style: TextStyle(
                              color: Color(0xFF4CAF50),
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Guest info
                          Text(
                            'Dobrodošli, ${widget.guestName}!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            widget.villaName,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Stats
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildStat(
                                  icon: Icons.people,
                                  value: '${widget.guestCount}',
                                  label: widget.guestCount == 1
                                      ? 'Gost'
                                      : 'Gostiju',
                                ),
                                Container(
                                  height: 40,
                                  width: 1,
                                  color: Colors.white24,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                ),
                                _buildStat(
                                  icon: Icons.timer,
                                  value: '${widget.checkInDuration.inSeconds}s',
                                  label: 'Trajanje',
                                ),
                                Container(
                                  height: 40,
                                  width: 1,
                                  color: Colors.white24,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                ),
                                _buildStat(
                                  icon: Icons.verified,
                                  value: '✓',
                                  label: 'Potvrđeno',
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Continue button with countdown
                          SizedBox(
                            width: 280,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _navigateToDashboard,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD4AF37),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 8,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.arrow_forward, size: 24),
                                  const SizedBox(width: 12),
                                  Text(
                                    'NASTAVI ($_countdown)',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Text(
                            'Automatski prelazak za $_countdown sekundi...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
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
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFFD4AF37), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HELPER: Show success screen
// ═══════════════════════════════════════════════════════════════════════════════

/// Pozovi ovo nakon uspješnog check-ina
void showCheckInSuccess(
  BuildContext context, {
  required int guestCount,
  required String guestName,
  required Duration checkInDuration,
}) {
  final villaName = StorageService.getVillaName();

  Navigator.pushReplacement(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return CheckInSuccessScreen(
          guestCount: guestCount,
          guestName: guestName,
          villaName: villaName,
          checkInDuration: checkInDuration,
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    ),
  );
}
