import type { PropsWithChildren } from 'react';

import { View, type ViewStyle } from 'react-native';

import { fortuneTheme } from '../lib/theme';

export function Card({
  children,
  style,
}: PropsWithChildren<{ style?: ViewStyle }>) {
  return (
    <View
      style={[
        {
          backgroundColor: fortuneTheme.colors.surface,
          borderWidth: 1,
          borderColor: fortuneTheme.colors.border,
          borderRadius: fortuneTheme.radius.card,
          padding: fortuneTheme.spacing.cardPadding,
          gap: fortuneTheme.spacing.sm,
        },
        style,
      ]}
    >
      {children}
    </View>
  );
}
