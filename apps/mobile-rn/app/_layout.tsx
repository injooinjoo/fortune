import 'react-native-gesture-handler';

import { Stack } from 'expo-router';
import { ThemeProvider } from '@react-navigation/native';
import { StatusBar } from 'expo-status-bar';
import { useFonts } from 'expo-font';
import { SafeAreaProvider } from 'react-native-safe-area-context';

import { initCrashReporting } from '../src/lib/crash-reporting';
import { OnDeviceAutoDownloader } from '../src/lib/on-device-auto-downloader';
import { navigationTheme } from '../src/lib/theme';
import { AppBootstrapProvider } from '../src/providers/app-bootstrap-provider';
import { FriendCreationProvider } from '../src/providers/friend-creation-provider';
import { MobileAppStateProvider } from '../src/providers/mobile-app-state-provider';
import { OnboardingFlowProvider } from '../src/providers/onboarding-flow-provider';
import { SocialAuthProvider } from '../src/providers/social-auth-provider';

// Initialize Sentry at module load so early boot errors are also captured.
// If no DSN is configured (local dev / missing EAS secret), this no-ops.
initCrashReporting();

export default function RootLayout() {
  // ZEN Serif is the ritual/oracle typeface used for fortune readings and
  // character "oracle voice" messages. UI chrome stays on the system font;
  // AppText switches to 'ZenSerif' only for variants that opt in.
  // Loading is non-blocking — until the font is ready, serif variants render
  // in the system serif fallback.
  useFonts({
    ZenSerif: require('../assets/fonts/ZenSerif-Regular.otf'),
  });

  return (
    <SafeAreaProvider>
      <ThemeProvider value={navigationTheme}>
        <AppBootstrapProvider>
          <MobileAppStateProvider>
            <OnDeviceAutoDownloader />
            <OnboardingFlowProvider>
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
            </OnboardingFlowProvider>
          </MobileAppStateProvider>
        </AppBootstrapProvider>
      </ThemeProvider>
    </SafeAreaProvider>
  );
}
