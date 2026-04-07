export type AppRouteId =
  | 'root'
  | 'splash'
  | 'signup'
  | 'auth-callback'
  | 'onboarding'
  | 'onboarding-toss-style'
  | 'chat'
  | 'home'
  | 'fortune'
  | 'trend'
  | 'premium'
  | 'account-deletion'
  | 'profile'
  | 'profile-edit'
  | 'profile-saju-summary'
  | 'profile-relationships'
  | 'profile-notifications'
  | 'privacy-policy'
  | 'terms-of-service'
  | 'character-profile'
  | 'friend-create-basic'
  | 'friend-create-persona'
  | 'friend-create-story'
  | 'friend-create-review'
  | 'friend-create-creating';

export type RouteGroup =
  | 'auth'
  | 'onboarding'
  | 'chat'
  | 'explore'
  | 'trend'
  | 'commerce'
  | 'profile'
  | 'legal'
  | 'character'
  | 'friends';

export interface AppRouteSpec {
  id: AppRouteId;
  path: string;
  title: string;
  description: string;
  group: RouteGroup;
  tabLabel?: string;
  redirectTo?: string;
}

export const appRoutes: readonly AppRouteSpec[] = [
  {
    id: 'root',
    path: '/',
    title: 'Root',
    description: '앱 루트는 chat-first 구조에 맞춰 /chat으로 이동합니다.',
    group: 'auth',
    redirectTo: '/chat',
  },
  {
    id: 'splash',
    path: '/splash',
    title: 'Splash',
    description: '부트스트랩, 세션 복원, 온보딩 게이트 판정을 수행하는 시작 화면입니다.',
    group: 'auth',
  },
  {
    id: 'signup',
    path: '/signup',
    title: 'Sign Up',
    description: '게스트 브라우즈와 소셜 로그인 진입을 제공하는 가입 화면입니다.',
    group: 'auth',
  },
  {
    id: 'auth-callback',
    path: '/auth/callback',
    title: 'Auth Callback',
    description: 'Supabase OAuth 콜백과 외부 인증 복귀를 처리합니다.',
    group: 'auth',
  },
  {
    id: 'onboarding',
    path: '/onboarding',
    title: 'Onboarding',
    description: '출생 정보와 취향을 수집해 chat-first 진입을 준비합니다.',
    group: 'onboarding',
  },
  {
    id: 'onboarding-toss-style',
    path: '/onboarding/toss-style',
    title: 'Onboarding Toss Style',
    description: '부분 완료와 재진입을 지원하는 온보딩 변형 흐름입니다.',
    group: 'onboarding',
  },
  {
    id: 'chat',
    path: '/chat',
    title: 'Chat',
    description: '실제 핵심 제품인 캐릭터 목록과 채팅 패널 중심의 메인 셸입니다.',
    group: 'chat',
    tabLabel: '채팅',
  },
  {
    id: 'home',
    path: '/home',
    title: 'Home Redirect',
    description: '기존 공개 경로는 유지하되 현재 제품 의도상 /chat으로 리다이렉트됩니다.',
    group: 'chat',
    redirectTo: '/chat',
  },
  {
    id: 'fortune',
    path: '/fortune',
    title: 'Explore',
    description: '운세 카탈로그와 탐색 허브가 자리잡을 RN 탐구 탭입니다.',
    group: 'explore',
    tabLabel: '탐구',
  },
  {
    id: 'trend',
    path: '/trend',
    title: 'Trend',
    description: '트렌드와 추천 흐름을 담을 보조 탭입니다.',
    group: 'trend',
    tabLabel: '트렌드',
  },
  {
    id: 'premium',
    path: '/premium',
    title: '프리미엄',
    description: '구독과 토큰 상품, 혜택을 확인하는 화면입니다.',
    group: 'commerce',
  },
  {
    id: 'account-deletion',
    path: '/account-deletion',
    title: '계정 삭제',
    description: '계정 삭제 전 확인할 내용과 다음 단계를 안내합니다.',
    group: 'profile',
  },
  {
    id: 'profile',
    path: '/profile',
    title: '프로필',
    description: '프로필 정보와 계정 관련 설정을 확인하는 화면입니다.',
    group: 'profile',
    tabLabel: '프로필',
  },
  {
    id: 'profile-edit',
    path: '/profile/edit',
    title: 'Profile Edit',
    description: '기본 프로필과 사용자 정보를 수정하는 화면입니다.',
    group: 'profile',
  },
  {
    id: 'profile-saju-summary',
    path: '/profile/saju-summary',
    title: 'Saju Summary',
    description: '사용자 사주 요약과 관련 프로필 파생정보를 보여줍니다.',
    group: 'profile',
  },
  {
    id: 'profile-relationships',
    path: '/profile/relationships',
    title: 'Relationships',
    description: '관계 관리와 연결된 친구/상대 프로필 편집 흐름입니다.',
    group: 'profile',
  },
  {
    id: 'profile-notifications',
    path: '/profile/notifications',
    title: 'Notifications',
    description: '알림 환경설정과 푸시 기본값을 다룹니다.',
    group: 'profile',
  },
  {
    id: 'privacy-policy',
    path: '/privacy-policy',
    title: 'Privacy Policy',
    description: '법률/정책 문서 중 개인정보처리방침 표면입니다.',
    group: 'legal',
  },
  {
    id: 'terms-of-service',
    path: '/terms-of-service',
    title: 'Terms of Service',
    description: '이용약관과 결제 관련 고지를 담는 표면입니다.',
    group: 'legal',
  },
  {
    id: 'character-profile',
    path: '/character/:id',
    title: 'Character Profile',
    description: '전문가 캐릭터 상세와 오버레이 진입 지점입니다.',
    group: 'character',
  },
  {
    id: 'friend-create-basic',
    path: '/friends/new/basic',
    title: 'Friend Creation Basic',
    description: '사용자 생성 캐릭터의 기본 정보 입력 단계입니다.',
    group: 'friends',
  },
  {
    id: 'friend-create-persona',
    path: '/friends/new/persona',
    title: 'Friend Creation Persona',
    description: '사용자 생성 캐릭터의 성격/페르소나 입력 단계입니다.',
    group: 'friends',
  },
  {
    id: 'friend-create-story',
    path: '/friends/new/story',
    title: 'Friend Creation Story',
    description: '사용자 생성 캐릭터의 설정과 스토리 작성 단계입니다.',
    group: 'friends',
  },
  {
    id: 'friend-create-review',
    path: '/friends/new/review',
    title: 'Friend Creation Review',
    description: '생성 전 검토 및 최종 확인 단계입니다.',
    group: 'friends',
  },
  {
    id: 'friend-create-creating',
    path: '/friends/new/creating',
    title: 'Friend Creation Creating',
    description: '생성 중 상태와 완료 전환을 다루는 단계입니다.',
    group: 'friends',
  },
];

export const appRouteIds = appRoutes.map((route) => route.id);

export const appRoutesById = Object.fromEntries(
  appRoutes.map((route) => [route.id, route]),
) as Record<AppRouteId, AppRouteSpec>;

export const tabRouteIds = appRoutes
  .filter((route) => Boolean(route.tabLabel))
  .map((route) => route.id as AppRouteId);
