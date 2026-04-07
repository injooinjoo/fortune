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
    title: '시작 화면',
    description: '앱을 열면 기본 채팅 화면으로 이어집니다.',
    group: 'auth',
    redirectTo: '/chat',
  },
  {
    id: 'splash',
    path: '/splash',
    title: '로딩 화면',
    description: '저장된 정보와 로그인 상태를 확인한 뒤 다음 화면으로 이어집니다.',
    group: 'auth',
  },
  {
    id: 'signup',
    path: '/signup',
    title: '로그인',
    description: '게스트로 둘러보거나 계정을 연결해 이용을 이어갈 수 있습니다.',
    group: 'auth',
  },
  {
    id: 'auth-callback',
    path: '/auth/callback',
    title: '로그인 확인',
    description: '로그인 연결을 확인하고 이전 화면으로 돌아갑니다.',
    group: 'auth',
  },
  {
    id: 'onboarding',
    path: '/onboarding',
    title: '처음 설정',
    description: '기본 정보와 관심사를 확인해 더 잘 맞는 경험을 준비합니다.',
    group: 'onboarding',
  },
  {
    id: 'onboarding-toss-style',
    path: '/onboarding/toss-style',
    title: '간편 설정',
    description: '중간 저장과 다시 이어하기를 지원하는 설정 흐름입니다.',
    group: 'onboarding',
  },
  {
    id: 'chat',
    path: '/chat',
    title: '메시지',
    description: '캐릭터와 대화를 이어가며 운세 결과를 확인하는 기본 화면입니다.',
    group: 'chat',
    tabLabel: '채팅',
  },
  {
    id: 'home',
    path: '/home',
    title: '홈',
    description: '현재는 기본 채팅 화면으로 이어지는 진입 경로입니다.',
    group: 'chat',
    redirectTo: '/chat',
  },
  {
    id: 'fortune',
    path: '/fortune',
    title: '탐구',
    description: '운세 카탈로그와 다양한 주제를 살펴보는 탭입니다.',
    group: 'explore',
    tabLabel: '탐구',
  },
  {
    id: 'trend',
    path: '/trend',
    title: '트렌드',
    description: '추천 흐름과 요즘 많이 보는 콘텐츠를 모아보는 탭입니다.',
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
    title: '프로필 수정',
    description: '이름과 기본 정보를 다시 입력하거나 수정하는 화면입니다.',
    group: 'profile',
  },
  {
    id: 'profile-saju-summary',
    path: '/profile/saju-summary',
    title: '사주 요약',
    description: '사주 해석에 필요한 출생 정보와 준비 상태를 확인합니다.',
    group: 'profile',
  },
  {
    id: 'profile-relationships',
    path: '/profile/relationships',
    title: '관계도',
    description: '최근 대화 흐름과 추천 캐릭터를 확인하는 화면입니다.',
    group: 'profile',
  },
  {
    id: 'profile-notifications',
    path: '/profile/notifications',
    title: '알림 설정',
    description: '푸시 알림과 주간 요약 같은 기본 알림 설정을 조정합니다.',
    group: 'profile',
  },
  {
    id: 'privacy-policy',
    path: '/privacy-policy',
    title: '개인정보처리방침',
    description: '개인정보 처리 방식과 이용 목적을 안내하는 문서입니다.',
    group: 'legal',
  },
  {
    id: 'terms-of-service',
    path: '/terms-of-service',
    title: '이용약관',
    description: '서비스 이용 조건과 결제 관련 안내를 확인하는 문서입니다.',
    group: 'legal',
  },
  {
    id: 'character-profile',
    path: '/character/:id',
    title: '캐릭터 프로필',
    description: '선택한 캐릭터의 소개와 대화 분위기를 확인합니다.',
    group: 'character',
  },
  {
    id: 'friend-create-basic',
    path: '/friends/new/basic',
    title: '친구 만들기 기본 정보',
    description: '새 친구 캐릭터의 기본 정보를 입력하는 단계입니다.',
    group: 'friends',
  },
  {
    id: 'friend-create-persona',
    path: '/friends/new/persona',
    title: '친구 만들기 성격 설정',
    description: '새 친구 캐릭터의 성격과 말투를 설정하는 단계입니다.',
    group: 'friends',
  },
  {
    id: 'friend-create-story',
    path: '/friends/new/story',
    title: '친구 만들기 스토리',
    description: '새 친구 캐릭터의 배경 이야기와 설정을 적는 단계입니다.',
    group: 'friends',
  },
  {
    id: 'friend-create-review',
    path: '/friends/new/review',
    title: '친구 만들기 검토',
    description: '입력한 정보를 다시 확인하고 최종 저장하는 단계입니다.',
    group: 'friends',
  },
  {
    id: 'friend-create-creating',
    path: '/friends/new/creating',
    title: '친구 만드는 중',
    description: '새 친구 캐릭터를 만드는 동안 진행 상태를 보여줍니다.',
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
