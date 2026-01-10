// FILE: lib/ui/screens/admin/admin_menu_screen.dart
// OPIS: Admin meni - prikazuje se nakon uspješnog Master PIN unosa
// VERZIJA: 1.0 - FAZA 4
// DATUM: 2026-01-10

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../data/services/kiosk_service.dart';
import '../../../data/services/tablet_auth_service.dart';
import '../../../data/services/sentry_service.dart';
import '../../../data/services/storage_service.dart';
import 'debug_screen.dart';

class AdminMenuScreen extends StatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  bool _isProcessing = false;
  String _processingMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          Center(
            child: FadeInUp(
              duration: const Duration(milliseconds: 400),
              child: Container(
                width: 450,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
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
                    // HEADER
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.admin_panel_settings,
                          size: 35, color: Color(0xFFD4AF37)),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'ADMIN PANEL',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2),
                    ),
                    const SizedBox(height: 8),
                    Text('Master PIN verified',
                        style:
                            TextStyle(color: Colors.green[400], fontSize: 14)),

                    const SizedBox(height: 32),

                    // MENU OPTIONS
                    _buildMenuOption(
                      icon: Icons.bug_report,
                      title: 'Debug Panel',
                      subtitle: 'View system status, Firebase, logs',
                      color: Colors.blue,
                      onTap: _openDebugPanel,
                    ),
                    const SizedBox(height: 12),
                    _buildMenuOption(
                      icon: Icons.lock_open,
                      title: 'Disable Kiosk (5 min)',
                      subtitle: 'Temporary unlock for maintenance',
                      color: Colors.orange,
                      onTap: _disableKioskTemporarily,
                    ),
                    const SizedBox(height: 12),
                    _buildMenuOption(
                      icon: Icons.restart_alt,
                      title: 'Factory Reset',
                      subtitle: 'Unlink tablet, return to Setup',
                      color: Colors.red,
                      onTap: _confirmFactoryReset,
                      isDanger: true,
                    ),

                    const SizedBox(height: 24),

                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Back to Dashboard'),
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[600]),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.tablet_android,
                              color: Colors.grey[600], size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Unit: ${StorageService.getUnitId() ?? "N/A"}',
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFFD4AF37)),
                    const SizedBox(height: 20),
                    Text(_processingMessage,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: color.withValues(alpha: isDanger ? 0.5 : 0.2),
                width: isDanger ? 2 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: isDanger ? color : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[600]),
            ],
          ),
        ),
      ),
    );
  }

  void _openDebugPanel() {
    SentryService.logUserAction('admin_open_debug_panel');
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const DebugScreen()));
  }

  Future<void> _disableKioskTemporarily() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock_open, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Disable Kiosk?', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'Kiosk mode will be disabled for 5 minutes.\n\n'
          'This allows access to Android settings and other apps.\n\n'
          'Kiosk will automatically re-enable after timeout.',
          style: TextStyle(color: Colors.grey, height: 1.5),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child:
                  const Text('CANCEL', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('DISABLE'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isProcessing = true;
      _processingMessage = 'Disabling kiosk...';
    });

    try {
      await KioskService.disableKioskMode();
      SentryService.logUserAction('admin_kiosk_disabled_temp');

      Timer(const Duration(minutes: 5), () {
        if (KioskService.isKioskEnabled) {
          KioskService.enableKioskMode();
          SentryService.logUserAction('admin_kiosk_auto_reenabled');
        }
      });

      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Kiosk disabled for 5 minutes')
            ]),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _showError('Failed to disable kiosk: $e');
    }
  }

  Future<void> _confirmFactoryReset() async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.red, width: 2)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('FACTORY RESET', style: TextStyle(color: Colors.red)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This will:',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildResetItem('Unlink tablet from property'),
            _buildResetItem('Clear all local data'),
            _buildResetItem('Disable kiosk mode'),
            _buildResetItem('Return to Setup screen'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text(
                          'Use when relocating tablet to different unit',
                          style:
                              TextStyle(color: Colors.orange, fontSize: 12))),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child:
                  const Text('CANCEL', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            child: const Text('RESET',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    await _performFactoryReset();
  }

  Widget _buildResetItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Future<void> _performFactoryReset() async {
    setState(() {
      _isProcessing = true;
      _processingMessage = 'Performing factory reset...';
    });

    try {
      SentryService.logUserAction('factory_reset_initiated');
      await TabletAuthService.fullReset();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Device unlinked successfully')
            ]),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/setup', (r) => false);
      }
    } catch (e) {
      debugPrint('❌ Factory reset error: $e');
      SentryService.captureException(e, hint: 'Factory reset failed');
      setState(() => _isProcessing = false);
      _showError('Reset failed: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.error, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message))
        ]),
        backgroundColor: Colors.red,
      ),
    );
  }
}
