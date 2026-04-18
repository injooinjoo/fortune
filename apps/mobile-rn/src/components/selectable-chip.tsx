import { Pressable, StyleSheet, type PressableProps } from 'react-native';

import { fortuneTheme } from '../lib/theme';
import { AppText } from './app-text';

interface SelectableChipProps extends Omit<PressableProps, 'style'> {
  label: string;
  selected?: boolean;
  onPress?: () => void;
}

/**
 * Interactive chip used for multi/single-select interest pickers and filter
 * rows. Distinct from the static `Chip` tag component — use THIS one when
 * `selected` state + onPress matters, and `Chip` when it's a read-only label.
 *
 * Pill-shaped (radius.full), 36px tall. Selected = violet fill + white text;
 * unselected = transparent fill + 1px border + foreground text.
 */
export function SelectableChip({
  label,
  selected = false,
  onPress,
  ...rest
}: SelectableChipProps) {
  return (
    <Pressable
      {...rest}
      accessibilityRole="button"
      accessibilityState={{ selected }}
      onPress={onPress}
      style={({ pressed }) => [
        styles.chip,
        selected ? styles.chipSelected : styles.chipUnselected,
        pressed && { opacity: 0.85 },
      ]}
    >
      <AppText
        variant="labelMedium"
        color={
          selected
            ? fortuneTheme.colors.ctaForeground
            : fortuneTheme.colors.textPrimary
        }
      >
        {label}
      </AppText>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  chip: {
    paddingHorizontal: fortuneTheme.spacing.lg,
    height: 36,
    borderRadius: fortuneTheme.radius.full,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1,
  },
  chipSelected: {
    backgroundColor: fortuneTheme.colors.ctaBackground,
    borderColor: fortuneTheme.colors.ctaBackground,
  },
  chipUnselected: {
    backgroundColor: 'transparent',
    borderColor: fortuneTheme.colors.border,
  },
});
