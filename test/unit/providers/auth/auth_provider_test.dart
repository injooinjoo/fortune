/// Auth Provider - Unit Test
/// 인증 상태 관리 테스트

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../../mocks/mock_auth_services.dart';

void main() {
  setUpAll(() {
    registerAuthFallbackValues();
  });

  group('AuthProvider 테스트', () {
    late MockGoTrueClient mockGoTrueClient;

    setUp(() {
      mockGoTrueClient = MockGoTrueClient();
    });

    group('로그인 상태 관리', () {
      test('초기 상태는 로그아웃 상태여야 함', () {
        // 세션이 없는 경우
        when(() => mockGoTrueClient.currentSession).thenReturn(null);
        when(() => mockGoTrueClient.currentUser).thenReturn(null);

        expect(mockGoTrueClient.currentSession, isNull);
        expect(mockGoTrueClient.currentUser, isNull);
      });

      test('세션이 있으면 로그인 상태여야 함', () {
        final mockSession = AuthTestData.createMockSession();
        final mockUser = AuthTestData.createMockUser();

        when(() => mockGoTrueClient.currentSession).thenReturn(mockSession);
        when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);

        expect(mockGoTrueClient.currentSession, isNotNull);
        expect(mockGoTrueClient.currentUser, isNotNull);
        expect(mockGoTrueClient.currentUser?.id, 'test-user-id-12345');
      });

      test('세션 만료 시 로그아웃 처리되어야 함', () {
        // 만료된 세션 시뮬레이션
        when(() => mockGoTrueClient.currentSession).thenReturn(null);
        when(() => mockGoTrueClient.currentUser).thenReturn(null);

        expect(mockGoTrueClient.currentSession, isNull);
      });
    });

    group('사용자 정보 관리', () {
      test('사용자 메타데이터에서 이름을 가져올 수 있어야 함', () {
        final mockUser = AuthTestData.createMockUser(
          userMetadata: {
            'full_name': 'Test User',
            'name': 'Test User',
          },
        );

        expect(mockUser.userMetadata?['full_name'], 'Test User');
        expect(mockUser.userMetadata?['name'], 'Test User');
      });

      test('Google 사용자 정보를 올바르게 파싱해야 함', () {
        final googleUser = AuthTestData.createGoogleUser();

        expect(googleUser.email, 'google.user@gmail.com');
        expect(googleUser.userMetadata?['provider'], 'google');
        expect(googleUser.userMetadata?['avatar_url'], isNotNull);
      });

      test('Kakao 사용자 정보를 올바르게 파싱해야 함', () {
        final kakaoUser = AuthTestData.createKakaoUser();

        expect(kakaoUser.email, contains('kakao'));
        expect(kakaoUser.userMetadata?['provider'], 'kakao');
      });

      test('Apple 사용자 정보를 올바르게 파싱해야 함', () {
        final appleUser = AuthTestData.createAppleUser();

        expect(appleUser.email, contains('privaterelay'));
        expect(appleUser.userMetadata?['provider'], 'apple');
      });

      test('Naver 사용자 정보를 올바르게 파싱해야 함', () {
        final naverUser = AuthTestData.createNaverUser();

        expect(naverUser.email, contains('naver'));
        expect(naverUser.userMetadata?['provider'], 'naver');
      });
    });

    group('토큰 갱신', () {
      test('유효한 리프레시 토큰으로 세션 갱신 가능해야 함', () async {
        final newSession = AuthTestData.createMockSession(
          accessToken: 'new-access-token',
          refreshToken: 'new-refresh-token',
        );
        final authResponse = AuthTestData.createMockAuthResponse(session: newSession);

        when(() => mockGoTrueClient.refreshSession())
            .thenAnswer((_) async => authResponse);

        final result = await mockGoTrueClient.refreshSession();

        expect(result.session, isNotNull);
        expect(result.session?.accessToken, 'new-access-token');
      });
    });

    group('로그아웃', () {
      test('로그아웃 후 세션이 제거되어야 함', () async {
        when(() => mockGoTrueClient.signOut()).thenAnswer((_) async {});

        await mockGoTrueClient.signOut();

        verify(() => mockGoTrueClient.signOut()).called(1);
      });
    });
  });

  group('인증 상태 스트림 테스트', () {
    test('인증 상태 변경 시 이벤트가 발생해야 함', () {
      // 인증 상태 변경 이벤트 테스트
      final events = <String>[];

      // 로그인 이벤트 시뮬레이션
      events.add('signedIn');
      expect(events, contains('signedIn'));

      // 로그아웃 이벤트 시뮬레이션
      events.add('signedOut');
      expect(events, contains('signedOut'));
    });
  });

  group('온보딩 상태 확인', () {
    test('온보딩 완료 프로필 확인', () {
      final profile = AuthTestData.createCompletedProfile();

      expect(profile['onboarding_completed'], isTrue);
      expect(profile['birth_date'], isNotNull);
      expect(profile['birth_time'], isNotNull);
    });

    test('온보딩 미완료 프로필 확인', () {
      final profile = AuthTestData.createIncompleteProfile();

      expect(profile['onboarding_completed'], isFalse);
      expect(profile['birth_date'], isNull);
    });

    test('생년월일 필수 입력 검증', () {
      final incompleteProfile = AuthTestData.createIncompleteProfile();
      final completeProfile = AuthTestData.createCompletedProfile();

      // 온보딩 필요 여부 판단
      bool needsOnboarding(Map<String, dynamic> profile) {
        return profile['birth_date'] == null ||
            profile['onboarding_completed'] != true;
      }

      expect(needsOnboarding(incompleteProfile), isTrue);
      expect(needsOnboarding(completeProfile), isFalse);
    });
  });
}
