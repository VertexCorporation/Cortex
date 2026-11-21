import 'package:home_widget_generator/home_widget_generator.dart';

@HomeWidget(
  name: 'CortexTasks',
  widgetUrl: 'cortex://tasks',
  android: HomeWidgetAndroidConfiguration(),
  iOS: HomeWidgetIOSConfiguration(groupId: 'group.com.vertex.cortex'),
  widget: HWDecoratedBox(
    decoration: HWBoxDecoration(
      color: HWColor.fixed(0xFF171820),
      borderRadius: HWBorderRadius.circular(24),
      border: HWBoxBorder(color: HWColor.fixed(0xFF343540), thickness: 1),
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
              color: HWColor.fixed(0xFFBDA7FF),
              fontWeight: HWFontWeight.bold,
            ),
          ),
          HWSizedBox(height: 10),
          HWText(
            HWString('nextTask', defaultValue: 'No tasks yet'),
            style: HWRoleTextStyle(
              role: HWTextStyleRole.title,
              color: HWColor.fixed(0xFFF5F3FA),
              fontWeight: HWFontWeight.bold,
            ),
          ),
          HWSizedBox(height: 6),
          HWText(
            HWString('taskCount', defaultValue: 'Open your Cortex tasks'),
            style: HWRoleTextStyle(
              role: HWTextStyleRole.caption,
              color: HWColor.fixed(0xFFAAA9B4),
            ),
          ),
        ],
      ),
    ),
  ),
)
class CortexTasksSchema {}
