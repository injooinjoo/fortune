/**
 * YearSwitcher — 세운/월운의 기준 년도 변경 UI.
 *
 * [<] 2026 [>] 형태. 최소/최대 범위 옵션.
 */

import { Pressable, View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { fortuneTheme, withAlpha } from '../../../lib/theme';

interface YearSwitcherProps {
  year: number;
  onChange: (next: number) => void;
  min?: number;
  max?: number;
  label?: string;
}

export function YearSwitcher({
  year,
  onChange,
  min = 1900,
  max = 2100,
  label = '기준 년도',
}: YearSwitcherProps) {
  const dec = (): void => {
    if (year > min) onChange(year - 1);
  };
  const inc = (): void => {
    if (year < max) onChange(year + 1);
  };
  return (
    <View
      style={{
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
        gap: 12,
        marginTop: 16,
        paddingVertical: 10,
        paddingHorizontal: 14,
        backgroundColor: fortuneTheme.colors.surfaceSecondary,
        borderRadius: fortuneTheme.radius.md,
      }}
    >
      <AppText variant="labelSmall" color={fortuneTheme.colors.textTertiary}>
        {label}
      </AppText>
      <Pressable
        onPress={dec}
        hitSlop={8}
        style={({ pressed }) => ({
          width: 32,
          height: 32,
          borderRadius: 16,
          alignItems: 'center',
          justifyContent: 'center',
          backgroundColor: withAlpha(fortuneTheme.colors.ctaBackground, pressed ? 0.25 : 0.12),
        })}
      >
        <AppText variant="labelMedium" color={fortuneTheme.colors.ctaBackground}>
          {'<'}
        </AppText>
      </Pressable>
      <AppText
        variant="heading4"
        color={fortuneTheme.colors.textPrimary}
        style={{ minWidth: 60, textAlign: 'center' }}
      >
        {year}
      </AppText>
      <Pressable
        onPress={inc}
        hitSlop={8}
        style={({ pressed }) => ({
          width: 32,
          height: 32,
          borderRadius: 16,
          alignItems: 'center',
          justifyContent: 'center',
          backgroundColor: withAlpha(fortuneTheme.colors.ctaBackground, pressed ? 0.25 : 0.12),
        })}
      >
        <AppText variant="labelMedium" color={fortuneTheme.colors.ctaBackground}>
          {'>'}
        </AppText>
      </Pressable>
    </View>
  );
}
