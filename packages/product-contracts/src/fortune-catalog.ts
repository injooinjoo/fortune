/**
 * 하늘이 운세 메뉴 카탈로그 — 클라이언트 정적 SoT.
 *
 * 디자인:
 * - 하늘이 채팅의 메뉴 카드 / quick-actions banner / AllFortunesSheet 그리드 가
 *   본 카탈로그를 정적 렌더 (LLM X).
 * - 매핑된 운세 54개 중 별칭 (zodiac/constellation/talisman/lotto/dream/chat-insight)
 *   과 메타 (view-all/profile-creation) 를 제외한 48개를 노출.
 * - `costPoints` 는 `fortune-pricing.ts` SoT 에서 lookup. 본 파일에 hardcode 금지.
 *   `fortune-pricing.test.ts` 가 catalog id 의 SoT 등록 + 가격 일치를 검증.
 *
 * 운영:
 * - 새 fortune-type 추가 시: catalog + fortuneTypeToResultKind + fortune-pricing 양쪽 업데이트.
 * - SoT 변경 → `pnpm sync:edge-pricing` → Edge 자동 동기화.
 */

import { FORTUNE_POINT_COSTS } from './fortune-pricing';
import type { FortuneTypeId } from './fortunes';

export type FortuneCatalogGroupId =
  | 'tarot_saju'
  | 'love'
  | 'career_money'
  | 'lifestyle'
  | 'premium_guide'
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
  /** SoT lookup 결과 — `fortune-pricing.ts` 의 FORTUNE_POINT_COSTS[id] 에서 자동 채움. */
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
  { id: 'tarot_saju',    label: '타로 · 사주',           order: 1 },
  { id: 'love',          label: '인연 · 사랑',           order: 2 },
  { id: 'career_money',  label: '일 · 돈',              order: 3 },
  { id: 'lifestyle',     label: '라이프',               order: 4 },
  { id: 'premium_guide', label: '프리미엄 가이드',         order: 5 },
  { id: 'health',        label: '건강 흐름',             order: 6 },
  { id: 'sports_game',   label: '경기 · 게임',           order: 7 },
  { id: 'meditation',    label: '명상 · 호흡',           order: 8 },
  { id: 'personality',   label: '성격 분석',             order: 9 },
  { id: 'coaching',      label: '코칭 · 일기',           order: 10 },
  { id: 'past_life',     label: '전생',                 order: 11 },
];

export const FORTUNE_CATALOG: ReadonlyArray<FortuneCatalogEntry> = [
  // === 타로 · 사주 ===
  { id: 'tarot',            displayName: '오늘의 타로',     shortDesc: '한 장의 카드로 오늘의 흐름을 읽어줘요',  group: 'tarot_saju',   costPoints: FORTUNE_POINT_COSTS.tarot,                 order: 1 },
  { id: 'traditional-saju', displayName: '전통 사주',       shortDesc: '오행 균형과 사주 포인트를 짚어줘요',     group: 'tarot_saju',   costPoints: FORTUNE_POINT_COSTS['traditional-saju'],    order: 2 },
  { id: 'daily',            displayName: '오늘의 운세',     shortDesc: '오늘 어떤 흐름이 있는지 짧게 봐줘요',     group: 'tarot_saju',   costPoints: FORTUNE_POINT_COSTS.daily,                 order: 3 },
  { id: 'daily-calendar',   displayName: '오늘의 만세력',   shortDesc: '날짜 흐름과 절기를 짧게 짚어줘요',       group: 'tarot_saju',   costPoints: FORTUNE_POINT_COSTS['daily-calendar'],     order: 4 },
  { id: 'naming',           displayName: '사주 작명',       shortDesc: '오행 분석으로 어울리는 이름을 짚어줘요',  group: 'tarot_saju',   costPoints: FORTUNE_POINT_COSTS.naming,                order: 5 },
  { id: 'new-year',         displayName: '새해 인사이트',   shortDesc: '한 해 흐름을 미리 종합해서 짚어줘요',     group: 'tarot_saju',   costPoints: FORTUNE_POINT_COSTS['new-year'],           order: 6 },

  // === 인연 · 사랑 ===
  { id: 'love',              displayName: '연애운',           shortDesc: '오늘의 연애 흐름과 표현 타이밍을 봐줘요',  group: 'love',  costPoints: FORTUNE_POINT_COSTS.love,                 order: 1 },
  { id: 'compatibility',     displayName: '궁합',             shortDesc: '두 사람의 리듬과 대화 온도를 읽어줘요',    group: 'love',  costPoints: FORTUNE_POINT_COSTS.compatibility,         order: 2 },
  { id: 'blind-date',        displayName: '소개팅운',         shortDesc: '첫인상과 대화 리듬을 짚어줘요',          group: 'love',  costPoints: FORTUNE_POINT_COSTS['blind-date'],         order: 3 },
  { id: 'ex-lover',          displayName: '재회운',           shortDesc: '재접점 가능성과 감정 흐름을 짚어줘요',     group: 'love',  costPoints: FORTUNE_POINT_COSTS['ex-lover'],           order: 4 },
  { id: 'avoid-people',      displayName: '피해야 할 인연',   shortDesc: '관계 경계 신호를 미리 짚어줘요',          group: 'love',  costPoints: FORTUNE_POINT_COSTS['avoid-people'],       order: 5 },
  { id: 'yearly-encounter',  displayName: '올해의 인연',      shortDesc: '만남 장소와 시그널을 봐줘요',            group: 'love',  costPoints: FORTUNE_POINT_COSTS['yearly-encounter'],   order: 6 },
  { id: 'celebrity',         displayName: '셀럽 궁합',        shortDesc: '좋아하는 셀럽과의 사주 케미를 봐줘요',     group: 'love',  costPoints: FORTUNE_POINT_COSTS.celebrity,             order: 7 },
  { id: 'blind-date-guide',  displayName: '소개팅 가이드',    shortDesc: '옷·헤어·말투까지 종합 코칭',             group: 'love',  costPoints: FORTUNE_POINT_COSTS['blind-date-guide'],   order: 8 },
  { id: 'family',            displayName: '가족운',           shortDesc: '가족 하모니와 관계 팁을 짚어줘요',         group: 'love',  costPoints: FORTUNE_POINT_COSTS.family,                order: 9 },
  { id: 'pet-compatibility', displayName: '반려동물 궁합',    shortDesc: '오늘의 반려 케미와 교감 미션',           group: 'love',  costPoints: FORTUNE_POINT_COSTS['pet-compatibility'],  order: 10 },

  // === 일 · 돈 ===
  { id: 'career', displayName: '직업운',     shortDesc: '커리어 흐름과 실행 팁을 짚어줘요',     group: 'career_money', costPoints: FORTUNE_POINT_COSTS.career, order: 1 },
  { id: 'exam',   displayName: '시험운',     shortDesc: '집중 타이밍과 실전 전략을 짚어줘요',   group: 'career_money', costPoints: FORTUNE_POINT_COSTS.exam,   order: 2 },
  { id: 'talent', displayName: '숨은 재능', shortDesc: '재능 축과 성장 로드맵을 짚어줘요',     group: 'career_money', costPoints: FORTUNE_POINT_COSTS.talent, order: 3 },
  { id: 'wealth', displayName: '재물운',     shortDesc: '금전 흐름과 머니 인사이트를 짚어줘요', group: 'career_money', costPoints: FORTUNE_POINT_COSTS.wealth, order: 4 },

  // === 라이프 ===
  { id: 'moving',           displayName: '이사 인사이트',   shortDesc: '방위 길흉과 풍수 배치를 짚어줘요',     group: 'lifestyle', costPoints: FORTUNE_POINT_COSTS.moving,             order: 1 },
  { id: 'lucky-items',      displayName: '행운 아이템',     shortDesc: '오늘의 색·숫자·패션·음식 종정리',     group: 'lifestyle', costPoints: FORTUNE_POINT_COSTS['lucky-items'],     order: 2 },
  { id: 'ootd-evaluation',  displayName: 'OOTD 점검',       shortDesc: '오늘 코디 점수와 추천 포인트',         group: 'lifestyle', costPoints: FORTUNE_POINT_COSTS['ootd-evaluation'], order: 3 },
  { id: 'fortune-cookie',   displayName: '포춘 쿠키',       shortDesc: '한 줄로 오늘의 메시지를 받아봐요',     group: 'lifestyle', costPoints: FORTUNE_POINT_COSTS['fortune-cookie'],  order: 4 },
  { id: 'birthstone',       displayName: '탄생석',          shortDesc: '월별·일별 탄생석 인사이트',           group: 'lifestyle', costPoints: FORTUNE_POINT_COSTS.birthstone,         order: 5 },

  // === 프리미엄 가이드 (이미지 / 헤비 보고서) ===
  { id: 'face-reading',        displayName: '관상 분석',     shortDesc: '얼굴형·오관·삼정 종합 분석',       group: 'premium_guide', costPoints: FORTUNE_POINT_COSTS['face-reading'],         order: 1 },
  { id: 'palm-reading',        displayName: '손금 가이드',   shortDesc: '내 손바닥 주요 손금을 풀어줘요',   group: 'premium_guide', costPoints: FORTUNE_POINT_COSTS['palm-reading'],         order: 2 },
  { id: 'beauty-simulation',   displayName: '뷰티 시뮬',     shortDesc: '내 얼굴 사진으로 스타일링 비교',   group: 'premium_guide', costPoints: FORTUNE_POINT_COSTS['beauty-simulation'],    order: 3 },
  { id: 'hair-style-guide',    displayName: '헤어 가이드',   shortDesc: '얼굴형에 어울리는 10가지 스타일', group: 'premium_guide', costPoints: FORTUNE_POINT_COSTS['hair-style-guide'],     order: 4 },
  { id: 'face-reading-guide',  displayName: '얼굴 인상',     shortDesc: '눈·코·입·분위기 인상 리포트',     group: 'premium_guide', costPoints: FORTUNE_POINT_COSTS['face-reading-guide'],   order: 5 },
  { id: 'ootd-guide',          displayName: 'OOTD 가이드',   shortDesc: '내 옷 색감·톤·상황 적합도',       group: 'premium_guide', costPoints: FORTUNE_POINT_COSTS['ootd-guide'],           order: 6 },
  { id: 'past-life-guide',     displayName: '전생 리포트',   shortDesc: '시대·역할·교훈을 한 장에',         group: 'premium_guide', costPoints: FORTUNE_POINT_COSTS['past-life-guide'],      order: 7 },
  { id: 'wish',                displayName: '소원 부적',     shortDesc: '소원과 실행 포인트를 함께 봐요',   group: 'premium_guide', costPoints: FORTUNE_POINT_COSTS.wish,                    order: 8 },

  // === 건강 흐름 ===
  { id: 'health',    displayName: '건강 흐름',   shortDesc: '컨디션과 주의해야 할 부분을 짚어줘요',  group: 'health', costPoints: FORTUNE_POINT_COSTS.health,    order: 1 },
  { id: 'biorhythm', displayName: '바이오리듬',  shortDesc: '몸·마음·지성 리듬의 위치를 알려줘요',   group: 'health', costPoints: FORTUNE_POINT_COSTS.biorhythm, order: 2 },
  { id: 'exercise',  displayName: '운동 인사이트', shortDesc: '추천 루틴과 컨디션 경고',            group: 'health', costPoints: FORTUNE_POINT_COSTS.exercise,  order: 3 },

  // === 경기 · 게임 ===
  { id: 'match-insight', displayName: '경기 인사이트', shortDesc: '오늘 경기에서 살릴 흐름을 봐줘요', group: 'sports_game', costPoints: FORTUNE_POINT_COSTS['match-insight'], order: 1 },
  { id: 'game-enhance',  displayName: '게임 인사이트', shortDesc: '게임 컨디션과 흐름을 봐줘요',     group: 'sports_game', costPoints: FORTUNE_POINT_COSTS['game-enhance'],  order: 2 },

  // === 명상 · 호흡 ===
  { id: 'breathing', displayName: '호흡 · 명상', shortDesc: '지금 어떤 호흡 흐름이 좋을지 안내해요', group: 'meditation', costPoints: FORTUNE_POINT_COSTS.breathing, order: 1 },

  // === 성격 분석 ===
  { id: 'personality-dna', displayName: '성격 분석',  shortDesc: '나만의 성격 DNA 를 짚어줘요',     group: 'personality', costPoints: FORTUNE_POINT_COSTS['personality-dna'], order: 1 },
  { id: 'mbti',            displayName: 'MBTI 운세',  shortDesc: 'MBTI 별 흐름을 짧게 봐줘요',     group: 'personality', costPoints: FORTUNE_POINT_COSTS.mbti,               order: 2 },
  { id: 'blood-type',      displayName: '혈액형',     shortDesc: '혈액형별 성향과 궁합',           group: 'personality', costPoints: FORTUNE_POINT_COSTS['blood-type'],      order: 3 },
  { id: 'zodiac-animal',   displayName: '띠별 운세',  shortDesc: '띠별 흐름과 오늘의 타이밍',     group: 'personality', costPoints: FORTUNE_POINT_COSTS['zodiac-animal'],   order: 4 },

  // === 코칭 · 일기 ===
  { id: 'coaching',      displayName: '코치 분석',   shortDesc: '대화에서 보인 흐름을 코치처럼 짚어줘요', group: 'coaching', costPoints: FORTUNE_POINT_COSTS.coaching,         order: 1 },
  { id: 'daily-review',  displayName: '오늘의 회고', shortDesc: '하루를 돌아보고 한 줄 정리해줘요',     group: 'coaching', costPoints: FORTUNE_POINT_COSTS['daily-review'],   order: 2 },
  { id: 'weekly-review', displayName: '주간 회고',   shortDesc: '한 주를 돌아보고 다음 주로 이어요',    group: 'coaching', costPoints: FORTUNE_POINT_COSTS['weekly-review'],  order: 3 },
  { id: 'decision',      displayName: '의사결정',     shortDesc: '선택 기준과 실행 순서를 정리',       group: 'coaching', costPoints: FORTUNE_POINT_COSTS.decision,          order: 4 },

  // === 전생 ===
  { id: 'past-life', displayName: '전생 이야기', shortDesc: '전생에서 이어진 흐름을 짚어줘요', group: 'past_life', costPoints: FORTUNE_POINT_COSTS['past-life'], order: 1 },
];

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
