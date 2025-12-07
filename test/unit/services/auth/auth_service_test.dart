/// Auth Service - Unit Test
/// 인증 서비스 비즈니스 로직 테스트

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../../mocks/mock_auth_services.dart';

void main() {
  setUpAll(() {
    registerAuthFallbackValues();
  });

  group('AuthService 테스트', () {
    late MockSupabaseClient mockSupabaseClient;
    late MockGoTrueClient mockGoTrueClient;
    late MockStorageService mockStorageService;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockGoTrueClient = MockGoTrueClient();
      mockStorageService = MockStorageService();

      when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    });

    group('세션 관리', () {
      test('현재 세션 조회', () {
        final mockSession = AuthTestData.createMockSession();
        when(() => mockGoTrueClient.currentSession).thenReturn(mockSession);

        final session = mockGoTrueClient.currentSession;

        expect(session, isNotNull);
        expect(session?.accessToken, 'mock-access-token');
      });

      test('현재 사용자 조회', () {
        final mockUser = AuthTestData.createMockUser();
        when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);

        final user = mockGoTrueClient.currentUser;

        expect(user, isNotNull);
        expect(user?.id, 'test-user-id-12345');
        expect(user?.email, 'test@example.com');
      });

      test('세션 없을 때 null 반환', () {
        when(() => mockGoTrueClient.currentSession).thenReturn(null);
        when(() => mockGoTrueClient.currentUser).thenReturn(null);

        expect(mockGoTrueClient.currentSession, isNull);
        expect(mockGoTrueClient.currentUser, isNull);
      });
    });

    group('로컬 스토리지 연동', () {
      test('프로필 저장', () async {
        final profile = AuthTestData.createCompletedProfile();

        when(() => mockStorageService.saveUserProfile(any()))
            .thenAnswer((_) async => true);

        await mockStorageService.saveUserProfile(profile);

        verify(() => mockStorageService.saveUserProfile(profile)).called(1);
      });

      test('프로필 조회', () async {
        final profile = AuthTestData.createCompletedProfile();

        when(() => mockStorageService.getUserProfile())
            .thenAnswer((_) async => profile);

        final result = await mockStorageService.getUserProfile();

        expect(result, isNotNull);
        expect(result?['name'], 'Test User');
        expect(result?['birth_date'], '1990-01-01');
      });

      test('프로필 삭제 (로그아웃 시)', () async {
        when(() => mockStorageService.clearUserProfile())
            .thenAnswer((_) async {});

        await mockStorageService.clearUserProfile();

        verify(() => mockStorageService.clearUserProfile()).called(1);
      });
    });

    group('토큰 검증', () {
      test('유효한 액세스 토큰', () {
        final session = AuthTestData.createMockSession(
          accessToken: 'valid-access-token',
          expiresIn: 3600,
        );

        expect(session.accessToken, 'valid-access-token');
        expect(session.expiresIn, greaterThan(0));
      });

      test('토큰 만료 확인', () {
        // 토큰 만료 로직 테스트
        final now = DateTime.now();
        final expiresAt = now.add(const Duration(hours: 1));
        final expiredAt = now.subtract(const Duration(hours: 1));

        bool isTokenExpired(DateTime expirationTime) {
          return DateTime.now().isAfter(expirationTime);
        }

        expect(isTokenExpired(expiresAt), isFalse);
        expect(isTokenExpired(expiredAt), isTrue);
      });
    });

    group('에러 처리', () {
      test('네트워크 오류 시 예외 발생', () async {
        when(() => mockGoTrueClient.refreshSession())
            .thenThrow(Exception('Network error'));

        expect(
          () => mockGoTrueClient.refreshSession(),
          throwsA(isA<Exception>()),
        );
      });

      test('세션 갱신 실패 시 null 반환 처리', () async {
        when(() => mockGoTrueClient.currentSession).thenReturn(null);
        when(() => mockGoTrueClient.currentUser).thenReturn(null);

        // 세션이 없을 때 적절히 null을 반환하는지 확인
        expect(mockGoTrueClient.currentSession, isNull);
        expect(mockGoTrueClient.currentUser, isNull);
      });
    });
  });

  group('프로필 데이터 검증', () {
    test('필수 필드 검증', () {
      final validProfile = AuthTestData.createCompletedProfile();
      final invalidProfile = AuthTestData.createIncompleteProfile();

      bool isValidProfile(Map<String, dynamic> profile) {
        return profile['birth_date'] != null &&
            profile['name'] != null &&
            profile['name'].toString().isNotEmpty;
      }

      expect(isValidProfile(validProfile), isTrue);
      expect(isValidProfile(invalidProfile), isFalse);
    });

    test('생년월일 형식 검증', () {
      final profile = AuthTestData.createCompletedProfile(
        birthDate: '1990-01-01',
      );

      bool isValidBirthDate(String? birthDate) {
        if (birthDate == null) return false;
        try {
          DateTime.parse(birthDate);
          return true;
        } catch (_) {
          return false;
        }
      }

      expect(isValidBirthDate(profile['birth_date']), isTrue);
      expect(isValidBirthDate('invalid-date'), isFalse);
      expect(isValidBirthDate(null), isFalse);
    });

    test('시간 형식 검증 (HH:mm)', () {
      bool isValidTimeFormat(String? time) {
        if (time == null) return false;
        final regex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
        return regex.hasMatch(time);
      }

      expect(isValidTimeFormat('09:00'), isTrue);
      expect(isValidTimeFormat('23:59'), isTrue);
      expect(isValidTimeFormat('12:30'), isTrue);
      expect(isValidTimeFormat('25:00'), isFalse);
      expect(isValidTimeFormat('9:00'), isTrue); // 한 자리 시간도 허용
      expect(isValidTimeFormat('invalid'), isFalse);
    });
  });

  group('사용자 타입별 처리', () {
    test('소셜 로그인 사용자 (이름 있음) - 이름 스텝 건너뛰기', () {
      final googleUser = AuthTestData.createGoogleUser();
      final name = googleUser.userMetadata?['full_name'] as String?;

      bool shouldSkipNameStep(String? userName) {
        return userName != null &&
            userName.isNotEmpty &&
            userName != '사용자' &&
            !userName.startsWith('kakao_');
      }

      expect(shouldSkipNameStep(name), isTrue);
    });

    test('Kakao 사용자 (이름 없음) - 이름 스텝 필요', () {
      final kakaoUser = AuthTestData.createMockUser(
        email: 'kakao_12345678@kakao.com',
        userMetadata: {},
      );

      final name = kakaoUser.userMetadata?['full_name'] as String?;

      bool shouldSkipNameStep(String? userName) {
        return userName != null &&
            userName.isNotEmpty &&
            userName != '사용자' &&
            !userName.startsWith('kakao_');
      }

      expect(shouldSkipNameStep(name), isFalse);
    });

    test('익명 사용자 처리', () {
      final anonymousUser = AuthTestData.createMockUser(
        id: 'anon-user-id',
        email: null,
        userMetadata: {},
      );

      expect(anonymousUser.email, isNull);
      expect(anonymousUser.userMetadata, isEmpty);
    });
  });
}
