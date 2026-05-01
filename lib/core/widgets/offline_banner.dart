import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_text_styles.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

final isOfflineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.maybeWhen(
    data: (results) =>
        results.contains(ConnectivityResult.none) || results.isEmpty,
    orElse: () => false,
  );
});

// ── Banner Widget ─────────────────────────────────────────────────────────────

/// Wraps any child with an offline banner at the top when connection is lost.
class OfflineAwareBanner extends ConsumerWidget {
  final Widget child;
  const OfflineAwareBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(isOfflineProvider);

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isOffline ? 36 : 0,
          color: Colors.orange.shade700,
          child: isOffline
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'You are offline — showing cached data',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: Colors.white),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        Expanded(child: child),
      ],
    );
  }
}
