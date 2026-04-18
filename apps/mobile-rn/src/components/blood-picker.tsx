import { View, Pressable, StyleSheet } from 'react-native';

import { fortuneTheme } from '../lib/theme';
import { AppText } from './app-text';

const BLOOD_TYPES = ['A', 'B', 'O', 'AB'] as const;

export type BloodType = (typeof BLOOD_TYPES)[number];

interface BloodPickerProps {
  value?: string;
  onChange?: (v: BloodType) => void;
}

export function BloodPicker({ value, onChange }: BloodPickerProps) {
  return (
    <View style={styles.row}>
      {BLOOD_TYPES.map((b) => {
        const selected = value === b;
        return (
          <Pressable
            key={b}
            onPress={() => onChange?.(b)}
            style={[styles.tile, selected && styles.tileSelected]}
          >
            <AppText
              variant="heading4"
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
    </View>
  );
}

const styles = StyleSheet.create({
  row: {
    flexDirection: 'row',
    gap: fortuneTheme.spacing.sm,
  },
  tile: {
    flex: 1,
    height: 56,
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
});
