// FILE: lib/presentation/widgets/kiosk_exit_dialog.dart
// OPIS: Dialog za unos PIN-a i izlaz iz kiosk mode-a
// VERZIJA: 1.0
// DATUM: 2025-01-10

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/services/kiosk_service.dart';

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
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  
  bool _isLoading = false;
  String? _errorMessage;
  int _attempts = 0;
  static const int _maxAttempts = 5;

  @override
  void initState() {
    super.initState();
    // Auto-focus na PIN input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleUnlock() async {
    if (_pinController.text.isEmpty) {
      setState(() => _errorMessage = 'Unesite PIN');
      return;
    }

    if (_attempts >= _maxAttempts) {
      setState(() => _errorMessage = 'Previše pokušaja. Pokušajte kasnije.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await KioskService.unlockWithPin(_pinController.text);
      
      if (success) {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        _attempts++;
        setState(() {
          _errorMessage = 'Pogrešan PIN. Preostalo pokušaja: ${_maxAttempts - _attempts}';
          _pinController.clear();
        });
        _focusNode.requestFocus();
      }
    } catch (e) {
      setState(() => _errorMessage = 'Greška: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.lock_outline,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 12),
          const Text('Kiosk Mode'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Unesite PIN za izlaz iz kiosk mode-a:',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          
          // PIN Input
          TextField(
            controller: _pinController,
            focusNode: _focusNode,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              hintText: '● ● ● ●',
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.password),
              errorText: _errorMessage,
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              letterSpacing: 8,
            ),
            onSubmitted: (_) => _handleUnlock(),
          ),
          
          const SizedBox(height: 8),
          
          // Info text
          Text(
            'Kontaktirajte administratora ako ne znate PIN.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Odustani'),
        ),
        ElevatedButton(
          onPressed: _isLoading || _attempts >= _maxAttempts ? null : _handleUnlock,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Otključaj'),
        ),
      ],
    );
  }
}


// ============================================================
// HIDDEN TAP DETECTOR - Za skriveni pristup settings-ima
// ============================================================

/// Widget koji detektira skriveni tap pattern za pristup kiosk exit dialogu
/// Koristi se npr. 5x tap na logo ili određeni dio ekrana
class HiddenKioskExitTrigger extends StatefulWidget {
  final Widget child;
  final int requiredTaps;
  final Duration resetDuration;
  final VoidCallback? onTriggered;

  const HiddenKioskExitTrigger({
    super.key,
    required this.child,
    this.requiredTaps = 5,
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
