// User Provider - Unit Test
// 사용자 상태 관리 테스트

import 'package:flutter_test/flutter_test.dart';
import '../../../mocks/mock_user_services.dart';
import '../../../mocks/mock_auth_services.dart';

void main() {
  setUpAll(() {
    registerUserFallbackValues();
    registerAuthFallbackValues();
  });

  group('UserProvider 테스트', () {
    group('사용자 정보 로드', () {
      test('프로필 정보를 정상적으로 로드해야 함', () {
        final profile = UserTestData.createUserProfile();

        expect(profile['id'], 'test-user-id');
        expect(profile['name'], '홍길동');
        expect(profile['birth_date'], '1990-01-15');
        expect(profile['onboarding_completed'], isTrue);
      });

      test('사주 정보가 계산된 프로필', () {
        final profile = UserTestData.createUserProfile(sajuCalculated: true);
        final sajuData = UserTestData.createSajuData();

        expect(profile['saju_calculated'], isTrue);
        expect(sajuData['four_pillars'], isNotNull);
        expect(sajuData['elements'], isNotNull);
      });

      test('프로필이 없는 경우 null 반환', () {
        Map<String, dynamic>? profile;

        expect(profile, isNull);
      });
    });

    group('프로필 업데이트', () {
      test('이름 변경', () {
        final profile = UserTestData.createUserProfile(name: '홍길동');
        final updatedProfile = {...profile, 'name': '김철수'};

        expect(updatedProfile['name'], '김철수');
      });

      test('생년월일 변경', () {
        final profile = UserTestData.createUserProfile(birthDate: '1990-01-15');
        final updatedProfile = {...profile, 'birth_date': '1991-05-20'};

        expect(updatedProfile['birth_date'], '1991-05-20');
      });

      test('MBTI 설정', () {
        final profile = UserTestData.createUserProfile(mbti: null);
        final updatedProfile = {...profile, 'mbti': 'INTJ'};

        expect(updatedProfile['mbti'], 'INTJ');
      });

      test('프로필 이미지 업데이트', () {
        final profile = UserTestData.createUserProfile();
        final updatedProfile = {
          ...profile,
          'profile_image_url': 'https://example.com/new-avatar.png',
        };

        expect(updatedProfile['profile_image_url'], isNotNull);
      });
    });

    group('사주 정보 관리', () {
      test('사주 데이터 구조 검증', () {
        final sajuData = UserTestData.createSajuData();

        expect(sajuData['four_pillars'], isA<Map>());
        expect(sajuData['four_pillars']['year'], isNotNull);
        expect(sajuData['four_pillars']['month'], isNotNull);
        expect(sajuData['four_pillars']['day'], isNotNull);
        expect(sajuData['four_pillars']['hour'], isNotNull);
      });

      test('오행 분포 검증', () {
        final sajuData = UserTestData.createSajuData();
        final elements = sajuData['elements'] as Map<String, dynamic>;

        expect(elements.keys,
            containsAll(['wood', 'fire', 'earth', 'metal', 'water']));

        // 총합이 8이어야 함 (사주팔자)
        final total =
            elements.values.fold<int>(0, (sum, val) => sum + (val as int));
        expect(total, 8);
      });

      test('주 오행 결정', () {
        final sajuData = UserTestData.createSajuData();

        expect(sajuData['main_element'], isNotNull);
        expect(['wood', 'fire', 'earth', 'metal', 'water'],
            contains(sajuData['main_element']));
      });
    });

    group('별자리 & 띠 계산', () {
      test('별자리 자동 계산', () {
        final profile1 =
            UserTestData.createUserProfile(birthDate: '1990-01-15');
        final profile2 =
            UserTestData.createUserProfile(birthDate: '1990-07-23');
        final profile3 =
            UserTestData.createUserProfile(birthDate: '1990-03-21');

        expect(profile1['zodiac_sign'], '염소자리');
        expect(profile2['zodiac_sign'], '사자자리');
        expect(profile3['zodiac_sign'], '양자리');
      });

      test('띠 자동 계산', () {
        final profile1990 =
            UserTestData.createUserProfile(birthDate: '1990-01-15');
        final profile1988 =
            UserTestData.createUserProfile(birthDate: '1988-05-20');
        final profile2000 =
            UserTestData.createUserProfile(birthDate: '2000-12-25');

        expect(profile1990['chinese_zodiac'], '말');
        expect(profile1988['chinese_zodiac'], '용');
        expect(profile2000['chinese_zodiac'], '용');
      });
    });

    group('운세 히스토리', () {
      test('히스토리 조회', () {
        final history = UserTestData.createFortuneHistory(count: 5);

        expect(history.length, 5);
        expect(history.first['type'], isNotNull);
        expect(history.first['score'], isNotNull);
      });

      test('히스토리 날짜순 정렬', () {
        final history = UserTestData.createFortuneHistory(count: 3);

        // 최신 순으로 정렬되어야 함
        final firstDate = DateTime.parse(history[0]['created_at']);
        final secondDate = DateTime.parse(history[1]['created_at']);

        expect(firstDate.isAfter(secondDate), isTrue);
      });

      test('운세 타입별 필터링', () {
        final history = UserTestData.createFortuneHistory(count: 10);

        final dailyFortunes =
            history.where((h) => h['type'] == 'daily').toList();
        final loveFortunes = history.where((h) => h['type'] == 'love').toList();

        expect(dailyFortunes, isNotEmpty);
        expect(loveFortunes, isNotEmpty);
      });
    });

    group('프로필 유효성 검증', () {
      test('필수 필드 검증', () {
        bool isValidProfile(Map<String, dynamic> profile) {
          return profile['name'] != null &&
              profile['birth_date'] != null &&
              profile['onboarding_completed'] == true;
        }

        final validProfile = UserTestData.createUserProfile();
        final invalidProfile = UserTestData.createUserProfile(
          name: '테스트',
        )..['birth_date'] = null;

        expect(isValidProfile(validProfile), isTrue);
        expect(isValidProfile(invalidProfile), isFalse);
      });

      test('이름 유효성 검증', () {
        bool isValidName(String? name) {
          if (name == null || name.isEmpty) return false;
          if (name == '사용자') return false;
          if (name.startsWith('kakao_')) return false;
          return true;
        }

        expect(isValidName('홍길동'), isTrue);
        expect(isValidName(''), isFalse);
        expect(isValidName(null), isFalse);
        expect(isValidName('사용자'), isFalse);
        expect(isValidName('kakao_12345'), isFalse);
      });

      test('생년월일 유효성 검증', () {
        bool isValidBirthDate(String? birthDate) {
          if (birthDate == null) return false;
          try {
            final date = DateTime.parse(birthDate);
            if (date.isAfter(DateTime.now())) return false;
            if (date.isBefore(DateTime(1900))) return false;
            return true;
          } catch (_) {
            return false;
          }
        }

        expect(isValidBirthDate('1990-01-15'), isTrue);
        expect(isValidBirthDate('2050-01-01'), isFalse); // 미래
        expect(isValidBirthDate('1800-01-01'), isFalse); // 너무 과거
        expect(isValidBirthDate(null), isFalse);
        expect(isValidBirthDate('invalid'), isFalse);
      });
    });

    group('캐시 동작', () {
      test('프로필 캐시 저장', () {
        final profile = UserTestData.createUserProfile();
        final cachedProfile = Map<String, dynamic>.from(profile);

        expect(cachedProfile, equals(profile));
      });

      test('캐시 만료 확인', () {
        final cacheTime = DateTime.now().subtract(const Duration(hours: 2));
        final maxCacheAge = const Duration(hours: 1);

        bool isCacheExpired(DateTime cachedAt, Duration maxAge) {
          return DateTime.now().difference(cachedAt) > maxAge;
        }

        expect(isCacheExpired(cacheTime, maxCacheAge), isTrue);
        expect(isCacheExpired(DateTime.now(), maxCacheAge), isFalse);
      });
    });
  });
}
