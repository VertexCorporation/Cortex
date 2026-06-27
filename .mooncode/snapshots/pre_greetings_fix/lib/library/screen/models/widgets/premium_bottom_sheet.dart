import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../navigation.dart';
import '../../../../funds/funds.dart';
import '../../../../app.dart';
import 'package:cortex/scaled_bottom_sheet.dart';

void showPremiumBottomSheet(BuildContext context) {
  HapticFeedback.lightImpact();
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    useSafeArea: false,
    constraints: BoxConstraints(
      maxWidth: MediaQuery.of(context).size.width,
    ),
    builder: (BuildContext modalContext) {
      return const ScaledBottomSheet(child: PremiumBottomSheetContent());
    },
  );
}

class PremiumBottomSheetContent extends StatelessWidget {
  const PremiumBottomSheetContent({super.key});

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.sizeOf(context).width;
    final loc = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      padding: EdgeInsets.all(w * 0.06),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: w * 0.1,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.tertiaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: w * 0.08),
            
            // Premium Icon/Banner
            Container(
              width: w * 0.3,
              height: w * 0.3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.premium.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.diamond_rounded, 
                  color: AppColors.premium,
                  size: 64,
                ),
              ),
            ),
            
            SizedBox(height: w * 0.06),
            
            // Title
            Text(
              "Sınırları Kaldırın!", // To-do: add to loc if needed
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryColor.inverted,
                fontSize: w * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: w * 0.03),
            
            // Description
            Text(
              "Bu güçlü yapay zeka modeline ve çok daha fazlasına sınırsız erişim sağlamak için Cortex Premium'a geçiş yapın.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryColor.inverted.withValues(alpha: 0.7),
                fontSize: w * 0.04,
              ),
            ),
            SizedBox(height: w * 0.08),
            
            // Primary Button
            SizedBox(
              width: double.infinity,
              height: w * 0.14,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.premium,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(w * 0.03),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  final target = const FundsScreen();
                  navigateToScreen(target, direction: const Offset(0.0, 1.0));
                },
                child: Text(
                  "Premium'u İncele",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: w * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: w * 0.03),
            
            // Secondary Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                loc.cancel,
                style: TextStyle(
                  color: AppColors.tertiaryColor,
                  fontSize: w * 0.04,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
