import { router, type Href } from 'expo-router';
import { Pressable, View } from 'react-native';

import { fortuneTheme } from '../lib/theme';
import { AppText } from './app-text';

interface RouteBackHeaderProps {
  fallbackHref?: Href;
  accessibilityLabel?: string;
  label?: string;
}

export function RouteBackHeader({
  fallbackHref = '/chat',
  accessibilityLabel,
  label,
}: RouteBackHeaderProps) {
  const resolvedAccessibilityLabel =
    accessibilityLabel ?? (label ? `${label} 뒤로 가기` : '뒤로 가기');

  function handlePress() {
    if (router.canGoBack()) {
      router.back();
      return;
    }

    router.replace(fallbackHref);
  }

  return (
    <Pressable
      accessibilityLabel={resolvedAccessibilityLabel}
      accessibilityRole="button"
      hitSlop={8}
      onPress={handlePress}
      style={({ pressed }) => ({ opacity: pressed ? 0.78 : 1 })}
    >
      <View
        style={{
          alignItems: 'center',
          alignSelf: 'flex-start',
          flexDirection: 'row',
          gap: fortuneTheme.spacing.xs,
          paddingVertical: fortuneTheme.spacing.xs,
        }}
      >
        <AppText
          style={{ lineHeight: 22 }}
          variant="heading4"
          color={fortuneTheme.colors.accentSecondary}
        >
          ‹
        </AppText>
        {label ? (
          <AppText
            variant="labelLarge"
            color={fortuneTheme.colors.accentSecondary}
          >
            {label}
          </AppText>
        ) : null}
      </View>
    </Pressable>
  );
}
