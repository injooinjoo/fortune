import { SocialAuthPillButton } from './social-auth-pill-button';

export function AppleAuthButton({
  disabled = false,
  label = '애플 로그인',
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
