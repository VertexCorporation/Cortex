import 'package:home_widget_generator/home_widget_generator.dart';

@HomeWidget(
  name: 'CortexQuickChat',
  widgetUrl: 'cortex://chat',
  android: HomeWidgetAndroidConfiguration(
    minWidth: 132,
    minHeight: 72,
    minResizeWidth: 110,
    minResizeHeight: 68,
    targetCellWidth: 2,
    targetCellHeight: 1,
    resizeMode: HWAndroidResizeMode.horizontalAndVertical,
    applyContentPadding: false,
  ),
  iOS: HomeWidgetIOSConfiguration(groupId: 'group.com.vertex.cortex'),
  widget: HWSizedBox.expand(
    child: HWDecoratedBox(
      decoration: HWBoxDecoration(
        color: HWColor.themed(
          light: HWColor.fixed(0xFFFFFFFF),
          dark: HWColor.fixed(0xFF101116),
        ),
        borderRadius: HWBorderRadius.circular(22),
        border: HWBoxBorder(
          color: HWColor.themed(
            light: HWColor.fixed(0xFFE2E5EC),
            dark: HWColor.fixed(0xFF30333D),
          ),
          thickness: 1,
        ),
      ),
      child: HWPadding(
        padding: HWEdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: HWColumn(
          crossAxisAlignment: HWCrossAxisAlignment.start,
          mainAxisAlignment: HWMainAxisAlignment.center,
          children: [
            HWText.fixed(
              'CORTEX AI',
              style: HWTextStyle(
                color: HWColor.themed(
                  light: HWColor.fixed(0xFF3366E8),
                  dark: HWColor.fixed(0xFF91A9FF),
                ),
                fontSize: 11,
                fontWeight: HWFontWeight.bold,
              ),
            ),
            HWSizedBox(height: 9),
            HWDecoratedBox(
              decoration: HWBoxDecoration(
                color: HWColor.themed(
                  light: HWColor.fixed(0xFFF3F5F9),
                  dark: HWColor.fixed(0xFF1B1E26),
                ),
                borderRadius: HWBorderRadius.circular(16),
              ),
              child: HWPadding(
                padding: HWEdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: HWRow(
                  crossAxisAlignment: HWCrossAxisAlignment.center,
                  mainAxisAlignment: HWMainAxisAlignment.spaceBetween,
                  children: [
                    HWText(
                      HWString('messageHint', defaultValue: 'Ask anything'),
                      style: HWTextStyle(
                        color: HWColor.themed(
                          light: HWColor.fixed(0xFF737985),
                          dark: HWColor.fixed(0xFFADB3C0),
                        ),
                        fontSize: 14,
                      ),
                    ),
                    HWText.fixed(
                      '↗',
                      style: HWTextStyle(
                        color: HWColor.themed(
                          light: HWColor.fixed(0xFF3366E8),
                          dark: HWColor.fixed(0xFF91A9FF),
                        ),
                        fontSize: 18,
                        fontWeight: HWFontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
)
class CortexQuickChatSchema {}
