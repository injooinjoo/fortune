import { Ionicons } from '@expo/vector-icons';
import { Pressable, StyleSheet, View } from 'react-native';

import { AppText } from './app-text';
import { confirmAction } from '../lib/haptics';
import { fortuneTheme } from '../lib/theme';

interface RelationshipCardProps {
  icon: string;
  title: string;
  caption: string;
  selected?: boolean;
  onPress?: () => void;
}

export function RelationshipCard({
  icon,
  title,
  caption,
  selected = false,
  onPress,
}: RelationshipCardProps) {
  const handlePress = () => {
    confirmAction();
    onPress?.();
  };

  return (
    <Pressable
      onPress={handlePress}
      accessibilityRole="button"
      accessibilityState={{ selected }}
      style={({ pressed }) => [
        styles.card,
        selected && styles.cardSelected,
        pressed && { opacity: 0.9 },
      ]}
    >
      <View style={[styles.iconWrap, selected && styles.iconWrapSelected]}>
        <AppText variant="labelLarge" style={styles.iconGlyph}>
          {icon}
        </AppText>
      </View>
      <View style={styles.textColumn}>
        <AppText
          variant="labelLarge"
          color={fortuneTheme.colors.textPrimary}
          style={styles.title}
        >
          {title}
        </AppText>
        <AppText
          variant="bodySmall"
          color={fortuneTheme.colors.textSecondary}
        >
          {caption}
        </AppText>
      </View>
      <Ionicons
        name={selected ? 'checkmark-circle' : 'ellipse-outline'}
        size={24}
        color={selected ? fortuneTheme.colors.accent : fortuneTheme.colors.border}
      />
    </Pressable>
  );
}

const styles = StyleSheet.create({
  card: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: fortuneTheme.spacing.md,
    padding: fortuneTheme.spacing.lg,
    borderRadius: fortuneTheme.radius.lg,
    borderWidth: 1,
    borderColor: fortuneTheme.colors.border,
    backgroundColor: fortuneTheme.colors.surface,
  },
  cardSelected: {
    borderColor: fortuneTheme.colors.accent,
    backgroundColor: fortuneTheme.colors.accentSubtle,
  },
  iconWrap: {
    width: 48,
    height: 48,
    borderRadius: 24,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: fortuneTheme.colors.accentSubtle,
  },
  iconWrapSelected: {
    backgroundColor: fortuneTheme.colors.accent,
  },
  iconGlyph: {
    fontSize: 22,
  },
  textColumn: {
    flex: 1,
    gap: 2,
  },
  title: {
    marginBottom: 2,
  },
});
