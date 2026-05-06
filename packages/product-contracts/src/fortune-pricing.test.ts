/**
 * Fortune 가격 SoT consistency test.
 *
 * - FORTUNE_CATALOG 의 모든 id 가 SoT (FORTUNE_POINT_COSTS) 에 존재 — drift 차단.
 * - catalog.costPoints 가 SoT[id] 와 정확히 일치 — 클라/Edge 가격 표시 = 실제 차감.
 * - SoT 키가 모두 양의 정수 — 가격 무결성.
 * - Edge generated 파일이 SoT 본문과 동일 — 클라 SoT 변경 시 codegen 미실행 차단.
 *
 * Edge 측 sync 검증 (generated 파일 ↔ SoT) 은 `pnpm check:edge-pricing` 도 담당하지만
 * 본 test 가 vitest 단위에서도 같은 검증을 통과시켜 PR 에서 빠르게 fail.
 */

import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

import { describe, expect, test } from 'vitest';

import { FORTUNE_CATALOG } from './fortune-catalog';
import { FORTUNE_POINT_COSTS } from './fortune-pricing';

describe('fortune-pricing SoT', () => {
  test('catalog 의 모든 id 가 SoT 에 존재한다 (drift 차단)', () => {
    for (const entry of FORTUNE_CATALOG) {
      expect(
        Object.prototype.hasOwnProperty.call(FORTUNE_POINT_COSTS, entry.id),
        `catalog id "${entry.id}" 가 FORTUNE_POINT_COSTS 에 없음 — SoT 등록 필요`,
      ).toBe(true);
    }
  });

  test('catalog.costPoints 가 SoT[id] 와 정확히 일치 (표시 = 차감)', () => {
    for (const entry of FORTUNE_CATALOG) {
      const sotCost = (FORTUNE_POINT_COSTS as Record<string, number>)[entry.id];
      expect(
        entry.costPoints,
        `catalog "${entry.id}" 의 costPoints (${entry.costPoints}) 가 SoT (${sotCost}) 와 다름 — fortune-catalog.ts 가 SoT lookup 사용 중인지 확인`,
      ).toBe(sotCost);
    }
  });

  test('SoT 의 모든 가격이 양의 정수 (또는 0 — daily free 케이스)', () => {
    for (const [key, value] of Object.entries(FORTUNE_POINT_COSTS)) {
      expect(Number.isInteger(value), `SoT key "${key}" 의 값이 정수 아님: ${value}`).toBe(true);
      expect(value, `SoT key "${key}" 의 값이 음수`).toBeGreaterThanOrEqual(0);
    }
  });

  test('SoT 의 모든 가격이 6단계 (0/1/5/12/25/50) 중 하나 — 가격 계층 일관성', () => {
    const ALLOWED_TIERS = new Set([0, 1, 5, 12, 25, 50]);
    for (const [key, value] of Object.entries(FORTUNE_POINT_COSTS)) {
      expect(
        ALLOWED_TIERS.has(value),
        `SoT key "${key}" 의 값 ${value} 이 표준 가격 계층 (0/1/5/12/25/50) 외부`,
      ).toBe(true);
    }
  });

  test('Edge generated 파일이 SoT 본문을 그대로 포함 — codegen 동기화', () => {
    // packages/product-contracts/src/ → 프로젝트 root 까지 3 단계 위.
    const repoRoot = resolve(__dirname, '../../..');
    const sourcePath = resolve(repoRoot, 'packages/product-contracts/src/fortune-pricing.ts');
    const generatedPath = resolve(repoRoot, 'supabase/functions/_shared/fortune-pricing-generated.ts');

    const sourceBody = readFileSync(sourcePath, 'utf-8');
    const generatedBody = readFileSync(generatedPath, 'utf-8');

    // generated 는 헤더 (// AUTO-GENERATED ... 등) 다음에 source 를 그대로 가짐.
    // 즉 source 가 generated 의 suffix 여야 한다.
    expect(
      generatedBody.endsWith(sourceBody),
      'fortune-pricing-generated.ts 가 fortune-pricing.ts 와 동기화되지 않음. `pnpm sync:edge-pricing` 실행 후 generated 파일 commit 필요.',
    ).toBe(true);
  });
});
