import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/features/character/presentation/utils/tarot_chat_payload_utils.dart';

void main() {
  test('normalizeAnswers flattens tarot selection and builds fallback question',
      () {
    final normalized = TarotChatPayloadUtils.normalizeAnswers({
      'deckId': 'thoth',
      'purpose': 'love',
      'questionText': '',
      'tarotSelection': {
        'selectedCardIndices': [4, 18, 33, 57, 77],
      },
    });

    expect(normalized['deck'], 'thoth');
    expect(normalized['spreadType'], 'relationship');
    expect(normalized['question'], '연애와 관계의 흐름이 궁금해요.');
    expect((normalized['selectedCards'] as List).length, 5);
    expect(
      (normalized['tarotSelection'] as Map<String, dynamic>)['cardCount'],
      5,
    );
  });

  test('buildSelectionPayload uses three-card spread for career purpose', () {
    final payload = TarotChatPayloadUtils.buildSelectionPayload(
      deckId: 'rider_waite',
      purpose: 'career',
      questionText: '이직 타이밍이 궁금해요.',
      selectedCardIndices: [1, 22, 64],
    );

    expect(payload['spreadType'], 'threeCard');
    expect(payload['question'], '이직 타이밍이 궁금해요.');
    expect((payload['selectedCards'] as List).length, 3);
  });
}
