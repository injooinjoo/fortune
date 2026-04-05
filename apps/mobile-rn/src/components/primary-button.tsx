import type { PropsWithChildren } from 'react';

import { Pressable } from 'react-native';

import { fortuneTheme } from '../lib/theme';
import { AppText } from './app-text';

export function PrimaryButton({
  children,
  onPress,
  tone = 'primary',
}: PropsWithChildren<{
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
      onPress={onPress}
      style={({ pressed }) => ({
        backgroundColor,
        opacity: pressed ? 0.82 : 1,
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
