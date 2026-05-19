// lib/settings/sections/delete.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../app.dart';
import '../../cache.dart';
import '../../chat/services/storage.dart';
import '../../darkener.dart';
import '../../l10n/app_localizations.dart';
import '../../notifications/introvert.dart';
import '../../shake.dart';
import '../../theme.dart';
import '../providers/general.dart';
import '../providers/actions.dart';

// --- DIALOG WIDGETS ---

/// A self-contained, stateful widget for the "Delete All Conversations" dialog.
class _DeleteAllConversationsDialog extends StatefulWidget {
  const _DeleteAllConversationsDialog();

  @override
  State<_DeleteAllConversationsDialog> createState() =>
      _DeleteAllConversationsDialogState();
}

class _DeleteAllConversationsDialogState
    extends State<_DeleteAllConversationsDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final TextEditingController _confirmController;
  String? _confirmError;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _confirmController = TextEditingController();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleDelete() async {
    // Before any async gaps, get all necessary providers and localizations.
    final notificationService = context.read<IntrovertNotificationService>();
    final appLocalizations = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context);

    if (_confirmController.text.trim() != "VERTEX") {
      setState(() => _confirmError = appLocalizations.confirmWordError);
      _shakeController.forward(from: 0);
      return;
    }
    if (!await ChatStorageService.hasAnyConversations()) {
      navigator.pop();
      notificationService.showNotification(
          message: appLocalizations.noConversationsToDelete,
          type: NotificationType.error);
      return;
    }

    await ChatStorageService.deleteAllConversations();
    CacheService.invalidateConversationCache();

    if (mounted) {
      navigator.pop();
      notificationService.showNotification(
          message: appLocalizations.allConversationsDeleted,
          type: NotificationType.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();

    final appLocalizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Center(
      child: SingleChildScrollView(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: screenWidth * 0.8,
            decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(10)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    child: Column(
                      children: [
                        Text(
                            appLocalizations.deleteAllConversationsConfirmTitle,
                            style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor.inverted),
                            textAlign: TextAlign.center),
                        SizedBox(height: screenWidth * 0.03),
                        Text(
                            appLocalizations
                                .deleteAllConversationsConfirmMessage,
                            style: TextStyle(
                                color: AppColors.quinaryColor,
                                fontSize: screenWidth * 0.035),
                            textAlign: TextAlign.center),
                        SizedBox(height: screenWidth * 0.05),
                        ShakeWidget(
                          controller: _shakeController,
                          child: TextField(
                            controller: _confirmController,
                            style: TextStyle(
                                color: AppColors.primaryColor.inverted,
                                fontSize: screenWidth * 0.04),
                            decoration: InputDecoration(
                              labelText: appLocalizations.confirmWord,
                              labelStyle: TextStyle(
                                  color: AppColors.primaryColor.inverted),
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                  BorderSide(color: AppColors.quinaryColor),
                                  borderRadius: BorderRadius.circular(10.0)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColors.primaryColor.inverted),
                                  borderRadius: BorderRadius.circular(10.0)),
                            ),
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _confirmError != null
                              ? Padding(
                              padding:
                              EdgeInsets.only(top: screenWidth * 0.02),
                              child: Text(_confirmError!,
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: screenWidth * 0.03),
                                  key: ValueKey(_confirmError)))
                              : const SizedBox.shrink(
                              key: ValueKey("emptyConfirmError")),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                      color: AppColors.quinaryColor, thickness: 0.5, height: 1),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                            child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      Navigator.of(context).pop();
                                    },
                                    splashColor: AppColors.senaryColor
                                        .withValues(alpha: 0.1),
                                    highlightColor: AppColors.senaryColor
                                        .withValues(alpha: 0.1),
                                    child: Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.symmetric(
                                            vertical: screenWidth * 0.04),
                                        child: Text(appLocalizations.cancel,
                                            style: TextStyle(
                                                color: AppColors.senaryColor,
                                                fontSize:
                                                screenWidth * 0.04)))))),
                        VerticalDivider(
                            width: 1,
                            thickness: 0.5,
                            color: AppColors.quinaryColor),
                        Expanded(
                            child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                    splashColor:
                                    Colors.red.withValues(alpha: 0.3),
                                    highlightColor:
                                    Colors.red.withValues(alpha: 0.1),
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      _handleDelete();
                                    },
                                    child: Container(
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.symmetric(
                                            vertical: screenWidth * 0.04),
                                        child: Text(appLocalizations.deleteAll,
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize:
                                                screenWidth * 0.04)))))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A self-contained, stateful widget for the "Delete Account" dialog.
class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final TextEditingController _confirmController;
  String? _confirmError;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _confirmController = TextEditingController();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleDelete() async {
    final actionProvider = context.read<SettingsActionProvider>();
    final appLocalizations = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context);

    if (_confirmController.text.trim() != "VERTEX") {
      setState(() => _confirmError = appLocalizations.confirmWordError);
      _shakeController.forward(from: 0);
      return;
    }

    try {
      await actionProvider.deleteAccount(context);
    } catch (e) {
      if (mounted) navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();

    final appLocalizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Center(
      child: SingleChildScrollView(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: screenWidth * 0.8,
            decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(10)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Consumer<SettingsActionProvider>(
                builder: (context, provider, child) {
                  final isDeleting = provider.isDeletingAccount;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(screenWidth * 0.05),
                        child: Column(
                          children: [
                            Text(appLocalizations.deleteAccount,
                                style: TextStyle(
                                    fontSize: screenWidth * 0.045,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor.inverted),
                                textAlign: TextAlign.center),
                            SizedBox(height: screenWidth * 0.03),
                            Text(appLocalizations.confirmDeleteAccount,
                                style: TextStyle(
                                    color: AppColors.quinaryColor,
                                    fontSize: screenWidth * 0.035),
                                textAlign: TextAlign.center),
                            SizedBox(height: screenWidth * 0.05),
                            ShakeWidget(
                              controller: _shakeController,
                              child: TextField(
                                controller: _confirmController,
                                style: TextStyle(
                                    color: AppColors.primaryColor.inverted,
                                    fontSize: screenWidth * 0.04),
                                decoration: InputDecoration(
                                  labelText: appLocalizations.confirmWord,
                                  labelStyle: TextStyle(
                                      color: AppColors.primaryColor.inverted),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppColors.quinaryColor),
                                      borderRadius:
                                      BorderRadius.circular(10.0)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                          AppColors.primaryColor.inverted),
                                      borderRadius:
                                      BorderRadius.circular(10.0)),
                                ),
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _confirmError != null
                                  ? Padding(
                                  padding: EdgeInsets.only(
                                      top: screenWidth * 0.02),
                                  child: Text(_confirmError!,
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: screenWidth * 0.03),
                                      key: ValueKey(_confirmError)))
                                  : const SizedBox.shrink(
                                  key: ValueKey("emptyConfirmError")),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                          color: AppColors.quinaryColor,
                          thickness: 0.5,
                          height: 1),
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            Expanded(
                                child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                        onTap: isDeleting
                                            ? null
                                            : () {
                                          HapticFeedback.lightImpact();
                                          Navigator.of(context).pop();
                                        },
                                        splashColor: AppColors.senaryColor
                                            .withValues(alpha: 0.1),
                                        highlightColor: AppColors.senaryColor
                                            .withValues(alpha: 0.1),
                                        child: Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.symmetric(
                                                vertical: screenWidth * 0.04),
                                            child: Text(appLocalizations.cancel,
                                                style: TextStyle(
                                                    color:
                                                    AppColors.senaryColor,
                                                    fontSize: screenWidth *
                                                        0.04)))))),
                            VerticalDivider(
                                width: 1,
                                thickness: 0.5,
                                color: AppColors.quinaryColor),
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  splashColor:
                                  Colors.red.withValues(alpha: 0.3),
                                  highlightColor:
                                  Colors.red.withValues(alpha: 0.1),
                                  onTap: isDeleting
                                      ? null
                                      : () {
                                    HapticFeedback.lightImpact();
                                    _handleDelete();
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(
                                        vertical: screenWidth * 0.04),
                                    child: isDeleting
                                        ? SizedBox(
                                        width: screenWidth * 0.05,
                                        height: screenWidth * 0.05,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                            color: AppColors
                                                .primaryColor.inverted))
                                        : Text(appLocalizations.delete,
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontSize: screenWidth * 0.04)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A stateless widget that displays the delete actions and launches the corresponding dialogs.
class DeleteSection extends StatelessWidget {
  final bool isFromActiveChat;

  const DeleteSection({
    super.key,
    this.isFromActiveChat = false,
  });

  void _showDialog(BuildContext context, {required Widget child}) {
    final RestoreCallback restoreNavBar = Darkener.darken();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'DeleteActionDialog',
      pageBuilder: (ctx, _, __) {
        final keyboardPadding = MediaQuery
            .of(ctx)
            .viewInsets
            .bottom;
        return AnimatedPadding(
          padding: EdgeInsets.only(bottom: keyboardPadding),
          duration: const Duration(milliseconds: 50),
          curve: Curves.easeInOut,
          child: child,
        );
      },
    ).whenComplete(restoreNavBar);
  }

  Widget _buildDeleteAllConversationsButton(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    return Material(
      color: AppColors.septenaryColor.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: AppColors.septenaryColor, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _showDialog(context, child: const _DeleteAllConversationsDialog());
        },
        borderRadius: BorderRadius.circular(10.0),
        splashColor: AppColors.septenaryColor,
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                appLocalizations.deleteAllConversationsButton,
                style: TextStyle(
                    color: AppColors.primaryColor.inverted,
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w500),
              ),
              Icon(Icons.arrow_forward_ios,
                  color: AppColors.primaryColor.inverted,
                  size: screenWidth * 0.04),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    return Material(
      color: AppColors.septenaryColor.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: AppColors.septenaryColor, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _showDialog(context, child: const _DeleteAccountDialog());
        },
        borderRadius: BorderRadius.circular(10.0),
        splashColor: AppColors.septenaryColor,
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                appLocalizations.deleteAccount,
                style: TextStyle(
                    color: AppColors.primaryColor.inverted,
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w500),
              ),
              Icon(Icons.arrow_forward_ios,
                  color: AppColors.primaryColor.inverted,
                  size: screenWidth * 0.04),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisabledInfoText(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.03, vertical: screenWidth * 0.03),
      decoration: BoxDecoration(
        color: AppColors.septenaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
            color: AppColors.septenaryColor.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/warning.svg',
            colorFilter:
            ColorFilter.mode(AppColors.quinaryColor, BlendMode.srcIn),
            width: screenWidth * 0.05,
            height: screenWidth * 0.05,
          ),
          SizedBox(width: screenWidth * 0.025),
          Expanded(
            child: Text(
              appLocalizations.deleteAllConversationsDisabledInfo,
              style: TextStyle(
                  color: AppColors.quinaryColor, fontSize: screenWidth * 0.035),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();

    final generalProvider = context.watch<SettingsGeneralProvider>();
    final hasInternet = generalProvider.hasInternet;
    final isAnonymous = generalProvider.isAnonymous;

    final appLocalizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appLocalizations.delete,
          style: TextStyle(
              color: AppColors.primaryColor.inverted,
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.w600),
        ),
        SizedBox(height: screenHeight * 0.01),
        Text(
          appLocalizations.deleteDescription,
          style: TextStyle(
              color: AppColors.quinaryColor, fontSize: screenWidth * 0.035),
        ),
        SizedBox(height: screenHeight * 0.02),
        if (isFromActiveChat)
          _buildDisabledInfoText(context)
        else
          _buildDeleteAllConversationsButton(context),
        if (hasInternet && !isAnonymous) ...[
          SizedBox(height: screenHeight * 0.015),
          _buildDeleteAccountButton(context),
        ],
      ],
    );
  }
}
