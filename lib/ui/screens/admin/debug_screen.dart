// FILE: lib/ui/screens/admin/debug_screen.dart
// OPIS: Debug Panel za QA testiranje - 5 tabova
// VERZIJA: 1.0 - FAZA 4
// DATUM: 2026-01-10

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/services/kiosk_service.dart';
import '../../../data/services/sentry_service.dart';
import '../../../data/services/connectivity_service.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, _TestResult> _testResults = {};
  bool _isRunningTests = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    SentryService.logUserAction('debug_panel_opened');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
        title: const Row(
          children: [
            Icon(Icons.bug_report, color: Color(0xFFD4AF37), size: 24),
            SizedBox(width: 12),
            Text('DEBUG PANEL',
                style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFD4AF37),
          labelColor: const Color(0xFFD4AF37),
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontSize: 11),
          tabs: const [
            Tab(icon: Icon(Icons.info_outline, size: 20), text: 'Status'),
            Tab(icon: Icon(Icons.cloud, size: 20), text: 'Firebase'),
            Tab(icon: Icon(Icons.storage, size: 20), text: 'Storage'),
            Tab(icon: Icon(Icons.play_arrow, size: 20), text: 'Tests'),
            Tab(icon: Icon(Icons.flash_on, size: 20), text: 'Actions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatusTab(),
          _buildFirebaseTab(),
          _buildStorageTab(),
          _buildTestsTab(),
          _buildActionsTab(),
        ],
      ),
    );
  }

  // TAB 1: STATUS
  Widget _buildStatusTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('📱 DEVICE', [
            _buildRow('Unit ID', StorageService.getUnitId() ?? 'N/A'),
            _buildRow('Owner ID', StorageService.getOwnerId() ?? 'N/A'),
            _buildRow('Villa', StorageService.getVillaName()),
            _buildRow('Registered', StorageService.isRegistered().toString()),
          ]),
          _buildSection('🔒 KIOSK', [
            ...KioskService.getDebugInfo()
                .entries
                .map((e) => _buildRow(e.key, e.value.toString())),
          ]),
          _buildSection('🌐 CONNECTIVITY', [
            FutureBuilder<bool>(
              future: ConnectivityService.checkConnection(),
              builder: (context, snapshot) => _buildRow(
                  'Internet', snapshot.data == true ? '✅ Online' : '❌ Offline'),
            ),
          ]),
          _buildSection('📊 BOOKING', [
            _buildRow('Booking ID', StorageService.getBookingId() ?? 'N/A'),
            ...StorageService.getCurrentBooking()
                .entries
                .take(5)
                .map((e) => _buildRow(e.key, e.value?.toString() ?? 'null')),
          ]),
        ],
      ),
    );
  }

  // TAB 2: FIREBASE
  Widget _buildFirebaseTab() {
    final ownerId = StorageService.getOwnerId();
    final unitId = StorageService.getUnitId();

    if (ownerId == null || unitId == null) {
      return const Center(
          child:
              Text('No owner/unit ID', style: TextStyle(color: Colors.grey)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('🔥 FIRESTORE DOCUMENTS'),
          const SizedBox(height: 12),
          _buildFirebaseDoc('owners/$ownerId',
              FirebaseFirestore.instance.collection('owners').doc(ownerId)),
          _buildFirebaseDoc(
              'owners/$ownerId/units/$unitId',
              FirebaseFirestore.instance
                  .collection('owners')
                  .doc(ownerId)
                  .collection('units')
                  .doc(unitId)),
          _buildFirebaseDoc('settings/$ownerId',
              FirebaseFirestore.instance.collection('settings').doc(ownerId)),
          const SizedBox(height: 16),
          _buildSectionTitle('📱 TABLET DOCUMENT'),
          const SizedBox(height: 12),
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('tablets')
                .where('ownerId', isEqualTo: ownerId)
                .where('unitId', isEqualTo: unitId)
                .limit(1)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildErrorCard('Tablet document NOT FOUND');
              }
              final doc = snapshot.data!.docs.first;
              return _buildDataCard(
                  'tablets/${doc.id}', doc.data() as Map<String, dynamic>);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFirebaseDoc(String path, DocumentReference ref) {
    return FutureBuilder<DocumentSnapshot>(
      future: ref.get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            color: const Color(0xFF1E1E1E),
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(path,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
              trailing: const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildErrorCard('$path - NOT FOUND');
        }
        return _buildDataCard(
            path, snapshot.data!.data() as Map<String, dynamic>);
      },
    );
  }

  Widget _buildDataCard(String title, Map<String, dynamic> data) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: const Icon(Icons.check_circle, color: Colors.green, size: 20),
        title: Text(title,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        subtitle: Text('${data.length} fields',
            style: TextStyle(color: Colors.grey[600], fontSize: 10)),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.black26,
            child: SelectableText(_formatJson(data),
                style: const TextStyle(
                    color: Colors.grey, fontSize: 11, fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
          leading: const Icon(Icons.error, color: Colors.red, size: 20),
          title: Text(message,
              style: const TextStyle(color: Colors.red, fontSize: 12))),
    );
  }

  String _formatJson(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    data.forEach((key, value) {
      final displayValue = value is Timestamp
          ? value.toDate().toString()
          : value?.toString() ?? 'null';
      buffer.writeln('$key: $displayValue');
    });
    return buffer.toString();
  }

  // TAB 3: STORAGE
  Widget _buildStorageTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('💾 LOCAL STORAGE (Hive)'),
          const SizedBox(height: 16),
          _buildStorageSection('Identity', {
            'unit_id': StorageService.getUnitId(),
            'owner_id': StorageService.getOwnerId(),
            'registered': StorageService.isRegistered()
          }),
          _buildStorageSection('Villa Data', StorageService.getVillaData()),
          _buildStorageSection('Contacts', StorageService.getContactOptions()),
          _buildStorageSection(
              'Current Booking', StorageService.getCurrentBooking()),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _dumpAllStorage,
              icon: const Icon(Icons.copy_all),
              label: const Text('COPY ALL TO CLIPBOARD'),
              style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD4AF37),
                  side: const BorderSide(color: Color(0xFFD4AF37)),
                  padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageSection(String title, Map<String, dynamic> data) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(title,
            style: const TextStyle(color: Colors.white, fontSize: 14)),
        subtitle: Text('${data.length} items',
            style: TextStyle(color: Colors.grey[600], fontSize: 11)),
        children: data.entries.map((e) {
          final value = e.value?.toString() ?? 'null';
          return ListTile(
            dense: true,
            title: Text(e.key,
                style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            subtitle: Text(
                value.length > 100 ? '${value.substring(0, 100)}...' : value,
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Copied: ${e.key}'),
                  duration: const Duration(seconds: 1)));
            },
          );
        }).toList(),
      ),
    );
  }

  void _dumpAllStorage() {
    final buffer = StringBuffer();
    buffer.writeln('=== VILLAOS STORAGE DUMP ===');
    buffer.writeln('Timestamp: ${DateTime.now()}');
    buffer.writeln('Unit: ${StorageService.getUnitId()}');
    buffer.writeln('Owner: ${StorageService.getOwnerId()}');
    buffer.writeln('');
    buffer.writeln('--- Villa Data ---');
    StorageService.getVillaData().forEach((k, v) => buffer.writeln('$k: $v'));
    buffer.writeln('');
    buffer.writeln('--- Booking ---');
    StorageService.getCurrentBooking()
        .forEach((k, v) => buffer.writeln('$k: $v'));

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Storage dump copied to clipboard'),
        backgroundColor: Colors.green));
  }

  // TAB 4: TESTS
  Widget _buildTestsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isRunningTests ? null : _runAllTests,
              icon: _isRunningTests
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black))
                  : const Icon(Icons.play_arrow),
              label: Text(_isRunningTests ? 'RUNNING...' : 'RUN ALL TESTS'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildTestItem('Storage Service', 'storage', _testStorage),
              _buildTestItem('Firebase Connection', 'firebase', _testFirebase),
              _buildTestItem('Kiosk Service', 'kiosk', _testKiosk),
              _buildTestItem('Connectivity', 'connectivity', _testConnectivity),
              _buildTestItem('Sentry Service', 'sentry', _testSentry),
            ],
          ),
        ),
        if (_testResults.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1E1E1E),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    'Passed: ${_testResults.values.where((r) => r.passed).length}/${_testResults.length}',
                    style: const TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold)),
                const SizedBox(width: 24),
                Text(
                    'Failed: ${_testResults.values.where((r) => !r.passed).length}',
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTestItem(
      String name, String key, Future<_TestResult> Function() testFn) {
    final result = _testResults[key];
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
            result == null
                ? Icons.circle_outlined
                : result.passed
                    ? Icons.check_circle
                    : Icons.error,
            color: result == null
                ? Colors.grey
                : result.passed
                    ? Colors.green
                    : Colors.red),
        title: Text(name, style: const TextStyle(color: Colors.white)),
        subtitle: result != null
            ? Text(result.message,
                style: TextStyle(
                    color: result.passed ? Colors.green : Colors.red,
                    fontSize: 11))
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.play_arrow, color: Color(0xFFD4AF37)),
          onPressed: () async {
            final r = await testFn();
            setState(() => _testResults[key] = r);
          },
        ),
      ),
    );
  }

  Future<void> _runAllTests() async {
    setState(() {
      _isRunningTests = true;
      _testResults.clear();
    });
    _testResults['storage'] = await _testStorage();
    setState(() {});
    _testResults['firebase'] = await _testFirebase();
    setState(() {});
    _testResults['kiosk'] = await _testKiosk();
    setState(() {});
    _testResults['connectivity'] = await _testConnectivity();
    setState(() {});
    _testResults['sentry'] = await _testSentry();
    setState(() => _isRunningTests = false);
    final passed = _testResults.values.where((r) => r.passed).length;
    SentryService.addBreadcrumb(
        message: 'Debug tests: $passed/${_testResults.length} passed',
        category: 'debug');
  }

  Future<_TestResult> _testStorage() async {
    try {
      final unitId = StorageService.getUnitId();
      final ownerId = StorageService.getOwnerId();
      if (unitId == null) {
        return _TestResult(false, 'No unit_id');
      }
      if (ownerId == null) {
        return _TestResult(false, 'No owner_id');
      }
      return _TestResult(true, 'unit=$unitId');
    } catch (e) {
      return _TestResult(false, e.toString());
    }
  }

  Future<_TestResult> _testFirebase() async {
    try {
      final ownerId = StorageService.getOwnerId();
      if (ownerId == null) return _TestResult(false, 'No ownerId');
      final doc = await FirebaseFirestore.instance
          .collection('owners')
          .doc(ownerId)
          .get();
      if (!doc.exists) return _TestResult(false, 'Owner doc not found');
      return _TestResult(true, 'Connected');
    } catch (e) {
      return _TestResult(false, e.toString());
    }
  }

  Future<_TestResult> _testKiosk() async {
    try {
      final info = KioskService.getDebugInfo();
      return _TestResult(true, 'enabled=${info['isKioskEnabled']}');
    } catch (e) {
      return _TestResult(false, e.toString());
    }
  }

  Future<_TestResult> _testConnectivity() async {
    try {
      final online = await ConnectivityService.checkConnection();
      return _TestResult(online, online ? 'Online' : 'Offline');
    } catch (e) {
      return _TestResult(false, e.toString());
    }
  }

  Future<_TestResult> _testSentry() async {
    try {
      SentryService.addBreadcrumb(message: 'Debug test', category: 'debug');
      return _TestResult(true, 'Breadcrumb sent');
    } catch (e) {
      return _TestResult(false, e.toString());
    }
  }

  // TAB 5: ACTIONS
  Widget _buildActionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('🧭 NAVIGATION'),
          const SizedBox(height: 12),
          _buildActionButton('Go to Welcome', Icons.home,
              () => Navigator.pushReplacementNamed(context, '/')),
          _buildActionButton('Go to Dashboard', Icons.dashboard,
              () => Navigator.pushReplacementNamed(context, '/dashboard')),
          _buildActionButton('Go to Setup', Icons.settings,
              () => Navigator.pushReplacementNamed(context, '/setup')),
          _buildActionButton('Test Check-in Flow', Icons.login,
              () => Navigator.pushNamed(context, '/checkin_intro')),
          const SizedBox(height: 24),
          _buildSectionTitle('🔧 SERVICES'),
          const SizedBox(height: 12),
          _buildActionButton('Clear Guest Data', Icons.person_remove, () async {
            await StorageService.clearGuestData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Guest data cleared'),
                  backgroundColor: Colors.green));
            }
          }),
          const SizedBox(height: 24),
          _buildSectionTitle('🐛 SENTRY'),
          const SizedBox(height: 12),
          _buildActionButton('Send Test Breadcrumb', Icons.message, () {
            SentryService.addBreadcrumb(
                message: 'Test breadcrumb from Debug Panel', category: 'debug');
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Breadcrumb sent')));
          }),
          _buildActionButton('Send Test Error', Icons.error, () {
            SentryService.captureMessage('Test error from Debug Panel',
                level: SentryLevel.error);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Error sent to Sentry'),
                backgroundColor: Colors.orange));
          }),
          const SizedBox(height: 24),
          _buildSectionTitle('⚠️ DANGER'),
          const SizedBox(height: 12),
          _buildActionButton('Force Crash (Sentry Test)', Icons.bug_report, () {
            throw Exception('Debug forced crash');
          }, isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap,
      {bool isDestructive = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 20),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isDestructive ? Colors.red : const Color(0xFF2A2A2A),
            foregroundColor:
                isDestructive ? Colors.white : const Color(0xFFD4AF37),
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.centerLeft,
          ),
        ),
      ),
    );
  }

  // HELPERS
  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(title,
      style: const TextStyle(
          color: Color(0xFFD4AF37),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1));

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
              width: 140,
              child: Text(label,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(color: Colors.white, fontSize: 12))),
        ],
      ),
    );
  }
}

class _TestResult {
  final bool passed;
  final String message;
  _TestResult(this.passed, this.message);
}
