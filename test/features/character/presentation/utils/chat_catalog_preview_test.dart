import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/core/navigation/fortune_chat_route.dart';
import 'package:fortune/features/character/data/fortune_characters.dart';
import 'package:fortune/features/character/presentation/utils/chat_catalog_preview.dart';

void main() {
  group('ChatCatalogPreview', () {
    test('parses general home preview from route query', () {
      final preview = ChatCatalogPreview.fromUri(
        Uri.parse('/chat?catalogState=general-home'),
      );

      expect(preview, isNotNull);
      expect(preview!.state, ChatCatalogPreviewState.generalHome);
      expect(preview.showsHomeShell, isTrue);
      expect(preview.showsChatOverlay, isFalse);
    });

    test('builds deterministic survey preview state for daily', () {
      const preview = ChatCatalogPreview(
        state: ChatCatalogPreviewState.curiositySurvey,
        fortuneType: 'daily',
      );

      final surveyState = catalogPreviewSurveyState(preview);

      expect(surveyState.isActive, isTrue);
      expect(surveyState.fortuneTypeString, 'daily');
      expect(surveyState.activeProgress?.currentStep.id, 'focus');
      expect(
        surveyState.activeProgress?.currentStep.options.map((e) => e.id),
        ['work', 'relationship', 'timing'],
      );
    });

    test('builds deterministic result preview with embedded result card', () {
      const preview = ChatCatalogPreview(
        state: ChatCatalogPreviewState.curiosityResult,
        fortuneType: 'daily',
      );

      final chatState = catalogPreviewChatState(
        preview: preview,
        character: haneulCharacter,
      );

      expect(chatState.hasConversation, isTrue);
      expect(chatState.messages.last.hasEmbeddedWidget, isTrue);
      expect(chatState.messages.last.embeddedWidgetType, 'fortune_result_card');
      expect(chatState.messages.last.componentData?['fortuneType'], 'daily');
    });
  });
}
