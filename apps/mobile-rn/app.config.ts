import type { ExpoConfig } from 'expo/config';

const config: ExpoConfig = {
  name: '온도',
  slug: 'ondo-mobile-rn',
  version: '1.0.0',
  orientation: 'portrait',
  icon: './assets/icon.png',
  scheme: 'com.beyond.fortune',
  userInterfaceStyle: 'automatic',
  newArchEnabled: true,
  splash: {
    image: './assets/splash-icon.png',
    resizeMode: 'contain',
    backgroundColor: '#0B0B10',
  },
  ios: {
    supportsTablet: true,
    bundleIdentifier: 'com.beyond.fortune',
  },
  android: {
    package: 'com.beyond.fortune',
    adaptiveIcon: {
      foregroundImage: './assets/adaptive-icon.png',
      backgroundColor: '#0B0B10',
    },
    edgeToEdgeEnabled: true,
    predictiveBackGestureEnabled: false,
  },
  plugins: ['expo-router'],
  experiments: {
    typedRoutes: true,
    autolinkingModuleResolution: true,
  },
  extra: {
    appEnv: process.env.EXPO_PUBLIC_APP_ENV ?? process.env.APP_ENV ?? 'development',
    supabaseUrl:
      process.env.EXPO_PUBLIC_SUPABASE_URL ?? process.env.SUPABASE_URL ?? '',
    supabaseAnonKey:
      process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY ??
      process.env.SUPABASE_ANON_KEY ??
      '',
    appDomain:
      process.env.EXPO_PUBLIC_APP_DOMAIN ?? process.env.APP_DOMAIN ?? '',
    sentryDsn:
      process.env.EXPO_PUBLIC_SENTRY_DSN ?? process.env.SENTRY_DSN ?? '',
    mixpanelToken:
      process.env.EXPO_PUBLIC_MIXPANEL_TOKEN ?? process.env.MIXPANEL_TOKEN ?? '',
    googleWebClientId:
      process.env.EXPO_PUBLIC_GOOGLE_WEB_CLIENT_ID ??
      process.env.GOOGLE_WEB_CLIENT_ID ??
      '',
    googleIosClientId:
      process.env.EXPO_PUBLIC_GOOGLE_IOS_CLIENT_ID ??
      process.env.GOOGLE_IOS_CLIENT_ID ??
      '',
    googleAndroidClientId:
      process.env.EXPO_PUBLIC_GOOGLE_ANDROID_CLIENT_ID ??
      process.env.GOOGLE_ANDROID_CLIENT_ID ??
      '',
    kakaoAppKey:
      process.env.EXPO_PUBLIC_KAKAO_APP_KEY ?? process.env.KAKAO_APP_KEY ?? '',
  },
};

export default config;
