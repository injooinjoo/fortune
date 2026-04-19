import { Ionicons } from '@expo/vector-icons';
import { Pressable, StyleSheet, View } from 'react-native';

import { confirmAction } from '../lib/haptics';
import { fortuneTheme } from '../lib/theme';
import { AppText } from './app-text';
import { Avatar } from './avatar';

/**
 * CharacterCard — generic row card for character selection lists.
 *
 * Avatar (left) + name / tagline (middle) + selection indicator (right),
 * with an optional full-width description row below. Wraps everything in
 * a Pressable that fires a `confirmAction()` haptic on tap.
 */
export interface CharacterCardProps {
  name: string;
  tagline: string;
  description?: string;
  /** Optional two-color gradient forwarded to the Avatar. */
  gradient?: readonly [string, string];
  /** Override initials; otherwise derived from `name`. */
  initials?: string;
  avatarSize?: number;
  selected?: boolean;
  onPress?: () => void;
  /**
   * Optional slot rendered full-width at the bottom of the card (e.g. status
   * chips). Shown after `description` when both are present.
   */
  footer?: React.ReactNode;
}

export function CharacterCard({
  name,
  tagline,
  description,
  gradient,
  initials,
  avatarSize = 72,
  selected = false,
  onPress,
  footer,
}: CharacterCardProps) {
  const handlePress = () => {
    confirmAction();
    onPress?.();
  };

  const indicatorColor = selected
    ? fortuneTheme.colors.ctaBackground
    : fortuneTheme.colors.textSecondary;

  return (
    <Pressable
      accessibilityRole="button"
      accessibilityState={{ selected }}
      onPress={handlePress}
      style={({ pressed }) => [
        styles.card,
        {
          backgroundColor: selected
            ? fortuneTheme.colors.surfaceSecondary
            : fortuneTheme.colors.surface,
          borderColor: selected
            ? fortuneTheme.colors.ctaBackground
            : fortuneTheme.colors.border,
          opacity: pressed ? 0.9 : 1,
        },
      ]}
    >
      <View style={styles.row}>
        <Avatar
          size={avatarSize}
          initials={initials ?? name}
          gradient={gradient ? [gradient[0], gradient[1]] : undefined}
        />
        <View style={styles.textStack}>
          <AppText variant="labelLarge">{name}</AppText>
          <AppText
            variant="bodySmall"
            color={fortuneTheme.colors.textSecondary}
            numberOfLines={1}
          >
            {tagline}
          </AppText>
        </View>
        <Ionicons
          name={selected ? 'checkmark-circle' : 'ellipse-outline'}
          size={24}
          color={indicatorColor}
        />
      </View>

      {description ? (
        <AppText
          variant="bodySmall"
          color={fortuneTheme.colors.textSecondary}
          style={styles.description}
        >
          {description}
        </AppText>
      ) : null}

      {footer ? <View style={styles.footer}>{footer}</View> : null}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  card: {
    borderRadius: fortuneTheme.radius.card,
    borderWidth: 1,
    padding: fortuneTheme.spacing.cardPadding,
    gap: fortuneTheme.spacing.sm,
  },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: fortuneTheme.spacing.sm,
  },
  textStack: {
    flex: 1,
    gap: 2,
  },
  description: {
    lineHeight: 20,
  },
  footer: {
    marginTop: 4,
  },
});
