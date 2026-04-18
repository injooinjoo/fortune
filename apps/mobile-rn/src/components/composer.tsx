import { useState } from 'react';
import {
  Platform,
  Pressable,
  StyleSheet,
  TextInput,
  View,
  type ViewStyle,
} from 'react-native';

import { Feather } from '@expo/vector-icons';

import { fortuneTheme } from '../lib/theme';

interface ComposerProps {
  onSend?: (text: string) => void;
  placeholder?: string;
  onPressPlus?: () => void;
  style?: ViewStyle;
}

/**
 * Chat composer row matching the Ondo design spec: circular + action on the
 * left, multi-line text input in the middle, violet circular send button on
 * the right. Send button dims when the field is empty.
 *
 * State is local (text) — the caller gets a clean string via `onSend` and
 * decides what to do with it. No built-in attachment handling; wire
 * `onPressPlus` to open your sheet / picker.
 */
export function Composer({
  onSend,
  placeholder = '메시지 입력',
  onPressPlus,
  style,
}: ComposerProps) {
  const [text, setText] = useState('');
  const canSend = text.trim().length > 0;

  const handleSend = () => {
    const trimmed = text.trim();
    if (!trimmed) return;
    onSend?.(trimmed);
    setText('');
  };

  return (
    <View style={[styles.wrap, style]}>
      <Pressable
        onPress={onPressPlus}
        accessibilityRole="button"
        accessibilityLabel="첨부 메뉴 열기"
        style={styles.iconBtn}
      >
        <Feather name="plus" size={20} color={fortuneTheme.colors.textSecondary} />
      </Pressable>

      <TextInput
        value={text}
        onChangeText={setText}
        placeholder={placeholder}
        placeholderTextColor={fortuneTheme.colors.textTertiary}
        style={styles.input}
        multiline
      />

      <Pressable
        onPress={handleSend}
        disabled={!canSend}
        accessibilityRole="button"
        accessibilityLabel="메시지 전송"
        accessibilityState={{ disabled: !canSend }}
        style={[styles.sendBtn, !canSend && { opacity: 0.35 }]}
      >
        <Feather
          name="arrow-up"
          size={20}
          color={fortuneTheme.colors.ctaForeground}
        />
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    paddingHorizontal: fortuneTheme.spacing.md,
    paddingVertical: fortuneTheme.spacing.sm,
    gap: fortuneTheme.spacing.sm,
    borderTopWidth: 1,
    borderTopColor: fortuneTheme.colors.divider,
    backgroundColor: fortuneTheme.colors.background,
  },
  iconBtn: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: fortuneTheme.colors.surface,
    alignItems: 'center',
    justifyContent: 'center',
  },
  input: {
    flex: 1,
    minHeight: 40,
    maxHeight: 120,
    paddingHorizontal: fortuneTheme.spacing.lg,
    paddingVertical: Platform.OS === 'ios' ? 10 : 6,
    backgroundColor: fortuneTheme.colors.surface,
    borderRadius: fortuneTheme.radius.lg,
    color: fortuneTheme.colors.textPrimary,
    fontSize: 15,
    lineHeight: 20,
  },
  sendBtn: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: fortuneTheme.colors.ctaBackground,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
