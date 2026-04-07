import { router, type Href } from 'expo-router';
import { Pressable, View } from 'react-native';

import { fortuneTheme } from '../lib/theme';
import { AppText } from './app-text';

interface RouteBackHeaderProps {
  fallbackHref?: Href;
  label?: string;
}

export function RouteBackHeader({
  fallbackHref = '/chat',
  label = '뒤로',
}: RouteBackHeaderProps) {
  function handlePress() {
    if (router.canGoBack()) {
      router.back();
      return;
    }

    router.replace(fallbackHref);
  }

  return (
    <Pressable
      accessibilityLabel={label}
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
        <AppText variant="labelLarge" color={fortuneTheme.colors.accentSecondary}>
          {label}
        </AppText>
      </View>
    </Pressable>
  );
}
