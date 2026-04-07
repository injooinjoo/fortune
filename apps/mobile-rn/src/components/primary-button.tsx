import type { PropsWithChildren } from 'react';

import { Pressable } from 'react-native';

import { fortuneTheme } from '../lib/theme';
import { AppText } from './app-text';

export function PrimaryButton({
  children,
  disabled = false,
  onPress,
  tone = 'primary',
}: PropsWithChildren<{
  disabled?: boolean;
  onPress?: () => void;
  tone?: 'primary' | 'secondary';
}>) {
  const backgroundColor =
    tone === 'primary'
      ? fortuneTheme.colors.ctaBackground
      : fortuneTheme.colors.secondaryBackground;
  const color =
    tone === 'primary'
      ? fortuneTheme.colors.ctaForeground
      : fortuneTheme.colors.secondaryForeground;

  return (
    <Pressable
      accessibilityRole="button"
      disabled={disabled}
      onPress={disabled ? undefined : onPress}
      style={({ pressed }) => ({
        backgroundColor,
        opacity: disabled ? 0.46 : pressed ? 0.82 : 1,
        borderRadius: fortuneTheme.radius.full,
        paddingHorizontal: 18,
        paddingVertical: 14,
      })}
    >
      <AppText
        variant="labelLarge"
        color={color}
        style={{ textAlign: 'center' }}
      >
        {children}
      </AppText>
    </Pressable>
  );
}
