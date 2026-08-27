import path from 'node:path';

import type { NextConfig } from 'next';

/**
 * 루트 `vercel.json` 의 `/.well-known/*` 헤더를 재현한 값.
 *
 * Vercel Root Directory = `apps/web` 인 프로젝트에서는 루트 vercel.json 이
 * 적용되지 않으므로 Next 가 직접 선언해야 한다. 두 파일 모두 확장자가 없거나
 * (`apple-app-site-association`) JSON 인데, iOS/Android 는 정확한 Content-Type
 * 없이는 universal link / app link 검증을 거부한다.
 */
const wellKnownHeaders = [
  { key: 'Content-Type', value: 'application/json; charset=utf-8' },
  { key: 'Cache-Control', value: 'public, max-age=300' },
];

const contentSecurityPolicy = [
  "default-src 'self'",
  "base-uri 'self'",
  "form-action 'self' https://accounts.google.com",
  "frame-ancestors 'none'",
  "object-src 'none'",
  "script-src 'self' 'unsafe-inline' https://www.googletagmanager.com https://js.tosspayments.com",
  "style-src 'self' 'unsafe-inline'",
  "img-src 'self' data: blob: https:",
  "font-src 'self' data:",
  "connect-src 'self' https: wss: https://www.google-analytics.com https://region1.google-analytics.com",
  "media-src 'self' data: blob: https:",
  "frame-src 'self' https://*.tosspayments.com",
  "worker-src 'self' blob:",
].join('; ');

const securityHeaders = [
  { key: 'Content-Security-Policy', value: contentSecurityPolicy },
  { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
  { key: 'Permissions-Policy', value: 'camera=(), microphone=(), geolocation=(), payment=(self)' },
  { key: 'X-Content-Type-Options', value: 'nosniff' },
  { key: 'X-Frame-Options', value: 'DENY' },
  { key: 'Cross-Origin-Opener-Policy', value: 'same-origin-allow-popups' },
  { key: 'Strict-Transport-Security', value: 'max-age=63072000; includeSubDomains; preload' },
];

const nextConfig: NextConfig = {
  /**
   * 모노레포 루트를 명시. 없으면 Next 가 lockfile 을 찾아 루트를 "추론"하는데,
   * 이 저장소는 worktree 사용 시 상위 체크아웃의 pnpm-lock.yaml 까지 발견해서
   * 엉뚱한 디렉터리를 루트로 고르고 경고를 낸다. 이 앱은 `../../packages/*` 를
   * 직접 참조하므로 트레이싱 루트가 흔들리면 안 된다.
   * `next build` 는 항상 프로젝트 디렉터리(apps/web)를 cwd 로 실행된다.
   */
  outputFileTracingRoot: path.join(process.cwd(), '..', '..'),
  // 세 패키지 모두 빌드 스텝 없이 raw src TS 를 main/types 로 노출한다 →
  // Next 가 직접 transpile 해야 번들에 들어간다.
  transpilePackages: [
    '@fortune/product-contracts',
    '@fortune/design-tokens',
    '@fortune/saju-engine',
  ],
  async headers() {
    return [
      {
        source: '/:path*',
        headers: securityHeaders,
      },
      {
        source: '/.well-known/apple-app-site-association',
        headers: wellKnownHeaders,
      },
      {
        source: '/.well-known/assetlinks.json',
        headers: wellKnownHeaders,
      },
    ];
  },
};

export default nextConfig;
