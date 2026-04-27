import type {
  BranchRelation,
  BranchRelationsResult,
  FourPillars,
  InteractionEntry,
  InteractionType,
  PillarName,
  BranchKr,
} from '../types.ts';
import {
  SAM_HAP,
  YUK_HAP,
  BANG_HAP,
  YUK_CHUNG,
  SAM_HYUNG,
  SANG_HYUNG,
  JA_HYUNG,
  YUK_PA,
  YUK_HAE,
  WON_JIN,
  GUIMUN,
  pairMatches,
} from '../constants/interactions.ts';

const PILLAR_NAMES: PillarName[] = ['year', 'month', 'day', 'hour'];

function branchOf(p: FourPillars, name: PillarName): BranchKr {
  return p[name].branch.korean;
}

export function calculateInteractions(pillars: FourPillars): InteractionEntry[] {
  const result: InteractionEntry[] = [];

  // Pair-based checks (육합, 육충, 상형, 육파, 육해, 원진, 귀문)
  for (let i = 0; i < PILLAR_NAMES.length; i++) {
    for (let j = i + 1; j < PILLAR_NAMES.length; j++) {
      const nameA = PILLAR_NAMES[i]!;
      const nameB = PILLAR_NAMES[j]!;
      const brA = branchOf(pillars, nameA);
      const brB = branchOf(pillars, nameB);

      // 육합
      for (const h of YUK_HAP) {
        if (pairMatches(brA, brB, [h.pair])) {
          result.push({ pair: [nameA, nameB], branches: [brA, brB], type: '육합', resultElement: h.element });
          break;
        }
      }

      // 육충
      if (pairMatches(brA, brB, YUK_CHUNG)) {
        result.push({ pair: [nameA, nameB], branches: [brA, brB], type: '육충' });
      }

      // 상형 (자묘)
      if (pairMatches(brA, brB, SANG_HYUNG)) {
        result.push({ pair: [nameA, nameB], branches: [brA, brB], type: '삼형' });
      }

      // 육파
      if (pairMatches(brA, brB, YUK_PA)) {
        result.push({ pair: [nameA, nameB], branches: [brA, brB], type: '육파' });
      }

      // 육해
      if (pairMatches(brA, brB, YUK_HAE)) {
        result.push({ pair: [nameA, nameB], branches: [brA, brB], type: '육해' });
      }

      // 원진
      if (pairMatches(brA, brB, WON_JIN)) {
        result.push({ pair: [nameA, nameB], branches: [brA, brB], type: '원진' });
      }

      // 귀문
      if (pairMatches(brA, brB, GUIMUN)) {
        result.push({ pair: [nameA, nameB], branches: [brA, brB], type: '귀문' });
      }

      // 자형 (같은 지지가 2번 이상)
      if (brA === brB && JA_HYUNG.includes(brA)) {
        result.push({ pair: [nameA, nameB], branches: [brA, brB], type: '자형' });
      }
    }
  }

  // 삼합/방합: 전체합 + 반합(2개만 있어도) 감지
  const allBranches = PILLAR_NAMES.map((n) => branchOf(pillars, n));
  for (const h of SAM_HAP) {
    const matched = h.branches.filter((b) => allBranches.includes(b));
    if (matched.length >= 2) {
      // 첫 2개 매칭된 지지의 위치로 페어 구성
      const [b1, b2] = matched;
      if (b1 && b2) {
        const p1 = PILLAR_NAMES[allBranches.indexOf(b1)]!;
        const p2 = PILLAR_NAMES[allBranches.lastIndexOf(b2)]!;
        result.push({
          pair: [p1, p2],
          branches: [b1, b2],
          type: '삼합',
          resultElement: h.element,
        });
      }
    }
  }

  for (const h of BANG_HAP) {
    const present = h.branches.every((b) => allBranches.includes(b));
    if (present) {
      const positions = h.branches.map((b) => PILLAR_NAMES[allBranches.indexOf(b)]!);
      if (positions[0] && positions[1]) {
        result.push({
          pair: [positions[0], positions[1]],
          branches: [h.branches[0], h.branches[1]],
          type: '방합',
          resultElement: h.element,
        });
      }
    }
  }

  // 삼형 (3개 지지 동시 존재)
  for (const hy of SAM_HYUNG) {
    const present = hy.every((b) => allBranches.includes(b));
    if (present) {
      const positions = hy.map((b) => PILLAR_NAMES[allBranches.indexOf(b)]!);
      if (positions[0] && positions[1]) {
        result.push({
          pair: [positions[0], positions[1]],
          branches: [hy[0], hy[1]],
          type: '삼형',
        });
      }
    }
  }

  return result;
}

const SHORT_LABEL: Record<InteractionType, string> = {
  삼합: '합',
  육합: '합',
  방합: '방합',
  육충: '충',
  삼형: '형',
  자형: '형',
  육파: '파',
  육해: '해',
  원진: '원진',
  귀문: '귀문',
};

/**
 * 기둥별 상세 관계 리스트 계산.
 *
 * 각 기둥에 대해 자신을 제외한 다른 기둥들과의 모든 관계를 수집.
 * UI의 "합충형파해 상세 (노란 박스)"에 사용.
 */
export function calculateBranchRelations(
  pillars: FourPillars,
  interactions: InteractionEntry[],
): BranchRelationsResult {
  const empty = (): BranchRelation[] => [];
  const result: BranchRelationsResult = {
    year: empty(),
    month: empty(),
    day: empty(),
    hour: empty(),
  };

  const seenKey = new Set<string>();

  for (const entry of interactions) {
    const [a, b] = entry.pair;
    if (a === b) continue;

    const branchA = pillars[a].branch.korean;
    const branchB = pillars[b].branch.korean;

    const keyAB = `${a}->${b}:${entry.type}`;
    if (!seenKey.has(keyAB)) {
      seenKey.add(keyAB);
      result[a].push({
        target: b,
        targetBranchKr: branchB,
        type: entry.type,
        shortLabel: SHORT_LABEL[entry.type],
      });
    }

    const keyBA = `${b}->${a}:${entry.type}`;
    if (!seenKey.has(keyBA)) {
      seenKey.add(keyBA);
      result[b].push({
        target: a,
        targetBranchKr: branchA,
        type: entry.type,
        shortLabel: SHORT_LABEL[entry.type],
      });
    }
  }

  return result;
}
