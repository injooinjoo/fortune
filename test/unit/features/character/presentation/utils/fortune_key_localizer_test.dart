import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/features/character/presentation/utils/fortune_key_localizer.dart';

void main() {
  group('FortuneKeyLocalizer', () {
    test('localizes new-year and saju keys to Korean', () {
      expect(FortuneKeyLocalizer.labelFor('yearElement'), '연간 오행');
      expect(FortuneKeyLocalizer.labelFor('compatibilityReason'), '궁합 해설');
      expect(FortuneKeyLocalizer.labelFor('strengthenTips'), '보완 팁');
      expect(FortuneKeyLocalizer.labelFor('balanceElements'), '균형 오행');
      expect(FortuneKeyLocalizer.labelFor('dominantElement'), '주된 오행');
    });

    test('covers snake_case and category-style keys', () {
      expect(FortuneKeyLocalizer.labelFor('reunion_possibility'), '재회 가능성');
      expect(FortuneKeyLocalizer.labelFor('realestate'), '부동산');
      expect(FortuneKeyLocalizer.labelFor('lucky_items'), '행운 아이템');
      expect(FortuneKeyLocalizer.labelFor('loveMatch'), '연애 궁합');
    });

    test('falls back to humanized text for unknown keys', () {
      expect(FortuneKeyLocalizer.labelFor('mysteryKey'), 'mystery Key');
      expect(FortuneKeyLocalizer.labelFor('unknown_value'), 'unknown value');
    });
  });
}
