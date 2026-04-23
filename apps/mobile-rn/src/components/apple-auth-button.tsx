import { Platform, View } from 'react-native';
import * as AppleAuthentication from 'expo-apple-authentication';

import { SocialAuthPillButton } from './social-auth-pill-button';

/**
 * Apple Sign-In 버튼.
 *
 * iOS 에서는 Apple 공식 `AppleAuthenticationButton` 을 사용 — Apple HIG +
 * App Store Guideline 4.8 ("Sign in with Apple 버튼은 Apple 공식 버튼 또는
 * 가이드라인을 따르는 동등 디자인이어야 함") 준수. 이전 구현은 커스텀
 * Pressable 로 4.8 / 2.5.1 리젝 리스크가 있었다.
 *
 * iOS 외 플랫폼(Android/Web) 에서는 기존 pill 디자인 유지 — 브랜드 일관성
 * 확보 + Apple 공식 버튼은 iOS 전용.
 *
 * 버튼 높이/모서리는 Apple 권장 기준 (44 x cornerRadius 8). 라벨은
 * `SIGN_IN` (로그인) / `CONTINUE` (계속) 중 호출부가 전달한 label 에 따라 결정.
 */
export function AppleAuthButton({
  disabled = false,
  label = '애플 로그인',
  onPress,
}: {
  disabled?: boolean;
  label?: string;
  onPress?: () => void;
}) {
  if (Platform.OS === 'ios') {
    const buttonType =
      label.includes('계속')
        ? AppleAuthentication.AppleAuthenticationButtonType.CONTINUE
        : AppleAuthentication.AppleAuthenticationButtonType.SIGN_IN;

    return (
      <View style={{ opacity: disabled ? 0.5 : 1 }}>
        <AppleAuthentication.AppleAuthenticationButton
          buttonType={buttonType}
          buttonStyle={
            AppleAuthentication.AppleAuthenticationButtonStyle.WHITE
          }
          cornerRadius={8}
          style={{ height: 50, width: '100%' }}
          onPress={() => {
            if (disabled) return;
            onPress?.();
          }}
        />
      </View>
    );
  }

  return (
    <SocialAuthPillButton
      disabled={disabled}
      label={label}
      onPress={onPress}
      provider="apple"
    />
  );
}
