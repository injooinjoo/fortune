import 'package:flutter_test/flutter_test.dart';
import 'package:ondo/core/services/fortune_generators/time_based_generator.dart';

void main() {
  group('TimeBasedGenerator', () {
    test('unwraps fortune-daily envelope into FortuneResult data', () {
      final result = TimeBasedGenerator.convertApiResponseForTesting(
        {
          'fortune': {
            'fortuneType': 'daily',
            'content': '차분하게 우선순위를 정리할수록 성과가 이어지는 날이에요.',
            'summary': '작은 정리가 큰 차이를 만드는 하루예요.',
            'score': 86,
            'categories': {
              'work': {'score': 88},
              'social': {'score': 82},
            },
            'advice': '오전에는 가장 중요한 일 하나를 먼저 끝내보세요.',
            'caution': '즉흥적인 소비는 한 번 더 점검하세요.',
          },
          'storySegments': const [],
          'cached': false,
          'tokensUsed': 0,
        },
        const {},
        fortuneType: 'daily',
      );

      expect(result.type, 'daily');
      expect(result.title, '오늘의 운세');
      expect(result.summary['message'], '작은 정리가 큰 차이를 만드는 하루예요.');
      expect(
        result.data['content'],
        '차분하게 우선순위를 정리할수록 성과가 이어지는 날이에요.',
      );
      expect(result.score, 86);
    });

    test('uses time endpoint contract for daily-calendar payloads', () {
      final result = TimeBasedGenerator.convertApiResponseForTesting(
        {
          'fortune': {
            'content': '일정 간격을 넉넉하게 둘수록 흐름이 깔끔해져요.',
            'summary': '오전 정리, 오후 집중의 리듬이 좋아요.',
            'overallScore': 79,
            'dayTheme': '정리된 흐름',
            'specialMessage': '회의 사이 공백을 남겨두면 좋아요.',
          },
          'cached': false,
          'tokensUsed': 12,
        },
        const {
          'period': 'today',
        },
        fortuneType: 'daily_calendar',
      );

      expect(result.type, 'daily-calendar');
      expect(result.title, '오늘 일정 흐름');
      expect(result.summary['message'], '오전 정리, 오후 집중의 리듬이 좋아요.');
      expect(result.data['dayTheme'], '정리된 흐름');
      expect(result.score, 79);
    });
  });
}
