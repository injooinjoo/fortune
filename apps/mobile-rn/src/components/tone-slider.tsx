import { useEffect, useRef } from 'react';
import { Animated, Pressable, StyleSheet, View } from 'react-native';

import { AppText } from './app-text';
import { confirmAction } from '../lib/haptics';
import { fortuneTheme } from '../lib/theme';

export interface ToneSliderProps {
  leftLabel: string;
  rightLabel: string;
  value: 0 | 1 | 2;
  onChange: (v: 0 | 1 | 2) => void;
}

const POSITIONS: ReadonlyArray<0 | 1 | 2> = [0, 1, 2];
const KNOB_SIZE = 22;

export function ToneSlider({ leftLabel, rightLabel, value, onChange }: ToneSliderProps) {
  const fillAnim = useRef(new Animated.Value(value * 50)).current;

  useEffect(() => {
    Animated.timing(fillAnim, {
      toValue: value * 50,
      duration: 180,
      useNativeDriver: false,
    }).start();
  }, [value, fillAnim]);

  const pick = (n: 0 | 1 | 2) => {
    if (n === value) return;
    confirmAction();
    onChange(n);
  };

  const fillWidth = fillAnim.interpolate({
    inputRange: [0, 100],
    outputRange: ['0%', '100%'],
  });

  return (
    <View style={styles.wrap}>
      <View style={styles.labelRow}>
        <AppText variant="labelSmall" color={fortuneTheme.colors.textSecondary}>
          {leftLabel}
        </AppText>
        <AppText variant="labelSmall" color={fortuneTheme.colors.textSecondary}>
          {rightLabel}
        </AppText>
      </View>
      <View style={styles.track}>
        <Animated.View style={[styles.fill, { width: fillWidth }]} />
        {POSITIONS.map((n) => {
          const active = value === n;
          return (
            <Pressable
              key={n}
              onPress={() => pick(n)}
              hitSlop={16}
              accessibilityRole="adjustable"
              accessibilityLabel={`${leftLabel} to ${rightLabel}, step ${n + 1} of 3`}
              accessibilityState={{ selected: active }}
              style={[
                styles.knob,
                { left: `${n * 50}%` },
                active && styles.knobActive,
              ]}
            />
          );
        })}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: {
    paddingVertical: fortuneTheme.spacing.md,
  },
  labelRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: fortuneTheme.spacing.md,
  },
  track: {
    height: 8,
    borderRadius: fortuneTheme.radius.xs,
    backgroundColor: fortuneTheme.colors.border,
    position: 'relative',
    justifyContent: 'center',
  },
  fill: {
    position: 'absolute',
    left: 0,
    top: 0,
    bottom: 0,
    borderRadius: fortuneTheme.radius.xs,
    backgroundColor: fortuneTheme.colors.accent,
  },
  knob: {
    position: 'absolute',
    width: KNOB_SIZE,
    height: KNOB_SIZE,
    borderRadius: KNOB_SIZE / 2,
    backgroundColor: fortuneTheme.colors.surfaceElevated,
    borderWidth: 2,
    borderColor: fortuneTheme.colors.surface,
    transform: [{ translateX: -KNOB_SIZE / 2 }],
  },
  knobActive: {
    backgroundColor: fortuneTheme.colors.accent,
    borderColor: fortuneTheme.colors.textTertiary,
    transform: [{ translateX: -KNOB_SIZE / 2 }, { scale: 1.15 }],
  },
});
