// FILE: lib/main.dart
// OPIS: Entry point s BARREL importima
// VERZIJA: 7.0 - Barrel Implementation
// DATUM: 2026-01-10

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

// ═══════════════════════════════════════════════════════════════════════════
// BARREL IMPORTS - Čisti i organizirani importi
// ═══════════════════════════════════════════════════════════════════════════
import 'config/config.dart';
import 'data/services/services.dart';
import 'ui/screens/screens.dart';
import 'utils/utils.dart';

void main() async {
  await SentryService.init(() async {
    await _initializeApp();
  });
}

Future<void> _initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. ZAKLJUČAVANJE ORIJENTACIJE (LANDSCAPE)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // 2. FULLSCREEN MODE (IMMERSIVE)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // 3. LOKALNA BAZA
  await Hive.initFlutter();
  await StorageService.init();

  // 4. OFFLINE QUEUE INIT
  await OfflineQueueService.init();
  debugPrint(
      "📦 Offline queue ready. Pending: ${OfflineQueueService.pendingCount}");

  // 5. FIREBASE
  bool firebaseReady = false;
  try {
    await Firebase.initializeApp();
    debugPrint("✅ FIREBASE CONNECTED");
    firebaseReady = true;

    // 6. FIREBASE PERFORMANCE
    await PerformanceService.setEnabled(true);
    debugPrint("✅ PERFORMANCE MONITORING ENABLED");

    // 7. UČITAJ API KLJUČEVE IZ BAZE
    await AppConstants.loadFromFirebase();
  } catch (e, stackTrace) {
    debugPrint("❌ FIREBASE/CONFIG ERROR: $e");
    SentryService.captureException(e,
        stackTrace: stackTrace, hint: 'Firebase init failed');
  }

  // 8. CONNECTIVITY SERVICE
  await ConnectivityService.init();
  debugPrint(
      "📡 Connectivity service ready. Online: ${ConnectivityService.isOnline}");

  // 9. PROCESS PENDING QUEUE (ako smo online)
  if (ConnectivityService.isOnline &&
      OfflineQueueService.hasPendingOperations) {
    debugPrint("🔄 Processing pending offline operations...");
    final processed = await OfflineQueueService.processQueue();
    debugPrint("✅ Processed $processed pending operations");
  }

  // 10. PROVJERI POSTOJEĆI AUTH SESSION
  String initialRoute = '/setup';

  if (firebaseReady) {
    initialRoute = await _determineInitialRoute();

    // 11. POSTAVI SENTRY KONTEKST
    await SentryService.setDeviceContext();

    // 12. KIOSK SERVICE INIT
    if (StorageService.isRegistered()) {
      await KioskService.init();
      debugPrint(
          "🔒 Kiosk service ready. Enabled: ${KioskService.isKioskEnabled}");
    }
  }

  runApp(VillaApp(initialRoute: initialRoute));
}

Future<String> _determineInitialRoute() async {
  try {
    final hasValidSession = await TabletAuthService.tryRestoreSession();

    if (!hasValidSession) {
      debugPrint("🔐 No valid session → Setup");
      SentryService.addBreadcrumb(
          message: 'No valid session', category: 'auth');
      return '/setup';
    }

    debugPrint("✅ Valid session found");
    SentryService.addBreadcrumb(message: 'Session restored', category: 'auth');

    TabletAuthService.startAutoRefresh();
    TabletAuthService.startHeartbeat();

    final checkInStatus = StorageService.getCheckInStatus();
    final welcomeDone = StorageService.isWelcomeDone();

    debugPrint("📊 Status: welcomeDone=$welcomeDone, checkIn=$checkInStatus");

    if (!welcomeDone) return '/';
    if (checkInStatus == 'pending') return '/house_rules';
    if (checkInStatus == 'completed') return '/dashboard';

    return '/';
  } catch (e, stackTrace) {
    debugPrint("❌ Route determination error: $e");
    SentryService.captureException(e,
        stackTrace: stackTrace, hint: 'Route determination failed');
    return '/setup';
  }
}

class VillaApp extends StatefulWidget {
  final String initialRoute;

  const VillaApp({super.key, required this.initialRoute});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  State<VillaApp> createState() => _VillaAppState();
}

class _VillaAppState extends State<VillaApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ConnectivityService.dispose();
    KioskService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    debugPrint("📱 App lifecycle: $state");

    if (state == AppLifecycleState.resumed) {
      if (KioskService.isKioskEnabled) {
        debugPrint("🔒 Re-enabling kiosk mode on resume...");
        KioskService.enableKioskMode();
        KioskService.hideSystemBars();
      }
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vesta Lumina',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      navigatorKey: VillaApp.navigatorKey,
      navigatorObservers: [
        _SentryNavigatorObserver(),
      ],
      builder: (context, child) {
        return InactivityWrapper(
          timeout: const Duration(seconds: 120),
          child: child!,
        );
      },
      initialRoute: widget.initialRoute,
      routes: {
        // Main Screens
        '/': (context) => const WelcomeScreen(),
        '/setup': (context) => const SetupScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/house_rules': (context) => const HouseRulesScreen(),
        '/feedback': (context) => const FeedbackScreen(),
        '/screensaver': (context) => const ScreensaverScreen(),

        // Check-in Flow
        '/checkin_intro': (context) => const CheckInIntroScreen(),

        // Cleaner Flow
        '/cleaner_login': (context) => const CleanerLoginScreen(),
        '/cleaner_tasks': (context) => const CleanerTasksScreen(),

        // Admin
        '/admin': (context) => const AdminMenuScreen(),
        '/debug': (context) => const DebugScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/guest-scan') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => GuestScanCoordinator(
              bookingId: args?['bookingId'] ?? '',
              unitId: args?['unitId'] ?? '',
            ),
          );
        }

        if (settings.name == '/chat') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => ChatScreen(
              agentId: args?['id'] ?? 'reception',
              agentTitle: args?['title'] ?? 'Reception',
              agentIcon: args?['icon'] ?? Icons.support_agent,
              agentColor: args?['color'] ?? const Color(0xFFD4AF37),
            ),
          );
        }

        return null;
      },
    );
  }
}

class _SentryNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    SentryService.logNavigation(
      previousRoute?.settings.name ?? 'unknown',
      route.settings.name ?? 'unknown',
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    SentryService.logNavigation(
      route.settings.name ?? 'unknown',
      previousRoute?.settings.name ?? 'unknown',
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    SentryService.logNavigation(
      oldRoute?.settings.name ?? 'unknown',
      newRoute?.settings.name ?? 'unknown',
    );
  }
}
