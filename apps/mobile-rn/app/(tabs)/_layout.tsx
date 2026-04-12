import { Tabs } from 'expo-router';
import { Platform } from 'react-native';

import { fortuneTheme } from '../../src/lib/theme';

export default function TabsLayout() {
  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarStyle: {
          display: Platform.OS === 'web' ? 'flex' : 'none',
          backgroundColor: fortuneTheme.colors.surface,
          borderTopColor: fortuneTheme.colors.borderOpaque,
        },
        tabBarActiveTintColor: fortuneTheme.colors.ctaBackground,
        tabBarInactiveTintColor: fortuneTheme.colors.textSecondary,
      }}
    >
      <Tabs.Screen
        name="chat"
        options={{
          title: '채팅',
        }}
      />
      <Tabs.Screen
        name="profile"
        options={{
          title: '프로필',
        }}
      />
    </Tabs>
  );
}
