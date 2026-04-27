import { Stack } from 'expo-router';

export default function WidgetsLayout() {
  return (
    <Stack
      screenOptions={{
        headerShown: true,
        headerBackTitle: '뒤로',
        title: 'Ondo 위젯',
        headerStyle: { backgroundColor: '#0A0A0F' },
        headerTintColor: '#F5F6FB',
        headerTitleStyle: { color: '#F5F6FB' },
      }}
    />
  );
}
