import { View, StyleSheet, type ViewStyle } from 'react-native';

import { fortuneTheme } from '../lib/theme';
import { AppText } from './app-text';

interface OracleMessageProps {
  authorName: string;
  authorInitials: string;
  text: string;
  /**
   * Optional two-color gradient. Only the second color is used as the flat
   * avatar background; the first is reserved for future linear gradient work.
   */
  gradient?: [string, string];
  style?: ViewStyle;
}

/**
 * Oracle-voice message — renders a character's fortune-telling reply in the
 * ZEN Serif typeface. Reserved for seer/fortune-teller characters; regular
 * chat bubbles should use the standard message renderer.
 *
 * Composition: round avatar (initials-only, no image since the oracle identity
 * is abstract) + small sans-serif name label + serif body. No bubble chrome
 * — the serif text IS the voice cue.
 */
export function OracleMessage({
  authorName,
  authorInitials,
  text,
  gradient,
  style,
}: OracleMessageProps) {
  const avatarBg = gradient?.[1] ?? fortuneTheme.colors.surfaceElevated;

  return (
    <View style={[styles.row, style]}>
      <View
        style={[
          styles.avatar,
          { backgroundColor: avatarBg },
        ]}
      >
        <AppText
          variant="labelLarge"
          color={fortuneTheme.colors.textPrimary}
          style={styles.initials}
        >
          {authorInitials.slice(0, 2)}
        </AppText>
      </View>

      <View style={styles.body}>
        <AppText
          variant="labelSmall"
          color={fortuneTheme.colors.textSecondary}
          style={styles.name}
        >
          {authorName}
        </AppText>
        <AppText variant="oracleBody" style={styles.text}>
          {text}
        </AppText>
      </View>
    </View>
  );
}

const AVATAR_SIZE = 36;

const styles = StyleSheet.create({
  row: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    gap: fortuneTheme.spacing.md,
    marginVertical: fortuneTheme.spacing.md,
  },
  avatar: {
    width: AVATAR_SIZE,
    height: AVATAR_SIZE,
    borderRadius: AVATAR_SIZE / 2,
    alignItems: 'center',
    justifyContent: 'center',
    overflow: 'hidden',
  },
  initials: {
    // Force this label to use the sans family even though labelLarge defaults
    // to system — we keep it explicit for readability.
    fontSize: AVATAR_SIZE * 0.38,
    fontWeight: '700',
  },
  body: { flex: 1 },
  name: {
    marginBottom: 4,
  },
  text: {
    letterSpacing: 0.2,
  },
});
