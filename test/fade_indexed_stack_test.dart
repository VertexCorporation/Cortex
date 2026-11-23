import 'package:cortex/stack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _DependentScreen extends StatefulWidget {
  const _DependentScreen();

  @override
  State<_DependentScreen> createState() => _DependentScreenState();
}

class _DependentScreenState extends State<_DependentScreen> {
  @override
  Widget build(BuildContext context) {
    // Register an inherited dependency like real screens do for sizing,
    // keyboard insets, theme, and localization.
    MediaQuery.sizeOf(context);
    return const Text('screen');
  }
}

Widget _host(int index) {
  return MaterialApp(
    home: Scaffold(
      body: FadeIndexedStack(
        index: index,
        duration: Duration.zero,
        children: [const _DependentScreen(), const Text('other screen')],
      ),
    ),
  );
}

void main() {
  testWidgets('screen state and inherited dependencies survive tab switches', (
    tester,
  ) async {
    await tester.pumpWidget(_host(0));
    await tester.pumpAndSettle();
    final originalState = tester.state<_DependentScreenState>(
      find.byType(_DependentScreen),
    );

    await tester.pumpWidget(_host(1));
    await tester.pumpAndSettle();
    expect(
      tester.state<_DependentScreenState>(find.byType(_DependentScreen)),
      same(originalState),
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(_host(0));
    await tester.pumpAndSettle();
    expect(
      tester.state<_DependentScreenState>(find.byType(_DependentScreen)),
      same(originalState),
    );
    expect(tester.takeException(), isNull);
  });
}
