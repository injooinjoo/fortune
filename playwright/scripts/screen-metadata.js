/**
 * Fortune App - Screen Metadata Registry
 *
 * 각 화면의 상세 정보를 정의합니다:
 * - 라우트 경로
 * - 한글 이름 및 설명
 * - UX 플로우 (이전/다음 화면)
 * - 사용된 컴포넌트
 * - 디자인 노트
 */

const SCREEN_METADATA = {
  // ===========================================================================
  // AUTH & ONBOARDING
  // ===========================================================================
  auth: {
    category: 'Auth & Onboarding',
    categoryKo: '인증 & 온보딩',
    figmaPage: '01-Auth-Onboarding',
    screens: {
      landing: {
        path: '/',
        name: 'Landing',
        nameKo: '랜딩 페이지',
        description: '앱 첫 진입 화면. 소셜 로그인 버튼 제공',
        descriptionKo: '앱 첫 진입 화면. 카카오/애플/구글 로그인',
        uxFlow: {
          prev: null,
          next: ['signup', 'home'],
          trigger: '로그인 버튼 클릭'
        },
        components: [
          'SocialLoginButton',
          'AppLogo',
          'AnimatedBackground'
        ],
        designNotes: [
          '브랜드 색상 강조',
          '소셜 로그인 아이콘 표준 가이드라인 준수',
          '다크모드: 배경 그라데이션 조정'
        ],
        states: ['default', 'loading'],
        dartFile: 'lib/screens/landing_page.dart'
      },
      splash: {
        path: '/splash',
        name: 'Splash',
        nameKo: '스플래시',
        description: '앱 로딩 화면',
        descriptionKo: '앱 시작 시 로고 애니메이션',
        uxFlow: {
          prev: null,
          next: ['landing', 'home'],
          trigger: '자동 (2초 후)'
        },
        components: ['AppLogo', 'LoadingIndicator'],
        designNotes: ['로고 페이드인 애니메이션', '로딩 프로그레스 표시'],
        states: ['loading'],
        dartFile: 'lib/screens/splash_screen.dart'
      },
      signup: {
        path: '/signup',
        name: 'Signup',
        nameKo: '회원가입',
        description: '신규 사용자 가입 화면',
        descriptionKo: '소셜 계정으로 회원가입',
        uxFlow: {
          prev: ['landing'],
          next: ['onboarding'],
          trigger: '가입 완료'
        },
        components: ['SocialLoginButton', 'TermsCheckbox'],
        designNotes: ['약관 동의 체크박스', '개인정보 처리방침 링크'],
        states: ['default', 'loading', 'error'],
        dartFile: 'lib/screens/auth/signup_screen.dart'
      },
      onboarding: {
        path: '/onboarding',
        name: 'Onboarding',
        nameKo: '온보딩',
        description: '사용자 정보 입력 플로우',
        descriptionKo: '이름, 생년월일, 성별 입력',
        uxFlow: {
          prev: ['signup'],
          next: ['home'],
          trigger: '온보딩 완료'
        },
        components: [
          'StepIndicator',
          'NameInput',
          'BirthDatePicker',
          'GenderSelector',
          'UnifiedButton'
        ],
        designNotes: [
          '단계별 진행 표시',
          '생년월일: 음력/양력 선택',
          '시간 선택: 12지지 기반'
        ],
        states: ['step1-name', 'step2-birth', 'step3-time', 'step4-gender', 'complete'],
        dartFile: 'lib/screens/onboarding/onboarding_page.dart'
      },
      'onboarding-toss-style': {
        path: '/onboarding/toss-style',
        name: 'Onboarding Toss Style',
        nameKo: '온보딩 (토스 스타일)',
        description: '토스 스타일 온보딩 UI',
        descriptionKo: '미니멀한 단계별 입력',
        uxFlow: {
          prev: ['signup'],
          next: ['home'],
          trigger: '완료'
        },
        components: ['TossStyleInput', 'ProgressBar', 'UnifiedButton'],
        designNotes: ['대형 타이틀', '단일 입력 포커스', '키보드 자동 표시'],
        states: ['step1', 'step2', 'step3', 'step4', 'step5'],
        dartFile: 'lib/screens/onboarding/onboarding_page.dart'
      }
    }
  },

  // ===========================================================================
  // HOME & MAIN NAVIGATION
  // ===========================================================================
  home: {
    category: 'Home & Navigation',
    categoryKo: '홈 & 네비게이션',
    figmaPage: '02-Home-Navigation',
    screens: {
      home: {
        path: '/home',
        name: 'Home',
        nameKo: '홈',
        description: '메인 홈 화면. 일일 운세 요약 및 퀵 액세스',
        descriptionKo: '오늘의 운세, 추천 콘텐츠, 바로가기',
        uxFlow: {
          prev: ['onboarding', 'landing'],
          next: ['fortune', 'profile', 'premium', 'any-fortune-page'],
          trigger: '탭/카드 클릭'
        },
        components: [
          'HomeAppBar',
          'DailyFortuneCard',
          'FortuneSwipeCards',
          'QuickAccessGrid',
          'BottomNavigationBar'
        ],
        designNotes: [
          '스와이프 카드 UI (일일운세)',
          '추천 운세 그리드',
          '프리미엄 배너'
        ],
        states: ['default', 'loading', 'premium-user', 'free-user'],
        dartFile: 'lib/screens/home/home_screen.dart'
      },
      'fortune-list': {
        path: '/fortune',
        name: 'Fortune List',
        nameKo: '운세 목록',
        description: '전체 운세 서비스 목록',
        descriptionKo: '카테고리별 운세 서비스 탐색',
        uxFlow: {
          prev: ['home'],
          next: ['any-fortune-detail'],
          trigger: '운세 카드 클릭'
        },
        components: [
          'FortuneListAppBar',
          'CategoryTabs',
          'FortuneListCard',
          'SearchBar'
        ],
        designNotes: [
          '카테고리 탭 (전체/사주/타로/연애/재물...)',
          '카드 그리드 레이아웃',
          '검색 기능'
        ],
        states: ['default', 'category-filtered', 'search-active'],
        dartFile: 'lib/features/fortune/presentation/pages/fortune_list_page.dart'
      },
      trend: {
        path: '/trend',
        name: 'Trend',
        nameKo: '트렌드',
        description: '트렌딩 콘텐츠 (심리테스트, 밸런스게임)',
        descriptionKo: '인기 심리테스트, 이상형 월드컵',
        uxFlow: {
          prev: ['home'],
          next: ['trend-psychology', 'trend-worldcup', 'trend-balance'],
          trigger: '콘텐츠 선택'
        },
        components: [
          'TrendAppBar',
          'TrendContentCard',
          'CategoryFilter'
        ],
        designNotes: ['카드 기반 레이아웃', '참여자 수 표시', '공유 버튼'],
        states: ['default', 'loading'],
        dartFile: 'lib/features/trend/presentation/pages/trend_page.dart'
      },
      premium: {
        path: '/premium',
        name: 'Premium',
        nameKo: '프리미엄',
        description: '프리미엄 구독 및 토큰 구매',
        descriptionKo: '구독 플랜, 토큰 충전',
        uxFlow: {
          prev: ['home', 'profile'],
          next: ['subscription', 'token-purchase'],
          trigger: '플랜/토큰 선택'
        },
        components: [
          'PremiumAppBar',
          'SubscriptionCard',
          'TokenPackageCard',
          'BenefitsList'
        ],
        designNotes: ['가격 강조', '혜택 목록', '인앱결제 연동'],
        states: ['default', 'subscribed', 'processing'],
        dartFile: 'lib/screens/premium/premium_screen.dart'
      },
      'fortune-cookie': {
        path: '/fortune-cookie',
        name: 'Fortune Cookie',
        nameKo: '포춘쿠키',
        description: '포춘쿠키 인터랙티브 경험',
        descriptionKo: '쿠키 터치 → 운세 메시지',
        uxFlow: {
          prev: ['home', 'interactive'],
          next: ['home'],
          trigger: '쿠키 터치'
        },
        components: [
          'FortuneCookieAnimation',
          'FortuneMessage',
          'ShareButton'
        ],
        designNotes: ['3D 쿠키 애니메이션', '종이 펼쳐지는 효과', '공유 기능'],
        states: ['closed', 'opening', 'opened', 'message-revealed'],
        dartFile: 'lib/features/interactive/presentation/pages/fortune_cookie_page.dart'
      }
    }
  },

  // ===========================================================================
  // PROFILE & SETTINGS
  // ===========================================================================
  profile: {
    category: 'Profile & Settings',
    categoryKo: '프로필 & 설정',
    figmaPage: '03-Profile-Settings',
    screens: {
      profile: {
        path: '/profile',
        name: 'Profile',
        nameKo: '프로필',
        description: '사용자 프로필 메인',
        descriptionKo: '내 정보, 사주 요약, 운세 히스토리',
        uxFlow: {
          prev: ['home'],
          next: ['profile-edit', 'profile-saju', 'profile-history', 'settings'],
          trigger: '메뉴 선택'
        },
        components: [
          'ProfileHeader',
          'SajuSummaryCard',
          'MenuList',
          'BottomNavigationBar'
        ],
        designNotes: ['아바타/이름', '사주 요약 카드', '설정 메뉴 리스트'],
        states: ['default', 'premium-user'],
        dartFile: 'lib/screens/profile/profile_screen.dart'
      },
      'profile-edit': {
        path: '/profile/edit',
        name: 'Profile Edit',
        nameKo: '프로필 수정',
        description: '사용자 정보 수정',
        descriptionKo: '이름, 생년월일 수정',
        uxFlow: {
          prev: ['profile'],
          next: ['profile'],
          trigger: '저장 버튼'
        },
        components: ['AppBar', 'TextInput', 'DatePicker', 'UnifiedButton'],
        designNotes: ['폼 검증', '저장 확인'],
        states: ['default', 'editing', 'saving', 'error'],
        dartFile: 'lib/screens/profile/profile_edit_page.dart'
      },
      'profile-saju': {
        path: '/profile/saju',
        name: 'Saju Detail',
        nameKo: '사주 상세',
        description: '내 사주팔자 상세 정보',
        descriptionKo: '사주팔자, 오행, 십이운성',
        uxFlow: {
          prev: ['profile'],
          next: ['profile-elements'],
          trigger: '오행 탭'
        },
        components: [
          'SajuPillarTable',
          'WuxingChart',
          'TwelveStagesWidget',
          'SinsalList'
        ],
        designNotes: ['사주 팔자표 (4기둥)', '오행 밸런스 차트', '십이운성 그래프'],
        states: ['default', 'loading'],
        dartFile: 'lib/screens/profile/saju_detail_page.dart'
      },
      'profile-elements': {
        path: '/profile/elements',
        name: 'Elements Detail',
        nameKo: '오행 상세',
        description: '오행(목화토금수) 분석',
        descriptionKo: '오행 비율 및 성향 분석',
        uxFlow: {
          prev: ['profile-saju'],
          next: ['profile'],
          trigger: '뒤로가기'
        },
        components: ['WuxingRadarChart', 'ElementCard', 'AnalysisText'],
        designNotes: ['레이더 차트', '색상별 오행 표시'],
        states: ['default'],
        dartFile: 'lib/screens/profile/elements_detail_page.dart'
      },
      'profile-history': {
        path: '/profile/history',
        name: 'Fortune History',
        nameKo: '운세 히스토리',
        description: '과거 운세 결과 목록',
        descriptionKo: '날짜별 운세 기록',
        uxFlow: {
          prev: ['profile'],
          next: ['fortune-history-detail'],
          trigger: '히스토리 항목 클릭'
        },
        components: ['HistoryListItem', 'DateFilter', 'EmptyState'],
        designNotes: ['날짜 그룹핑', '운세 유형 아이콘', '무한 스크롤'],
        states: ['default', 'empty', 'loading'],
        dartFile: 'lib/features/history/presentation/pages/fortune_history_page.dart'
      },
      settings: {
        path: '/settings',
        name: 'Settings',
        nameKo: '설정',
        description: '앱 설정',
        descriptionKo: '알림, 계정, 폰트, 정책',
        uxFlow: {
          prev: ['profile'],
          next: ['settings-notifications', 'settings-font', 'help', 'privacy-policy'],
          trigger: '설정 항목 선택'
        },
        components: ['SettingsMenuList', 'VersionInfo'],
        designNotes: ['섹션별 그룹핑', '버전 정보 표시'],
        states: ['default'],
        dartFile: 'lib/screens/settings/settings_screen.dart'
      },
      'settings-notifications': {
        path: '/settings/notifications',
        name: 'Notification Settings',
        nameKo: '알림 설정',
        description: '푸시 알림 설정',
        descriptionKo: '알림 유형별 on/off',
        uxFlow: {
          prev: ['settings'],
          next: ['settings'],
          trigger: '뒤로가기'
        },
        components: ['SwitchListTile', 'SectionHeader'],
        designNotes: ['스위치 토글', '알림 시간 설정'],
        states: ['default'],
        dartFile: 'lib/features/notification/presentation/pages/notification_settings_page.dart'
      },
      'settings-font': {
        path: '/settings/font',
        name: 'Font Settings',
        nameKo: '폰트 설정',
        description: '앱 폰트 크기 설정',
        descriptionKo: '텍스트 크기 조절',
        uxFlow: {
          prev: ['settings'],
          next: ['settings'],
          trigger: '뒤로가기'
        },
        components: ['FontSizeSlider', 'PreviewText'],
        designNotes: ['슬라이더 UI', '미리보기 텍스트'],
        states: ['default'],
        dartFile: 'lib/features/settings/presentation/pages/font_settings_page.dart'
      },
      subscription: {
        path: '/subscription',
        name: 'Subscription',
        nameKo: '구독',
        description: '구독 플랜 선택',
        descriptionKo: '월간/연간 구독',
        uxFlow: {
          prev: ['premium'],
          next: ['home'],
          trigger: '구독 완료'
        },
        components: ['PlanCard', 'BenefitsList', 'PurchaseButton'],
        designNotes: ['가격 비교', '할인 강조', 'IAP 연동'],
        states: ['default', 'processing', 'success', 'error'],
        dartFile: 'lib/screens/subscription/subscription_page.dart'
      },
      'token-purchase': {
        path: '/token-purchase',
        name: 'Token Purchase',
        nameKo: '토큰 구매',
        description: '토큰 패키지 구매',
        descriptionKo: '운세 이용권 충전',
        uxFlow: {
          prev: ['premium'],
          next: ['home'],
          trigger: '구매 완료'
        },
        components: ['TokenPackageCard', 'BalanceDisplay', 'PurchaseButton'],
        designNotes: ['패키지 옵션', '보너스 표시', '현재 잔액'],
        states: ['default', 'processing', 'success'],
        dartFile: 'lib/features/payment/presentation/pages/token_purchase_page.dart'
      },
      help: {
        path: '/help',
        name: 'Help',
        nameKo: '도움말',
        description: 'FAQ 및 문의',
        descriptionKo: '자주 묻는 질문, 고객센터',
        uxFlow: {
          prev: ['settings'],
          next: ['settings'],
          trigger: '뒤로가기'
        },
        components: ['FAQAccordion', 'ContactButton'],
        designNotes: ['아코디언 UI', '카카오톡 문의 버튼'],
        states: ['default'],
        dartFile: 'lib/features/support/presentation/pages/help_page.dart'
      },
      'privacy-policy': {
        path: '/privacy-policy',
        name: 'Privacy Policy',
        nameKo: '개인정보처리방침',
        description: '개인정보 처리방침',
        descriptionKo: '법적 고지',
        uxFlow: {
          prev: ['settings', 'signup'],
          next: ['settings'],
          trigger: '뒤로가기'
        },
        components: ['WebView', 'AppBar'],
        designNotes: ['HTML 렌더링'],
        states: ['default', 'loading'],
        dartFile: 'lib/features/policy/presentation/pages/privacy_policy_page.dart'
      },
      'terms-of-service': {
        path: '/terms-of-service',
        name: 'Terms of Service',
        nameKo: '이용약관',
        description: '서비스 이용약관',
        descriptionKo: '법적 고지',
        uxFlow: {
          prev: ['settings', 'signup'],
          next: ['settings'],
          trigger: '뒤로가기'
        },
        components: ['WebView', 'AppBar'],
        designNotes: ['HTML 렌더링'],
        states: ['default', 'loading'],
        dartFile: 'lib/features/policy/presentation/pages/terms_of_service_page.dart'
      }
    }
  },

  // ===========================================================================
  // FORTUNE - BASIC
  // ===========================================================================
  fortune_basic: {
    category: 'Fortune - Basic',
    categoryKo: '운세 - 기본',
    figmaPage: '04-Fortune-Basic',
    screens: {
      mbti: {
        path: '/mbti',
        name: 'MBTI Fortune',
        nameKo: 'MBTI 운세',
        description: 'MBTI 기반 오늘의 운세',
        descriptionKo: 'MBTI 유형별 맞춤 운세',
        uxFlow: {
          prev: ['fortune-list'],
          next: ['fortune-list'],
          trigger: '결과 확인 후'
        },
        components: [
          'StandardFortuneAppBar',
          'MBTISelector',
          'FortuneResultCard',
          'UnifiedBlurWrapper',
          'ShareButton'
        ],
        designNotes: [
          'MBTI 16유형 선택 그리드',
          '결과 카드 (블러 처리)',
          '프리미엄 해제 버튼'
        ],
        states: ['input', 'loading', 'result-blurred', 'result-unlocked'],
        dartFile: 'lib/features/fortune/presentation/pages/mbti_fortune_page.dart'
      },
      compatibility: {
        path: '/compatibility',
        name: 'Compatibility',
        nameKo: '궁합',
        description: '두 사람의 사주 궁합',
        descriptionKo: '연인/친구/가족 궁합 분석',
        uxFlow: {
          prev: ['fortune-list'],
          next: ['fortune-list'],
          trigger: '결과 확인 후'
        },
        components: [
          'StandardFortuneAppBar',
          'PersonInputCard',
          'CompatibilityScoreCircle',
          'CompatibilityAnalysisCard',
          'UnifiedBlurWrapper'
        ],
        designNotes: [
          '두 명 정보 입력',
          '궁합 점수 원형 게이지',
          '카테고리별 분석'
        ],
        states: ['input', 'loading', 'result'],
        dartFile: 'lib/features/fortune/presentation/pages/compatibility_page.dart'
      },
      celebrity: {
        path: '/celebrity',
        name: 'Celebrity Fortune',
        nameKo: '유명인 운세',
        description: '유명인과 비교 운세',
        descriptionKo: '나와 비슷한 사주의 유명인',
        uxFlow: {
          prev: ['fortune-list'],
          next: ['fortune-list'],
          trigger: '결과 확인 후'
        },
        components: [
          'StandardFortuneAppBar',
          'CelebrityMatchCard',
          'SajuComparisonTable',
          'UnifiedBlurWrapper'
        ],
        designNotes: ['유명인 사진/프로필', '사주 비교 테이블'],
        states: ['loading', 'result'],
        dartFile: 'lib/features/fortune/presentation/pages/celebrity_fortune_page.dart'
      },
      family: {
        path: '/family',
        name: 'Family Fortune',
        nameKo: '가족 운세',
        description: '가족 구성원 운세',
        descriptionKo: '가족 전체 운세 분석',
        uxFlow: {
          prev: ['fortune-list'],
          next: ['fortune-list'],
          trigger: '결과 확인 후'
        },
        components: [
          'StandardFortuneAppBar',
          'FamilyMemberInput',
          'FamilyFortuneCard',
          'RelationshipAnalysis'
        ],
        designNotes: ['가족 구성원 추가', '관계별 궁합'],
        states: ['input', 'loading', 'result'],
        dartFile: 'lib/features/fortune/presentation/pages/family_fortune_page.dart'
      },
      'pet-compatibility': {
        path: '/pet',
        name: 'Pet Compatibility',
        nameKo: '반려동물 궁합',
        description: '반려동물과의 궁합',
        descriptionKo: '나와 반려동물의 궁합',
        uxFlow: {
          prev: ['fortune-list'],
          next: ['fortune-list'],
          trigger: '결과 확인 후'
        },
        components: [
          'StandardFortuneAppBar',
          'PetTypeSelector',
          'CompatibilityScoreCircle',
          'PetAdviceCard'
        ],
        designNotes: ['반려동물 종류 선택', '궁합 점수', '케어 조언'],
        states: ['input', 'loading', 'result'],
        dartFile: 'lib/features/fortune/presentation/pages/pet_compatibility_page.dart'
      },
      'avoid-people': {
        path: '/avoid-people',
        name: 'Avoid People Fortune',
        nameKo: '피해야 할 사람',
        description: '조심해야 할 인연 분석',
        descriptionKo: '사주로 보는 주의할 관계',
        uxFlow: {
          prev: ['fortune-list'],
          next: ['fortune-list'],
          trigger: '결과 확인 후'
        },
        components: [
          'StandardFortuneAppBar',
          'WarningPersonCard',
          'RelationshipAdvice',
          'UnifiedBlurWrapper'
        ],
        designNotes: ['경고 스타일 카드', '조언 섹션'],
        states: ['loading', 'result'],
        dartFile: 'lib/features/fortune/presentation/pages/avoid_people_fortune_page.dart'
      },
      'personality-dna': {
        path: '/personality-dna',
        name: 'Personality DNA',
        nameKo: '성격 DNA',
        description: '사주 기반 성격 분석',
        descriptionKo: '타고난 성향과 기질',
        uxFlow: {
          prev: ['fortune-list'],
          next: ['fortune-list'],
          trigger: '결과 확인 후'
        },
        components: [
          'StandardFortuneAppBar',
          'PersonalityRadarChart',
          'TraitCard',
          'DNAVisualizer'
        ],
        designNotes: ['레이더 차트', 'DNA 시각화', '성향 카드'],
        states: ['loading', 'result'],
        dartFile: 'lib/features/fortune/presentation/pages/personality_dna_page.dart'
      },
      'daily-calendar': {
        path: '/daily-calendar',
        name: 'Daily Calendar',
        nameKo: '일일 달력 운세',
        description: '날짜별 운세 캘린더',
        descriptionKo: '월별 운세 한눈에 보기',
        uxFlow: {
          prev: ['fortune-list', 'home'],
          next: ['fortune-list'],
          trigger: '날짜 선택'
        },
        components: [
          'StandardFortuneAppBar',
          'MonthCalendar',
          'DayFortuneCard',
          'LuckyItemsRow'
        ],
        designNotes: ['달력 UI', '운세 점수 색상 표시', '선택 날짜 상세'],
        states: ['default', 'date-selected', 'loading'],
        dartFile: 'lib/features/fortune/presentation/pages/daily_calendar_fortune_page.dart'
      },
      moving: {
        path: '/moving',
        name: 'Moving Fortune',
        nameKo: '이사 운세',
        description: '이사 길일 분석',
        descriptionKo: '좋은 이사 날짜 추천',
        uxFlow: {
          prev: ['fortune-list'],
          next: ['fortune-list'],
          trigger: '결과 확인 후'
        },
        components: [
          'StandardFortuneAppBar',
          'DateRangePicker',
          'MovingDateCard',
          'DirectionAdvice'
        ],
        designNotes: ['날짜 범위 선택', '길일 표시', '방향 조언'],
        states: ['input', 'loading', 'result'],
        dartFile: 'lib/features/fortune/presentation/pages/moving_fortune_page.dart'
      },
      wish: {
        path: '/wish',
        name: 'Wish Fortune',
        nameKo: '소원 빌기',
        description: '소원 운세',
        descriptionKo: '소원 성취 가능성 분석',
        uxFlow: {
          prev: ['fortune-list'],
          next: ['fortune-list'],
          trigger: '결과 확인 후'
        },
        components: [
          'StandardFortuneAppBar',
          'WishInput',
          'WishResultCard',
          'SuccessRateGauge'
        ],
        designNotes: ['소원 텍스트 입력', '성취율 게이지', '조언'],
        states: ['input', 'loading', 'result'],
        dartFile: 'lib/features/fortune/presentation/pages/wish_fortune_page.dart'
      }
    }
  },

  // ===========================================================================
  // FORTUNE - TRADITIONAL
  // ===========================================================================
  fortune_traditional: {
    category: 'Fortune - Traditional',
    categoryKo: '운세 - 전통',
    figmaPage: '05-Fortune-Traditional',
    screens: {
      traditional: {
        path: '/traditional',
        name: 'Traditional Fortune',
        nameKo: '전통 운세',
        description: '전통 사주 분석',
        descriptionKo: '정통 사주팔자 해석',
        uxFlow: {
          prev: ['fortune-list'],
          next: ['fortune-list'],
          trigger: '결과 확인 후'
        },
        components: [
          'StandardFortuneAppBar',
          'SajuPillarTablePro',
          'WuxingBalanceChart',
          'YearlyFortuneTimeline'
        ],
        designNotes: ['정통 사주표', '오행 밸런스', '대운/세운'],
        states: ['loading', 'result'],
        dartFile: 'lib/features/fortune/presentation/pages/traditional_fortune_page.dart'
      },
      'traditional-saju': {
        path: '/traditional-saju',
        name: 'Traditional Saju',
        nameKo: '정통 사주',
        description: '심층 사주 분석',
        descriptionKo: '만세력 기반 정밀 분석',
        uxFlow: {
          prev: ['fortune-list'],
          next: ['fortune-list'],
          trigger: '결과 확인 후'
        },
        components: [
          'StandardFortuneAppBar',
          'ManselyeokTable',
          'SinsalWidget',
          'TwelveStagesWidget',
          'HapChungWidget'
        ],
        designNotes: ['만세력 테이블', '신살 목록', '십이운성 차트', '합/충/형 분석'],
        states: ['loading', 'result-overview', 'result-detail'],
        dartFile: 'lib/features/fortune/presentation/pages/traditional_saju_page.dart'
      },
      'face-reading': {
        path: '/face-reading',
        name: 'Face Reading',
        nameKo: '관상',
        description: 'AI 관상 분석',
        descriptionKo: '얼굴 사진으로 관상 보기',
        uxFlow: {
          prev: ['fortune-list'],
          next: ['fortune-list'],
          trigger: '결과 확인 후'
        },
        components: [
          'StandardFortuneAppBar',
          'CameraCapture',
          'FaceAnalysisOverlay',
          'FaceReadingResultCard',
          'CelebrityMatchCarousel'
        ],
        designNotes: ['카메라/갤러리 선택', '얼굴 포인트 오버레이', '유명인 닮은꼴'],
        states: ['input', 'analyzing', 'result'],
        dartFile: 'lib/features/fortune/presentation/pages/face_reading_fortune_page.dart'
      },
      tarot: {
        path: '/tarot',
        name: 'Tarot',
        nameKo: '타로',
        description: '타로 카드 운세',
        descriptionKo: '질문 기반 타로 리딩',
        uxFlow: {
          prev: ['fortune-list'],
          next: ['tarot-deck-selection', 'tarot-result'],
          trigger: '카드 뽑기'
        },
        components: [
          'StandardFortuneAppBar',
          'QuestionInput',
          'SpreadSelector',
          'TarotCardWidget',
          'TarotResultCard'
        ],
        designNotes: ['질문 입력', '스프레드 선택 (3/5/10장)', '카드 뒤집기 애니메이션'],
        states: ['question-input', 'spread-selection', 'card-selection', 'reading', 'result'],
        dartFile: 'lib/features/fortune/presentation/pages/tarot_page.dart'
      },
      talisman: {
        path: '/lucky-talisman',
        name: 'Talisman Fortune',
        nameKo: '부적 운세',
        description: '맞춤 부적 생성',
        descriptionKo: '나만의 행운 부적',
        uxFlow: {
          prev: ['fortune-list'],
          next: ['fortune-list'],
          trigger: '부적 생성 후'
        },
        components: [
          'StandardFortuneAppBar',
          'TalismanTypeSelector',
          'TalismanResultCard',
          'TalismanShareWidget'
        ],
        designNotes: ['부적 유형 선택', '생성된 부적 이미지', '저장/공유'],
        states: ['input', 'generating', 'result'],
        dartFile: 'lib/features/fortune/presentation/pages/talisman_fortune_page.dart'
      }
    }
  },

  // ===========================================================================
  // FORTUNE - LOVE
  // ===========================================================================
  fortune_love: {
    category: 'Fortune - Love',
    categoryKo: '운세 - 연애',
    figmaPage: '06-Fortune-Love',
    screens: {
      'love-input': {
        path: '/love',
        name: 'Love Fortune Input',
        nameKo: '연애운 입력',
        description: '연애 운세 입력',
        descriptionKo: '연애 상태 및 고민 입력',
        uxFlow: {
          prev: ['fortune-list'],
          next: ['love-result'],
          trigger: '분석 시작'
        },
        components: [
          'StandardFortuneAppBar',
          'RelationshipStatusSelector',
          'ConcernInput',
          'UnifiedButton'
        ],
        designNotes: ['연애 상태 선택', '고민 텍스트 입력'],
        states: ['input', 'loading'],
        dartFile: 'lib/features/fortune/presentation/pages/love_fortune_input_page.dart'
      },
      'ex-lover': {
        path: '/ex-lover-simple',
        name: 'Ex Lover Fortune',
        nameKo: '전 애인 운세',
        description: '전 애인 감정 분석',
        descriptionKo: '헤어진 연인의 현재 감정',
        uxFlow: {
          prev: ['fortune-list'],
          next: ['ex-lover-result'],
          trigger: '분석 시작'
        },
        components: [
          'StandardFortuneAppBar',
          'ExPartnerInput',
          'EmotionAnalysisCard',
          'ReconciliationAdvice'
        ],
        designNotes: ['전 애인 정보 입력', '감정 분석 시각화', '조언'],
        states: ['input', 'loading', 'result'],
        dartFile: 'lib/features/fortune/presentation/pages/ex_lover_fortune_simple_page.dart'
      },
      'blind-date': {
        path: '/blind-date',
        name: 'Blind Date Fortune',
        nameKo: '소개팅 운세',
        description: '소개팅 성공 분석',
        descriptionKo: '소개팅 상대와의 궁합',
        uxFlow: {
          prev: ['fortune-list'],
          next: ['fortune-list'],
          trigger: '결과 확인 후'
        },
        components: [
          'StandardFortuneAppBar',
          'BlindDateInput',
          'CompatibilityScoreCircle',
          'FirstImpressionAdvice',
          'ConversationTopics'
        ],
        designNotes: ['상대 정보 입력', '궁합 점수', '대화 주제 추천'],
        states: ['input', 'loading', 'result'],
        dartFile: 'lib/features/fortune/presentation/pages/blind_date_fortune_page.dart'
      }
    }
  },

  // ===========================================================================
  // FORTUNE - CAREER
  // ===========================================================================
  fortune_career: {
    category: 'Fortune - Career',
    categoryKo: '운세 - 커리어',
    figmaPage: '07-Fortune-Career',
    screens: {
      'career-coaching': {
        path: '/career',
        name: 'Career Coaching',
        nameKo: '커리어 코칭',
        description: '진로/직업 상담',
        descriptionKo: '사주 기반 커리어 조언',
        uxFlow: {
          prev: ['fortune-list'],
          next: ['career-result'],
          trigger: '분석 시작'
        },
        components: [
          'StandardFortuneAppBar',
          'CareerStatusInput',
          'ConcernSelector',
          'UnifiedButton'
        ],
        designNotes: ['현재 직업 상태', '고민 카테고리 선택'],
        states: ['input', 'loading'],
        dartFile: 'lib/features/fortune/presentation/pages/career_coaching_input_page.dart'
      },
      investment: {
        path: '/investment',
        name: 'Investment Fortune',
        nameKo: '투자 운세',
        description: '투자/재테크 운세',
        descriptionKo: '금전운 및 투자 조언',
        uxFlow: {
          prev: ['fortune-list'],
          next: ['investment-result'],
          trigger: '분석 시작'
        },
        components: [
          'StandardFortuneAppBar',
          'InvestmentTypeSelector',
          'RiskToleranceSlider',
          'InvestmentAdviceCard'
        ],
        designNotes: ['투자 유형 선택', '위험 성향', '조언 카드'],
        states: ['input', 'loading', 'result'],
        dartFile: 'lib/features/fortune/presentation/pages/investment_fortune_page.dart'
      },
      'lucky-exam': {
        path: '/lucky-exam',
        name: 'Lucky Exam Fortune',
        nameKo: '합격 운세',
        description: '시험/면접 운세',
        descriptionKo: '시험 합격 가능성 분석',
        uxFlow: {
          prev: ['fortune-list'],
          next: ['fortune-list'],
          trigger: '결과 확인 후'
        },
        components: [
          'StandardFortuneAppBar',
          'ExamTypeSelector',
          'ExamDatePicker',
          'SuccessRateGauge',
          'StudyAdvice'
        ],
        designNotes: ['시험 유형/날짜', '합격률 게이지', '공부 조언'],
        states: ['input', 'loading', 'result'],
        dartFile: 'lib/features/fortune/presentation/pages/lucky_exam_fortune_page.dart'
      },
      'talent-input': {
        path: '/talent-fortune-input',
        name: 'Talent Fortune Input',
        nameKo: '재능 운세 입력',
        description: '타고난 재능 분석',
        descriptionKo: '사주로 보는 재능',
        uxFlow: {
          prev: ['fortune-list'],
          next: ['talent-result'],
          trigger: '분석 시작'
        },
        components: [
          'StandardFortuneAppBar',
          'InterestSelector',
          'UnifiedButton'
        ],
        designNotes: ['관심 분야 선택'],
        states: ['input', 'loading'],
        dartFile: 'lib/features/fortune/presentation/pages/talent_fortune_input_page.dart'
      }
    }
  },

  // ===========================================================================
  // FORTUNE - TIME BASED
  // ===========================================================================
  fortune_time: {
    category: 'Fortune - Time Based',
    categoryKo: '운세 - 시간 기반',
    figmaPage: '08-Fortune-Time',
    screens: {
      biorhythm: {
        path: '/biorhythm',
        name: 'Biorhythm',
        nameKo: '바이오리듬',
        description: '바이오리듬 분석',
        descriptionKo: '신체/감성/지성 리듬',
        uxFlow: {
          prev: ['fortune-list'],
          next: ['fortune-list'],
          trigger: '결과 확인 후'
        },
        components: [
          'StandardFortuneAppBar',
          'BiorhythmChart',
          'BiorhythmStatusCards',
          'DailyForecast',
          'RecommendationCards'
        ],
        designNotes: ['3가지 곡선 차트', '오늘 상태 카드', '일별 예측'],
        states: ['loading', 'result'],
        dartFile: 'lib/features/fortune/presentation/pages/biorhythm_fortune_page.dart'
      },
      'time-fortune': {
        path: '/time',
        name: 'Time Fortune',
        nameKo: '시간 운세',
        description: '시간대별 운세',
        descriptionKo: '하루 중 좋은 시간',
        uxFlow: {
          prev: ['fortune-list'],
          next: ['fortune-list'],
          trigger: '결과 확인 후'
        },
        components: [
          'StandardFortuneAppBar',
          'HourlyScoreGraph',
          'TimeSlotCard',
          'ActivityRecommendation'
        ],
        designNotes: ['시간대 그래프', '최적 시간대 강조'],
        states: ['loading', 'result'],
        dartFile: 'lib/features/fortune/presentation/pages/time_fortune_page.dart'
      },
      yearly: {
        path: '/yearly',
        name: 'Yearly Fortune',
        nameKo: '연간 운세',
        description: '올해의 운세',
        descriptionKo: '월별 운세 분석',
        uxFlow: {
          prev: ['fortune-list'],
          next: ['fortune-list'],
          trigger: '결과 확인 후'
        },
        components: [
          'StandardFortuneAppBar',
          'YearOverviewCard',
          'MonthlyTimeline',
          'KeyEventsList'
        ],
        designNotes: ['연간 요약', '월별 타임라인', '주요 이벤트'],
        states: ['loading', 'result'],
        dartFile: 'lib/features/fortune/presentation/pages/yearly_fortune_page.dart'
      },
      'new-year': {
        path: '/new-year',
        name: 'New Year Fortune',
        nameKo: '신년 운세',
        description: '새해 운세',
        descriptionKo: '새해 종합 운세',
        uxFlow: {
          prev: ['fortune-list'],
          next: ['fortune-list'],
          trigger: '결과 확인 후'
        },
        components: [
          'StandardFortuneAppBar',
          'NewYearOverviewCard',
          'LuckyItemsGrid',
          'MonthlyHighlights'
        ],
        designNotes: ['새해 테마 디자인', '행운 아이템', '월별 하이라이트'],
        states: ['loading', 'result'],
        dartFile: 'lib/features/fortune/presentation/pages/new_year_fortune_page.dart'
      }
    }
  },

  // ===========================================================================
  // FORTUNE - HEALTH & SPORTS
  // ===========================================================================
  fortune_health: {
    category: 'Fortune - Health & Sports',
    categoryKo: '운세 - 건강/스포츠',
    figmaPage: '09-Fortune-Health',
    screens: {
      health: {
        path: '/health-toss',
        name: 'Health Fortune',
        nameKo: '건강 운세',
        description: '건강 운세 분석',
        descriptionKo: 'Apple Health 연동 건강 분석',
        uxFlow: {
          prev: ['fortune-list'],
          next: ['health-result'],
          trigger: '분석 시작'
        },
        components: [
          'StandardFortuneAppBar',
          'HealthDataCard',
          'BodyPartAnalysis',
          'HealthAdviceCard'
        ],
        designNotes: ['건강 데이터 연동', '취약 부위 표시', '건강 조언'],
        states: ['input', 'loading', 'result'],
        dartFile: 'lib/features/health/presentation/pages/health_fortune_page.dart'
      },
      exercise: {
        path: '/exercise',
        name: 'Exercise Fortune',
        nameKo: '운동 운세',
        description: '오늘의 운동 운세',
        descriptionKo: '추천 운동 및 시간',
        uxFlow: {
          prev: ['fortune-list'],
          next: ['fortune-list'],
          trigger: '결과 확인 후'
        },
        components: [
          'StandardFortuneAppBar',
          'ExerciseRecommendation',
          'OptimalTimeCard',
          'IntensityGauge'
        ],
        designNotes: ['추천 운동 카드', '최적 시간', '강도 표시'],
        states: ['loading', 'result'],
        dartFile: 'lib/features/sports/presentation/pages/sports_fortune_page.dart'
      },
      'lucky-golf': {
        path: '/lucky-golf',
        name: 'Golf Fortune',
        nameKo: '골프 운세',
        description: '골프 운세',
        descriptionKo: '오늘의 골프 운',
        uxFlow: { prev: ['fortune-list'], next: ['fortune-list'], trigger: '결과' },
        components: ['StandardFortuneAppBar', 'SportsFortuneCard'],
        designNotes: ['스포츠별 아이콘', '운세 결과'],
        states: ['loading', 'result'],
        dartFile: 'lib/features/sports/presentation/pages/sports_fortune_page.dart'
      }
      // ... 나머지 스포츠 운세 (baseball, tennis, running, cycling, swim, fishing, hiking, yoga, fitness)
    }
  },

  // ===========================================================================
  // FORTUNE - SPECIAL
  // ===========================================================================
  fortune_special: {
    category: 'Fortune - Special',
    categoryKo: '운세 - 특수',
    figmaPage: '10-Fortune-Special',
    screens: {
      'dream-fortune': {
        path: '/dream',
        name: 'Dream Fortune',
        nameKo: '꿈 해몽',
        description: '꿈 해석 운세',
        descriptionKo: '꿈 내용으로 운세 보기',
        uxFlow: {
          prev: ['fortune-list'],
          next: ['fortune-list'],
          trigger: '결과 확인 후'
        },
        components: [
          'StandardFortuneAppBar',
          'DreamInput',
          'VoiceInputWidget',
          'DreamAnalysisCard',
          'LuckyNumbersCard'
        ],
        designNotes: ['텍스트/음성 입력', '꿈 해석 결과', '로또 번호 추천'],
        states: ['input', 'recording', 'analyzing', 'result'],
        dartFile: 'lib/features/fortune/presentation/pages/dream_fortune_voice_page.dart'
      },
      'lucky-items': {
        path: '/lucky-items',
        name: 'Lucky Items',
        nameKo: '행운 아이템',
        description: '오늘의 행운 아이템',
        descriptionKo: '색상, 숫자, 방향 등',
        uxFlow: {
          prev: ['fortune-list', 'home'],
          next: ['fortune-list'],
          trigger: '결과 확인 후'
        },
        components: [
          'StandardFortuneAppBar',
          'LuckyColorCard',
          'LuckyNumberCard',
          'LuckyDirectionCard',
          'LuckyFoodCard'
        ],
        designNotes: ['카테고리별 카드', '시각적 아이콘'],
        states: ['loading', 'result'],
        dartFile: 'lib/features/fortune/presentation/pages/lucky_items_page.dart'
      }
    }
  },

  // ===========================================================================
  // INTERACTIVE
  // ===========================================================================
  interactive: {
    category: 'Interactive',
    categoryKo: '인터랙티브',
    figmaPage: '11-Interactive',
    screens: {
      'interactive-list': {
        path: '/interactive',
        name: 'Interactive List',
        nameKo: '인터랙티브 목록',
        description: '인터랙티브 콘텐츠 목록',
        descriptionKo: '타로, 심리테스트, 꿈해몽 등',
        uxFlow: {
          prev: ['home'],
          next: ['tarot-chat', 'psychology-test', 'dream-interpretation'],
          trigger: '콘텐츠 선택'
        },
        components: ['InteractiveListAppBar', 'InteractiveContentCard'],
        designNotes: ['카드 그리드', '카테고리 필터'],
        states: ['default'],
        dartFile: 'lib/features/interactive/presentation/pages/interactive_list_page.dart'
      },
      'dream-interpretation': {
        path: '/interactive/dream',
        name: 'Dream Interpretation',
        nameKo: '꿈 해몽',
        description: 'AI 꿈 해석',
        descriptionKo: '꿈 내용 분석',
        uxFlow: {
          prev: ['interactive-list'],
          next: ['interactive-list'],
          trigger: '해석 완료'
        },
        components: [
          'AppBar',
          'DreamTopicSelector',
          'DreamInput',
          'AnalysisResultCard'
        ],
        designNotes: ['인기 주제 버튼', '텍스트 입력', 'AI 분석 결과'],
        states: ['input', 'analyzing', 'result'],
        dartFile: 'lib/features/interactive/presentation/pages/dream_interpretation_page.dart'
      },
      'psychology-test': {
        path: '/interactive/psychology-test',
        name: 'Psychology Test',
        nameKo: '심리 테스트',
        description: '심리 테스트',
        descriptionKo: '성격/연애 심리 테스트',
        uxFlow: {
          prev: ['interactive-list'],
          next: ['interactive-list'],
          trigger: '결과 확인'
        },
        components: [
          'AppBar',
          'QuestionCard',
          'ProgressBar',
          'ResultCard',
          'ShareButton'
        ],
        designNotes: ['질문 카드', '진행 바', '결과 공유'],
        states: ['intro', 'question', 'result'],
        dartFile: 'lib/features/interactive/presentation/pages/psychology_test_page.dart'
      },
      'tarot-chat': {
        path: '/interactive/tarot',
        name: 'Tarot Chat',
        nameKo: '타로 채팅',
        description: 'AI 타로 리더와 대화',
        descriptionKo: '채팅 형식 타로 상담',
        uxFlow: {
          prev: ['interactive-list'],
          next: ['tarot-deck-selection'],
          trigger: '질문 입력'
        },
        components: [
          'ChatAppBar',
          'ChatBubble',
          'QuickReplyButtons',
          'TarotCardReveal'
        ],
        designNotes: ['채팅 UI', '빠른 응답 버튼', '카드 공개 애니메이션'],
        states: ['intro', 'chatting', 'card-reveal', 'reading'],
        dartFile: 'lib/features/interactive/presentation/pages/tarot_chat_page.dart'
      },
      'tarot-deck-selection': {
        path: '/interactive/tarot/deck-selection',
        name: 'Tarot Deck Selection',
        nameKo: '타로 덱 선택',
        description: '타로 덱 선택',
        descriptionKo: '스프레드 및 덱 선택',
        uxFlow: {
          prev: ['tarot-chat'],
          next: ['tarot-animated-flow'],
          trigger: '덱 선택'
        },
        components: [
          'AppBar',
          'SpreadSelector',
          'DeckCarousel',
          'UnifiedButton'
        ],
        designNotes: ['스프레드 옵션 (3/5/10장)', '덱 캐러셀'],
        states: ['default'],
        dartFile: 'lib/features/fortune/presentation/pages/tarot_deck_selection_page.dart'
      },
      'tarot-animated-flow': {
        path: '/interactive/tarot/animated-flow',
        name: 'Tarot Animated Flow',
        nameKo: '타로 카드 뽑기',
        description: '타로 카드 선택 애니메이션',
        descriptionKo: '카드 뽑기 인터랙션',
        uxFlow: {
          prev: ['tarot-deck-selection'],
          next: ['tarot-storytelling'],
          trigger: '카드 선택 완료'
        },
        components: [
          'TarotCardFan',
          'CardSelectionIndicator',
          'CardFlipAnimation'
        ],
        designNotes: ['카드 부채꼴 배열', '선택 애니메이션', '뒤집기 효과'],
        states: ['selecting', 'flipping', 'complete'],
        dartFile: 'lib/features/interactive/presentation/pages/tarot_animated_flow_page.dart'
      },
      'face-reading-interactive': {
        path: '/interactive/face-reading',
        name: 'Face Reading Interactive',
        nameKo: '관상 보기',
        description: '인터랙티브 관상',
        descriptionKo: '얼굴 분석 인터랙션',
        uxFlow: {
          prev: ['interactive-list'],
          next: ['interactive-list'],
          trigger: '분석 완료'
        },
        components: [
          'AppBar',
          'CameraCapture',
          'FacePointOverlay',
          'AnalysisResultCard'
        ],
        designNotes: ['카메라 캡처', '얼굴 포인트 표시'],
        states: ['capture', 'analyzing', 'result'],
        dartFile: 'lib/features/interactive/presentation/pages/face_reading_page.dart'
      },
      taemong: {
        path: '/interactive/taemong',
        name: 'Taemong',
        nameKo: '태몽',
        description: '태몽 해석',
        descriptionKo: '태몽 꿈 분석',
        uxFlow: {
          prev: ['interactive-list'],
          next: ['interactive-list'],
          trigger: '해석 완료'
        },
        components: ['AppBar', 'DreamInput', 'TaemongResultCard'],
        designNotes: ['임신 관련 꿈 해석', '아기 성별/성격 예측'],
        states: ['input', 'analyzing', 'result'],
        dartFile: 'lib/features/interactive/presentation/pages/taemong_page.dart'
      },
      'worry-bead': {
        path: '/interactive/worry-bead',
        name: 'Worry Bead',
        nameKo: '염주',
        description: '디지털 염주',
        descriptionKo: '명상/기도 카운터',
        uxFlow: {
          prev: ['interactive-list'],
          next: ['interactive-list'],
          trigger: '완료'
        },
        components: ['BeadAnimation', 'Counter', 'AmbientSound'],
        designNotes: ['염주 애니메이션', '카운터', '배경음'],
        states: ['default', 'counting', 'complete'],
        dartFile: 'lib/features/interactive/presentation/pages/worry_bead_page.dart'
      },
      'dream-journal': {
        path: '/interactive/dream-journal',
        name: 'Dream Journal',
        nameKo: '꿈 일기',
        description: '꿈 기록 및 분석',
        descriptionKo: '꿈 일기장',
        uxFlow: {
          prev: ['interactive-list'],
          next: ['interactive-list'],
          trigger: '저장'
        },
        components: ['AppBar', 'DreamEntryCard', 'DreamCalendar', 'AnalysisSummary'],
        designNotes: ['일기 목록', '달력 뷰', '분석 요약'],
        states: ['list', 'entry', 'calendar'],
        dartFile: 'lib/features/interactive/presentation/pages/dream_page.dart'
      }
    }
  },

  // ===========================================================================
  // TREND
  // ===========================================================================
  trend: {
    category: 'Trend',
    categoryKo: '트렌드',
    figmaPage: '12-Trend',
    screens: {
      'trend-psychology': {
        path: '/trend/psychology/:contentId',
        name: 'Trend Psychology Test',
        nameKo: '트렌드 심리테스트',
        description: '인기 심리테스트',
        descriptionKo: '바이럴 심리테스트',
        uxFlow: {
          prev: ['trend'],
          next: ['trend'],
          trigger: '결과 공유'
        },
        components: ['QuestionCard', 'ProgressBar', 'ResultCard', 'ShareButton'],
        designNotes: ['질문 카드', '결과 이미지', '공유 버튼'],
        states: ['intro', 'question', 'result'],
        dartFile: 'lib/features/trend/presentation/pages/trend_psychology_test_page.dart'
      },
      'trend-worldcup': {
        path: '/trend/worldcup/:contentId',
        name: 'Ideal Worldcup',
        nameKo: '이상형 월드컵',
        description: '이상형 월드컵',
        descriptionKo: '토너먼트 형식 선택',
        uxFlow: {
          prev: ['trend'],
          next: ['trend'],
          trigger: '최종 선택'
        },
        components: ['MatchupCard', 'BracketView', 'WinnerCard', 'ShareButton'],
        designNotes: ['2개 선택지', '토너먼트 진행', '최종 결과'],
        states: ['intro', 'round', 'final', 'result'],
        dartFile: 'lib/features/trend/presentation/pages/trend_ideal_worldcup_page.dart'
      },
      'trend-balance': {
        path: '/trend/balance/:contentId',
        name: 'Balance Game',
        nameKo: '밸런스 게임',
        description: '밸런스 게임',
        descriptionKo: 'A vs B 선택',
        uxFlow: {
          prev: ['trend'],
          next: ['trend'],
          trigger: '결과 확인'
        },
        components: ['BalanceChoiceCard', 'StatisticsBar', 'ShareButton'],
        designNotes: ['2개 선택지', '통계 바', '공유'],
        states: ['question', 'result'],
        dartFile: 'lib/features/trend/presentation/pages/trend_balance_game_page.dart'
      }
    }
  }
};

// =============================================================================
// Export
// =============================================================================

module.exports = {
  SCREEN_METADATA,

  /**
   * 전체 화면 목록 (flat)
   */
  getAllScreens: () => {
    const screens = [];
    for (const [categoryKey, category] of Object.entries(SCREEN_METADATA)) {
      for (const [screenKey, screen] of Object.entries(category.screens)) {
        screens.push({
          categoryKey,
          category: category.category,
          categoryKo: category.categoryKo,
          figmaPage: category.figmaPage,
          screenKey,
          ...screen
        });
      }
    }
    return screens;
  },

  /**
   * Figma 페이지별 그룹
   */
  getScreensByFigmaPage: () => {
    const byPage = {};
    for (const [categoryKey, category] of Object.entries(SCREEN_METADATA)) {
      if (!byPage[category.figmaPage]) {
        byPage[category.figmaPage] = {
          category: category.category,
          categoryKo: category.categoryKo,
          screens: []
        };
      }
      for (const [screenKey, screen] of Object.entries(category.screens)) {
        byPage[category.figmaPage].screens.push({
          screenKey,
          ...screen
        });
      }
    }
    return byPage;
  },

  /**
   * UX 플로우 맵 생성
   */
  getUXFlowMap: () => {
    const flowMap = {};
    for (const category of Object.values(SCREEN_METADATA)) {
      for (const [screenKey, screen] of Object.entries(category.screens)) {
        flowMap[screenKey] = {
          path: screen.path,
          nameKo: screen.nameKo,
          uxFlow: screen.uxFlow
        };
      }
    }
    return flowMap;
  }
};

// CLI 실행 시 JSON 출력
if (require.main === module) {
  const fs = require('fs');
  const path = require('path');

  const outputDir = path.join(__dirname, '../../screenshots/metadata');
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  // 전체 메타데이터 저장
  fs.writeFileSync(
    path.join(outputDir, 'screen-metadata.json'),
    JSON.stringify(SCREEN_METADATA, null, 2)
  );

  // UX 플로우 맵 저장
  fs.writeFileSync(
    path.join(outputDir, 'ux-flow-map.json'),
    JSON.stringify(module.exports.getUXFlowMap(), null, 2)
  );

  // Figma 페이지별 구조 저장
  fs.writeFileSync(
    path.join(outputDir, 'figma-structure.json'),
    JSON.stringify(module.exports.getScreensByFigmaPage(), null, 2)
  );

  console.log('Screen metadata exported to screenshots/metadata/');
  console.log(`Total screens: ${module.exports.getAllScreens().length}`);
}
