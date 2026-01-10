// FILE: lib/ui/screens/cleaner/cleaner_tasks_screen.dart
// OPIS: Checklist za čistačice s taskovima iz Web Panela + napomena.
// VERZIJA: 5.0 - FAZA 2: OfflineBanner + Offline queue
// DATUM: 2026-01-10
//
// ⚠️ PROMJENA: Web Panel koristi 'cleanerChecklist', ne 'cleanerTasks'!

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/services/firestore_service.dart';
import '../../../data/services/connectivity_service.dart';
import '../../../data/services/offline_queue_service.dart';
import '../../widgets/offline_indicator.dart';

class CleanerTasksScreen extends StatefulWidget {
  const CleanerTasksScreen({super.key});

  @override
  State<CleanerTasksScreen> createState() => _CleanerTasksScreenState();
}

class _CleanerTasksScreenState extends State<CleanerTasksScreen> {
  // Task lista - Map<taskName, isCompleted>
  Map<String, bool> _tasks = {};
  bool _isLoadingTasks = true;

  // Napomena za vlasnika
  final _notesController = TextEditingController();

  // Stanje
  bool _isSubmitting = false;
  String? _errorMessage;

  // Info o jedinici
  String _unitName = "";
  String? _currentBookingId;

  @override
  void initState() {
    super.initState();
    _loadTasksAndInfo();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  /// Učitava taskove iz Firestore Settings + info o jedinici
  Future<void> _loadTasksAndInfo() async {
    try {
      final ownerId = StorageService.getOwnerId();

      // Dohvati ime vile
      final villaData = StorageService.getVillaData();
      _unitName = villaData['name'] ?? 'Unit';

      // Dohvati trenutni booking ID
      _currentBookingId = await FirestoreService.getCurrentBookingId();
      debugPrint('📋 Current booking ID: $_currentBookingId');

      if (ownerId == null) {
        throw "Owner ID not found";
      }

      // ⭐ FAZA 2: Ako smo offline, koristi default taskove
      if (!ConnectivityService.isOnline) {
        debugPrint('📴 Offline - using default tasks');
        setState(() {
          _tasks = {for (var task in _getDefaultTasks()) task: false};
          _isLoadingTasks = false;
        });
        return;
      }

      // Dohvati taskove iz Settings
      final settingsDoc = await FirebaseFirestore.instance
          .collection('settings')
          .doc(ownerId)
          .get();

      List<String> taskList = [];

      if (settingsDoc.exists && settingsDoc.data() != null) {
        final data = settingsDoc.data()!;

        // ✅ FIX: Koristi 'cleanerChecklist' (kako Web Panel sprema)
        if (data['cleanerChecklist'] != null &&
            data['cleanerChecklist'] is List) {
          taskList = List<String>.from(data['cleanerChecklist']);
          debugPrint('✅ Loaded ${taskList.length} tasks from cleanerChecklist');
        }
        // Fallback za legacy 'cleanerTasks'
        else if (data['cleanerTasks'] != null && data['cleanerTasks'] is List) {
          taskList = List<String>.from(data['cleanerTasks']);
          debugPrint(
              '⚠️ Loaded ${taskList.length} tasks from legacy cleanerTasks');
        }
      }

      // Ako nema taskova u bazi, koristi default
      if (taskList.isEmpty) {
        taskList = _getDefaultTasks();
        debugPrint('ℹ️ Using default task list');
      }

      setState(() {
        _tasks = {for (var task in taskList) task: false};
        _isLoadingTasks = false;
      });
    } catch (e) {
      debugPrint("❌ Error loading tasks: $e");

      // Fallback na default taskove
      setState(() {
        _tasks = {for (var task in _getDefaultTasks()) task: false};
        _isLoadingTasks = false;
        _errorMessage = "Using default checklist (couldn't load from server)";
      });
    }
  }

  /// Default taskovi ako nema u bazi
  List<String> _getDefaultTasks() {
    return [
      'Change bed linen & make beds',
      'Clean bathroom & replace towels',
      'Vacuum & mop all floors',
      'Clean kitchen & appliances',
      'Empty all trash bins',
      'Check minibar / fridge',
      'Clean balcony / terrace',
      'Check all lights & remotes',
      'Restock toiletries',
      'Final inspection',
    ];
  }

  /// Izračunaj postotak dovršenosti
  double get _completionPercentage {
    if (_tasks.isEmpty) return 0;
    final completed = _tasks.values.where((v) => v).length;
    return completed / _tasks.length;
  }

  /// Provjeri jesu li svi taskovi završeni
  bool get _allTasksCompleted {
    return _tasks.values.every((v) => v);
  }

  /// Završi čišćenje i pokreni cleanup
  Future<void> _finishCleaning() async {
    // Upozori ako nisu svi taskovi završeni
    if (!_allTasksCompleted) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange),
              SizedBox(width: 12),
              Text("Incomplete Tasks", style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const Text(
            "Not all tasks are checked.\nAre you sure you want to finish?",
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child:
                  const Text("GO BACK", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text("FINISH ANYWAY"),
            ),
          ],
        ),
      );

      if (proceed != true) return;
    }

    setState(() => _isSubmitting = true);

    try {
      // ⭐ FAZA 2: Provjeri internet konekciju
      final isOnline = ConnectivityService.isOnline;

      // 1. SPREMI CLEANING LOG
      if (isOnline) {
        await FirestoreService.saveCleaningLog(
          tasks: _tasks,
          notes: _notesController.text.trim(),
          bookingId: _currentBookingId,
        );
      } else {
        // Offline - stavi u queue
        await OfflineQueueService.queueSaveCleaningLog(
          tasks: _tasks,
          notes: _notesController.text.trim(),
          bookingId: _currentBookingId,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.cloud_queue, color: Colors.white),
                  SizedBox(width: 10),
                  Text("Report saved. Will sync when online."),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }

      // ═══════════════════════════════════════════════════════
      // ⭐ 2. FIREBASE CLEANUP - GDPR compliant (samo ako smo online)
      // ═══════════════════════════════════════════════════════
      Map<String, int> cleanupResults = {};

      if (_currentBookingId != null && isOnline) {
        debugPrint('🧹 Starting Firebase cleanup...');

        // Pokaži progress dialog
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20),
                  CircularProgressIndicator(color: Color(0xFFD4AF37)),
                  SizedBox(height: 24),
                  Text(
                    "Cleaning up data...",
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Archiving booking, deleting signatures...",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          );
        }

        // Izvrši cleanup
        cleanupResults = await FirestoreService.performCheckoutCleanup(
          _currentBookingId!,
        );

        // Zatvori progress dialog
        if (mounted) Navigator.pop(context);

        debugPrint('✅ Cleanup results: $cleanupResults');
      }

      // 3. OČISTI LOKALNE PODATKE (Pripremi za novog gosta)
      await StorageService.clearGuestData();

      if (!mounted) return;

      // 4. PRIKAŽI USPJEH S DETALJIMA
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Cleaning Complete!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _unitName,
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),

              // ⭐ Cleanup summary (samo ako smo online i imamo rezultate)
              if (cleanupResults.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Data Cleanup Summary",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildCleanupRow(
                        Icons.draw,
                        "Signatures deleted",
                        cleanupResults['signatures_deleted'] ?? 0,
                      ),
                      const SizedBox(height: 8),
                      _buildCleanupRow(
                        Icons.people,
                        "Guest records deleted",
                        cleanupResults['guests_deleted'] ?? 0,
                      ),
                      const SizedBox(height: 8),
                      _buildCleanupRow(
                        Icons.archive,
                        "Booking archived",
                        cleanupResults['booking_archived'] ?? 0,
                        isBoolean: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ⭐ Offline notice
              if (!isOnline) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.cloud_queue, color: Colors.orange, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Report queued. Data cleanup will run when online.",
                          style: TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              Text(
                isOnline
                    ? "Report sent to owner.\nTablet is ready for new guests."
                    : "Report saved locally.\nTablet is ready for new guests.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Zatvori dialog
                    // Vrati na Welcome screen (početak)
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "DONE",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      debugPrint("❌ Error finishing: $e");

      // Zatvori progress dialog ako je otvoren
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildCleanupRow(IconData icon, String label, int count,
      {bool isBoolean = false}) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: count > 0
                ? Colors.green.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isBoolean ? (count > 0 ? "✓" : "—") : count.toString(),
            style: TextStyle(
              color: count > 0 ? Colors.green : Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [
          // ⭐ FAZA 2: OFFLINE BANNER
          const OfflineBanner(),

          // GLAVNI SADRŽAJ
          Expanded(
            child: _isLoadingTasks
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                  )
                : Row(
                    children: [
                      // ========== LIJEVI PANEL - INFO & PROGRESS ==========
                      Container(
                        width: 320,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                          ),
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // BACK BUTTON
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.arrow_back,
                                      color: Colors.white),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.white10,
                                  ),
                                ),

                                const Spacer(),

                                // CLEANER MODE INDICATOR
                                FadeInDown(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD4AF37)
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.cleaning_services,
                                            color: Color(0xFFD4AF37), size: 16),
                                        SizedBox(width: 8),
                                        Text(
                                          "CLEANER MODE",
                                          style: TextStyle(
                                            color: Color(0xFFD4AF37),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // UNIT NAME
                                FadeInLeft(
                                  delay: const Duration(milliseconds: 100),
                                  child: Text(
                                    _unitName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // BOOKING ID (ako postoji)
                                if (_currentBookingId != null)
                                  FadeInLeft(
                                    delay: const Duration(milliseconds: 150),
                                    child: Text(
                                      "Booking: ${_currentBookingId!.substring(0, _currentBookingId!.length > 8 ? 8 : _currentBookingId!.length)}...",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),

                                const SizedBox(height: 30),

                                // PROGRESS CIRCLE
                                FadeInUp(
                                  delay: const Duration(milliseconds: 200),
                                  child: Center(
                                    child: SizedBox(
                                      width: 180,
                                      height: 180,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          SizedBox(
                                            width: 180,
                                            height: 180,
                                            child: CircularProgressIndicator(
                                              value: _completionPercentage,
                                              strokeWidth: 12,
                                              backgroundColor:
                                                  Colors.white.withValues(alpha: 0.1),
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                _allTasksCompleted
                                                    ? Colors.green
                                                    : const Color(0xFFD4AF37),
                                              ),
                                            ),
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "${(_completionPercentage * 100).toInt()}%",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 42,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                "${_tasks.values.where((v) => v).length} of ${_tasks.length}",
                                                style: TextStyle(
                                                  color: Colors.grey[500],
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                const Spacer(),

                                // FINISH BUTTON
                                FadeInUp(
                                  delay: const Duration(milliseconds: 300),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 60,
                                    child: ElevatedButton.icon(
                                      onPressed: _isSubmitting
                                          ? null
                                          : _finishCleaning,
                                      icon: _isSubmitting
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Icon(
                                              _allTasksCompleted
                                                  ? Icons.check_circle
                                                  : Icons.send,
                                              size: 22,
                                            ),
                                      label: _isSubmitting
                                          ? const Text("PROCESSING...")
                                          : Text(
                                              _allTasksCompleted
                                                  ? "COMPLETE"
                                                  : "FINISH & REPORT",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _allTasksCompleted
                                            ? Colors.green
                                            : const Color(0xFFD4AF37),
                                        foregroundColor: _allTasksCompleted
                                            ? Colors.white
                                            : Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ========== DESNI PANEL - TASKS + NOTES ==========
                      Expanded(
                        child: SafeArea(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ERROR MESSAGE
                                if (_errorMessage != null)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 20),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.orange.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.info_outline,
                                          color: Colors.orange,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            _errorMessage!,
                                            style: const TextStyle(
                                              color: Colors.orange,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // TASK LIST
                                const Text(
                                  "TASKS",
                                  style: TextStyle(
                                    color: Color(0xFFD4AF37),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E1E1E),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.05),
                                    ),
                                  ),
                                  child: Column(
                                    children: _tasks.entries.map((entry) {
                                      final index = _tasks.keys
                                          .toList()
                                          .indexOf(entry.key);
                                      return FadeInRight(
                                        delay:
                                            Duration(milliseconds: 50 * index),
                                        child: _buildTaskItem(
                                            entry.key, entry.value),
                                      );
                                    }).toList(),
                                  ),
                                ),

                                const SizedBox(height: 30),

                                // NOTES SECTION
                                const Text(
                                  "NOTES FOR OWNER",
                                  style: TextStyle(
                                    color: Color(0xFFD4AF37),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Report issues, missing items, or anything the owner should know.",
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 13),
                                ),
                                const SizedBox(height: 16),

                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E1E1E),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.05),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _notesController,
                                    maxLines: 4,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText:
                                          "e.g. Broken lamp in bedroom, low on shampoo...",
                                      hintStyle:
                                          TextStyle(color: Colors.grey[700]),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.all(20),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 30),

                                // ⭐ CLEANUP INFO BOX
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.blue.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.info_outline,
                                          color: Colors.blue, size: 20),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          "When you tap FINISH, guest signatures and scanned documents will be permanently deleted for privacy.",
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(String taskName, bool isCompleted) {
    return InkWell(
      onTap: () {
        setState(() {
          _tasks[taskName] = !isCompleted;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ),
        child: Row(
          children: [
            // CHECKBOX
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCompleted ? Colors.green : Colors.grey,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),

            const SizedBox(width: 16),

            // TASK NAME
            Expanded(
              child: Text(
                taskName,
                style: TextStyle(
                  color: isCompleted ? Colors.grey : Colors.white,
                  fontSize: 15,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),

            // STATUS ICON
            if (isCompleted)
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
