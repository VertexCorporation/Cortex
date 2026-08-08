// report.dart
//
// A self-contained modal dialog for users to report an AI-generated message.
// It handles user input, validation, internet checks, and submission to Firebase.
// The UI is fully responsive, scaling typography and spacing based on screen width.
//
// ──────────────────────────────────────────────────────────────────────────────

import 'package:cortex/app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';
import '../../../darkener.dart';
import '../../../notifications/introvert.dart';
import '../../../theme.dart';

/// Defines the possible reasons for reporting a message.
enum ReportSubject {
  harmful,
  notTrue,
  notHelpful,
}

/// A dialog for reporting an AI message.
class ReportDialog extends StatefulWidget {
  final String aiMessage;
  final String modelId;
  // A callback function to be invoked on success.
  final VoidCallback onReportSuccess;

  const ReportDialog({
    super.key,
    required this.aiMessage,
    required this.modelId,
    required this.onReportSuccess,
  });

  // SHOW METHOD
  static Future<void> show(
    BuildContext context, {
    required String aiMessage,
    required String modelId,
    required VoidCallback onReportSuccess,
  }) async {
    final restoreSystemUI = Darkener.darken(affectStatusBar: true);

    try {
      await showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'ReportDialog',
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (dialogContext, _, __) {
          return ReportDialog(
            aiMessage: aiMessage,
            modelId: modelId,
            onReportSuccess: onReportSuccess,
          );
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        },
      );
    } finally {
      restoreSystemUI();
    }
  }

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog>
    with SingleTickerProviderStateMixin {
  final _descriptionController = TextEditingController();

  ReportSubject? _selectedSubject;
  String _errorMessage = '';
  bool _showError = false;
  bool _isSubmitting = false;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmission() async {
    const logPrefix = "[ReportDialog._handleSubmission]";
    if (_isSubmitting) {
      if (kDebugMode) {
        debugPrint("$logPrefix Submission already in progress. Ignoring tap.");
      }
      return;
    }

    final localizations = AppLocalizations.of(context)!;
    FocusScope.of(context).unfocus();

    if (_selectedSubject == null) {
      setState(() {
        _errorMessage = localizations.reportErrorMessage;
        _showError = true;
      });
      if (kDebugMode) {
        debugPrint("$logPrefix Validation failed: No subject selected.");
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
      _showError = false;
    });

    try {
      final hasInternet = await InternetConnection().hasInternetAccess;
      if (!mounted) return;

      if (!hasInternet) {
        setState(() {
          _errorMessage = localizations.noInternetConnection;
          _showError = true;
        });
        if (kDebugMode) {
          debugPrint("$logPrefix Submission failed: No internet connection.");
        }
        return;
      }

      final localizationsBeforePop = localizations;
      final notificationServiceBeforePop =
          Provider.of<IntrovertNotificationService>(context, listen: false);

      await _submitReportToFirebase();

      if (mounted) {
        if (kDebugMode) {
          debugPrint("$logPrefix Submission successful. Closing dialog.");
        }
        Navigator.of(context).pop();
      }

      notificationServiceBeforePop.showNotification(
          message: localizationsBeforePop.reportSubmitted,
          type: NotificationType.success);
    } catch (e) {
      if (kDebugMode) {
        debugPrint("$logPrefix An error occurred during submission: $e");
      }
      if (mounted) {
        setState(() {
          _errorMessage = localizations.anErrorOccurred;
          _showError = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _submitReportToFirebase() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (kDebugMode) {
        debugPrint("[ReportDialog] Aborted: No authenticated user.");
      }
      return;
    }

    final reportData = {
      'messageText': widget.aiMessage,
      'reporterUid': currentUser.uid,
      'modelId': widget.modelId,
      'description': _descriptionController.text.trim(),
      'subject': _selectedSubject!.index + 1,
      'timestamp': FieldValue.serverTimestamp(),
    };

    if (kDebugMode) {
      debugPrint("[ReportDialog] Submitting report to Firestore: $reportData");
    }
    await FirebaseFirestore.instance.collection('reports').add(reportData);

    widget.onReportSuccess();
    if (kDebugMode) {
      debugPrint(
          "[ReportDialog] Called onReportSuccess callback to update parent UI.");
    }

  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    // --- DYNAMIC SCALING ---
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double scale = screenWidth / 400.0; // Reference width of 400

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        backgroundColor: AppColors.background,
        insetPadding: EdgeInsets.all(16.0 * scale),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12 * scale)),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.85,
              maxWidth: 600 * scale, // Scaled constraint for tablets
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        20.0 * scale, 20.0 * scale, 20.0 * scale, 12.0 * scale),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          localizations.reportDialogTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primaryColor.inverted,
                            fontSize: 20.0 * scale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.0 * scale),
                        TextField(
                          controller: _descriptionController,
                          maxLength: 150,
                          maxLines: 3,
                          style: TextStyle(
                              color: AppColors.tertiaryColor,
                              fontSize: 16 * scale),
                          decoration: InputDecoration(
                            labelText: localizations.reportDescriptionLabel,
                            alignLabelWithHint: true,
                            labelStyle: TextStyle(
                                color: AppColors.tertiaryColor,
                                fontSize: 16 * scale),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0 * scale),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0 * scale),
                              borderSide: BorderSide(color: colors.primary),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.0 * scale),
                        _buildCheckRow(
                          label: localizations.reportHarmful,
                          subject: ReportSubject.harmful,
                          scale: scale,
                        ),
                        _buildCheckRow(
                          label: localizations.reportNotTrue,
                          subject: ReportSubject.notTrue,
                          scale: scale,
                        ),
                        _buildCheckRow(
                          label: localizations.reportNotHelpful,
                          subject: ReportSubject.notHelpful,
                          scale: scale,
                        ),
                        SizedBox(height: 8.0 * scale),
                        AnimatedOpacity(
                          opacity: _showError ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: _showError
                              ? Padding(
                                  padding: EdgeInsets.only(bottom: 8.0 * scale),
                                  child: Text(
                                    _errorMessage,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: colors.error,
                                      fontSize: 14.0 * scale,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                  _buildActionButtons(scale),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckRow({
    required String label,
    required ReportSubject subject,
    required double scale,
  }) {
    final bool isSelected = _selectedSubject == subject;
    return InkWell(
      borderRadius: BorderRadius.circular(8 * scale),
      onTap: () {
        setState(() {
          _selectedSubject = isSelected ? null : subject;
          if (_showError) _showError = false;
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.0 * scale),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 12.0 * scale),
              child: Text(label,
                  style: TextStyle(
                      color: AppColors.tertiaryColor, fontSize: 16 * scale)),
            ),
            Transform.scale(
              scale: scale, // Scale the checkbox widget itself
              child: Checkbox(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    _selectedSubject = (value ?? false) ? subject : null;
                    if (_showError) _showError = false;
                  });
                },
                activeColor: Theme.of(context).colorScheme.primary,
                checkColor: Theme.of(context).colorScheme.onPrimary,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(double scale) {
    final localizations = AppLocalizations.of(context)!;

    final Color cancelColor = AppColors.senaryColor;
    final Color submitColor = AppColors.senaryColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(color: AppColors.quinaryColor, thickness: 0.5, height: 1),
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  splashColor: cancelColor.withValues(alpha: 0.16),
                  highlightColor: cancelColor.withValues(alpha: 0.10),
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 16 * scale),
                    child: Text(
                      localizations.closeButton,
                      style: TextStyle(
                        color: cancelColor,
                        fontSize: 16 * scale,
                      ),
                    ),
                  ),
                ),
              ),
              VerticalDivider(
                width: 1,
                thickness: 0.5,
                color: AppColors.quinaryColor,
              ),
              Expanded(
                child: InkWell(
                  onTap: _isSubmitting ? null : _handleSubmission,
                  splashColor: _isSubmitting
                      ? Colors.transparent
                      : submitColor.withValues(alpha: 0.18),
                  highlightColor: _isSubmitting
                      ? Colors.transparent
                      : submitColor.withValues(alpha: 0.12),
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 16 * scale),
                    child: _isSubmitting
                        ? SizedBox(
                            width: 20 * scale,
                            height: 20 * scale,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5 * scale,
                              color: submitColor,
                            ),
                          )
                        : Text(
                            localizations.submitButton,
                            style: TextStyle(
                              color: submitColor,
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
