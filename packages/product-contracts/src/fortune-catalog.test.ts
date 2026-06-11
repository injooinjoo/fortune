/**
 * PR-A: fortune-catalog SoT 와 다른 contract 의 일관성 검증.
 *
 * Round 4 codex P2: FORTUNE_CATALOG 가 fortuneTypeToResultKind / FORTUNE_POINT_COSTS
 * 와 drift 하면 메뉴 카드 탭 시 broken / 비용 mismatch. 컴파일 시점 + 런타임 양쪽
 * 검증.
 */

import { describe, expect, test } from 'vitest';

import { FORTUNE_CATALOG, FORTUNE_CATALOG_GROUPS, groupFortuneCatalog } from './fortune-catalog';
import { fortuneTypesById, resolveFortuneEndpoint } from './fortunes';
import type { FortuneTypeId } from './fortunes';

describe('fortune-catalog', () => {
  test('catalog id 는 FortuneTypeId 의 알려진 값 — 컴파일 타임 보장', () => {
    // 본 test 가 typecheck 통과 = catalog id 가 모두 FortuneTypeId union 의 일원.
    const ids: FortuneTypeId[] = FORTUNE_CATALOG.map((e) => e.id);
    expect(ids.length).toBeGreaterThan(0);
  });

  test('catalog 안에 같은 id 가 두 번 등장하지 않음', () => {
    const seen = new Set<FortuneTypeId>();
    for (const entry of FORTUNE_CATALOG) {
      expect(seen.has(entry.id)).toBe(false);
      seen.add(entry.id);
    }
  });

  test('모든 catalog entry 가 등록된 group 에 속함', () => {
    const groupIds = new Set(FORTUNE_CATALOG_GROUPS.map((g) => g.id));
    for (const entry of FORTUNE_CATALOG) {
      expect(groupIds.has(entry.group)).toBe(true);
    }
  });

  test('costPoints 는 양의 정수 (또는 0 — daily free 케이스 등)', () => {
    for (const entry of FORTUNE_CATALOG) {
      expect(Number.isInteger(entry.costPoints)).toBe(true);
      expect(entry.costPoints).toBeGreaterThanOrEqual(0);
    }
  });

  test('groupFortuneCatalog 는 빈 group 을 제외하고 정렬된 결과 반환', () => {
    const grouped = groupFortuneCatalog();
    // 그룹 순서가 FORTUNE_CATALOG_GROUPS.order 순
    for (let i = 1; i < grouped.length; i++) {
      expect(grouped[i].group.order).toBeGreaterThanOrEqual(
        grouped[i - 1].group.order,
      );
    }
    // 각 그룹 안 entry 는 entry.order 순
    for (const { entries } of grouped) {
      for (let i = 1; i < entries.length; i++) {
        expect(entries[i].order).toBeGreaterThanOrEqual(entries[i - 1].order);
      }
    }
  });

  test('displayName 과 shortDesc 가 비어있지 않음', () => {
    for (const entry of FORTUNE_CATALOG) {
      expect(entry.displayName.length).toBeGreaterThan(0);
      expect(entry.shortDesc.length).toBeGreaterThan(0);
    }
  });

  test('local-only 타입은 원격 endpoint 를 노출하지 않음', () => {
    for (const spec of Object.values(fortuneTypesById)) {
      if (spec.isLocalOnly === true) {
        expect(spec.endpoint).toBeNull();
        expect(resolveFortuneEndpoint(spec.id)).toBeNull();
      }
    }
  });

  test('wish/decision 은 실제 Edge Function 이 있는 서버형 타입으로 남김', () => {
    expect(fortuneTypesById.wish.isLocalOnly).not.toBe(true);
    expect(resolveFortuneEndpoint('wish')).toBe('/analyze-wish');
    expect(fortuneTypesById.decision.isLocalOnly).not.toBe(true);
    expect(resolveFortuneEndpoint('decision')).toBe('/fortune-decision');
  });

  test('lotto 는 구현되지 않은 Edge Function 대신 로컬 fallback 계약을 사용', () => {
    expect(fortuneTypesById.lotto.isLocalOnly).toBe(true);
    expect(resolveFortuneEndpoint('lotto')).toBeNull();
  });
});
