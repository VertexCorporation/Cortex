// report.dart
//
// A self-contained modal dialog for users to report an AI-generated message.
// It handles user input, validation, internet checks, and submission to Firebase.
// It accepts a callback to update the UI of the calling screen.
//
// ──────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';
import '../../notifications.dart';

import '../../darkener.dart';
import '../../theme.dart';

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
  // NEW: A callback function to be invoked on success.
  final VoidCallback onReportSuccess;

  const ReportDialog({
    Key? key,
    required this.aiMessage,
    required this.modelId,
    required this.onReportSuccess, // <<< NEW PARAMETER
  }) : super(key: key);

  // UPDATED STATIC SHOW METHOD
  static Future<void> show(BuildContext context, {
    required String aiMessage,
    required String modelId,
    required VoidCallback onReportSuccess, // <<< NEW PARAMETER
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
            onReportSuccess: onReportSuccess, // <<< Passed down to the instance
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
    // This method's logic remains the same.
    const logPrefix = "[ReportDialog._handleSubmission]";
    if (_isSubmitting) {
      if (kDebugMode) debugPrint("$logPrefix Submission already in progress. Ignoring tap.");
      return;
    }

    final localizations = AppLocalizations.of(context)!;
    FocusScope.of(context).unfocus();

    if (_selectedSubject == null) {
      setState(() {
        _errorMessage = localizations.reportErrorMessage;
        _showError = true;
      });
      if (kDebugMode) debugPrint("$logPrefix Validation failed: No subject selected.");
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
        if (kDebugMode) debugPrint("$logPrefix Submission failed: No internet connection.");
        return;
      }

      await _submitReportToFirebase();

      if (mounted) {
        if (kDebugMode) debugPrint("$logPrefix Submission successful. Closing dialog.");
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (kDebugMode) debugPrint("$logPrefix An error occurred during submission: $e");
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
    final notificationService = Provider.of<NotificationService>(context, listen: false);

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (kDebugMode) debugPrint("[ReportDialog] Aborted: No authenticated user.");
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

    if (kDebugMode) debugPrint("[ReportDialog] Submitting report to Firestore: $reportData");
    await FirebaseFirestore.instance.collection('reports').add(reportData);

    // Call the success callback to update the parent UI (e.g., mark as reported)
    widget.onReportSuccess();
    if (kDebugMode) debugPrint("[ReportDialog] Called onReportSuccess callback to update parent UI.");

    // --- NEW: SHOW SUCCESS NOTIFICATION ---
    // We need to get the AppLocalizations for the notification message.
    // Since this method might be called when the context is being torn down,
    // it's safer to get it before the async gap if possible, or just use the
    // current context which should still be valid here.
    final localizations = AppLocalizations.of(context);
    if (localizations != null) {
      notificationService.showNotification(
        message: localizations.reportSubmitted, // e.g., "Report submitted successfully."
        isSuccess: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (no changes in this method's body)
    final localizations = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        backgroundColor: AppColors.background,
        insetPadding: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
              maxWidth: 600, // Good practice for tablet layouts.
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          localizations.reportDialogTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.onBackground,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        TextField(
                          controller: _descriptionController,
                          maxLength: 150,
                          maxLines: 3,
                          style: TextStyle(color: colors.onBackground),
                          decoration: InputDecoration(
                            labelText: localizations.reportDescriptionLabel,
                            alignLabelWithHint: true,
                            labelStyle: TextStyle(color: AppColors.tertiaryColor),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: colors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        _buildCheckRow(
                          label: localizations.reportHarmful,
                          subject: ReportSubject.harmful,
                        ),
                        _buildCheckRow(
                          label: localizations.reportNotTrue,
                          subject: ReportSubject.notTrue,
                        ),
                        _buildCheckRow(
                          label: localizations.reportNotHelpful,
                          subject: ReportSubject.notHelpful,
                        ),
                        const SizedBox(height: 8.0),
                        AnimatedOpacity(
                          opacity: _showError ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: _showError
                              ? Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              _errorMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: colors.error,
                                fontSize: 14.0,
                              ),
                            ),
                          )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                  _buildActionButtons(),
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
  }) {
    // ... (no changes in this method's body)
    final bool isSelected = _selectedSubject == subject;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        setState(() {
          _selectedSubject = isSelected ? null : subject;
          if (_showError) _showError = false;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text(label, style: TextStyle(color: AppColors.tertiaryColor)),
            ),
            Checkbox(
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
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    // ... (no changes in this method's body)
    final localizations = AppLocalizations.of(context)!;
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
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      localizations.closeButton,
                      style: TextStyle(color: AppColors.senaryColor, fontSize: 16),
                    ),
                  ),
                ),
              ),
              VerticalDivider(width: 1, thickness: 0.5, color: AppColors.quinaryColor),
              Expanded(
                child: InkWell(
                  onTap: _isSubmitting ? null : _handleSubmission,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: _isSubmitting
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.septenaryColor,
                      ),
                    )
                        : Text(
                      localizations.submitButton,
                      style: TextStyle(
                        color: AppColors.septenaryColor,
                        fontSize: 16,
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