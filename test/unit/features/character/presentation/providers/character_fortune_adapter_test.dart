import 'package:flutter_test/flutter_test.dart';
import 'package:fortune/core/models/fortune_result.dart';
import 'package:fortune/features/character/presentation/providers/character_fortune_adapter.dart';

void main() {
  group('CharacterFortuneAdapter', () {
    test('maps standard fortune payload fields', () {
      final result = FortuneResult(
        id: 'fortune-1',
        type: 'dream',
        title: '꿈 분석',
        summary: const {'message': '요약 메시지'},
        data: const {
          'content': '상세 운세 내용',
          'overallScore': 91,
          'luckyItems': {'color': 'blue'},
          'recommendations': ['물 많이 마시기'],
          'warnings': ['충동 구매 주의'],
          'specialTip': '아침 명상',
          'metadata': {'source': 'edge'},
        },
        createdAt: DateTime(2026, 2, 23),
      );

      final fortune = CharacterFortuneAdapter.fromFortuneResult(
        result: result,
        userId: 'user-1',
        fortuneType: 'dream',
      );

      expect(fortune.content, '상세 운세 내용');
      expect(fortune.overallScore, 91);
      expect(fortune.summary, '요약 메시지');
      expect(fortune.luckyItems?['color'], 'blue');
      expect(fortune.recommendations, ['물 많이 마시기']);
      expect(fortune.warnings, ['충동 구매 주의']);
      expect(fortune.specialTip, '아침 명상');
      expect(fortune.metadata?['raw_payload'], result.data);
    });

    test('falls back to summary when content is missing', () {
      final result = FortuneResult(
        id: 'fortune-2',
        type: 'love',
        title: '연애 분석',
        summary: const {'message': '요약 기반 컨텐츠'},
        data: const {
          'overallScore': 77,
        },
      );

      final fortune = CharacterFortuneAdapter.fromFortuneResult(
        result: result,
        userId: 'user-2',
        fortuneType: 'love',
      );

      expect(fortune.content, '요약 기반 컨텐츠');
      expect(fortune.overallScore, 77);
    });

    test('throws on invalid empty payload', () {
      final result = FortuneResult(
        id: 'fortune-3',
        type: 'daily',
        title: '운세',
        summary: const {},
        data: const {},
      );

      expect(
        () => CharacterFortuneAdapter.fromFortuneResult(
          result: result,
          userId: 'user-3',
          fortuneType: 'daily',
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
