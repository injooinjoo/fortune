import { SocialAuthPillButton } from './social-auth-pill-button';

/**
 * Apple Sign-In 버튼.
 *
 * 모든 플랫폼 (iOS / Android / Web) 에서 공통 디자인 — 흰 배경 pill +
 * 공식 Apple 로고 + 공식 한국어 라벨 ("Apple로 로그인"). 옆에 놓이는 구글
 * pill 과 시각 무게/형태를 통일해 사용자 인지 부담을 줄인다.
 *
 * App Store Guideline 4.8 / Apple HIG 컴플라이언스:
 *   - 공식 `AppleAuthenticationButton` 컴포넌트 OR
 *   - 공식 로고 + 공식 라벨 ("Sign in with Apple", "Apple로 로그인" 등) +
 *     허용 색상 조합 (흰 배경 + 검정 텍스트, 검정 배경 + 흰 텍스트, 외곽선)
 *     을 만족하는 커스텀 버튼
 * 둘 다 허용. 이 구현은 후자 (커스텀이지만 가이드 만족).
 *
 * 이전 구현은 BLACK 변종 공식 버튼이었지만, 다크 테마 BG 와 시각 충돌 +
 * 옆 구글 pill 과 모양 차이로 사용자가 "버튼 디자인이 깨졌다" 인지하는
 * 회귀가 있어 통일된 pill 로 복귀.
 */
export function AppleAuthButton({
  disabled = false,
  label = 'Apple로 로그인',
  onPress,
}: {
  disabled?: boolean;
  label?: string;
  onPress?: () => void;
}) {
  return (
    <SocialAuthPillButton
      disabled={disabled}
      label={label}
      onPress={onPress}
      provider="apple"
    />
  );
}
