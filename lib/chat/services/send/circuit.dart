import 'package:cortex/design.dart';
// lib/chat/services/send/circuit.dart

import 'package:flutter/material.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';

/// Circuit breaker and fallback notice coordinator for model execution failures.
class CircuitBreaker {
  static final Set<String> _failedModels = {};

  bool isFailed(String modelId) => _failedModels.contains(modelId);

  void recordFailure(String modelId) {
    _failedModels.add(modelId);
  }

  void reset() {
    _failedModels.clear();
  }

  /// Displays a subtle, localized floating notice when a model fails and
  /// the system automatically falls back to a working alternative.
  void displayFallbackNotice(
    BuildContext? context,
    AppLocalizations localizations,
  ) {
    if (context == null || !context.mounted) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF1E1E24),
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            Icon(
              Icons.bolt_rounded,
              color: AppColors.septenaryColor,
              size: CortexDesign.icon,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                "Seçilen model yanıt veremedi, akıllı yedek modele geçildi.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
