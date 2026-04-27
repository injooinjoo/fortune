import { LegalScreen } from '../src/screens/legal-screen';

// OSS 고지. 주요 라이브러리 + 라이선스 표기.
// 정확한 버전·전체 transitive 의존성 목록은 향후 스크립트 자동 생성으로 대체 가능
// (expo-modules-core / licenses CLI 등). 현재는 주요 top-level 의존성 수동 정리.

export default function OpenSourceLicensesRoute() {
  return (
    <LegalScreen
      path="/open-source-licenses"
      title="오픈소스 라이선스"
      summary="온도는 아래 오픈소스 소프트웨어를 사용하여 만들어졌습니다. 각 프로젝트와 제작자에게 감사드립니다."
      sections={[
        {
          title: 'React Native 플랫폼',
          body:
            '- React Native (MIT) — Meta Platforms, Inc.\n' +
            '- React (MIT) — Meta Platforms, Inc.\n' +
            '- react-dom (MIT) — Meta Platforms, Inc.\n' +
            '- react-native-web (MIT) — Nicolas Gallagher',
        },
        {
          title: 'Expo 에코시스템',
          body:
            '- expo, expo-router, expo-updates, expo-notifications (MIT) — 650 Industries, Inc.\n' +
            '- expo-apple-authentication, expo-iap, expo-secure-store (MIT)\n' +
            '- expo-image-picker, expo-av, expo-speech-recognition (MIT)\n' +
            '- expo-file-system, expo-constants, expo-device, expo-font, expo-haptics (MIT)\n' +
            '- expo-linking, expo-status-bar, expo-system-ui, expo-web-browser, expo-crypto (MIT)\n' +
            '- expo-splash-screen, expo-dev-client, @expo/metro-runtime, @expo/vector-icons (MIT)',
        },
        {
          title: 'UI / 제스처 / 애니메이션',
          body:
            '- react-native-gesture-handler (MIT) — Software Mansion\n' +
            '- react-native-reanimated (MIT) — Software Mansion\n' +
            '- react-native-screens (MIT) — Software Mansion\n' +
            '- react-native-safe-area-context (MIT) — Th3rd Wave\n' +
            '- react-native-svg (MIT)\n' +
            '- react-native-keyboard-controller (MIT) — Kiryl Ziusko',
        },
        {
          title: '네트워크·스토리지',
          body:
            '- @supabase/supabase-js (MIT) — Supabase Inc.\n' +
            '- react-native-url-polyfill (MIT)\n' +
            '- react-native-shared-group-preferences (MIT)',
        },
        {
          title: 'AI · 로컬 추론',
          body:
            '- llama.rn (MIT) — Jhen-Jie Hong\n' +
            '- llama.cpp (MIT) — Georgi Gerganov',
        },
        {
          title: '모니터링',
          body: '- @sentry/react-native (MIT) — Sentry',
        },
        {
          title: '폰트 · 에셋',
          body:
            '- ZEN Antique Serif (OFL-1.1) — Yoshimichi Ohira\n' +
            'SIL Open Font License 1.1 에 따라 사용됩니다.',
        },
        {
          title: '라이선스 전문',
          body:
            '각 라이브러리의 라이선스 전문은 해당 프로젝트 저장소 또는 npm 레지스트리에서 확인하실 수 있습니다.\n\n' +
            'MIT License 원문 (대표 예시):\n' +
            '"Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software..."\n\n' +
            '라이선스 고지에 누락·오류가 있을 경우 injooinjoo@gmail.com 으로 알려주시면 즉시 수정하겠습니다.',
        },
      ]}
    />
  );
}
