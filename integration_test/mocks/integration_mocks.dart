/// Integration Test Mocks
/// 테스트에서 사용할 Mock Provider 및 데이터

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 테스트용 Provider Override 목록 생성
///
/// [mockAuth] - 인증 Mock 사용 여부 (기본: true)
/// [mockFortune] - 운세 API Mock 사용 여부 (기본: true)
/// [mockPayment] - 결제 Mock 사용 여부 (기본: true)
List<Override> createTestOverrides({
  bool mockAuth = true,
  bool mockFortune = true,
  bool mockPayment = true,
}) {
  final overrides = <Override>[];

  // 기본 테스트 모드에서는 .env.test의 설정을 사용하므로
  // 추가 Override가 필요하지 않을 수 있음

  // 필요한 경우 여기에 Provider Override 추가
  // 예:
  // if (mockAuth) {
  //   overrides.add(authServiceProvider.overrideWith((ref) => MockAuthService()));
  // }

  return overrides;
}

/// 테스트용 사용자 데이터
class TestUserData {
  static const String testEmail = 'test@fortune.com';
  static const String testPassword = 'test1234!';
  static const String testName = '테스트 사용자';
  static const String testBirthdate = '1990-01-01';
  static const String testGender = 'male';
  static const String testMbti = 'INTJ';
}

/// 테스트용 운세 데이터
class TestFortuneData {
  static const String dailyFortuneTitle = '오늘의 운세';
  static const String loveFortuneTitle = '연애운';
  static const String moneyFortuneTitle = '금전운';
  static const String healthFortuneTitle = '건강운';

  static Map<String, dynamic> get mockDailyFortune => {
        'title': dailyFortuneTitle,
        'score': 85,
        'summary': '오늘은 좋은 하루가 될 것입니다.',
        'details': {
          'overall': '전반적으로 긍정적인 에너지가 넘치는 하루입니다.',
          'love': '연인과의 관계가 더욱 깊어질 수 있습니다.',
          'money': '재정적으로 안정적인 하루입니다.',
          'health': '컨디션이 좋아 활동적인 하루를 보낼 수 있습니다.',
        },
        'luckyItems': ['파란색', '동쪽', '숫자 7'],
      };
}

/// 테스트용 결제 데이터
class TestPaymentData {
  static const String premiumProductId = 'premium_monthly';
  static const String tokenPackageId = 'token_100';
  static const int testTokenBalance = 100;
}

/// 테스트 시나리오별 설정
enum TestScenario {
  /// 신규 사용자 (온보딩 필요)
  newUser,

  /// 기존 사용자 (자동 로그인)
  existingUser,

  /// 프리미엄 사용자
  premiumUser,

  /// 토큰 부족 사용자
  lowTokenUser,

  /// 오프라인 모드
  offlineMode,
}

/// 테스트 시나리오에 따른 Override 생성
List<Override> createScenarioOverrides(TestScenario scenario) {
  switch (scenario) {
    case TestScenario.newUser:
      // 신규 사용자 - 온보딩 표시, 기본 토큰 제공
      return [];

    case TestScenario.existingUser:
      // 기존 사용자 - 자동 로그인, 온보딩 스킵
      return [];

    case TestScenario.premiumUser:
      // 프리미엄 사용자 - 모든 기능 언락
      return [];

    case TestScenario.lowTokenUser:
      // 토큰 부족 - 결제 유도 테스트용
      return [];

    case TestScenario.offlineMode:
      // 오프라인 - 네트워크 에러 핸들링 테스트용
      return [];
  }
}
