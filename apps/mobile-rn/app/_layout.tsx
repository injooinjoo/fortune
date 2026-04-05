import 'react-native-gesture-handler';

import { Stack } from 'expo-router';
import { ThemeProvider } from '@react-navigation/native';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaProvider } from 'react-native-safe-area-context';

import { navigationTheme } from '../src/lib/theme';
import { AppBootstrapProvider } from '../src/providers/app-bootstrap-provider';
import { MobileAppStateProvider } from '../src/providers/mobile-app-state-provider';
import { SocialAuthProvider } from '../src/providers/social-auth-provider';

export default function RootLayout() {
  return (
    <SafeAreaProvider>
      <ThemeProvider value={navigationTheme}>
        <AppBootstrapProvider>
          <MobileAppStateProvider>
            <SocialAuthProvider>
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
            </SocialAuthProvider>
          </MobileAppStateProvider>
        </AppBootstrapProvider>
      </ThemeProvider>
    </SafeAreaProvider>
  );
}
