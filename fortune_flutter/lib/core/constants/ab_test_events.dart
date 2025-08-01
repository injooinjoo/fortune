/// Firebase Analytics 이벤트 상수
/// A/B 테스트에서 추적할 모든 이벤트 정의
class ABTestEvents {
  // Private constructor to prevent instantiation
  ABTestEvents._();
  
  // ===== 구독 관련 이벤트 =====
  
  /// 구독 화면 조회
  static const String subscriptionScreenView = 'subscription_screen_view';
  
  /// 구독 플랜 선택
  static const String subscriptionPlanSelected = 'subscription_plan_selected';
  
  /// 구독 구매 시작
  static const String subscriptionPurchaseStarted = 'subscription_purchase_started';
  
  /// 구독 구매 완료
  static const String subscriptionPurchased = 'subscription_purchased';
  
  /// 구독 구매 실패
  static const String subscriptionPurchaseFailed = 'subscription_purchase_failed';
  
  /// 구독 취소
  static const String subscriptionCancelled = 'subscription_cancelled';
  
  /// 구독 복원
  static const String subscriptionRestored = 'subscription_restored';
  
  // ===== 토큰 관련 이벤트 =====
  
  /// 토큰 구매 화면 조회
  static const String tokenPurchaseScreenView = 'token_purchase_screen_view';
  
  /// 토큰 패키지 선택
  static const String tokenPackageSelected = 'token_package_selected';
  
  /// 토큰 구매 시작
  static const String tokenPurchaseStarted = 'token_purchase_started';
  
  /// 토큰 구매 완료
  static const String tokenPurchased = 'token_purchased';
  
  /// 토큰 구매 실패
  static const String tokenPurchaseFailed = 'token_purchase_failed';
  
  /// 토큰 사용
  static const String tokenUsed = 'token_used';
  
  /// 토큰 부족
  static const String tokenInsufficient = 'token_insufficient';
  
  // ===== 온보딩 관련 이벤트 =====
  
  /// 온보딩 시작
  static const String onboardingStarted = 'onboarding_started';
  
  /// 온보딩 단계 완료
  static const String onboardingStepCompleted = 'onboarding_step_completed';
  
  /// 온보딩 완료
  static const String onboardingCompleted = 'onboarding_completed';
  
  /// 온보딩 스킵
  static const String onboardingSkipped = 'onboarding_skipped';
  
  /// 온보딩 이탈
  static const String onboardingAbandoned = 'onboarding_abandoned';
  
  // ===== 운세 관련 이벤트 =====
  
  /// 운세 목록 조회
  static const String fortuneListView = 'fortune_list_view';
  
  /// 운세 타입 선택
  static const String fortuneTypeSelected = 'fortune_type_selected';
  
  /// 운세 생성 시작
  static const String fortuneGenerationStarted = 'fortune_generation_started';
  
  /// 운세 생성 완료
  static const String fortuneGenerated = 'fortune_generated';
  
  /// 운세 생성 실패
  static const String fortuneGenerationFailed = 'fortune_generation_failed';
  
  /// 운세 조회
  static const String fortuneViewed = 'fortune_viewed';
  
  /// 운세 공유
  static const String fortuneShared = 'fortune_shared';
  
  /// 운세 저장
  static const String fortuneSaved = 'fortune_saved';
  
  // ===== 사용자 인증 관련 이벤트 =====
  
  /// 로그인 화면 조회
  static const String loginScreenView = 'login_screen_view';
  
  /// 로그인 시도
  static const String loginAttempted = 'login_attempted';
  
  /// 로그인 성공
  static const String loginSucceeded = 'login_succeeded';
  
  /// 로그인 실패
  static const String loginFailed = 'login_failed';
  
  /// 회원가입 시작
  static const String signupStarted = 'signup_started';
  
  /// 회원가입 완료
  static const String signupCompleted = 'signup_completed';
  
  /// 로그아웃
  static const String logout = 'logout';
  
  // ===== 프로필 관련 이벤트 =====
  
  /// 프로필 조회
  static const String profileViewed = 'profile_viewed';
  
  /// 프로필 편집
  static const String profileEdited = 'profile_edited';
  
  /// 프로필 사진 변경
  static const String profilePhotoChanged = 'profile_photo_changed';
  
  // ===== 설정 관련 이벤트 =====
  
  /// 설정 화면 조회
  static const String settingsViewed = 'settings_viewed';
  
  /// 알림 설정 변경
  static const String notificationSettingsChanged = 'notification_settings_changed';
  
  /// 언어 변경
  static const String languageChanged = 'language_changed';
  
  /// 테마 변경
  static const String themeChanged = 'theme_changed';
  
  // ===== 참여도 관련 이벤트 =====
  
  /// 앱 열기
  static const String appOpened = 'app_opened';
  
  /// 세션 시작
  static const String sessionStarted = 'session_started';
  
  /// 세션 종료
  static const String sessionEnded = 'session_ended';
  
  /// 일일 활성 사용자
  static const String dailyActive = 'daily_active';
  
  /// 주간 활성 사용자
  static const String weeklyActive = 'weekly_active';
  
  /// 월간 활성 사용자
  static const String monthlyActive = 'monthly_active';
  
  // ===== 추천 및 공유 관련 이벤트 =====
  
  /// 추천 링크 생성
  static const String referralLinkCreated = 'referral_link_created';
  
  /// 추천 링크 공유
  static const String referralLinkShared = 'referral_link_shared';
  
  /// 추천으로 가입
  static const String referralSignup = 'referral_signup';
  
  /// 리뷰 요청 표시
  static const String reviewRequested = 'review_requested';
  
  /// 리뷰 작성
  static const String reviewSubmitted = 'review_submitted';
  
  // ===== 에러 및 성능 관련 이벤트 =====
  
  /// API 에러
  static const String apiError = 'api_error';
  
  /// 결제 에러
  static const String paymentError = 'payment_error';
  
  /// 네트워크 에러
  static const String networkError = 'network_error';
  
  /// 화면 로드 시간
  static const String screenLoadTime = 'screen_load_time';
  
  /// API 응답 시간
  static const String apiResponseTime = 'api_response_time';
}

/// 이벤트 파라미터 키
class ABTestEventParams {
  // Private constructor to prevent instantiation
  ABTestEventParams._();
  
  // 공통 파라미터
  static const String screenName = 'screen_name';
  static const String screenClass = 'screen_class';
  static const String source = 'source';
  static const String timestamp = 'timestamp';
  
  // 구독 관련 파라미터
  static const String subscriptionPrice = 'subscription_price';
  static const String subscriptionPlan = 'subscription_plan';
  static const String subscriptionDuration = 'subscription_duration';
  
  // 토큰 관련 파라미터
  static const String tokenAmount = 'token_amount';
  static const String tokenPrice = 'token_price';
  static const String tokenPackageId = 'token_package_id';
  static const String remainingTokens = 'remaining_tokens';
  
  // 온보딩 관련 파라미터
  static const String onboardingStep = 'onboarding_step';
  static const String onboardingStepName = 'onboarding_step_name';
  static const String onboardingFlow = 'onboarding_flow';
  static const String onboardingDuration = 'onboarding_duration';
  
  // 운세 관련 파라미터
  static const String fortuneType = 'fortune_type';
  static const String fortuneCategory = 'fortune_category';
  static const String fortuneDate = 'fortune_date';
  static const String fortuneCost = 'fortune_cost';
  
  // 사용자 관련 파라미터
  static const String userId = 'user_id';
  static const String userType = 'user_type';
  static const String loginMethod = 'login_method';
  static const String signupMethod = 'signup_method';
  
  // 에러 관련 파라미터
  static const String errorCode = 'error_code';
  static const String errorMessage = 'error_message';
  static const String errorType = 'error_type';
  
  // 성능 관련 파라미터
  static const String loadTime = 'load_time';
  static const String responseTime = 'response_time';
  static const String duration = 'duration';
  
  // A/B 테스트 관련 파라미터
  static const String experimentName = 'experiment_name';
  static const String experimentVariant = 'experiment_variant';
  static const String abTestGroup = 'ab_test_group';
}