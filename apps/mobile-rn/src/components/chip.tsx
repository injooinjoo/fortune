import { View } from 'react-native';

import { fortuneTheme } from '../lib/theme';
import { AppText } from './app-text';

export function Chip({
  label,
  tone = 'neutral',
}: {
  label: string;
  tone?: 'neutral' | 'accent' | 'success';
}) {
  const backgroundColor =
    tone === 'accent'
      ? fortuneTheme.colors.chipLavender
      : tone === 'success'
        ? fortuneTheme.colors.chipGreen
        : fortuneTheme.colors.surfaceSecondary;

  const color =
    tone === 'neutral'
      ? fortuneTheme.colors.textSecondary
      : fortuneTheme.colors.chipText;

  return (
    <View
      style={{
        alignSelf: 'flex-start',
        backgroundColor,
        borderRadius: fortuneTheme.radius.chip,
        paddingHorizontal: 12,
        paddingVertical: 6,
      }}
    >
      <AppText variant="labelSmall" color={color}>
        {label}
      </AppText>
    </View>
  );
}
