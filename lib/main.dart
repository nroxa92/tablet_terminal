// FILE: lib/main.dart
// OPIS: Entry point. Učitava servise, Firebase i provjerava auth session.
// VERZIJA: 3.0 - FAZA 1: Sentry + Performance Monitoring
// DATUM: 2026-01-10

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'config/theme.dart';
import 'config/constants.dart';
import 'data/services/storage_service.dart';
import 'data/services/tablet_auth_service.dart';
import 'data/services/sentry_service.dart';
import 'data/services/performance_service.dart';
import 'utils/inactivity_wrapper.dart';

// EKRANI
import 'ui/screens/welcome_screen.dart';
import 'ui/screens/dashboard_screen.dart';
import 'ui/screens/setup_screen.dart';
import 'ui/screens/cleaner/cleaner_login_screen.dart';
import 'ui/screens/screensaver_screen.dart';
import 'ui/screens/cleaner/cleaner_tasks_screen.dart';

// CHECK-IN
import 'ui/screens/checkin/checkin_intro_screen.dart';
import 'ui/screens/checkin/guest_scan_coordinator.dart';
import 'ui/screens/house_rules_screen.dart';

// CHAT & FEEDBACK
import 'ui/screens/chat_screen.dart';
import 'ui/screens/feedback_screen.dart';

void main() async {
  // Sentry wrapper - hvata sve unhandled exceptions
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

  // 4. FIREBASE
  bool firebaseReady = false;
  try {
    await Firebase.initializeApp();
    debugPrint("✅ FIREBASE CONNECTED");
    firebaseReady = true;

    // 5. FIREBASE PERFORMANCE
    await PerformanceService.setEnabled(true);
    debugPrint("✅ PERFORMANCE MONITORING ENABLED");

    // 6. UČITAJ API KLJUČEVE IZ BAZE
    await AppConstants.loadFromFirebase();
  } catch (e, stackTrace) {
    debugPrint("❌ FIREBASE/CONFIG ERROR: $e");
    SentryService.captureException(e,
        stackTrace: stackTrace, hint: 'Firebase init failed');
  }

  // 7. PROVJERI POSTOJEĆI AUTH SESSION
  String initialRoute = '/setup';

  if (firebaseReady) {
    initialRoute = await _determineInitialRoute();

    // 8. POSTAVI SENTRY KONTEKST
    await SentryService.setDeviceContext();
  }

  runApp(VillaApp(initialRoute: initialRoute));
}

/// Određuje početnu rutu na temelju auth statusa i check-in statusa
Future<String> _determineInitialRoute() async {
  try {
    // 1. PROVJERI FIREBASE AUTH SESSION
    final hasValidSession = await TabletAuthService.tryRestoreSession();

    if (!hasValidSession) {
      debugPrint("🔐 No valid session → Setup");
      SentryService.addBreadcrumb(
          message: 'No valid session', category: 'auth');
      return '/setup';
    }

    debugPrint("✅ Valid session found");
    SentryService.addBreadcrumb(message: 'Session restored', category: 'auth');

    // 2. POKRENI AUTO REFRESH I HEARTBEAT
    TabletAuthService.startAutoRefresh();
    TabletAuthService.startHeartbeat();

    // 3. PROVJERI GUEST FLOW STATUS
    final checkInStatus = StorageService.getCheckInStatus();
    final welcomeDone = StorageService.isWelcomeDone();

    debugPrint("📊 Status: welcomeDone=$welcomeDone, checkIn=$checkInStatus");

    // LOGIKA RUTIRANJA:
    // - Ako welcome nije završen → Welcome (odabir jezika)
    // - Ako je check-in pending → CheckIn Intro
    // - Ako je check-in completed → Dashboard
    // - Default → Welcome

    if (!welcomeDone) {
      return '/'; // Welcome Screen
    }

    if (checkInStatus == 'pending') {
      return '/house_rules'; // Nastavi check-in od kuć. pravila
    }

    if (checkInStatus == 'completed') {
      return '/dashboard'; // Sve završeno
    }

    // Default - počni ispočetka
    return '/';
  } catch (e, stackTrace) {
    debugPrint("❌ Route determination error: $e");
    SentryService.captureException(e,
        stackTrace: stackTrace, hint: 'Route determination failed');
    return '/setup';
  }
}

class VillaApp extends StatelessWidget {
  final String initialRoute;

  const VillaApp({super.key, required this.initialRoute});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vesta Lumina',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      navigatorKey: navigatorKey,

      // NAVIGATION OBSERVER - logira navigaciju u Sentry
      navigatorObservers: [
        _SentryNavigatorObserver(),
      ],

      // SCREENSAVER LOGIKA
      builder: (context, child) {
        return InactivityWrapper(
          timeout: const Duration(seconds: 120), // 2 minute
          child: child!,
        );
      },

      initialRoute: initialRoute,

      routes: {
        '/': (context) => const WelcomeScreen(),
        '/setup': (context) => const SetupScreen(),
        '/checkin_intro': (context) => const CheckInIntroScreen(),
        '/house_rules': (context) => const HouseRulesScreen(),
        '/dashboard': (context) => const DashboardScreen(),

        // CLEANER FLOW
        '/cleaner_login': (context) => const CleanerLoginScreen(),
        '/cleaner_tasks': (context) => const CleanerTasksScreen(),

        '/screensaver': (context) => const ScreensaverScreen(),
        '/feedback': (context) => const FeedbackScreen(),
      },

      onGenerateRoute: (settings) {
        // GUEST SCAN FLOW (novi)
        if (settings.name == '/guest-scan') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => GuestScanCoordinator(
              bookingId: args?['bookingId'] ?? '',
              unitId: args?['unitId'] ?? '',
            ),
          );
        }

        // CHAT SCREEN
        if (settings.name == '/chat') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) {
              return ChatScreen(
                agentId: args?['id'] ?? 'reception',
                agentTitle: args?['title'] ?? 'Reception',
                agentIcon: args?['icon'] ?? Icons.support_agent,
                agentColor: args?['color'] ?? const Color(0xFFD4AF37),
              );
            },
          );
        }

        return null;
      },
    );
  }
}

/// Navigator Observer za Sentry - logira sve navigacije
class _SentryNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    final from = previousRoute?.settings.name ?? 'unknown';
    final to = route.settings.name ?? 'unknown';
    SentryService.logNavigation(from, to);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    final from = route.settings.name ?? 'unknown';
    final to = previousRoute?.settings.name ?? 'unknown';
    SentryService.logNavigation(from, to);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final from = oldRoute?.settings.name ?? 'unknown';
    final to = newRoute?.settings.name ?? 'unknown';
    SentryService.logNavigation(from, to);
  }
}
