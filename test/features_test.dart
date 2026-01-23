import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/select.dart';
import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/library/backend/data/service.dart';

import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:mockito/mockito.dart';

// --- Mocks ---
class MockChatSessionProvider extends Mock implements ChatSessionProvider {
  String? _modelId;

  @override
  String? get modelId => _modelId;

  @override
  void selectModel(ModelEntity model, {bool savePreference = true}) {
    _modelId = model.id;
  }
}

class MockConversationProvider extends Mock implements ConversationProvider {
  bool _cleared = false;

  bool get cleared => _cleared;

  @override
  void clearConversation() {
    _cleared = true;
  }
}

class MockModelService extends Mock implements ModelService {}

void main() {
  group('SelectionService Tests', () {
    late SelectionService selectionService;
    late MockChatSessionProvider mockSession;
    late MockConversationProvider mockConversation;
    late MockModelService mockModelService;

    setUp(() {
      mockSession = MockChatSessionProvider();
      mockConversation = MockConversationProvider();
      mockModelService = MockModelService();

      selectionService = SelectionService(
        sessionProvider: mockSession,
        conversationProvider: mockConversation,
        modelService: mockModelService,
      );
    });

    test('switchActiveModel changes model but DOES NOT clear conversation',
        () async {
      // Setup
      final newModel =
          ModelEntity.fromMap({'id': 'new-model', 'title': 'New'}, 'en');

      // Execute
      await selectionService.switchActiveModel(newModel);

      // Verify
      // 1. Model ID should be updated (via selectModel)
      expect(mockSession.modelId, 'new-model');

      // 2. Conversation should NOT be cleared
      expect(mockConversation.cleared, false);
    });
  });
}
