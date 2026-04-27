/**
 * 간단한 self-check 테스트 러너.
 *
 * 실행:
 *   node --experimental-strip-types __tests__/run-tests.ts
 *   또는: npx tsx __tests__/run-tests.ts
 */

import { calculateSaju } from '../src/index.ts';
import { FIXTURE_1988 } from './fixtures.ts';

let passed = 0;
let failed = 0;
const failures: string[] = [];

function assert(cond: boolean, msg: string): void {
  if (cond) {
    passed++;
  } else {
    failed++;
    failures.push(msg);
    console.error(`  ❌ ${msg}`);
  }
}

function assertEq<T>(actual: T, expected: T, msg: string): void {
  const ok = JSON.stringify(actual) === JSON.stringify(expected);
  if (ok) {
    passed++;
  } else {
    failed++;
    failures.push(`${msg}: expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`);
    console.error(`  ❌ ${msg}`);
    console.error(`     expected: ${JSON.stringify(expected)}`);
    console.error(`     actual:   ${JSON.stringify(actual)}`);
  }
}

function runBenchmark1988(): void {
  const fx = FIXTURE_1988;
  console.log(`\n🧪 ${fx.name}`);
  const r = calculateSaju(fx.input, fx.opts);

  // Pillars
  assertEq(r.pillars.year.stem.korean, fx.expected.pillars.year.stem, '년간');
  assertEq(r.pillars.year.branch.korean, fx.expected.pillars.year.branch, '년지');
  assertEq(r.pillars.month.stem.korean, fx.expected.pillars.month.stem, '월간');
  assertEq(r.pillars.month.branch.korean, fx.expected.pillars.month.branch, '월지');
  assertEq(r.pillars.day.stem.korean, fx.expected.pillars.day.stem, '일간');
  assertEq(r.pillars.day.branch.korean, fx.expected.pillars.day.branch, '일지');
  assertEq(r.pillars.hour.stem.korean, fx.expected.pillars.hour.stem, '시간');
  assertEq(r.pillars.hour.branch.korean, fx.expected.pillars.hour.branch, '시지');

  // Elements
  assertEq(r.elements.wood, fx.expected.elements.wood, '오행 목');
  assertEq(r.elements.fire, fx.expected.elements.fire, '오행 화');
  assertEq(r.elements.earth, fx.expected.elements.earth, '오행 토');
  assertEq(r.elements.metal, fx.expected.elements.metal, '오행 금');
  assertEq(r.elements.water, fx.expected.elements.water, '오행 수');

  // Voids
  assertEq([...r.voids.day], fx.expected.voidDay, '공망 (일주)');
  assertEq([...r.voids.year], fx.expected.voidYear, '공망 (년주)');

  // Luck cycles
  assertEq(r.luckCycles.startAge, fx.expected.luckStartAge, '대운수');
  assertEq(r.luckCycles.direction, fx.expected.luckDirection, '대운 방향');

  // NapEum
  assertEq(r.napEum.year, fx.expected.napEum.year, '납음 (년)');
  assertEq(r.napEum.month, fx.expected.napEum.month, '납음 (월)');
  assertEq(r.napEum.day, fx.expected.napEum.day, '납음 (일)');
  assertEq(r.napEum.hour, fx.expected.napEum.hour, '납음 (시)');

  // Stars (벤치마크 기대: 년=[백호살], 월=[태극귀인,홍염살,관귀학관,현침살], 일=[협록,천덕귀인], 시=[암록,양인살,협록,천덕귀인,백호살])
  console.log(`\n📊 신살 계산 결과:`);
  console.log(`  year: ${JSON.stringify(r.stars.year)}`);
  console.log(`  month: ${JSON.stringify(r.stars.month)}`);
  console.log(`  day: ${JSON.stringify(r.stars.day)}`);
  console.log(`  hour: ${JSON.stringify(r.stars.hour)}`);

  const expectedStars = {
    year: ['백호살'],
    month: ['태극귀인', '홍염살', '관귀학관', '현침살'],
    day: ['협록', '천덕귀인'],
    hour: ['암록', '양인살', '협록', '천덕귀인', '백호살'],
  };
  let starMatches = 0;
  let starTotal = 0;
  for (const key of ['year', 'month', 'day', 'hour'] as const) {
    for (const s of expectedStars[key]) {
      starTotal++;
      if (r.stars[key].includes(s as never)) starMatches++;
    }
  }
  const rate = starTotal > 0 ? (starMatches / starTotal) * 100 : 0;
  console.log(`\n⭐ 신살 일치율: ${starMatches}/${starTotal} (${rate.toFixed(0)}%)`);
  assert(rate >= 80, `신살 일치율 80% 이상 (${rate.toFixed(0)}%)`);

  // Interactions (벤치마크: 진-해 원진+귀문, 신-진 삼합)
  const hasWonjin = r.interactions.some((i) => i.type === '원진' && i.branches.includes('진') && i.branches.includes('해'));
  const hasGuimun = r.interactions.some((i) => i.type === '귀문' && i.branches.includes('진') && i.branches.includes('해'));
  const hasSamhap = r.interactions.some((i) => i.type === '삼합' && (i.branches.includes('신') || i.branches.includes('진')));
  assert(hasWonjin, '관계: 진해 원진');
  assert(hasGuimun, '관계: 진해 귀문');
  assert(hasSamhap, '관계: 신자진 삼합 (부분)');
}

runBenchmark1988();

console.log(`\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`);
console.log(`Summary: ${passed} passed, ${failed} failed`);
if (failed > 0) {
  console.error(`\nFailed assertions:`);
  for (const f of failures) console.error(`  - ${f}`);
  process.exit(1);
}
console.log(`✅ All tests passed\n`);
