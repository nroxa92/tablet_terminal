// FILE: lib/ui/widgets/welcome_message_overlay.dart
// OPIS: Modal dialog s pozdravnom porukom i 30 sec countdown
// VERZIJA: 1.0

import 'dart:async';
import 'package:flutter/material.dart';

class WelcomeMessageOverlay {
  /// Prikazuje modal s pozdravnom porukom
  /// Automatski se zatvara nakon [duration] sekundi ili kad korisnik klikne
  static Future<void> show({
    required BuildContext context,
    required String message,
    int duration = 30,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (context) => _WelcomeMessageDialog(
        message: message,
        duration: duration,
      ),
    );
  }
}

class _WelcomeMessageDialog extends StatefulWidget {
  final String message;
  final int duration;

  const _WelcomeMessageDialog({
    required this.message,
    required this.duration,
  });

  @override
  State<_WelcomeMessageDialog> createState() => _WelcomeMessageDialogState();
}

class _WelcomeMessageDialogState extends State<_WelcomeMessageDialog>
    with SingleTickerProviderStateMixin {
  late int _secondsRemaining;
  Timer? _timer;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.duration;

    // Animacije
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    // Countdown timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() => _secondsRemaining--);
      } else {
        _close();
      }
    });
  }

  void _close() {
    _timer?.cancel();
    _animationController.reverse().then((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(40),
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E1E1E),
                Color(0xFF121212),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                blurRadius: 40,
                spreadRadius: 5,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ICON
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD4AF37), Color(0xFFB8941F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.waving_hand,
                      size: 35,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // MESSAGE
                  Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // CLOSE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _close,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "CONTINUE",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Countdown badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "$_secondsRemaining",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
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
          ),
        ),
      ),
    );
  }
}
