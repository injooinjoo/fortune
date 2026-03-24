import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/features/character/presentation/providers/character_chat_survey_provider.dart';
import 'package:fortune/features/chat/domain/models/fortune_survey_config.dart';

void main() {
  group('CharacterChatSurveyNotifier talisman options', () {
    test('disables prebuilt option when catalog is unavailable', () {
      final notifier = CharacterChatSurveyNotifier();

      notifier.startSurvey(
        FortuneSurveyType.talisman,
        fortuneTypeStr: 'talisman',
        talismanCatalogAvailable: false,
      );

      final options = notifier.getCurrentStepOptions();
      final prebuilt = options.firstWhere((option) => option.id == 'prebuilt');
      final premium = options.firstWhere((option) => option.id == 'premium_ai');

      expect(prebuilt.isDisabled, isTrue);
      expect(prebuilt.label, '랜덤 부적 (준비중)');
      expect(premium.isDisabled, isFalse);
    });
  });
}
