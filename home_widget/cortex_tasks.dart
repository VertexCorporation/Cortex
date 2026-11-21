import 'package:home_widget_generator/home_widget_generator.dart';

@HomeWidget(
  name: 'CortexTasks',
  widgetUrl: 'cortex://tasks',
  android: HomeWidgetAndroidConfiguration(),
  iOS: HomeWidgetIOSConfiguration(groupId: 'group.com.vertex.cortex'),
  widget: HWDecoratedBox(
    decoration: HWBoxDecoration(
      color: HWColor.themed(
        light: HWColor.fixed(0xFFFFFFFF),
        dark: HWColor.fixed(0xFF090909),
      ),
      borderRadius: HWBorderRadius.circular(24),
      border: HWBoxBorder(
        color: HWColor.themed(
          light: HWColor.fixed(0xFFDADADA),
          dark: HWColor.fixed(0xFF2C2C2C),
        ),
        thickness: 1,
      ),
    ),
    child: HWPadding(
      padding: HWEdgeInsets.all(16),
      child: HWColumn(
        crossAxisAlignment: HWCrossAxisAlignment.start,
        children: [
          HWText.fixed(
            'CORTEX  ·  TASKS',
            style: HWRoleTextStyle(
              role: HWTextStyleRole.caption,
              color: HWColor.themed(
                light: HWColor.fixed(0xFF0D62FE),
                dark: HWColor.fixed(0xFF7C9CFF),
              ),
              fontWeight: HWFontWeight.bold,
            ),
          ),
          HWSizedBox(height: 10),
          HWText(
            HWString('nextTask', defaultValue: 'No tasks yet'),
            style: HWRoleTextStyle(
              role: HWTextStyleRole.title,
              color: HWColor.themed(
                light: HWColor.fixed(0xFF171717),
                dark: HWColor.fixed(0xFFF5F5F5),
              ),
              fontWeight: HWFontWeight.bold,
            ),
          ),
          HWSizedBox(height: 6),
          HWText(
            HWString('taskCount', defaultValue: 'Open your Cortex tasks'),
            style: HWRoleTextStyle(
              role: HWTextStyleRole.caption,
              color: HWColor.themed(
                light: HWColor.fixed(0xFF666666),
                dark: HWColor.fixed(0xFF9B9B9B),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
)
class CortexTasksSchema {}
