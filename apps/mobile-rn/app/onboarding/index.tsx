import { Redirect } from 'expo-router';

/**
 * `/onboarding` 진입 시 신규 Ondo 6-step 플로우의 첫 번째 스텝인
 * `/onboarding/name` 으로 리다이렉트. 이전 레거시 OnboardingScreen
 * (src/screens/onboarding-screen.tsx) 은 더 이상 라우트에 연결돼 있지
 * 않다. age gate(W1) 와 keyboardAvoiding(W16) 은 모두 새 스텝별 화면에
 * 적용돼 있다.
 *
 * 기존 call site:
 *   - splash-screen.tsx 에서 `gate === 'profile-flow'` 시 `/onboarding` 이동
 *   - auth-callback 이후 초기 프로필 진입
 */
export default function OnboardingIndexRoute() {
  return <Redirect href="/onboarding/name" />;
}
