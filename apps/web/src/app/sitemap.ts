import type { MetadataRoute } from 'next';

import { WEB_FORTUNES } from '@/features/fortune/catalog';
import { siteUrl } from '@/lib/env';

type ChangeFrequency = NonNullable<MetadataRoute.Sitemap[number]['changeFrequency']>;

interface PublicRoute {
  /** siteUrl 뒤에 붙는 경로. 루트는 빈 문자열. 인코딩 전 원문. */
  path: string;
  changeFrequency: ChangeFrequency;
  priority: number;
}

/**
 * 공개 색인 대상만 넣는다. `/app/*` 과 `/auth/*` 는 robots 에서 제외한
 * 로그인 뒤 화면이라 sitemap 에도 넣지 않는다.
 *
 * 운세 목록은 라우트 폴더를 스캔하지 않고 `WEB_FORTUNES` 에서 만든다 —
 * 카탈로그가 웹 라우팅의 SoT 라 새 운세가 늘면 sitemap 이 자동으로 따라간다.
 */
const ROUTES: PublicRoute[] = [
  { path: '', changeFrequency: 'daily', priority: 1 },
  { path: '운세', changeFrequency: 'weekly', priority: 0.9 },
  ...WEB_FORTUNES.map((fortune) => ({
    path: `운세/${fortune.slug}`,
    changeFrequency: 'daily' as ChangeFrequency,
    // 오늘의 운세가 첫 방문자의 도착점이라 목록과 같은 가중치를 유지한다.
    priority: fortune.fortuneType === 'daily' ? 0.9 : 0.8,
  })),
  { path: '대화', changeFrequency: 'weekly', priority: 0.7 },
];

export default function sitemap(): MetadataRoute.Sitemap {
  const lastModified = new Date();

  return ROUTES.map((route) => ({
    // 한글 경로는 sitemap 에서 퍼센트 인코딩돼야 한다. 경로 구분자(/)는 그대로 둔다.
    url: route.path.length > 0 ? `${siteUrl}/${encodeURI(route.path)}` : siteUrl,
    lastModified,
    changeFrequency: route.changeFrequency,
    priority: route.priority,
  }));
}
