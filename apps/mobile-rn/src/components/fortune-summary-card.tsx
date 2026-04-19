import { Pressable, StyleSheet, View } from 'react-native';

import { confirmAction } from '../lib/haptics';
import { fortuneTheme } from '../lib/theme';
import { AppText } from './app-text';
import { Card } from './card';

export interface FortuneSummaryCardProps {
  /** Short header label, e.g. '오늘' or '운세' */
  kind: string;
  /** Serif headline */
  title: string;
  /** Serif paragraph body */
  body: string;
  /** Optional 0-100 score; renders as pill when provided */
  score?: number;
  /** Tap entire card */
  onPress?: () => void;
  accessibilityLabel?: string;
}

export function FortuneSummaryCard({
  kind,
  title,
  body,
  score,
  onPress,
  accessibilityLabel,
}: FortuneSummaryCardProps) {
  const content = (
    <Card style={styles.card}>
      <View style={styles.header}>
        <AppText
          variant="labelSmall"
          color={fortuneTheme.colors.textTertiary}
          style={styles.kind}
        >
          {kind}
        </AppText>
        {score !== undefined && (
          <View style={styles.scorePill}>
            <AppText
              variant="labelSmall"
              color={fortuneTheme.colors.textPrimary}
            >
              {Math.round(score)}
            </AppText>
          </View>
        )}
      </View>
      <AppText variant="oracleTitle" style={styles.title}>
        {title}
      </AppText>
      <AppText variant="oracleBody" numberOfLines={4}>
        {body}
      </AppText>
    </Card>
  );

  if (!onPress) {
    return content;
  }

  return (
    <Pressable
      accessibilityRole="button"
      accessibilityLabel={accessibilityLabel ?? title}
      onPress={() => {
        confirmAction();
        onPress();
      }}
      style={({ pressed }) => (pressed ? styles.pressed : undefined)}
    >
      {content}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  card: {
    ...fortuneTheme.shadows.card,
    gap: fortuneTheme.spacing.sm,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  kind: {
    letterSpacing: 1.4,
    textTransform: 'uppercase',
  },
  scorePill: {
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: fortuneTheme.radius.full,
    backgroundColor: fortuneTheme.colors.accentSubtle,
  },
  title: {
    marginTop: fortuneTheme.spacing.xs,
    marginBottom: fortuneTheme.spacing.xs,
  },
  pressed: {
    opacity: 0.85,
  },
});
