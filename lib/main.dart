// FILE: lib/main.dart
// OPIS: Entry point. Učitava servise, Firebase i provjerava auth session.
// VERZIJA: 2.1 - Integriran GuestScanCoordinator

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'config/theme.dart';
import 'config/constants.dart';
import 'data/services/storage_service.dart';
import 'data/services/tablet_auth_service.dart';
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
import 'ui/screens/checkin/guest_scan_coordinator.dart'; // NOVI IMPORT
import 'ui/screens/house_rules_screen.dart';

// CHAT & FEEDBACK
import 'ui/screens/chat_screen.dart';
import 'ui/screens/feedback_screen.dart';

void main() async {
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

    // 5. UČITAJ API KLJUČEVE IZ BAZE
    await AppConstants.loadFromFirebase();
  } catch (e) {
    debugPrint("❌ FIREBASE/CONFIG ERROR: $e");
  }

  // 6. PROVJERI POSTOJEĆI AUTH SESSION
  String initialRoute = '/setup';

  if (firebaseReady) {
    initialRoute = await _determineInitialRoute();
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
      return '/setup';
    }

    debugPrint("✅ Valid session found");

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
  } catch (e) {
    debugPrint("❌ Route determination error: $e");
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
      title: 'Villa AI Concierge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      navigatorKey: navigatorKey,

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
