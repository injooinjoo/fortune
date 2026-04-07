import * as AppleAuthentication from 'expo-apple-authentication';
import { Platform, View } from 'react-native';

import { fortuneTheme } from '../lib/theme';
import { PrimaryButton } from './primary-button';

export function AppleAuthButton({
  disabled = false,
  label = 'Apple로 계속하기',
  onPress,
}: {
  disabled?: boolean;
  label?: string;
  onPress?: () => void;
}) {
  if (Platform.OS !== 'ios') {
    return (
      <PrimaryButton disabled={disabled} onPress={onPress}>
        {label}
      </PrimaryButton>
    );
  }

  return (
    <View
      style={{
        opacity: disabled ? 0.46 : 1,
      }}
    >
      <AppleAuthentication.AppleAuthenticationButton
        accessibilityHint="Apple 계정으로 로그인합니다."
        accessibilityLabel={label}
        buttonStyle={AppleAuthentication.AppleAuthenticationButtonStyle.WHITE}
        buttonType={AppleAuthentication.AppleAuthenticationButtonType.CONTINUE}
        cornerRadius={fortuneTheme.radius.full}
        onPress={disabled || !onPress ? () => undefined : onPress}
        style={{
          height: 52,
          width: '100%',
        }}
      />
    </View>
  );
}
