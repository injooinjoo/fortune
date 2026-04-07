import fs from 'node:fs';
import path from 'node:path';

import type { ExpoConfig } from 'expo/config';

function isPlaceholderEnvValue(value: string) {
  const normalized = value.trim().toLowerCase();

  return (
    normalized.length === 0 ||
    normalized.includes('placeholder') ||
    normalized.startsWith('your-dev-') ||
    normalized.startsWith('your-prod-') ||
    normalized === 'https://your-dev-project.supabase.co' ||
    normalized === 'https://your-prod-project.supabase.co'
  );
}

function parseEnvFile(filePath: string, protectedKeys: ReadonlySet<string>) {
  const content = fs.readFileSync(filePath, 'utf8');

  for (const rawLine of content.split(/\r?\n/)) {
    const line = rawLine.trim();

    if (!line || line.startsWith('#')) {
      continue;
    }

    const separatorIndex = line.indexOf('=');
    if (separatorIndex <= 0) {
      continue;
    }

    const key = line.slice(0, separatorIndex).trim();
    let value = line.slice(separatorIndex + 1).trim();

    if (protectedKeys.has(key)) {
      continue;
    }

    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    } else {
      value = value.replace(/\s+#.*$/, '');
    }

    if (isPlaceholderEnvValue(value)) {
      continue;
    }

    process.env[key] = value;
  }
}

function loadWorkspaceEnvFiles() {
  const workspaceRoot = path.resolve(__dirname, '../..');
  const initialKeys = new Set(Object.keys(process.env));
  const appEnvironment =
    process.env.EXPO_PUBLIC_APP_ENV ??
    process.env.APP_ENV ??
    process.env.NODE_ENV ??
    'development';
  const candidates = [
    '.env',
    `.env.${appEnvironment}`,
    '.env.local',
    `.env.${appEnvironment}.local`,
  ];

  for (const name of candidates) {
    const filePath = path.join(workspaceRoot, name);

    if (!fs.existsSync(filePath)) {
      continue;
    }

    parseEnvFile(filePath, initialKeys);
  }
}

loadWorkspaceEnvFiles();

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
    usesAppleSignIn: true,
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
  plugins: [
    'expo-router',
    'expo-iap',
    'expo-apple-authentication',
    'expo-web-browser',
    './plugins/with-ios-prebuilt-react-native',
  ],
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
