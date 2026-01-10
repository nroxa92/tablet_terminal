// FILE: lib/ui/widgets/error_boundary.dart
// OPIS: Error boundary widget koji hvata greške i prikazuje user-friendly UI
// VERZIJA: 1.0 - FAZA 3
// DATUM: 2026-01-10

import 'package:flutter/material.dart';
import '../../data/services/sentry_service.dart';

/// Error Boundary - Wrappa child widget i hvata sve greške
/// Umjesto crvenog "Red Screen of Death" prikazuje user-friendly poruku
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final String? screenName;
  final VoidCallback? onRetry;
  final VoidCallback? onGoHome;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.screenName,
    this.onRetry,
    this.onGoHome,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool _hasError = false;
  dynamic _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
  }

  void _handleError(dynamic error, StackTrace? stackTrace) {
    setState(() {
      _hasError = true;
      _error = error;
      _stackTrace = stackTrace;
    });

    // Log to Sentry
    SentryService.captureException(
      error,
      stackTrace: stackTrace,
      hint: 'Error in ${widget.screenName ?? "unknown screen"}',
      category: 'ui_error',
      extras: {
        'screen': widget.screenName,
      },
    );
  }

  void _retry() {
    setState(() {
      _hasError = false;
      _error = null;
      _stackTrace = null;
    });
    widget.onRetry?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _ErrorScreen(
        error: _error,
        screenName: widget.screenName,
        onRetry: _retry,
        onGoHome: widget.onGoHome ??
            () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', (route) => false);
            },
      );
    }

    // Wrap u ErrorWidget.builder za catching build errors
    return Builder(
      builder: (context) {
        // Original error handler
        final originalOnError = FlutterError.onError;

        FlutterError.onError = (FlutterErrorDetails details) {
          _handleError(details.exception, details.stack);
          // Also call original handler
          originalOnError?.call(details);
        };

        return widget.child;
      },
    );
  }
}

/// Error Screen UI
class _ErrorScreen extends StatelessWidget {
  final dynamic error;
  final String? screenName;
  final VoidCallback onRetry;
  final VoidCallback onGoHome;

  const _ErrorScreen({
    required this.error,
    this.screenName,
    required this.onRetry,
    required this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.red.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Error Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              const Text(
                'Ups! Nešto je pošlo po zlu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Dogodila se neočekivana greška${screenName != null ? ' na ekranu "$screenName"' : ''}. '
                'Naš tim je obaviješten.',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Buttons
              Row(
                children: [
                  // Go Home Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onGoHome,
                      icon: const Icon(Icons.home, size: 20),
                      label: const Text('POČETNA'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Retry Button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh, size: 20),
                      label: const Text(
                        'POKUŠAJ PONOVNO',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Error code (collapsible)
              ExpansionTile(
                title: Text(
                  'Tehnički detalji',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                iconColor: Colors.grey[600],
                collapsedIconColor: Colors.grey[600],
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      error?.toString() ?? 'Unknown error',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Globalni Error Handler za cijelu aplikaciju
/// Pozovi u main.dart
class GlobalErrorHandler {
  static void init() {
    // Flutter errors
    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint('🔴 Flutter Error: ${details.exception}');
      SentryService.captureException(
        details.exception,
        stackTrace: details.stack,
        hint: 'Flutter framework error',
        category: 'flutter_error',
      );
    };
  }
}
