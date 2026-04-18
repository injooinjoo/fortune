import { View, Pressable, StyleSheet } from 'react-native';

import { fortuneTheme } from '../lib/theme';
import { AppText } from './app-text';

const MBTI_TYPES = [
  'ISTJ',
  'ISFJ',
  'INFJ',
  'INTJ',
  'ISTP',
  'ISFP',
  'INFP',
  'INTP',
  'ESTP',
  'ESFP',
  'ENFP',
  'ENTP',
  'ESTJ',
  'ESFJ',
  'ENFJ',
  'ENTJ',
] as const;

export type MbtiType = (typeof MBTI_TYPES)[number];

interface MBTIPickerProps {
  value?: string;
  onChange?: (v: MbtiType) => void;
}

export function MBTIPicker({ value, onChange }: MBTIPickerProps) {
  return (
    <View style={styles.grid}>
      {MBTI_TYPES.map((t) => {
        const selected = value === t;
        return (
          <Pressable
            key={t}
            onPress={() => onChange?.(t)}
            style={[styles.tile, selected && styles.tileSelected]}
          >
            <AppText
              variant="labelLarge"
              color={
                selected
                  ? fortuneTheme.colors.ctaForeground
                  : fortuneTheme.colors.textPrimary
              }
              style={styles.label}
            >
              {t}
            </AppText>
          </Pressable>
        );
      })}
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
    width: '23%',
    height: 52,
    backgroundColor: fortuneTheme.colors.surface,
    borderRadius: fortuneTheme.radius.md,
    borderWidth: 1,
    borderColor: fortuneTheme.colors.border,
    alignItems: 'center',
    justifyContent: 'center',
  },
  tileSelected: {
    backgroundColor: fortuneTheme.colors.ctaBackground,
    borderColor: fortuneTheme.colors.ctaBackground,
  },
  label: {
    letterSpacing: 0.8,
  },
});
