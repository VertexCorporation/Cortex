import 'package:cortex/app.dart';
import 'package:cortex/axon/widgets/item.dart';
import 'package:cortex/design.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => AppColors.currentTheme = 'light');

  test('Every palette supplies matching Material brightness and readable text',
      () {
    for (final entry in AppColors.themeDefinitions.entries) {
      AppColors.currentTheme = entry.key;
      final theme = Cortex.themeFor(entry.key);
      expect(theme.brightness,
          ThemeData.estimateBrightnessForColor(entry.value.background),
          reason: entry.key);
      final background = theme.colorScheme.surface.computeLuminance();
      final text = theme.colorScheme.onSurface.computeLuminance();
      final contrast = (text > background ? text + .05 : background + .05) /
          (text > background ? background + .05 : text + .05);
      expect(contrast, greaterThanOrEqualTo(4.5), reason: entry.key);
    }
  });

  test('Navigation and reading geometry fit phones and wide screens', () {
    for (final width in [320.0, 390.0, 600.0, 1024.0, 1440.0]) {
      expect(CortexDesign.drawerWidth(width), lessThanOrEqualTo(width));
      expect(width - CortexDesign.readingInset(width) * 2,
          lessThanOrEqualTo(CortexDesign.readingWidth));
    }
  });

  for (final width in [320.0, 390.0, 1024.0]) {
    for (final direction in TextDirection.values) {
      testWidgets(
          'Navigation remains tappable at $width / $direction with large text',
          (tester) async {
        tester.view.physicalSize = Size(width, 850);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var taps = 0;
        AppColors.currentTheme = 'dark';
        await tester.pumpWidget(MaterialApp(
          theme: Cortex.themeFor('dark'),
          home: MediaQuery(
            data: MediaQueryData(
                size: Size(width, 850), textScaler: const TextScaler.linear(2)),
            child: Directionality(
              textDirection: direction,
              child: Scaffold(
                  body: Align(
                alignment: AlignmentDirectional.topStart,
                child: SizedBox(
                    width: CortexDesign.drawerWidth(width),
                    child: AxonItem(
                      label: 'Belgeler ve uzun konuşma başlıkları',
                      iconPath: 'assets/icons/attachment.svg',
                      screenHeight: 850,
                      referenceWidth: CortexDesign.drawerWidth(width),
                      isActive: true,
                      onTap: () => taps++,
                    )),
              )),
            ),
          ),
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(tester.getSize(find.byType(InkWell)).height,
            greaterThanOrEqualTo(48));
        await tester.tap(find.byType(InkWell));
        expect(taps, 1);
      });
    }
  }
}
