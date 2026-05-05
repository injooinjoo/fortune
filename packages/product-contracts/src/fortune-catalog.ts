/**
 * PR-A: 하늘이 운세 메뉴 카탈로그 — 클라이언트 정적 SoT.
 *
 * 디자인:
 * - 하늘이 채팅 메뉴 카드는 LLM 이 아니라 본 카탈로그를 정적 렌더 (Round 1 결정).
 * - 80+ FortuneTypeId 전체가 아닌 사용자에게 의미 있는 ~12 큐레이션
 * - 그룹 단위로 묶어 메뉴 카드 섹션 구분 (타로/사주, 건강, 경기·게임 등)
 * - `costPoints` 는 FORTUNE_POINT_COSTS 와 일치해야 — `feature-flag-catalog-consistency.test.ts`
 *   에서 검증
 *
 * 운영:
 * - 새 fortune-type 추가 시 본 catalog + fortuneTypeToResultKind 양쪽 업데이트
 * - 클라/Edge 둘 다 contracts 패키지를 import (catalog 변경은 앱 OTA 또는 Edge 배포로 전파)
 */

import type { FortuneTypeId } from './fortunes';

export type FortuneCatalogGroupId =
  | 'tarot_saju'
  | 'health'
  | 'sports_game'
  | 'meditation'
  | 'personality'
  | 'coaching'
  | 'past_life';

export interface FortuneCatalogEntry {
  /** 라우팅 키 — `fortune-results/registry` 와 일치해야 */
  id: FortuneTypeId;
  /** 메뉴 카드에 표시될 한글 이름 */
  displayName: string;
  /** 1-2 문장 짧은 설명 */
  shortDesc: string;
  /** 메뉴 카드의 그룹 섹션 */
  group: FortuneCatalogGroupId;
  /** FORTUNE_POINT_COSTS 와 일치 — Cost confirmation modal 표시용 */
  costPoints: number;
  /** UI 정렬 우선순위 (그룹 내). 작을수록 먼저. */
  order: number;
}

export interface FortuneCatalogGroup {
  id: FortuneCatalogGroupId;
  label: string;
  /** UI 섹션 순서. 작을수록 먼저. */
  order: number;
}

export const FORTUNE_CATALOG_GROUPS: ReadonlyArray<FortuneCatalogGroup> = [
  { id: 'tarot_saju',   label: '타로 · 사주',  order: 1 },
  { id: 'health',       label: '건강 흐름',     order: 2 },
  { id: 'sports_game',  label: '경기 · 게임 인사이트', order: 3 },
  { id: 'meditation',   label: '명상 · 호흡',   order: 4 },
  { id: 'personality',  label: '성격 분석',     order: 5 },
  { id: 'coaching',     label: '코칭 · 일기',   order: 6 },
  { id: 'past_life',    label: '전생 · 인연',   order: 7 },
] as const;

export const FORTUNE_CATALOG: ReadonlyArray<FortuneCatalogEntry> = [
  // 타로 · 사주
  {
    id: 'tarot',
    displayName: '오늘의 타로',
    shortDesc: '한 장의 카드로 오늘의 흐름을 읽어줘요',
    group: 'tarot_saju',
    costPoints: 5,
    order: 1,
  },
  {
    id: 'traditional-saju',
    displayName: '전통 사주 한 줄',
    shortDesc: '오행과 사주 포인트를 짧게 정리해줘요',
    group: 'tarot_saju',
    costPoints: 12,
    order: 2,
  },
  {
    id: 'daily',
    displayName: '오늘의 운세',
    shortDesc: '오늘 어떤 흐름이 있는지 짧게 봐줘요',
    group: 'tarot_saju',
    costPoints: 1,
    order: 3,
  },

  // 건강 흐름
  {
    id: 'health',
    displayName: '건강 흐름',
    shortDesc: '컨디션과 주의해야 할 부분을 짚어줘요',
    group: 'health',
    costPoints: 3,
    order: 1,
  },
  {
    id: 'biorhythm',
    displayName: '바이오리듬',
    shortDesc: '몸·마음·지성 리듬의 위치를 알려줘요',
    group: 'health',
    costPoints: 3,
    order: 2,
  },

  // 경기 · 게임 인사이트
  {
    id: 'match-insight',
    displayName: '경기 인사이트',
    shortDesc: '오늘 경기에서 살릴 흐름을 봐줘요',
    group: 'sports_game',
    costPoints: 3,
    order: 1,
  },
  {
    id: 'game-enhance',
    displayName: '게임 인사이트',
    shortDesc: '게임 컨디션과 흐름을 봐줘요',
    group: 'sports_game',
    costPoints: 3,
    order: 2,
  },

  // 명상 · 호흡
  {
    id: 'breathing',
    displayName: '호흡 · 명상',
    shortDesc: '지금 어떤 호흡 흐름이 좋을지 안내해요',
    group: 'meditation',
    costPoints: 3,
    order: 1,
  },

  // 성격 분석
  {
    id: 'personality-dna',
    displayName: '성격 분석',
    shortDesc: '나만의 성격 DNA 를 짚어줘요',
    group: 'personality',
    costPoints: 4,
    order: 1,
  },
  {
    id: 'mbti',
    displayName: 'MBTI 운세',
    shortDesc: 'MBTI 별 흐름을 짧게 봐줘요',
    group: 'personality',
    costPoints: 3,
    order: 2,
  },

  // 코칭 · 일기
  {
    id: 'coaching',
    displayName: '코치 분석',
    shortDesc: '대화에서 보인 흐름을 코치처럼 짚어줘요',
    group: 'coaching',
    costPoints: 3,
    order: 1,
  },
  {
    id: 'daily-review',
    displayName: '오늘의 회고',
    shortDesc: '하루를 돌아보고 한 줄 정리해줘요',
    group: 'coaching',
    costPoints: 3,
    order: 2,
  },

  // 전생 · 인연
  {
    id: 'past-life',
    displayName: '전생 이야기',
    shortDesc: '전생에서 이어진 흐름을 짚어줘요',
    group: 'past_life',
    costPoints: 10,
    order: 1,
  },
] as const;

/**
 * 그룹별로 분류된 catalog — UI 렌더링 편의.
 */
export function groupFortuneCatalog(
  catalog: ReadonlyArray<FortuneCatalogEntry> = FORTUNE_CATALOG,
): Array<{ group: FortuneCatalogGroup; entries: FortuneCatalogEntry[] }> {
  const byGroupId = new Map<FortuneCatalogGroupId, FortuneCatalogEntry[]>();
  for (const entry of catalog) {
    const arr = byGroupId.get(entry.group) ?? [];
    arr.push(entry);
    byGroupId.set(entry.group, arr);
  }

  const result: Array<{
    group: FortuneCatalogGroup;
    entries: FortuneCatalogEntry[];
  }> = [];

  for (const group of [...FORTUNE_CATALOG_GROUPS].sort((a, b) => a.order - b.order)) {
    const entries = (byGroupId.get(group.id) ?? []).slice();
    entries.sort((a, b) => a.order - b.order);
    if (entries.length > 0) {
      result.push({ group, entries });
    }
  }

  return result;
}

/**
 * id 로 catalog 엔트리 조회.
 */
export function findCatalogEntry(
  id: FortuneTypeId,
): FortuneCatalogEntry | undefined {
  return FORTUNE_CATALOG.find((e) => e.id === id);
}
