import type { PropsWithChildren } from 'react';

import { ScrollView, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { fortuneTheme } from '../lib/theme';

export function Screen({ children }: PropsWithChildren) {
  return (
    <SafeAreaView
      style={{
        flex: 1,
        backgroundColor: fortuneTheme.colors.background,
      }}
    >
      <ScrollView
        contentContainerStyle={{
          paddingHorizontal: fortuneTheme.spacing.pageHorizontal,
          paddingVertical: fortuneTheme.spacing.pageVertical,
          gap: fortuneTheme.spacing.md,
        }}
        style={{ flex: 1 }}
      >
        <View style={{ gap: fortuneTheme.spacing.md }}>{children}</View>
      </ScrollView>
    </SafeAreaView>
  );
}
