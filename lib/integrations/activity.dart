import 'package:cortex/app.dart';
import 'package:cortex/integrations/logo.dart';
import 'package:cortex/integrations/service.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Small live row used inside the existing AI tool/reasoning area. It does
/// not introduce a new chat layout; it simply enriches the current tool trace
/// while a plugin action is running.
class IntegrationLiveActivity extends StatelessWidget {
  final String toolActivity;
  final double scale;

  const IntegrationLiveActivity({
    super.key,
    required this.toolActivity,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final isIntegrationTool = toolActivity == 'discover_integration_tools' ||
        toolActivity == 'execute_integration_tool';
    if (!isIntegrationTool) return const SizedBox.shrink();

    return ListenableBuilder(
      listenable: IntegrationService.instance,
      builder: (context, _) {
        final active = IntegrationService.instance.activeIntegrationTool;
        final isTurkish = Localizations.localeOf(context).languageCode == 'tr';
        final label = toolActivity == 'discover_integration_tools'
            ? (isTurkish ? 'Uygun eklenti aranıyor' : 'Finding the right plugin')
            : active == null
                ? (isTurkish ? 'Eklenti hazırlanıyor' : 'Preparing plugin')
                : (isTurkish
                    ? '${active.toolkitName} ile işlem yapılıyor'
                    : 'Working with ${active.toolkitName}');

        return Padding(
          padding: EdgeInsets.only(
            top: 2 * scale,
            left: 4 * scale,
            bottom: 4 * scale,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.asset(
                  'assets/cortexlogo.png',
                  width: 20 * scale,
                  height: 20 * scale,
                  fit: BoxFit.cover,
                ),
              ),
              if (active != null) ...[
                SizedBox(width: 5 * scale),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 12 * scale,
                  color: AppColors.tertiaryColor.withValues(alpha: 0.65),
                ),
                SizedBox(width: 5 * scale),
                IntegrationLogo(
                  name: active.toolkitName,
                  logoUrl: active.toolkitLogo,
                  size: 20 * scale,
                ),
              ],
              SizedBox(width: 8 * scale),
              Flexible(
                child: Shimmer.fromColors(
                  baseColor: AppColors.tertiaryColor,
                  highlightColor:
                      AppColors.primaryColor.withValues(alpha: 0.52),
                  period: const Duration(milliseconds: 1500),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.tertiaryColor,
                      fontFamily: 'Inter',
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
