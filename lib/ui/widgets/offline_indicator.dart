// FILE: lib/ui/widgets/offline_indicator.dart
// OPIS: Widget koji prikazuje offline status i pending operacije
// VERZIJA: 1.0
// DATUM: 2026-01-10

import 'package:flutter/material.dart';
import '../../data/services/connectivity_service.dart';
import '../../data/services/offline_queue_service.dart';

/// Banner koji se prikazuje na vrhu ekrana kad je uređaj offline
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: ConnectivityService.onConnectivityChanged,
      initialData: ConnectivityService.isOnline,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;

        if (isOnline) {
          // Online - ne prikazuj ništa
          return const SizedBox.shrink();
        }

        // Offline - prikaži banner
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.shade700,
                Colors.orange.shade600,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                const Icon(
                  Icons.wifi_off,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'No internet connection - Changes will sync when online',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Pending count badge
                if (OfflineQueueService.hasPendingOperations)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.hourglass_empty,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${OfflineQueueService.pendingCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Manji indikator za AppBar ili druge uže prostore
class OfflineIndicatorSmall extends StatelessWidget {
  const OfflineIndicatorSmall({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: ConnectivityService.onConnectivityChanged,
      initialData: ConnectivityService.isOnline,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;

        if (isOnline) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off, color: Colors.white, size: 14),
              SizedBox(width: 4),
              Text(
                'Offline',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Ikona za status konekcije (za AppBar actions)
class ConnectionStatusIcon extends StatelessWidget {
  const ConnectionStatusIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: ConnectivityService.onConnectivityChanged,
      initialData: ConnectivityService.isOnline,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;

        return Tooltip(
          message: isOnline ? 'Connected' : 'Offline',
          child: Icon(
            isOnline ? Icons.wifi : Icons.wifi_off,
            color: isOnline ? Colors.green : Colors.orange,
            size: 20,
          ),
        );
      },
    );
  }
}

/// Animirani sync indikator
class SyncingIndicator extends StatefulWidget {
  final bool isSyncing;

  const SyncingIndicator({
    super.key,
    this.isSyncing = false,
  });

  @override
  State<SyncingIndicator> createState() => _SyncingIndicatorState();
}

class _SyncingIndicatorState extends State<SyncingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    if (widget.isSyncing) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(SyncingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSyncing && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isSyncing && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isSyncing) {
      return const SizedBox.shrink();
    }

    return RotationTransition(
      turns: _controller,
      child: const Icon(
        Icons.sync,
        color: Color(0xFFD4AF37),
        size: 20,
      ),
    );
  }
}
