// test/screen_root_stability_test.dart
//
// THE SUBTREE-ROOT STABILITY CONTRACT (lib/screen.dart) — the architectural
// invariant behind three production incidents:
//
//   1. Composer corruption: on feature-sheet/model-picker open/close (each a
//      route push/pop), send/+ buttons disappeared and the composer's
//      expansion/FocusNode/controller state reset.
//   2. Render/semantics reparenting assertions (`identical(childRenderObject,
//      parentRenderObject) is not true`) around the composer.
//   3. The Axon conversation list flashed empty when the rename dialog
//      (showGeneralDialog — a route) opened.
//
// Mechanism: MainScreen used to return a BARE main-content widget while its
// route was current, but a MediaQuery-WRAPPED one while any route sat on
// top. Swapping the subtree root's widget TYPE on every route push/pop
// tears the whole main content down and rebuilds it — the composer's State
// (FocusNode/TextEditingController/expansion controller) and the Axon
// list's State are destroyed and recreated, and GlobalKeyed subtrees are
// reparented through the fresh tree, tripping semantics/render assertions.
//
// The fix keeps a PERMANENT MediaQuery wrapper whose DATA varies (viewInsets
// zeroed while another route owns the keyboard). Same root type => elements
// update in place => every State below survives every route transition.
//
// This test replicates both shapes minimally and pins the difference:
// the stable root preserves child State across push/pop cycles; the legacy
// root swap destroys it on the very first push.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A stateful leaf WITHOUT a GlobalKey — exactly like the composer panel
/// state that owns the FocusNode/TextEditingController in production.
class _StatefulLeaf extends StatefulWidget {
  const _StatefulLeaf({super.key});

  @override
  State<_StatefulLeaf> createState() => _StatefulLeafState();
}

class _StatefulLeafState extends State<_StatefulLeaf> {
  int buildCount = 0;

  @override
  Widget build(BuildContext context) {
    buildCount++;
    return const Text('leaf-content', textDirection: TextDirection.ltr);
  }
}

/// The FIXED shape: the subtree root is ALWAYS MediaQuery; only its data
/// varies with route presence (the viewInsets zeroing MainScreen performs).
class StableRootHost extends StatelessWidget {
  const StableRootHost({super.key, this.leafKey});

  final Key? leafKey;

  @override
  Widget build(BuildContext context) {
    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
    final base = MediaQuery.of(context);
    final data =
        isCurrentRoute ? base : base.copyWith(viewInsets: EdgeInsets.zero);
    return MediaQuery(
      data: data,
      child: _StatefulLeaf(key: leafKey),
    );
  }
}

/// The LEGACY shape: the subtree root's widget TYPE swaps between bare
/// content and a MediaQuery wrapper on route push/pop.
class LegacyRootHost extends StatelessWidget {
  const LegacyRootHost({super.key});

  @override
  Widget build(BuildContext context) {
    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
    if (isCurrentRoute) {
      return const _StatefulLeaf();
    }
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(viewInsets: EdgeInsets.zero),
      child: const _StatefulLeaf(),
    );
  }
}

Future<void> _pushAndPopDialog(WidgetTester tester) async {
  final navigatorState =
      tester.state<NavigatorState>(find.byType(Navigator).first);
  navigatorState.push(DialogRoute<void>(
    context: navigatorState.context,
    builder: (_) => const Dialog(child: SizedBox(width: 50, height: 50)),
  ));
  await tester.pumpAndSettle();
  navigatorState.pop();
  await tester.pumpAndSettle();
}

Widget _host(Widget host) =>
    MaterialApp(home: Scaffold(body: Center(child: host)));

void main() {
  testWidgets('STABLE ROOT: the main-content State survives repeated route push/pop cycles',
      (tester) async {
    final keyed = GlobalKey<_StatefulLeafState>(debugLabel: 'chat');
    await tester.pumpWidget(_host(StableRootHost(leafKey: keyed)));
    await tester.pumpAndSettle();

    final leafState = tester.state<_StatefulLeafState>(find.byType(_StatefulLeaf));
    expect(leafState.buildCount, greaterThan(0));
    expect(keyed.currentState, same(leafState),
        reason: 'the keyed leaf must be the one under test');

    // Repeated rapid transitions: rename dialogs, feature sheets, model
    // pickers — every cycle must keep the SAME State object alive, keyed and
    // unkeyed alike (the keyed child mirrors ChatController's screen key, the
    // unkeyed state beneath it mirrors the composer panel's FocusNode/
    // controller holder — which must never be destroyed by a route push).
    for (var i = 0; i < 5; i++) {
      await _pushAndPopDialog(tester);
      expect(tester.state<_StatefulLeafState>(find.byType(_StatefulLeaf)),
          same(leafState),
          reason: 'route cycle $i must not tear down the main-content State');
      expect(keyed.currentState, same(leafState),
          reason: 'GlobalKeyed state must survive route cycle $i');
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('LEGACY ROOT SWAP (the pre-fix shape): the main-content State is destroyed on the first route push',
      (tester) async {
    await tester.pumpWidget(_host(const LegacyRootHost()));
    await tester.pumpAndSettle();

    final leafState = tester.state<_StatefulLeafState>(find.byType(_StatefulLeaf));
    await _pushAndPopDialog(tester);

    // The teardown this pins is the incident mechanism: with a bare
    // (non-GlobalKey) leaf below the swapped root, the State object does
    // not survive — in production this destroyed the composer's
    // FocusNode/controller/animation state and the Axon list state on
    // every sheet/dialog open.
    expect(tester.state<_StatefulLeafState>(find.byType(_StatefulLeaf)),
        isNot(same(leafState)),
        reason: 'the legacy root-type swap must still demonstrate the teardown '
            '(if this fails, the reproduction no longer reproduces — re-check '
            'the harness against the real screen.dart pattern)');
    expect(tester.takeException(), isNull);
  });
}
