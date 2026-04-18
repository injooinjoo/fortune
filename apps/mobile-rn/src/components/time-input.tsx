import { View, Pressable, StyleSheet } from 'react-native';

import { fortuneTheme } from '../lib/theme';
import { AppText } from './app-text';

// 12 Earthly Branches (십이지) — the traditional East Asian birth-hour
// classification used for saju fortune-telling. Values are stored as the raw
// Korean string so the Edge Function receives the same token that's rendered.
const BRANCHES = [
  '자(23~1시)',
  '축(1~3시)',
  '인(3~5시)',
  '묘(5~7시)',
  '진(7~9시)',
  '사(9~11시)',
  '오(11~13시)',
  '미(13~15시)',
  '신(15~17시)',
  '유(17~19시)',
  '술(19~21시)',
  '해(21~23시)',
] as const;

/**
 * Sentinel value for "time unknown". Callers should pass this through to the
 * saju API rather than substituting an empty string so the backend can branch
 * on explicit unknown vs. not-yet-answered.
 */
export const TIME_INPUT_UNKNOWN = '모름';

interface TimeInputProps {
  value?: string;
  onChange?: (v: string) => void;
}

export function TimeInput({ value, onChange }: TimeInputProps) {
  return (
    <View style={styles.grid}>
      {BRANCHES.map((b) => {
        const selected = value === b;
        return (
          <Pressable
            key={b}
            onPress={() => onChange?.(b)}
            style={[styles.tile, selected && styles.tileSelected]}
          >
            <AppText
              variant="labelMedium"
              color={
                selected
                  ? fortuneTheme.colors.ctaForeground
                  : fortuneTheme.colors.textPrimary
              }
            >
              {b}
            </AppText>
          </Pressable>
        );
      })}
      <Pressable
        onPress={() => onChange?.(TIME_INPUT_UNKNOWN)}
        style={[
          styles.tileWide,
          value === TIME_INPUT_UNKNOWN && styles.tileSelected,
        ]}
      >
        <AppText
          variant="labelMedium"
          color={
            value === TIME_INPUT_UNKNOWN
              ? fortuneTheme.colors.ctaForeground
              : fortuneTheme.colors.textPrimary
          }
        >
          시간 모름
        </AppText>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  grid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: fortuneTheme.spacing.sm,
  },
  tile: {
    width: '31%',
    paddingVertical: fortuneTheme.spacing.md,
    backgroundColor: fortuneTheme.colors.surface,
    borderRadius: fortuneTheme.radius.md,
    borderWidth: 1,
    borderColor: fortuneTheme.colors.border,
    alignItems: 'center',
  },
  tileWide: {
    width: '100%',
    paddingVertical: fortuneTheme.spacing.md,
    backgroundColor: fortuneTheme.colors.surface,
    borderRadius: fortuneTheme.radius.md,
    borderWidth: 1,
    borderColor: fortuneTheme.colors.border,
    alignItems: 'center',
  },
  tileSelected: {
    backgroundColor: fortuneTheme.colors.ctaBackground,
    borderColor: fortuneTheme.colors.ctaBackground,
  },
});
