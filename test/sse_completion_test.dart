// test/sse_completion_test.dart
//
// The client half of the EXPLICIT COMPLETION CONTRACT (fulcrum/generation.md):
// how a finished HTTP stream is classified as complete vs interrupted.
//
// [ApiService.streamInterrupted] is the single classification point for the
// gateway's terminal `done` event:
//
//   NORMAL COMPLETION     done{truncated:false}             -> complete
//   TOKEN-LIMIT CUT       done{truncated:true, reason:"length"|...} -> truncated
//   CONTENT-FILTER CUT    done{truncated:true, "content_filter"}  -> truncated
//   TRANSPORT DEATH       EOF with NO done event             -> INTERRUPTED
//
// The transport-death classification is the incident fix: when the gateway
// connection dies mid-generation (socket drop, function-process timeout),
// the client must NOT present the partial text as a complete response — and
// it must not claim the model hit its token limit either; it marks the
// response interrupted so the UI offers to continue from the partial text.
import 'package:cortex/chat/services/api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiService.streamInterrupted — the terminal stream classification', () {
    test('NORMAL COMPLETION: done event says not truncated -> complete', () {
      expect(
        ApiService.streamInterrupted(
          serverReportedTruncation: false,
          sawDoneEvent: true,
        ),
        isFalse,
      );
    });

    test('REAL TOKEN LIMIT: done event says truncated -> truncated', () {
      expect(
        ApiService.streamInterrupted(
          serverReportedTruncation: true,
          sawDoneEvent: true,
        ),
        isTrue,
      );
    });

    test('TRANSPORT DEATH: EOF without a done event -> INTERRUPTED, never complete', () {
      // The gateway sends the terminal done event for EVERY non-terminated
      // request (text and media lanes alike). An EOF that never saw one means
      // the transport died mid-generation.
      expect(
        ApiService.streamInterrupted(
          serverReportedTruncation: false,
          sawDoneEvent: false,
        ),
        isTrue,
      );
    });

    test('transport death plus a truncation report still reports interrupted', () {
      expect(
        ApiService.streamInterrupted(
          serverReportedTruncation: true,
          sawDoneEvent: false,
        ),
        isTrue,
      );
    });

    test('the full truth table has exactly one complete outcome', () {
      // Only done{truncated:false} is a completion — everything else is an
      // interrupted generation. This pins the contract against regressions
      // that would reintroduce "EOF means complete".
      final completeOutcomes = <(bool, bool)>[];
      for (final truncated in [false, true]) {
        for (final sawDone in [false, true]) {
          if (!ApiService.streamInterrupted(
            serverReportedTruncation: truncated,
            sawDoneEvent: sawDone,
          )) {
            completeOutcomes.add((truncated, sawDone));
          }
        }
      }
      expect(completeOutcomes, [(false, true)]);
    });
  });
}
