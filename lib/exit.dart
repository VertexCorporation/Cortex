// lib/exit.dart

import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'darkener.dart';
import 'l10n/app_localizations.dart';

/// Displays a centralized dialog to confirm app exit.
Future<bool> showExitConfirmationDialog(BuildContext context) async {
  final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
  final void Function() restoreNavBar = Darkener.darken();

  final bool? result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'ExitConfirmation',
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (
        BuildContext ctx,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        ) {
      final Size size = MediaQuery.of(ctx).size;

      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: size.width * 0.8,
            decoration: BoxDecoration(
              color: AppColors.secondaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: <Widget>[
                        Text(
                          appLocalizations.exitAppTitle,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor.inverted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: size.height * 0.02),
                        Text(
                          appLocalizations.exitAppConfirmation,
                          style: TextStyle(
                            color: AppColors.primaryColor.inverted
                                .withValues(alpha: 0.4),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: AppColors.border,
                    thickness: 0.5,
                    height: 1,
                  ),
                  IntrinsicHeight(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: AppColors.senaryColor
                                  .withValues(alpha: 0.1),
                              highlightColor: AppColors.senaryColor
                                  .withValues(alpha: 0.1),
                              onTap: () => Navigator.of(ctx).pop(false),
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Text(
                                  appLocalizations.no,
                                  style: TextStyle(
                                    color: AppColors.senaryColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        VerticalDivider(
                          width: 1,
                          thickness: 0.5,
                          color: AppColors.border,
                        ),
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: AppColors.septenaryColor
                                  .withValues(alpha: 0.1),
                              highlightColor: AppColors.septenaryColor
                                  .withValues(alpha: 0.1),
                              onTap: () => Navigator.of(ctx).pop(true),
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Text(
                                  appLocalizations.yes,
                                  style: TextStyle(
                                    color: AppColors.septenaryColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
        ) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  ).whenComplete(() {
    restoreNavBar();
  });

  // If the dialog is dismissed (null), treat it as "No, do not exit".
  return result ?? false;
}