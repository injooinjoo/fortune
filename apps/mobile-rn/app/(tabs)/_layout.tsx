import { Tabs } from 'expo-router';

import { fortuneTheme } from '../../src/lib/theme';

export default function TabsLayout() {
  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarStyle: {
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
        name="fortune"
        options={{
          title: '탐구',
        }}
      />
      <Tabs.Screen
        name="trend"
        options={{
          title: '트렌드',
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
