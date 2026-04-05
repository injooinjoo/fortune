import 'react-native-gesture-handler';

import { Stack } from 'expo-router';
import { ThemeProvider } from '@react-navigation/native';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaProvider } from 'react-native-safe-area-context';

import { navigationTheme } from '../src/lib/theme';
import { AppBootstrapProvider } from '../src/providers/app-bootstrap-provider';

export default function RootLayout() {
  return (
    <SafeAreaProvider>
      <ThemeProvider value={navigationTheme}>
        <AppBootstrapProvider>
          <StatusBar style="light" />
          <Stack
            screenOptions={{
              headerShown: false,
              contentStyle: {
                backgroundColor: navigationTheme.colors.background,
              },
            }}
          >
            <Stack.Screen name="(tabs)" />
          </Stack>
        </AppBootstrapProvider>
      </ThemeProvider>
    </SafeAreaProvider>
  );
}
