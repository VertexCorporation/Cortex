// lib/models/screen/widget/appbar.dart

import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../theme.dart';

/// A custom AppBar for the ModelsScreen, encapsulating the title and the 'Create' action button.
///
/// This widget is designed to be a self-contained and reusable component.
/// It receives all necessary data via its constructor, making it independent of the screen's state.
class ModelsAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The main title to be displayed in the AppBar.
  final String title;

  /// The text for the create button.
  final String createButtonText;

  /// The callback function that is triggered when the create button is tapped.
  final VoidCallback onOpenCreateScreen;

  const ModelsAppBar({
    super.key,
    required this.title,
    required this.createButtonText,
    required this.onOpenCreateScreen,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return AppBar(
      scrolledUnderElevation: 0,
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Roboto',
          color: AppColors.primaryColor.inverted,
          fontSize: screenWidth * 0.07,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.background,
      centerTitle: false,
      elevation: 0,
      actions: [
        // The "Create" button logic is now fully contained within this widget.
        SizedBox(
          width: screenWidth * 0.37,
          height: screenHeight * 0.1,
          child: Stack(
            children: [
              Positioned(
                top: screenHeight * 0.0129,
                left: screenWidth * 0.082,
                child: Container(
                  width: screenWidth * 0.26,
                  height: screenHeight * 0.045,
                  decoration: BoxDecoration(
                    color: AppColors.senaryColor.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: screenWidth * 0.02,
                        right: screenWidth * 0.10,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          createButtonText,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.036,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: screenHeight * 0.0129,
                left: screenWidth * 0.25,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    // Use the provided callback function.
                    onTap: onOpenCreateScreen,
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      width: screenWidth * 0.1,
                      height: screenHeight * 0.045,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.senaryColor,
                      ),
                      padding: EdgeInsets.all(screenWidth * 0.026),
                      child: SvgPicture.asset(
                        'assets/icons/plus.svg',
                        colorFilter:
                        const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        width: screenWidth * 0.02,
                        height: screenWidth * 0.02,
                      ),
                    ),
                  ),
                ),
              ),
              // This is the larger, invisible tappable area for the whole button.
              Positioned.fill(
                left: screenWidth * 0.07,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    // It also triggers the same callback.
                    onTap: onOpenCreateScreen,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Defines the height of the AppBar. This is required by the `PreferredSizeWidget` interface.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}