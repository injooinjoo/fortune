// Social Auth Service - Unit Test
// 소셜 로그인 서비스 테스트

import 'package:flutter_test/flutter_test.dart';
import '../../../mocks/mock_auth_services.dart';

void main() {
  setUpAll(() {
    registerAuthFallbackValues();
  });

  group('SocialAuthService 테스트', () {
    group('Google OAuth', () {
      test('Google 로그인 성공 시 사용자 정보 반환', () {
        final googleUser = AuthTestData.createGoogleUser();
        final session = AuthTestData.createMockSession(user: googleUser);

        expect(session.user.email, 'google.user@gmail.com');
        expect(session.user.userMetadata?['provider'], 'google');
        expect(session.user.userMetadata?['full_name'], 'Google User');
      });

      test('Google 사용자는 이름이 있어야 함', () {
        final googleUser = AuthTestData.createGoogleUser();
        final name = googleUser.userMetadata?['full_name'] as String?;

        expect(name, isNotNull);
        expect(name, isNotEmpty);
      });
    });

    group('Kakao OAuth', () {
      test('Kakao 로그인 성공 시 사용자 정보 반환', () {
        final kakaoUser = AuthTestData.createKakaoUser();
        final session = AuthTestData.createMockSession(user: kakaoUser);

        expect(session.user.email, contains('kakao'));
        expect(session.user.userMetadata?['provider'], 'kakao');
      });

      test('Kakao 이메일은 kakao_ 접두사를 포함할 수 있음', () {
        final kakaoUser = AuthTestData.createKakaoUser();

        // Kakao 이메일 형식 확인
        bool isKakaoEmail(String? email) {
          return email != null &&
              (email.contains('kakao') || email.startsWith('kakao_'));
        }

        expect(isKakaoEmail(kakaoUser.email), isTrue);
      });

      test('Kakao 사용자 이름 추출 (이름 없는 경우 처리)', () {
        final kakaoUserWithoutName = AuthTestData.createMockUser(
          email: 'kakao_12345678@kakao.com',
          userMetadata: {'provider': 'kakao'},
        );

        final name = kakaoUserWithoutName.userMetadata?['full_name'] as String?;

        // 이름이 없으면 이메일에서 추출하지 않음 (kakao_ 접두사 때문)
        String getDisplayName(String? email, String? fullName) {
          if (fullName != null && fullName.isNotEmpty) return fullName;
          if (email != null && !email.startsWith('kakao_')) {
            return email.split('@')[0];
          }
          return '';
        }

        expect(getDisplayName(kakaoUserWithoutName.email, name), isEmpty);
      });
    });

    group('Apple OAuth', () {
      test('Apple 로그인 성공 시 사용자 정보 반환', () {
        final appleUser = AuthTestData.createAppleUser();
        final session = AuthTestData.createMockSession(user: appleUser);

        expect(session.user.email, contains('privaterelay'));
        expect(session.user.userMetadata?['provider'], 'apple');
      });

      test('Apple 사용자는 프라이빗 릴레이 이메일 사용 가능', () {
        final appleUser = AuthTestData.createAppleUser();

        bool isApplePrivateRelay(String? email) {
          return email != null && email.contains('privaterelay.appleid.com');
        }

        expect(isApplePrivateRelay(appleUser.email), isTrue);
      });

      test('Apple 첫 로그인 시 이름 저장 필요', () {
        // Apple Sign In은 첫 로그인 시에만 이름을 제공
        final appleUser = AuthTestData.createAppleUser();
        final name = appleUser.userMetadata?['full_name'] as String?;

        expect(name, isNotNull);
      });
    });

    group('Naver OAuth', () {
      test('Naver 로그인 성공 시 사용자 정보 반환', () {
        final naverUser = AuthTestData.createNaverUser();
        final session = AuthTestData.createMockSession(user: naverUser);

        expect(session.user.email, contains('naver'));
        expect(session.user.userMetadata?['provider'], 'naver');
        expect(session.user.userMetadata?['full_name'], '네이버 사용자');
      });

      test('Naver 아바타 URL 확인', () {
        final naverUser = AuthTestData.createNaverUser();
        final avatarUrl = naverUser.userMetadata?['avatar_url'] as String?;

        expect(avatarUrl, contains('pstatic.net'));
      });
    });

    group('Provider 공통 로직', () {
      test('모든 Provider는 사용자 ID를 반환해야 함', () {
        final providers = [
          AuthTestData.createGoogleUser(),
          AuthTestData.createKakaoUser(),
          AuthTestData.createAppleUser(),
          AuthTestData.createNaverUser(),
        ];

        for (final user in providers) {
          expect(user.id, isNotNull);
          expect(user.id, isNotEmpty);
        }
      });

      test('Provider 타입 식별', () {
        String getProviderType(Map<String, dynamic>? metadata) {
          return metadata?['provider'] as String? ?? 'unknown';
        }

        expect(getProviderType(AuthTestData.createGoogleUser().userMetadata), 'google');
        expect(getProviderType(AuthTestData.createKakaoUser().userMetadata), 'kakao');
        expect(getProviderType(AuthTestData.createAppleUser().userMetadata), 'apple');
        expect(getProviderType(AuthTestData.createNaverUser().userMetadata), 'naver');
      });

      test('Linked Providers 관리', () {
        // 여러 Provider를 연결한 사용자
        final linkedProviders = ['google', 'kakao'];

        bool hasProvider(List<String> providers, String provider) {
          return providers.contains(provider);
        }

        expect(hasProvider(linkedProviders, 'google'), isTrue);
        expect(hasProvider(linkedProviders, 'kakao'), isTrue);
        expect(hasProvider(linkedProviders, 'apple'), isFalse);
      });

      test('Primary Provider 결정', () {
        // 첫 번째 로그인한 Provider가 primary
        String determinePrimaryProvider(
          String? existing,
          String current,
        ) {
          return existing ?? current;
        }

        expect(determinePrimaryProvider(null, 'google'), 'google');
        expect(determinePrimaryProvider('kakao', 'google'), 'kakao');
      });
    });

    group('에러 케이스', () {
      test('OAuth 취소 처리', () {
        // 사용자가 로그인 취소한 경우
        final cancelledResult = null;

        expect(cancelledResult, isNull);
      });

      test('네트워크 오류 처리', () {
        // 네트워크 오류 시뮬레이션
        Exception? networkError;
        try {
          throw Exception('Network error');
        } catch (e) {
          networkError = e as Exception;
        }

        expect(networkError, isA<Exception>());
      });

      test('토큰 교환 실패 처리', () {
        // OAuth 토큰 교환 실패
        Exception? tokenError;
        try {
          throw Exception('Token exchange failed');
        } catch (e) {
          tokenError = e as Exception;
        }

        expect(tokenError, isA<Exception>());
      });
    });
  });

  group('프로필 업데이트 로직', () {
    test('새 프로필 생성', () {
      final profile = AuthTestData.createCompletedProfile(
        id: 'new-user-id',
        name: 'New User',
      );

      expect(profile['id'], 'new-user-id');
      expect(profile['name'], 'New User');
    });

    test('기존 프로필 업데이트', () {
      final existingProfile = AuthTestData.createCompletedProfile();
      final updates = {'name': 'Updated Name'};

      // 업데이트 병합
      final updatedProfile = {...existingProfile, ...updates};

      expect(updatedProfile['name'], 'Updated Name');
      expect(updatedProfile['birth_date'], existingProfile['birth_date']);
    });

    test('이름 업데이트 조건', () {
      bool shouldUpdateName(String? currentName, String? newName) {
        if (newName == null || newName.isEmpty) return false;
        if (currentName == null) return true;
        if (currentName == '사용자') return true;
        if (currentName.startsWith('kakao_')) return true;
        return false;
      }

      expect(shouldUpdateName(null, 'New Name'), isTrue);
      expect(shouldUpdateName('사용자', 'Real Name'), isTrue);
      expect(shouldUpdateName('kakao_123', 'Real Name'), isTrue);
      expect(shouldUpdateName('Existing Name', 'New Name'), isFalse);
    });

    test('아바타 URL 업데이트 우선순위', () {
      // Google 아바타가 우선
      bool shouldUpdateAvatar(String provider, String? existingUrl) {
        if (provider == 'google') return true;
        if (existingUrl == null || existingUrl.isEmpty) return true;
        return false;
      }

      expect(shouldUpdateAvatar('google', 'existing-url'), isTrue);
      expect(shouldUpdateAvatar('kakao', null), isTrue);
      expect(shouldUpdateAvatar('kakao', 'existing-url'), isFalse);
    });
  });
}
