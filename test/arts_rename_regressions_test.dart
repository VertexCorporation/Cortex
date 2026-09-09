import 'dart:async';
import 'package:cortex/arts/video_preview.dart';
import 'package:cortex/axon/inbox/panel/actions/rename.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// The fake implements the existing video_player plugin's test interface.
// ignore: depend_on_referenced_packages
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

class FakeVideoPlatform extends VideoPlayerPlatform {
  final events = StreamController<VideoEvent>.broadcast();
  bool disposed = false;
  bool played = false;
  double? volume;
  Duration? position;
  @override
  Future<void> init() async {}
  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async => 1;
  @override
  Stream<VideoEvent> videoEventsFor(int playerId) => events.stream;
  @override
  Future<void> dispose(int playerId) async {
    disposed = true;
  }

  @override
  Future<void> setLooping(int playerId, bool looping) async {}
  @override
  Future<void> setVolume(int playerId, double value) async {
    volume = value;
  }

  @override
  Future<void> play(int playerId) async {
    played = true;
  }

  @override
  Future<void> pause(int playerId) async {}
  @override
  Future<void> seekTo(int playerId, Duration value) async {
    position = value;
  }

  @override
  Widget buildViewWithOptions(VideoViewOptions options) =>
      const ColoredBox(key: Key('video-frame'), color: Colors.blue);
}

void main() {
  testWidgets('rename dialog saves after the originating row unmounts',
      (tester) async {
    final visible = ValueNotifier(true);
    addTearDown(visible.dispose);
    String? renamed;
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
          body: ValueListenableBuilder<bool>(
              valueListenable: visible,
              builder: (context, show, _) => show
                  ? TextButton(
                      onPressed: () async {
                        final result = await showDialog<String>(
                            context: context,
                            builder: (_) => const ConversationRenameDialog(
                                initialTitle: 'Old title'));
                        renamed = result;
                      },
                      child: const Text('Rename'))
                  : const SizedBox())),
    ));
    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();
    visible.value = false;
    await tester.pump();
    await tester.enterText(find.byType(TextField), '  New title  ');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(renamed, 'New title');
    expect(tester.takeException(), isNull);
  });

  testWidgets('video preview shows a silent frame and releases the player',
      (tester) async {
    final platform = FakeVideoPlatform();
    final previous = VideoPlayerPlatform.instance;
    VideoPlayerPlatform.instance = platform;
    addTearDown(() async {
      VideoPlayerPlatform.instance = previous;
      await platform.events.close();
    });
    await tester.pumpWidget(const MaterialApp(
        home: SizedBox(
            width: 180,
            height: 180,
            child: ArtVideoPreview(path: '/tmp/video.mp4'))));
    await tester.pump();
    platform.events.add(VideoEvent(
        eventType: VideoEventType.initialized,
        duration: const Duration(seconds: 2),
        size: const Size(640, 480)));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('video-frame')), findsOneWidget);
    expect(platform.volume, 0);
    expect(platform.played, false);
    expect(platform.position, const Duration(milliseconds: 200));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    expect(platform.disposed, true);
    expect(tester.takeException(), isNull);
  });
}
