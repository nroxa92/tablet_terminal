// FILE: lib/ui/screens/setup_screen.dart
// VERZIJA: 2.1 - PREZENTACIJSKA verzija s reklamnim prostorom
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/firestore_service.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tenantIdController = TextEditingController();
  final _unitIdController = TextEditingController();

  bool _isLoading = false;
  String _statusMessage = "";
  bool _isError = false;

  Future<void> _handleBinding() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _statusMessage = "Connecting...";
      _isError = false;
    });

    final tenantId = _tenantIdController.text.trim().toUpperCase();
    final unitId = _unitIdController.text.trim().toUpperCase();

    try {
      debugPrint("Checking tenant: $tenantId");

      final tenantDoc = await FirebaseFirestore.instance
          .collection('tenant_links')
          .doc(tenantId)
          .get();

      if (!tenantDoc.exists) {
        throw "Tenant ID '$tenantId' not found.";
      }

      final tenantData = tenantDoc.data()!;

      if (tenantData['status'] != 'active') {
        throw "Tenant account is not active.";
      }

      debugPrint("Tenant found: ${tenantData['displayName']}");

      if (mounted) {
        setState(() => _statusMessage = "Finding unit...");
      }

      debugPrint("Looking for unit: $unitId");

      final unitDoc = await FirebaseFirestore.instance
          .collection('units')
          .doc(unitId)
          .get();

      if (!unitDoc.exists) {
        throw "Unit '$unitId' not found.";
      }

      final unitData = unitDoc.data()!;
      debugPrint("Unit found: ${unitData['name']}");

      final unitOwnerId = unitData['ownerId']?.toString().toUpperCase() ?? '';

      if (unitOwnerId != tenantId) {
        throw "Unit '$unitId' doesn't belong to tenant '$tenantId'.";
      }

      debugPrint("Ownership verified");

      if (mounted) {
        setState(() => _statusMessage = "Registering device...");
      }

      await StorageService.setUnitId(unitId);
      await StorageService.setOwnerId(tenantId);

      await StorageService.setVillaData(
        unitData['name'] ?? 'Villa Guest',
        unitData['address'] ?? '',
        unitData['wifi_ssid'] ?? '',
        unitData['wifi_pass'] ?? '',
        unitData['contact_phone'] ?? '',
      );

      if (unitData['contacts'] != null) {
        final Map<String, String> contacts = {};
        (unitData['contacts'] as Map).forEach((key, value) {
          contacts[key.toString()] = value.toString();
        });
        await StorageService.setContactOptions(contacts);
      }

      debugPrint("Local storage saved");

      if (mounted) {
        setState(() => _statusMessage = "Syncing settings...");
      }

      await FirestoreService.syncUnitSettings();

      debugPrint("Settings synced");

      if (!mounted) return;

      setState(() {
        _statusMessage = "Connected!";
        _isError = false;
      });

      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } catch (e) {
      debugPrint("Setup error: $e");
      if (mounted) {
        setState(() {
          _statusMessage = "$e";
          _isError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tenantIdController.dispose();
    _unitIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ═══════════════════════════════════════════════════════
              // LIJEVA STRANA - VillaOS Branding
              // ═══════════════════════════════════════════════════════
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1A1A1A),
                        Color(0xFF0D0D0D),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFD4AF37), Color(0xFFB8962E)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4AF37)
                                  .withValues(alpha: 0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.villa,
                          size: 45,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "VillaOS",
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Digital Reception System",
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 13,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ═══════════════════════════════════════════════════════
              // SREDINA - Premium Reklama
              // ═══════════════════════════════════════════════════════
              Expanded(
                flex: 4,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF1E1E1E),
                        Color(0xFF121212),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Background pattern
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: CustomPaint(
                            painter: _GridPainter(),
                          ),
                        ),
                      ),

                      // Content
                      Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Stats row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatItem("500+", "Properties"),
                                _buildStatDivider(),
                                _buildStatItem("50K+", "Check-ins"),
                                _buildStatDivider(),
                                _buildStatItem("99%", "Uptime"),
                              ],
                            ),

                            const SizedBox(height: 28),

                            // Main message
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFFD4AF37), Color(0xFFF4E4BC)],
                              ).createShader(bounds),
                              child: const Text(
                                "The Receptionist\nThat Never Sleeps",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            Text(
                              "Automate check-in, delight guests,\nboost your reviews",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Features
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildFeatureChip(
                                    Icons.document_scanner, "OCR Scan"),
                                const SizedBox(width: 12),
                                _buildFeatureChip(Icons.smart_toy, "AI Agent"),
                                const SizedBox(width: 12),
                                _buildFeatureChip(Icons.star, "Reviews"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ═══════════════════════════════════════════════════════
              // DESNA STRANA - Connect Forma
              // ═══════════════════════════════════════════════════════
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.only(left: 12),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "CONNECT DEVICE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Link this tablet to your property",
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                        const SizedBox(height: 24),
                        _buildTextField(
                          controller: _tenantIdController,
                          label: "Tenant ID",
                          hint: "e.g. TEST22",
                          icon: Icons.business,
                        ),
                        const SizedBox(height: 14),
                        _buildTextField(
                          controller: _unitIdController,
                          label: "Unit ID",
                          hint: "e.g. PLAVI",
                          icon: Icons.home,
                        ),
                        const SizedBox(height: 18),
                        if (_statusMessage.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: _isError
                                  ? Colors.red.withValues(alpha: 0.1)
                                  : const Color(0xFFD4AF37)
                                      .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _isError
                                    ? Colors.red.withValues(alpha: 0.3)
                                    : const Color(0xFFD4AF37)
                                        .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isError
                                      ? Icons.error_outline
                                      : Icons.info_outline,
                                  color: _isError
                                      ? Colors.red
                                      : const Color(0xFFD4AF37),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _statusMessage,
                                    style: TextStyle(
                                      color: _isError
                                          ? Colors.red[300]
                                          : const Color(0xFFD4AF37),
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleBinding,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37),
                              foregroundColor: Colors.black,
                              disabledBackgroundColor: const Color(0xFFD4AF37)
                                  .withValues(alpha: 0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    "CONNECT",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      letterSpacing: 1,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withValues(alpha: 0.1),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFD4AF37), size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      textCapitalization: TextCapitalization.characters,
      validator: (value) =>
          value == null || value.trim().isEmpty ? "Required" : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
        prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

// Custom painter za grid pattern u pozadini
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;

    const spacing = 30.0;

    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
