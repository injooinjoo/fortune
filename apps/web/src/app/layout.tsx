import type { Metadata, Viewport } from 'next';
import type { ReactNode } from 'react';

import { fortuneColors } from '@fortune/design-tokens';

import { siteUrl } from '@/lib/env';

import '@/styles/tokens.css';
import './globals.css';

export const metadata: Metadata = {
  metadataBase: new URL(siteUrl),
  title: {
    default: '온도 — 오늘의 운세와 캐릭터 대화',
    template: '%s · 온도',
  },
  description:
    '생년월일과 태어난 시간으로 오늘의 운세를 읽고, 나를 기억하는 캐릭터와 대화하는 AI 운세 서비스 온도.',
  openGraph: {
    type: 'website',
    locale: 'ko_KR',
    siteName: '온도',
    title: '온도 — 오늘의 운세와 캐릭터 대화',
    description: '생년월일과 태어난 시간으로 읽는 오늘의 운세.',
    url: siteUrl,
  },
};

// themeColor 는 CSS 변수를 쓸 수 없는 자리라 토큰 SoT 에서 직접 읽는다.
export const viewport: Viewport = {
  colorScheme: 'dark',
  themeColor: fortuneColors.dark.background,
};

/**
 * dark 전용 루트 레이아웃.
 *
 * `[data-theme]` 분기를 두지 않는다 — `createFortuneTheme('light')` 는
 * repo 전체에서 호출부가 0 이고, 웹만 라이트 팔레트를 들고 있으면
 * 앱과 색이 갈라진다.
 */
export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="ko">
      <body>{children}</body>
    </html>
  );
}
