import type { MetadataRoute } from 'next';

import { WEB_CHAT_CHARACTERS } from '@/features/chat/characters';
import { MBTI_TYPES } from '@/features/f-b/mbti-types';
import { ZODIAC_ANIMALS } from '@/features/f-b/zodiac-animals';
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
 * 목록은 라우트 폴더를 스캔하지 않고 각 SoT 에서 만든다 — 카탈로그·캐릭터·
 * 띠·MBTI 배열이 라우팅의 SoT 라, 항목이 늘면 sitemap 이 자동으로 따라간다.
 *
 * `generateStaticParams` 로 미리 만들어지는 하위 페이지(띠 12개, MBTI 16개,
 * 캐릭터 4개)가 전부 빠져 있었다. 색인 가능한 페이지를 만들어 두고 sitemap 에는
 * 알리지 않는 상태였고, 검색 수요가 가장 뚜렷한 게 하필 이 조합형 페이지들이다.
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
  ...ZODIAC_ANIMALS.map((animal) => ({
    path: `운세/띠별/${animal.name}`,
    changeFrequency: 'daily' as ChangeFrequency,
    priority: 0.7,
  })),
  ...MBTI_TYPES.map((type) => ({
    path: `운세/엠비티아이/${type.id}`,
    changeFrequency: 'daily' as ChangeFrequency,
    priority: 0.7,
  })),
  { path: '대화', changeFrequency: 'weekly', priority: 0.7 },
  ...WEB_CHAT_CHARACTERS.map((character) => ({
    path: `대화/${character.id}`,
    changeFrequency: 'weekly' as ChangeFrequency,
    priority: 0.6,
  })),
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
