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

    test('maps singular caution field into warnings', () {
      final result = FortuneResult(
        id: 'fortune-4',
        type: 'daily',
        title: '오늘의 운세',
        summary: const {'message': '하루 흐름 요약'},
        data: const {
          'content': '실제 운세 본문',
          'score': 83,
          'caution': '충동적인 약속은 한 번 더 확인하세요.',
        },
      );

      final fortune = CharacterFortuneAdapter.fromFortuneResult(
        result: result,
        userId: 'user-4',
        fortuneType: 'daily',
      );

      expect(
        fortune.warnings,
        ['충동적인 약속은 한 번 더 확인하세요.'],
      );
    });

    test('unwraps legacy wrapped payloads from cache or old API envelopes', () {
      final result = FortuneResult(
        id: 'fortune-5',
        type: 'daily',
        title: '오늘의 운세',
        summary: const {},
        data: const {
          'fortune': {
            'content': '차분하게 우선순위를 정리할수록 성과가 이어지는 날이에요.',
            'summary': '작은 정리가 큰 차이를 만드는 하루예요.',
            'score': 86,
            'categories': {
              'work': {'score': 88},
              'social': {'score': 82},
            },
            'advice': '오전에는 가장 중요한 일 하나를 먼저 끝내보세요.',
            'caution': '즉흥적인 소비는 한 번 더 확인하세요.',
          },
          'storySegments': [],
          'cached': true,
          'tokensUsed': 0,
        },
      );

      final fortune = CharacterFortuneAdapter.fromFortuneResult(
        result: result,
        userId: 'user-5',
        fortuneType: 'daily',
      );

      expect(
        fortune.content,
        '차분하게 우선순위를 정리할수록 성과가 이어지는 날이에요.',
      );
      expect(fortune.summary, '작은 정리가 큰 차이를 만드는 하루예요.');
      expect(fortune.overallScore, 86);
      expect(fortune.warnings, ['즉흥적인 소비는 한 번 더 확인하세요.']);
      expect(
        fortune.metadata?['raw_payload'],
        isA<Map<String, dynamic>>(),
      );
      expect(
        (fortune.metadata?['raw_payload'] as Map<String, dynamic>)['content'],
        '차분하게 우선순위를 정리할수록 성과가 이어지는 날이에요.',
      );
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
