/**
 * 웹이 실제로 서빙하는 운세 목록 — 웹 라우팅의 단일 소스.
 *
 * 네이티브는 48개를 노출하지만 웹은 "설치 없이 바로 보는" 13개만 연다.
 * 사진 업로드/이미지 생성이 필요한 프리미엄 계열은 웹 첫 방문 흐름과 맞지 않아
 * 뺐다.
 *
 * 이름/설명은 여기서 새로 쓰지 않고 `@fortune/product-contracts` 의
 * FORTUNE_CATALOG (앱 메뉴가 쓰는 SoT) 에서 가져온다. 같은 운세를 웹과 앱이
 * 다르게 부르면 안 되고, SoT 문구가 바뀌면 여기도 따라가야 하기 때문이다.
 * 가격도 같은 이유로 `getFortuneCostPoints` lookup 이다 — 숫자 하드코딩 금지.
 *
 * slug 는 한글이다. 제품이 한국어 전용이고 SERP/카카오 링크 프리뷰에서 경로
 * 토큰이 그대로 읽힌다 (`/운세/오늘` 과 같은 이유).
 */

import {
  FORTUNE_CATALOG_GROUPS,
  findCatalogEntry,
  getFortuneCostPoints,
  type FortuneCatalogGroupId,
  type FortuneTypeId,
} from '@fortune/product-contracts';

export interface WebFortune {
  /** `/운세/` 뒤에 오는 경로 조각. */
  slug: string;
  /** Edge Function 이름의 뿌리 (`fortune-<fortuneType>`). */
  fortuneType: string;
  title: string;
  blurb: string;
  /** 목록 페이지 섹션 제목 (앱 카탈로그 그룹 라벨과 동일). */
  group: string;
  /** 1회 생성에 드는 온도. `FORTUNE_POINT_COSTS` SoT lookup. */
  costPoints: number;
}

interface WebFortuneSeed {
  slug: string;
  id: FortuneTypeId;
  group: FortuneCatalogGroupId;
  /** FORTUNE_CATALOG 에 행이 없는 운세만 채운다 (현재 dream 하나). */
  fallback?: { title: string; blurb: string };
}

/**
 * 그룹 순서 = 앱 카탈로그 순서. 그룹 안 순서는 배열 순서.
 * dream 은 앱에서 채팅 별칭으로만 노출돼 FORTUNE_CATALOG 에 행이 없다
 * (`fortune-catalog.ts` 상단 주석의 별칭 제외 목록). 문구는 Edge Function
 * `supabase/functions/fortune-dream/index.ts` 의 설명을 그대로 요약했다.
 */
const SEEDS: ReadonlyArray<WebFortuneSeed> = [
  { slug: '오늘', id: 'daily', group: 'tarot_saju' },
  { slug: '타로', id: 'tarot', group: 'tarot_saju' },
  { slug: '사주', id: 'traditional-saju', group: 'tarot_saju' },

  { slug: '연애', id: 'love', group: 'love' },
  { slug: '궁합', id: 'compatibility', group: 'love' },

  { slug: '재물', id: 'wealth', group: 'career_money' },
  { slug: '직업', id: 'career', group: 'career_money' },

  {
    slug: '꿈해몽',
    id: 'dream',
    group: 'lifestyle',
    fallback: { title: '꿈해몽', blurb: '꿈에 나온 상징을 심리와 전통 해석으로 함께 풀어줘요' },
  },
  { slug: '행운아이템', id: 'lucky-items', group: 'lifestyle' },

  { slug: '건강', id: 'health', group: 'health' },
  { slug: '바이오리듬', id: 'biorhythm', group: 'health' },

  { slug: '띠별', id: 'zodiac-animal', group: 'personality' },
  { slug: '엠비티아이', id: 'mbti', group: 'personality' },
];

const GROUP_LABELS = new Map<FortuneCatalogGroupId, string>(
  FORTUNE_CATALOG_GROUPS.map((group) => [group.id, group.label]),
);

function toWebFortune(seed: WebFortuneSeed): WebFortune {
  const entry = findCatalogEntry(seed.id);
  return {
    slug: seed.slug,
    fortuneType: seed.id,
    title: entry?.displayName ?? seed.fallback?.title ?? seed.id,
    blurb: entry?.shortDesc ?? seed.fallback?.blurb ?? '',
    group: GROUP_LABELS.get(seed.group) ?? seed.group,
    costPoints: getFortuneCostPoints(seed.id),
  };
}

export const WEB_FORTUNES: WebFortune[] = SEEDS.map(toWebFortune);

/** `/운세/[slug]` 해석용. 없으면 undefined → 페이지에서 notFound(). */
export function findWebFortuneBySlug(slug: string): WebFortune | undefined {
  return WEB_FORTUNES.find((fortune) => fortune.slug === slug);
}

export function findWebFortuneByType(fortuneType: string): WebFortune | undefined {
  return WEB_FORTUNES.find((fortune) => fortune.fortuneType === fortuneType);
}

/** 목록 페이지용 그룹 묶음. 배열 순서를 그대로 유지한다. */
export function groupWebFortunes(): Array<{ group: string; fortunes: WebFortune[] }> {
  const sections: Array<{ group: string; fortunes: WebFortune[] }> = [];
  for (const fortune of WEB_FORTUNES) {
    const last = sections[sections.length - 1];
    if (last && last.group === fortune.group) {
      last.fortunes.push(fortune);
      continue;
    }
    sections.push({ group: fortune.group, fortunes: [fortune] });
  }
  return sections;
}
