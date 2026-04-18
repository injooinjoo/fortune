import 'react-native-gesture-handler';

import { Stack } from 'expo-router';
import { ThemeProvider } from '@react-navigation/native';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaProvider } from 'react-native-safe-area-context';

import { initCrashReporting } from '../src/lib/crash-reporting';
import { navigationTheme } from '../src/lib/theme';
import { AppBootstrapProvider } from '../src/providers/app-bootstrap-provider';
import { FriendCreationProvider } from '../src/providers/friend-creation-provider';
import { MobileAppStateProvider } from '../src/providers/mobile-app-state-provider';
import { SocialAuthProvider } from '../src/providers/social-auth-provider';

// Initialize Sentry at module load so early boot errors are also captured.
// If no DSN is configured (local dev / missing EAS secret), this no-ops.
initCrashReporting();

export default function RootLayout() {
  return (
    <SafeAreaProvider>
      <ThemeProvider value={navigationTheme}>
        <AppBootstrapProvider>
          <MobileAppStateProvider>
            <FriendCreationProvider>
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
                  <Stack.Screen name="result/[resultKind]" />
                </Stack>
              </SocialAuthProvider>
            </FriendCreationProvider>
          </MobileAppStateProvider>
        </AppBootstrapProvider>
      </ThemeProvider>
    </SafeAreaProvider>
  );
}
