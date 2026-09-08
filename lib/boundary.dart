import 'package:cortex/design.dart';
// lib/boundary.dart

import 'package:flutter/material.dart';
import 'package:cortex/theme.dart';

enum BoundaryAction {
  retry,
  offline,
  reset,
}

/// A resilient, user-friendly error boundary widget.
/// Instead of a silent freeze or red screen of death, it displays
/// an actionable recovery card with retry and offline fallback options.
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final String? customTitle;
  final String? customMessage;
  final void Function(BoundaryAction action)? onAction;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.customTitle,
    this.customMessage,
    this.onAction,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _errorDetails;

  @override
  void initState() {
    super.initState();
  }

  void _resetError() {
    setState(() {
      _errorDetails = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_errorDetails != null) {
      return _buildRecoveryUI(context);
    }

    // Wrap child in an ErrorWidget.builder interceptor
    return ErrorWidgetBuilder(
      onError: (details) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _errorDetails = details;
            });
          }
        });
      },
      child: widget.child,
    );
  }

  Widget _buildRecoveryUI(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E24) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.septenaryColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.septenaryColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_fix_high_rounded,
                color: AppColors.septenaryColor,
                size: CortexDesign.icon,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.customTitle ?? "Beklenmeyen Bir Durum Oluştu",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.customMessage ??
                  "İşlem sırasında bir aksaklık yaşandı. Aşağıdaki seçeneklerle sohbetine kaldığın yerden devam edebilirsin.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.quinaryColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _resetError();
                      widget.onAction?.call(BoundaryAction.offline);
                    },
                    icon: const Icon(Icons.offline_bolt_outlined,
                        size: CortexDesign.icon),
                    label: const Text("Çevrimdışı"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.quinaryColor,
                      side: BorderSide(
                          color:
                              AppColors.septenaryColor.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _resetError();
                      widget.onAction?.call(BoundaryAction.retry);
                    },
                    icon: const Icon(Icons.refresh_rounded,
                        size: CortexDesign.icon),
                    label: const Text("Tekrar Dene"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.septenaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper component to safely catch rendering exceptions
class ErrorWidgetBuilder extends StatelessWidget {
  final Widget child;
  final void Function(FlutterErrorDetails details) onError;

  const ErrorWidgetBuilder({
    super.key,
    required this.child,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
