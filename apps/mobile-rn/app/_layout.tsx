import 'react-native-gesture-handler';

import { useEffect } from 'react';

import { router, type Href } from 'expo-router';
import { Stack } from 'expo-router';
import { ThemeProvider } from '@react-navigation/native';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaProvider } from 'react-native-safe-area-context';

import { notificationService, type NotificationRouteData } from '../src/lib/notifications/notification-service';
import { setPendingChatFortuneType } from '../src/lib/storage';
import { navigationTheme } from '../src/lib/theme';
import { AppBootstrapProvider } from '../src/providers/app-bootstrap-provider';
import { FriendCreationProvider } from '../src/providers/friend-creation-provider';
import { MobileAppStateProvider } from '../src/providers/mobile-app-state-provider';
import { SocialAuthProvider } from '../src/providers/social-auth-provider';

function NotificationRouteBridge() {
  useEffect(() => {
    function routeFromNotification(data: NotificationRouteData) {
      const pathname = data.pathname ?? '/chat';
      const navigate = () => router.push(pathname as Href);

      if (!data.fortuneType) {
        navigate();
        return;
      }

      void setPendingChatFortuneType(data.fortuneType)
        .catch(() => undefined)
        .finally(navigate);
    }

    void notificationService.initialize(routeFromNotification);

    return () => {
      notificationService.dispose();
    };
  }, []);

  return null;
}

export default function RootLayout() {
  return (
    <SafeAreaProvider>
      <ThemeProvider value={navigationTheme}>
        <AppBootstrapProvider>
          <MobileAppStateProvider>
            <FriendCreationProvider>
              <SocialAuthProvider>
                <NotificationRouteBridge />
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
                  <Stack.Screen
                    name="signup"
                    options={{
                      animation: 'fade',
                      contentStyle: {
                        backgroundColor: 'transparent',
                      },
                      presentation: 'transparentModal',
                    }}
                  />
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
