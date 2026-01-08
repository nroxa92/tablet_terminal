// FILE: lib/utils/inactivity_wrapper.dart
// VERZIJA: 2.0 - Screensaver SAMO na Dashboard ekranu
import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart';

class InactivityWrapper extends StatefulWidget {
  final Widget child;
  final Duration timeout;

  const InactivityWrapper({
    super.key,
    required this.child,
    this.timeout = const Duration(minutes: 2),
  });

  @override
  State<InactivityWrapper> createState() => _InactivityWrapperState();
}

class _InactivityWrapperState extends State<InactivityWrapper> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(widget.timeout, _handleInactivity);
  }

  void _resetTimer() {
    _startTimer();
  }

  void _handleInactivity() {
    final navState = VillaApp.navigatorKey.currentState;
    if (navState == null) return;

    // PROVJERI TRENUTNU RUTU
    String? currentRoute;
    navState.popUntil((route) {
      currentRoute = route.settings.name;
      return true;
    });

    // SAMO NA DASHBOARDU aktiviraj screensaver
    if (currentRoute != '/dashboard') {
      debugPrint(
          "⏸️ Screensaver SKIP - nismo na dashboard (trenutno: $currentRoute)");
      _startTimer(); // Restart timer za sljedeću provjeru
      return;
    }

    // Provjeri da nismo već na screensaveru
    bool isAlreadyOnScreensaver = false;
    navState.popUntil((route) {
      if (route.settings.name == '/screensaver') {
        isAlreadyOnScreensaver = true;
      }
      return true;
    });

    if (isAlreadyOnScreensaver) return;

    debugPrint("💤 Inactivity na DASHBOARD! Opening Screensaver...");
    navState.pushNamed('/screensaver');
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetTimer(),
      onPointerMove: (_) => _resetTimer(),
      onPointerUp: (_) => _resetTimer(),
      child: widget.child,
    );
  }
}
