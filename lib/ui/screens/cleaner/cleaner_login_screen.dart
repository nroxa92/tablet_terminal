// FILE: lib/ui/screens/cleaner/cleaner_login_screen.dart
// OPIS: PIN pristup za čistačice i master reset.
// VERZIJA: 2.0 - Dinamički PIN-ovi iz Settings + Factory Reset

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/services/tablet_auth_service.dart';

class CleanerLoginScreen extends StatefulWidget {
  const CleanerLoginScreen({super.key});

  @override
  State<CleanerLoginScreen> createState() => _CleanerLoginScreenState();
}

class _CleanerLoginScreenState extends State<CleanerLoginScreen> {
  final _pinController = TextEditingController();
  String _error = "";
  bool _isLoading = false;

  // PIN-ovi se čitaju iz Storage (sync-ani iz Firestore Settings)
  late String _cleanerPin;
  late String _masterPin;

  @override
  void initState() {
    super.initState();
    _loadPins();
  }

  void _loadPins() {
    // Čitamo PIN-ove iz lokalnog storage-a (sync-ani iz Firestore)
    _cleanerPin = StorageService.getCleanerPin();
    _masterPin = StorageService.getMasterPin();

    debugPrint("🔐 Loaded PINs - Cleaner: $_cleanerPin, Master: $_masterPin");
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _verifyPin() async {
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
      // ✅ CLEANER PIN - Idi na Cleaner Tasks
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/cleaner_tasks');
      }
    } else if (pin == _masterPin) {
      // ⚠️ MASTER PIN - Factory Reset
      await _performFactoryReset();
    } else {
      // ❌ Krivi PIN
      setState(() {
        _error = "Invalid PIN";
        _isLoading = false;
      });
      _pinController.clear();

      // Vibriraj (ako je dostupno)
      // HapticFeedback.heavyImpact();
    }
  }

  Future<void> _performFactoryReset() async {
    // Pokaži confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text("Factory Reset", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          "This will unlink this tablet from the current property.\n\n"
          "Use this when moving the tablet to a different unit.\n\n"
          "Are you sure?",
          style: TextStyle(color: Colors.grey, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("RESET"),
          ),
        ],
      ),
    );

    if (confirm != true) {
      setState(() => _isLoading = false);
      _pinController.clear();
      return;
    }

    // Izvršava Factory Reset
    try {
      await TabletAuthService.fullReset();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text("Device unlinked successfully"),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Idi na Setup Screen
        Navigator.pushNamedAndRemoveUntil(context, '/setup', (r) => false);
      }
    } catch (e) {
      debugPrint("❌ Factory reset error: $e");
      if (mounted) {
        setState(() {
          _error = "Reset failed: $e";
          _isLoading = false;
        });
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
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    size: 35,
                    color: Color(0xFFD4AF37),
                  ),
                ),

                const SizedBox(height: 24),

                // TITLE
                const Text(
                  "STAFF ACCESS",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 8),

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
                          Text(
                            _error,
                            style: const TextStyle(color: Colors.red),
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
                        Icons.settings_backup_restore,
                        "Master PIN",
                        "Factory reset (relocate tablet)",
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
