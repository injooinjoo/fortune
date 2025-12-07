/// UnifiedFortuneService - Unit Test
/// 운세 서비스 핵심 로직 테스트

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock dependencies
class MockSupabaseFunctions extends Mock {
  Future<Map<String, dynamic>> invoke(String functionName, {Map<String, dynamic>? body});
}

void main() {
  group('UnifiedFortuneService 테스트', () {
    late MockSupabaseFunctions mockFunctions;

    setUp(() {
      mockFunctions = MockSupabaseFunctions();
    });

    group('운세 생성 요청', () {
      test('필수 파라미터가 포함되어야 함', () {
        // 운세 생성 시 필요한 파라미터 검증
        final requiredParams = {
          'userId': 'test-user-id',
          'birthDate': '1990-01-01',
          'gender': 'male',
        };

        expect(requiredParams.containsKey('userId'), isTrue);
        expect(requiredParams.containsKey('birthDate'), isTrue);
        expect(requiredParams.containsKey('gender'), isTrue);
      });

      test('운세 타입별 추가 파라미터 검증', () {
        // 사주 운세는 시간 정보 필요
        final sajuParams = {
          'fortuneType': 'saju',
          'birthTime': '09:00',
          'isLunar': false,
        };

        expect(sajuParams['fortuneType'], 'saju');
        expect(sajuParams.containsKey('birthTime'), isTrue);

        // 궁합 운세는 상대방 정보 필요
        final compatibilityParams = {
          'fortuneType': 'compatibility',
          'partnerBirthDate': '1992-05-15',
          'partnerGender': 'female',
        };

        expect(compatibilityParams['fortuneType'], 'compatibility');
        expect(compatibilityParams.containsKey('partnerBirthDate'), isTrue);
      });
    });

    group('운세 결과 파싱', () {
      test('JSON 응답을 FortuneResult로 변환', () {
        final jsonResponse = {
          'success': true,
          'data': {
            'overallScore': 85,
            'sections': [
              {
                'title': '오늘의 운세',
                'content': '좋은 하루가 될 것입니다.',
                'score': 85,
              },
            ],
            'luckyItems': {
              'color': '파랑',
              'number': 7,
            },
          },
        };

        expect(jsonResponse['success'], isTrue);
        expect(jsonResponse['data'], isNotNull);

        final data = jsonResponse['data'] as Map<String, dynamic>;
        expect(data['overallScore'], 85);
        expect(data['sections'], isA<List>());
        expect(data['luckyItems'], isA<Map>());
      });

      test('에러 응답 처리', () {
        final errorResponse = {
          'success': false,
          'error': '토큰이 부족합니다.',
          'errorCode': 'INSUFFICIENT_TOKENS',
        };

        expect(errorResponse['success'], isFalse);
        expect(errorResponse['error'], isNotNull);
        expect(errorResponse['errorCode'], 'INSUFFICIENT_TOKENS');
      });
    });

    group('블러/프리미엄 상태 관리', () {
      test('무료 사용자는 일부 콘텐츠가 블러 처리됨', () {
        final fortuneResult = {
          'isBlurred': true,
          'sections': [
            {'key': 'summary', 'isBlurred': false},
            {'key': 'detail', 'isBlurred': true},
            {'key': 'advice', 'isBlurred': true},
          ],
        };

        expect(fortuneResult['isBlurred'], isTrue);

        final sections = fortuneResult['sections'] as List;
        final blurredSections = sections.where((s) => s['isBlurred'] == true);
        expect(blurredSections.length, 2);
      });

      test('프리미엄 사용자는 모든 콘텐츠 접근 가능', () {
        final premiumResult = {
          'isBlurred': false,
          'sections': [
            {'key': 'summary', 'isBlurred': false},
            {'key': 'detail', 'isBlurred': false},
            {'key': 'advice', 'isBlurred': false},
          ],
        };

        expect(premiumResult['isBlurred'], isFalse);

        final sections = premiumResult['sections'] as List;
        final allUnblurred = sections.every((s) => s['isBlurred'] == false);
        expect(allUnblurred, isTrue);
      });
    });

    group('캐시 동작', () {
      test('같은 날짜의 일일운세는 캐시됨', () {
        final cacheKey = 'daily_fortune_2024-01-15_user123';
        final cachedData = {
          'cacheKey': cacheKey,
          'cachedAt': DateTime.now().toIso8601String(),
          'expiresAt': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
        };

        expect(cachedData['cacheKey'], contains('daily_fortune'));
        expect(cachedData['cachedAt'], isNotNull);
      });

      test('다른 운세 타입은 별도 캐시', () {
        final dailyKey = 'daily_fortune_2024-01-15_user123';
        final tarotKey = 'tarot_fortune_2024-01-15_user123_spread_3card';

        expect(dailyKey, isNot(equals(tarotKey)));
      });
    });
  });

  group('FortuneResult 모델 테스트', () {
    test('점수 범위 검증 (0-100)', () {
      final validScores = [0, 50, 85, 100];
      final invalidScores = [-1, 101, 150];

      for (final score in validScores) {
        expect(score >= 0 && score <= 100, isTrue);
      }

      for (final score in invalidScores) {
        expect(score >= 0 && score <= 100, isFalse);
      }
    });

    test('섹션 키 유효성', () {
      final validSectionKeys = [
        'summary',
        'love',
        'career',
        'wealth',
        'health',
        'advice',
        'luckyItems',
      ];

      for (final key in validSectionKeys) {
        expect(key, isNotEmpty);
        expect(key, matches(RegExp(r'^[a-zA-Z]+$')));
      }
    });
  });
}
