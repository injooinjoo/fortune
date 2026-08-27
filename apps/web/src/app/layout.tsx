import type { Metadata, Viewport } from 'next';
import type { ReactNode } from 'react';

import { fortuneColors } from '@fortune/design-tokens';

import { SiteFooter } from '@/components/site-footer';
import { SiteHeader } from '@/components/site-header';
import { Analytics } from '@/components/analytics';
import {
  gaMeasurementId,
  googleSiteVerification,
  naverSiteVerification,
  siteUrl,
} from '@/lib/env';

import '@/styles/tokens.css';
import './globals.css';

export const metadata: Metadata = {
  metadataBase: new URL(siteUrl),
  applicationName: '온도',
  category: 'lifestyle',
  title: {
    default: '온도 — 오늘의 운세와 캐릭터 대화',
    template: '%s · 온도',
  },
  description:
    '생년월일과 태어난 시간으로 오늘의 운세를 읽고, 나를 기억하는 캐릭터와 대화하는 AI 운세 서비스 온도.',
  keywords: ['온도', '오늘의 운세', '사주', '타로', 'AI 운세', '캐릭터 대화'],
  robots: { index: true, follow: true },
  verification: {
    google: googleSiteVerification || undefined,
    other: naverSiteVerification
      ? { 'naver-site-verification': naverSiteVerification }
      : undefined,
  },
  openGraph: {
    type: 'website',
    locale: 'ko_KR',
    siteName: '온도',
    title: '온도 — 오늘의 운세와 캐릭터 대화',
    description: '생년월일과 태어난 시간으로 읽는 오늘의 운세.',
    url: siteUrl,
    images: [{ url: '/opengraph-image', width: 1200, height: 630, alt: '온도 — 오늘의 흐름을 읽고 마음을 이어가는 곳' }],
  },
  twitter: {
    card: 'summary_large_image',
    title: '온도 — 오늘의 운세와 캐릭터 대화',
    description: '생년월일과 태어난 시간으로 읽는 오늘의 운세.',
    images: ['/opengraph-image'],
  },
};

// themeColor 는 CSS 변수를 쓸 수 없는 자리라 토큰 SoT 에서 직접 읽는다.
export const viewport: Viewport = {
  colorScheme: 'light',
  themeColor: fortuneColors.light.background,
};

/**
 * 웹 전용 light 루트 레이아웃.
 *
 * 앱의 dark 테마 기본값은 유지하고, 웹은 브라우저 읽기성과 반복 사용성을 위해
 * design-tokens 의 light 팔레트를 명시적으로 소비한다.
 *
 * 헤더/푸터는 여기에만 둔다. 둘 다 세션을 읽지 않는 순수 컴포넌트라 페이지의
 * 정적 생성 여부를 바꾸지 않는다.
 */
export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="ko">
      <body>
        <SiteHeader />
        {children}
        <SiteFooter />
        <Analytics measurementId={gaMeasurementId} />
      </body>
    </html>
  );
}
