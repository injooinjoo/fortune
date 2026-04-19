import { forwardRef, useRef, useState } from 'react';
import {
  View,
  TextInput,
  StyleSheet,
  type TextInputProps,
} from 'react-native';

import { fortuneTheme } from '../lib/theme';
import { AppText } from './app-text';

export interface DateInputValue {
  y: string;
  m: string;
  d: string;
}

interface DateInputProps {
  value?: DateInputValue;
  onChange?: (v: DateInputValue) => void;
  /** Auto-focus the year field on mount so the keypad comes up immediately. */
  autoFocus?: boolean;
}

/**
 * Segmented YYYY.MM.DD birth date input. Three numeric fields with auto-focus
 * chaining — year fills 4 digits → jumps to month → 2 digits → day.
 *
 * Non-numeric input is stripped silently. No internal validation for "real"
 * dates (leap years, month ranges); the caller is responsible for validating
 * before submit so users can correct partial entries without scolding.
 */
export function DateInput({ value, onChange, autoFocus }: DateInputProps) {
  const [y, setY] = useState(value?.y ?? '');
  const [m, setM] = useState(value?.m ?? '');
  const [d, setD] = useState(value?.d ?? '');
  const mRef = useRef<TextInput>(null);
  const dRef = useRef<TextInput>(null);

  const update = (ny: string, nm: string, nd: string) => {
    setY(ny);
    setM(nm);
    setD(nd);
    onChange?.({ y: ny, m: nm, d: nd });
  };

  return (
    <View style={styles.row}>
      <Segment
        value={y}
        placeholder="YYYY"
        flex={1.4}
        maxLength={4}
        autoFocus={autoFocus}
        onChange={(t) => {
          update(t, m, d);
          if (t.length === 4) mRef.current?.focus();
        }}
      />
      <AppText variant="heading3" style={styles.sep}>
        .
      </AppText>
      <Segment
        ref={mRef}
        value={m}
        placeholder="MM"
        flex={1}
        maxLength={2}
        onChange={(t) => {
          update(y, t, d);
          if (t.length === 2) dRef.current?.focus();
        }}
      />
      <AppText variant="heading3" style={styles.sep}>
        .
      </AppText>
      <Segment
        ref={dRef}
        value={d}
        placeholder="DD"
        flex={1}
        maxLength={2}
        onChange={(t) => update(y, m, t)}
      />
    </View>
  );
}

interface SegmentProps
  extends Pick<TextInputProps, 'placeholder' | 'maxLength' | 'autoFocus'> {
  value: string;
  flex: number;
  onChange: (t: string) => void;
}

const Segment = forwardRef<TextInput, SegmentProps>(function Segment(
  { value, placeholder, flex, maxLength, onChange, autoFocus },
  ref,
) {
  return (
    <TextInput
      ref={ref}
      value={value}
      onChangeText={(t) => onChange(t.replace(/[^0-9]/g, ''))}
      placeholder={placeholder}
      placeholderTextColor={fortuneTheme.colors.textTertiary}
      keyboardType="number-pad"
      maxLength={maxLength}
      autoFocus={autoFocus}
      style={[styles.segment, { flex }]}
    />
  );
});

const styles = StyleSheet.create({
  row: { flexDirection: 'row', alignItems: 'center' },
  segment: {
    height: 56,
    backgroundColor: fortuneTheme.colors.surface,
    borderRadius: fortuneTheme.radius.md,
    borderWidth: 1,
    borderColor: fortuneTheme.colors.border,
    color: fortuneTheme.colors.textPrimary,
    fontSize: 18,
    fontWeight: '500',
    textAlign: 'center',
    letterSpacing: 1,
  },
  sep: {
    color: fortuneTheme.colors.textTertiary,
    marginHorizontal: fortuneTheme.spacing.xs,
  },
});
