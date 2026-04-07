import { Pressable } from 'react-native';

import { fortuneTheme } from '../lib/theme';
import { AppText } from './app-text';

export function SocialAuthPillButton({
  disabled = false,
  label,
  onPress,
}: {
  disabled?: boolean;
  label: string;
  onPress?: () => void;
}) {
  return (
    <Pressable
      accessibilityLabel={label}
      accessibilityRole="button"
      disabled={disabled}
      onPress={disabled || !onPress ? undefined : onPress}
      style={({ pressed }) => ({
        alignItems: 'center',
        backgroundColor: fortuneTheme.colors.textPrimary,
        borderRadius: fortuneTheme.radius.full,
        justifyContent: 'center',
        minHeight: 52,
        opacity: disabled ? 0.46 : pressed ? 0.84 : 1,
        paddingHorizontal: 18,
        width: '100%',
      })}
    >
      <AppText
        variant="labelLarge"
        color={fortuneTheme.colors.background}
        style={{ textAlign: 'center' }}
      >
        {label}
      </AppText>
    </Pressable>
  );
}
