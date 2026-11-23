import 'package:home_widget_generator/home_widget_generator.dart';

@HomeWidget(
  name: 'CortexTasks',
  widgetUrl: 'cortex://tasks',
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
            HWText(
              HWString('widgetTitle', defaultValue: 'Tasks'),
              style: HWTextStyle(
                color: HWColor.themed(
                  light: HWColor.fixed(0xFF3366E8),
                  dark: HWColor.fixed(0xFF91A9FF),
                ),
                fontSize: 11,
                fontWeight: HWFontWeight.bold,
              ),
            ),
            HWSizedBox(height: 7),
            HWText(
              HWString('nextTask', defaultValue: 'Nothing on your list yet'),
              style: HWTextStyle(
                color: HWColor.themed(
                  light: HWColor.fixed(0xFF171A21),
                  dark: HWColor.fixed(0xFFF2F3F7),
                ),
                fontSize: 16,
                fontWeight: HWFontWeight.bold,
              ),
            ),
            HWSizedBox(height: 3),
            HWText(
              HWString('taskCount', defaultValue: 'Tap to add a task'),
              style: HWTextStyle(
                color: HWColor.themed(
                  light: HWColor.fixed(0xFF737985),
                  dark: HWColor.fixed(0xFFADB3C0),
                ),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    ),
  ),
)
class CortexTasksSchema {}
