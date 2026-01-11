// FILE: lib/ui/widgets/kiosk_exit_dialog.dart
// OPIS: Dialog za unos 6-znamenkastog PIN-a i izlaz iz kiosk mode-a
// VERZIJA: 3.0 - LOKALIZACIJA (EN fallback + Translations)
// DATUM: 2026-01-11

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/services/kiosk_service.dart';
import '../../utils/translations/translations.dart';

class KioskExitDialog extends StatefulWidget {
  const KioskExitDialog({super.key});

  /// Prikaži dialog i vrati true ako je otključano
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const KioskExitDialog(),
    );
    return result ?? false;
  }

  @override
  State<KioskExitDialog> createState() => _KioskExitDialogState();
}

class _KioskExitDialogState extends State<KioskExitDialog> {
  // 6 kontrolera za 6 PIN polja
  final List<TextEditingController> _controllers = List.generate(
    KioskService.pinLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    KioskService.pinLength,
    (_) => FocusNode(),
  );

  bool _isLoading = false;
  String? _errorMessage;
  int _attempts = 0;
  static const int _maxAttempts = 5;

  @override
  void initState() {
    super.initState();
    // Auto-focus na prvi input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _enteredPin {
    return _controllers.map((c) => c.text).join();
  }

  void _clearPin() {
    for (var c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
  }

  Future<void> _handleUnlock() async {
    final pin = _enteredPin;

    // Provjeri duljinu
    if (pin.length != KioskService.pinLength) {
      setState(() => _errorMessage = Translations.t('kiosk_enter_all_digits'));
      return;
    }

    // Provjeri max pokušaje
    if (_attempts >= _maxAttempts) {
      setState(() => _errorMessage = Translations.t('kiosk_too_many_attempts'));
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await KioskService.unlockWithPin(pin);

      if (success) {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        _attempts++;
        setState(() {
          _errorMessage = Translations.t('kiosk_wrong_pin_attempts',
              {'attempts': '${_maxAttempts - _attempts}'});
        });
        _clearPin();
      }
    } catch (e) {
      setState(() => _errorMessage = '${Translations.t('error')}: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onDigitEntered(int index, String value) {
    if (value.length == 1) {
      // Pomakni se na sljedeće polje
      if (index < KioskService.pinLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Zadnje polje - pokušaj unlock
        _handleUnlock();
      }
    }
  }

  void _onKeyPressed(int index, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_controllers[index].text.isEmpty && index > 0) {
          // Pomakni se na prethodno polje
          _focusNodes[index - 1].requestFocus();
          _controllers[index - 1].clear();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.lock_outline,
              color: Color(0xFFD4AF37),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            Translations.t('kiosk_mode_title'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            Translations.t('kiosk_enter_pin'),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),

          // 6 PIN POLJA
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(KioskService.pinLength, (index) {
              return Container(
                width: 45,
                height: 55,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index]
                    ..onKeyEvent = (node, event) {
                      _onKeyPressed(index, event);
                      return KeyEventResult.ignored;
                    },
                  obscureText: true,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFD4AF37),
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) => _onDigitEntered(index, value),
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          // Error message
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Info text
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  Translations.t('kiosk_contact_admin'),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: Text(
            Translations.t('btn_cancel'),
            style: TextStyle(color: Colors.grey[400]),
          ),
        ),
        ElevatedButton(
          onPressed:
              _isLoading || _attempts >= _maxAttempts ? null : _handleUnlock,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4AF37),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                )
              : Text(
                  Translations.t('kiosk_unlock'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}

// ============================================================
// HIDDEN TAP DETECTOR - Za skriveni pristup settings-ima
// ============================================================

/// Widget koji detektira skriveni tap pattern za pristup kiosk exit dialogu
class HiddenKioskExitTrigger extends StatefulWidget {
  final Widget child;
  final int requiredTaps;
  final Duration resetDuration;
  final VoidCallback? onTriggered;

  const HiddenKioskExitTrigger({
    super.key,
    required this.child,
    this.requiredTaps = 7, // Default 7 tapova
    this.resetDuration = const Duration(seconds: 3),
    this.onTriggered,
  });

  @override
  State<HiddenKioskExitTrigger> createState() => _HiddenKioskExitTriggerState();
}

class _HiddenKioskExitTriggerState extends State<HiddenKioskExitTrigger> {
  int _tapCount = 0;
  DateTime? _lastTapTime;

  void _handleTap() {
    final now = DateTime.now();

    // Reset ako je prošlo previše vremena
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) > widget.resetDuration) {
      _tapCount = 0;
    }

    _lastTapTime = now;
    _tapCount++;

    debugPrint('🔢 Hidden tap: $_tapCount/${widget.requiredTaps}');

    if (_tapCount >= widget.requiredTaps) {
      _tapCount = 0;
      debugPrint('🔓 Hidden exit triggered!');

      if (widget.onTriggered != null) {
        widget.onTriggered!();
      } else {
        // Default: prikaži exit dialog
        KioskExitDialog.show(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}
