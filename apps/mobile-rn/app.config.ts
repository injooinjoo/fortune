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
  const workspaceRoot = path.resolve(process.cwd(), '../..');
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
  version: '1.0.9',
  orientation: 'portrait',
  icon: './assets/icon.png',
  // expo-router + expo-linking 가 standalone production 빌드에서 deep link
  // URL을 구성할 때 `Constants.expoConfig.scheme` 을 직접 참조한다. 이 값이
  // 없으면 ContextNavigator mount 시 "Cannot make a deep link into a
  // standalone app with no custom scheme defined" 예외로 JS 번들이 초기화
  // 단계에서 throw 되어 expo-updates ErrorRecovery 가 StartupProcedure
  // .throwException 을 호출하며 앱이 crash 한다 (build 27 사례, 기기 로그로
  // 확인). 이전 P3-B9 commit 에서 Info.plist 중복 CFBundleURLSchemes 엔트리
  // 를 없애려 이 값을 제거했는데, Linking 붕괴가 훨씬 심각하므로 되돌림.
  // 중복 엔트리는 기능적으로 무해하며 App Store 심사 사유가 아니다.
  scheme: 'com.beyond.fortune',
  // Ondo 브랜드 정체성상 다크 전용. theme.ts / _layout StatusBar 모두 다크
  // 고정이므로 manifest도 'dark'로 일치시켜 HIG 4.5 불일치 방지.
  userInterfaceStyle: 'dark',
  newArchEnabled: true,
  splash: {
    image: './assets/splash-icon.png',
    resizeMode: 'contain',
    backgroundColor: '#0B0B10',
  },
  ios: {
    supportsTablet: true,
    // iPad multitasking(Split View/Slide Over)을 포기하는 대신 portrait 잠금
    // 허용. Expo prebuild 기본값은 `supportsTablet: true` 시 iPad에 landscape
    // 4방향을 강제하는데, `requireFullScreen: true` 로 multitasking 요구사항을
    // 면제받아 portrait만 남길 수 있다. (W6 보완)
    requireFullScreen: true,
    bundleIdentifier: 'com.beyond.fortune',
    usesAppleSignIn: true,
    infoPlist: {
      ITSAppUsesNonExemptEncryption: false,
      UIBackgroundModes: ['remote-notification'],
      // iPad landscape 차단 — `supportsTablet: true` 시 Expo 기본이
      // iPad용 landscape 4방향 포함하는 Info.plist를 생성. Ondo는 모든
      // 화면이 portrait-optimized 이므로 iPad도 portrait 잠금.
      // (W6 audit finding)
      'UISupportedInterfaceOrientations~ipad': [
        'UIInterfaceOrientationPortrait',
        'UIInterfaceOrientationPortraitUpsideDown',
      ],
    },
    entitlements: {
      'aps-environment': 'production',
      // Sprint W1 — iOS 홈 화면 위젯 브릿지. 메인 앱과 위젯 extension이
      // 동일 App Group을 공유해야 UserDefaults(suiteName:)로 위젯 데이터를
      // 주고받을 수 있음. 위젯 extension 쪽 entitlement는
      // @bacons/apple-targets 가 expo-target.config.json → entitlements 로
      // 자동 주입.
      'com.apple.security.application-groups': [
        'group.com.beyond.fortune.widgets',
      ],
    },
    // ios/app/PrivacyInfo.xcprivacy는 gitignored로 prebuild 시 재생성.
    // NSPrivacyAccessedAPITypes 블록도 여기에서 공급해야 Accessed API 카테고리
    // 선언이 유실되지 않음. NSPrivacyCollectedDataTypes는 ASC "App Privacy"
    // 답변과 1:1 일치해야 함 (artifacts/sprint-fixes/P6-B11/mapping.md 참조).
    privacyManifests: {
      NSPrivacyTracking: false,
      NSPrivacyAccessedAPITypes: [
        {
          NSPrivacyAccessedAPIType: 'NSPrivacyAccessedAPICategoryFileTimestamp',
          NSPrivacyAccessedAPITypeReasons: ['C617.1', '0A2A.1', '3B52.1'],
        },
        {
          NSPrivacyAccessedAPIType: 'NSPrivacyAccessedAPICategoryUserDefaults',
          NSPrivacyAccessedAPITypeReasons: ['CA92.1'],
        },
        {
          NSPrivacyAccessedAPIType: 'NSPrivacyAccessedAPICategorySystemBootTime',
          NSPrivacyAccessedAPITypeReasons: ['35F9.1'],
        },
        {
          NSPrivacyAccessedAPIType: 'NSPrivacyAccessedAPICategoryDiskSpace',
          NSPrivacyAccessedAPITypeReasons: ['E174.1', '85F4.1'],
        },
      ],
      NSPrivacyCollectedDataTypes: [
        {
          NSPrivacyCollectedDataType: 'NSPrivacyCollectedDataTypeEmailAddress',
          NSPrivacyCollectedDataTypeLinked: true,
          NSPrivacyCollectedDataTypeTracking: false,
          NSPrivacyCollectedDataTypePurposes: [
            'NSPrivacyCollectedDataTypePurposeAppFunctionality',
          ],
        },
        {
          NSPrivacyCollectedDataType: 'NSPrivacyCollectedDataTypeName',
          NSPrivacyCollectedDataTypeLinked: true,
          NSPrivacyCollectedDataTypeTracking: false,
          NSPrivacyCollectedDataTypePurposes: [
            'NSPrivacyCollectedDataTypePurposeAppFunctionality',
            'NSPrivacyCollectedDataTypePurposeProductPersonalization',
          ],
        },
        {
          NSPrivacyCollectedDataType: 'NSPrivacyCollectedDataTypeUserID',
          NSPrivacyCollectedDataTypeLinked: true,
          NSPrivacyCollectedDataTypeTracking: false,
          NSPrivacyCollectedDataTypePurposes: [
            'NSPrivacyCollectedDataTypePurposeAppFunctionality',
          ],
        },
        {
          NSPrivacyCollectedDataType: 'NSPrivacyCollectedDataTypeDeviceID',
          NSPrivacyCollectedDataTypeLinked: true,
          NSPrivacyCollectedDataTypeTracking: false,
          NSPrivacyCollectedDataTypePurposes: [
            'NSPrivacyCollectedDataTypePurposeAppFunctionality',
            'NSPrivacyCollectedDataTypePurposeAnalytics',
          ],
        },
        {
          NSPrivacyCollectedDataType: 'NSPrivacyCollectedDataTypeCrashData',
          NSPrivacyCollectedDataTypeLinked: true,
          NSPrivacyCollectedDataTypeTracking: false,
          NSPrivacyCollectedDataTypePurposes: [
            'NSPrivacyCollectedDataTypePurposeAppFunctionality',
          ],
        },
        {
          NSPrivacyCollectedDataType: 'NSPrivacyCollectedDataTypePerformanceData',
          NSPrivacyCollectedDataTypeLinked: true,
          NSPrivacyCollectedDataTypeTracking: false,
          NSPrivacyCollectedDataTypePurposes: [
            'NSPrivacyCollectedDataTypePurposeAnalytics',
          ],
        },
        {
          NSPrivacyCollectedDataType: 'NSPrivacyCollectedDataTypeOtherDiagnosticData',
          NSPrivacyCollectedDataTypeLinked: true,
          NSPrivacyCollectedDataTypeTracking: false,
          NSPrivacyCollectedDataTypePurposes: [
            'NSPrivacyCollectedDataTypePurposeAppFunctionality',
            'NSPrivacyCollectedDataTypePurposeAnalytics',
          ],
        },
        {
          NSPrivacyCollectedDataType: 'NSPrivacyCollectedDataTypePhotosorVideos',
          NSPrivacyCollectedDataTypeLinked: true,
          NSPrivacyCollectedDataTypeTracking: false,
          NSPrivacyCollectedDataTypePurposes: [
            'NSPrivacyCollectedDataTypePurposeAppFunctionality',
          ],
        },
        {
          NSPrivacyCollectedDataType: 'NSPrivacyCollectedDataTypeAudioData',
          NSPrivacyCollectedDataTypeLinked: true,
          NSPrivacyCollectedDataTypeTracking: false,
          NSPrivacyCollectedDataTypePurposes: [
            'NSPrivacyCollectedDataTypePurposeAppFunctionality',
          ],
        },
        {
          NSPrivacyCollectedDataType: 'NSPrivacyCollectedDataTypeOtherUserContent',
          NSPrivacyCollectedDataTypeLinked: true,
          NSPrivacyCollectedDataTypeTracking: false,
          NSPrivacyCollectedDataTypePurposes: [
            'NSPrivacyCollectedDataTypePurposeAppFunctionality',
            'NSPrivacyCollectedDataTypePurposeProductPersonalization',
          ],
        },
        {
          NSPrivacyCollectedDataType: 'NSPrivacyCollectedDataTypePurchaseHistory',
          NSPrivacyCollectedDataTypeLinked: true,
          NSPrivacyCollectedDataTypeTracking: false,
          NSPrivacyCollectedDataTypePurposes: [
            'NSPrivacyCollectedDataTypePurposeAppFunctionality',
          ],
        },
      ],
    },
  },
  android: {
    package: 'com.beyond.fortune',
    // Android's scheme plugin has no bundleId fallback — must declare
    // explicitly or intent-filter for `com.beyond.fortune://` deep links
    // (OAuth callback, push routing) will not register.
    scheme: 'com.beyond.fortune',
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
    ['expo-speech-recognition', {
      microphonePermission: '음성으로 텍스트를 입력하기 위해 마이크 접근이 필요합니다.',
      speechRecognitionPermission: '음성을 텍스트로 변환하기 위해 음성 인식 접근이 필요합니다.',
    }],
    [
      'expo-notifications',
      {
        icon: './assets/icon.png',
        color: '#0B0B10',
      },
    ],
    [
      'expo-image-picker',
      {
        photosPermission: '관상 분석을 위해 사진 접근이 필요합니다.',
        cameraPermission: '관상 분석을 위해 카메라 접근이 필요합니다.',
      },
    ],
    '@sentry/react-native',
    './plugins/with-ios-prebuilt-react-native',
    // Sprint W1 — iOS 홈 화면 위젯 extension 타겟(@main)을
    // apps/mobile-rn/targets/widgets/ 에서 선언된 expo-target.config.json
    // 을 읽어 prebuild 시점에 ios/ 프로젝트에 자동 주입. 수동 Xcode 편집 없이
    // Widget Extension 타겟 + entitlements + SwiftUI 소스까지 관리.
    '@bacons/apple-targets',
    // llama.rn config plugin — Expo 환경에서 JSI 바인딩이 제대로 설치되려면
    // entitlements + C++20 + OpenCL 옵션이 필요. plugin 없이 설치만 하면
    // initLlama 호출 시 "property 'install'" JSI 에러로 'unsupported' 상태.
    [
      'llama.rn',
      {
        enableEntitlements: true,
        entitlementsProfile: 'production',
        forceCxx20: true,
        enableOpenCL: true,
      },
    ],
  ],
  updates: {
    url: 'https://u.expo.dev/f7a724ea-b46e-494a-b83c-94e7a6fec02a',
    // 시작 시 OTA 다운로드 대기 화면("Downloading X%...") 차단 방지.
    // 캐시된 번들로 즉시 실행하고, 새 번들은 _layout.tsx useEffect 에서
    // 백그라운드로 받아 다음 launch 또는 reloadAsync 로 적용.
    checkAutomatically: 'NEVER',
    fallbackToCacheTimeout: 0,
  },
  runtimeVersion: '1.0.9',
  experiments: {
    typedRoutes: true,
    autolinkingModuleResolution: true,
  },
  extra: {
    eas: {
      projectId: 'f7a724ea-b46e-494a-b83c-94e7a6fec02a',
    },
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
