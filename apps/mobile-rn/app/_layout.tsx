import 'react-native-gesture-handler';

import { useEffect } from 'react';
import { Stack } from 'expo-router';
import { ThemeProvider } from '@react-navigation/native';
import { StatusBar } from 'expo-status-bar';
import { useFonts } from 'expo-font';
import * as Updates from 'expo-updates';
import { SafeAreaProvider } from 'react-native-safe-area-context';

import { OnDeviceDownloadProgressBar } from '../src/components/on-device-download-progress-bar';
import { WidgetSyncBridge } from '../src/components/widget-sync-bridge';
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

  // OTA 강제 체크 — 기본 백그라운드 체크가 어떤 환경에서 동작하지 않는 경우
  // 대비. 런칭 직후 새 번들이 있으면 받아서 즉시 reload. 기존 번들이 최신이면
  // no-op. dev 빌드에선 스킵.
  useEffect(() => {
    if (__DEV__ || !Updates.isEnabled) return;
    (async () => {
      try {
        const check = await Updates.checkForUpdateAsync();
        if (check.isAvailable) {
          await Updates.fetchUpdateAsync();
          await Updates.reloadAsync();
        }
      } catch {
        // 네트워크 이슈 등은 조용히 무시 — 다음 런칭에서 재시도.
      }
    })();
  }, []);

  return (
    <SafeAreaProvider>
      <ThemeProvider value={navigationTheme}>
        <AppBootstrapProvider>
          <MobileAppStateProvider>
            <OnDeviceAutoDownloader />
            {/* iOS 홈 화면 위젯 App Group UserDefaults sync. */}
            {/* useMySaju 를 쓰므로 MobileAppStateProvider 자식으로 배치. */}
            <WidgetSyncBridge />
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
                <OnDeviceDownloadProgressBar />
              </SocialAuthProvider>
            </FriendCreationProvider>
            </OnboardingFlowProvider>
          </MobileAppStateProvider>
        </AppBootstrapProvider>
      </ThemeProvider>
    </SafeAreaProvider>
  );
}
