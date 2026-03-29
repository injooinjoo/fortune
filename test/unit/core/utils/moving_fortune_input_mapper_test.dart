import 'package:flutter_test/flutter_test.dart';
import 'package:ondo/core/utils/moving_fortune_input_mapper.dart';

void main() {
  group('MovingFortuneInputMapper', () {
    test('normalizes current moving survey keys for API payloads', () {
      final normalized = MovingFortuneInputMapper.normalize({
        'currentArea': '서울 강남구',
        'targetArea': '부산 해운대구',
        'movingPeriod': 'year',
        'purpose': 'investment',
        'concerns': ['direction', 'cost'],
      });

      expect(normalized['currentArea'], '서울 강남구');
      expect(normalized['current_area'], '서울 강남구');
      expect(normalized['targetArea'], '부산 해운대구');
      expect(normalized['target_area'], '부산 해운대구');
      expect(normalized['movingPeriod'], 'year');
      expect(normalized['moving_period'], 'year');
      expect(normalized['purpose'], '투자 목적');
      expect(normalized['purposeCategory'], '투자 목적');
      expect(normalized['concerns'], ['방위', '비용']);
      expect(normalized['direction'], isNotNull);
    });

    test('accepts legacy moving keys and map-based locations', () {
      final normalized = MovingFortuneInputMapper.normalize({
        'current_area': {
          'displayName': '서울 송파구',
        },
        'targetArea': {
          'sido': '경기도',
          'sigungu': '성남시',
        },
        'moving_period': '1year',
        'purpose': 'job',
      });

      expect(normalized['currentArea'], '서울 송파구');
      expect(normalized['target_area'], '경기도 성남시');
      expect(normalized['movingPeriod'], 'year');
      expect(normalized['purpose'], '직장/취업');
    });

    test('resolves moving date for current and legacy period ids', () {
      final baseDate = DateTime(2026, 3, 6);

      expect(
        MovingFortuneInputMapper.resolveMovingDate(
          null,
          movingPeriod: 'year',
          now: baseDate,
        ),
        '2027-03-06',
      );
      expect(
        MovingFortuneInputMapper.resolveMovingDate(
          null,
          movingPeriod: '1year',
          now: baseDate,
        ),
        '2027-03-06',
      );
      expect(
        MovingFortuneInputMapper.resolveMovingDate(
          {
            'selectedDate': '2026-04-15',
          },
          movingPeriod: '1month',
          now: baseDate,
        ),
        '2026-04-15',
      );
    });
  });
}
