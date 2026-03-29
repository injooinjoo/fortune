import 'package:flutter_test/flutter_test.dart';
import 'package:ondo/core/models/fortune_result.dart';
import 'package:ondo/features/character/presentation/providers/character_fortune_adapter.dart';

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
            'timeSpecificFortunes': [
              {
                'time': '오전',
                'title': '집중 시동',
                'score': 87,
                'description': '핵심 업무를 밀어붙이기 좋은 시간이에요.',
                'recommendation': '중요한 메모를 먼저 정리하세요.',
              },
            ],
            'personalActions': [
              {
                'title': '우선순위 3개만 남기기',
                'description': '집중운이 살아나요.',
                'timing': '오전 초반',
              },
            ],
            'sajuInsight': {
              'energy': '차분한 정리와 구조화가 유리해요.',
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
      expect(fortune.categories?['work'], isA<Map<String, dynamic>>());
      expect(fortune.personalActions, isNotEmpty);
      expect(fortune.timeSpecificFortunes, isNotEmpty);
      expect(fortune.timeSpecificFortunes?.first.time, '오전');
      expect(
        fortune.sajuInsight?['energy'],
        '차분한 정리와 구조화가 유리해요.',
      );
      expect(
        fortune.metadata?['raw_payload'],
        isA<Map<String, dynamic>>(),
      );
      expect(
        (fortune.metadata?['raw_payload'] as Map<String, dynamic>)['content'],
        '차분하게 우선순위를 정리할수록 성과가 이어지는 날이에요.',
      );
    });

    test('maps flat fortune-cookie lucky fields into luckyItems', () {
      final result = FortuneResult(
        id: 'fortune-6',
        type: 'fortune-cookie',
        title: '포춘 쿠키',
        summary: const {
          'message': '작은 용기가 오늘의 흐름을 바꿔줄 거예요.',
        },
        data: const {
          'message': '작은 용기가 오늘의 흐름을 바꿔줄 거예요.',
          'lucky_number': '3',
          'lucky_color': '문라이트 블루',
          'lucky_color_hex': '#7B8CFF',
          'lucky_time': '오전 10시',
          'lucky_direction': '동남',
          'lucky_item': '작은 노트',
          'lucky_place': '창가 자리',
          'action_mission': '연락 하나를 먼저 보내보세요.',
          'emoji': '🥠',
        },
        score: 79,
      );

      final fortune = CharacterFortuneAdapter.fromFortuneResult(
        result: result,
        userId: 'user-6',
        fortuneType: 'fortune-cookie',
      );

      expect(fortune.luckyItems?['number'], '3');
      expect(fortune.luckyItems?['color'], '문라이트 블루');
      expect(fortune.luckyItems?['time'], '오전 10시');
      expect(fortune.luckyItems?['direction'], '동남');
      expect(fortune.luckyItems?['item'], '작은 노트');
      expect(fortune.luckyItems?['place'], '창가 자리');
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
