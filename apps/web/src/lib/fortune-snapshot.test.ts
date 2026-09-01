import assert from 'node:assert/strict';
import test from 'node:test';

import {
  FORTUNE_SNAPSHOT_VERSION,
  projectFortuneSnapshot,
  readFortuneSnapshot,
} from './fortune-snapshot.ts';

test('결과 본문을 그대로 보존해서 다시 렌더할 수 있게 한다', () => {
  const snapshot = projectFortuneSnapshot('daily', {
    fortune: {
      score: 83,
      lucky_items: { number: '7', color: '골드' },
      categories: { total: { advice: { detail: '무리하지 말고 자연스럽게' } } },
    },
    cached: false,
  });

  assert.ok(snapshot);
  assert.equal(snapshot.fortuneType, 'daily');
  assert.equal(snapshot.version, FORTUNE_SNAPSHOT_VERSION);
  // 요약 투영과 달리 8개 하이라이트로 잘리지 않는다.
  const value = snapshot.value as { fortune: { lucky_items: Record<string, string> } };
  assert.equal(value.fortune.lucky_items.number, '7');
  assert.equal(value.fortune.lucky_items.color, '골드');
});

test('프롬프트·자격증명 계열 키는 저장하지 않는다', () => {
  const snapshot = projectFortuneSnapshot('daily', {
    fortune: { score: 70 },
    systemPrompt: '너는 이제부터',
    api_key: 'sk-live-xxxx',
    credentials: { password: 'hunter2' },
    controlAction: 'drop table',
  });

  assert.ok(snapshot);
  const encoded = JSON.stringify(snapshot);
  for (const leak of ['systemPrompt', 'api_key', 'credentials', 'controlAction', 'sk-live', 'hunter2']) {
    assert.ok(!encoded.includes(leak), `${leak} 가 스냅샷에 남았다`);
  }
  assert.ok(encoded.includes('70'));
});

test('함수·순환 참조처럼 직렬화할 수 없는 값은 통과하지 못한다', () => {
  const circular: Record<string, unknown> = { fortune: { score: 50 } };
  circular.self = circular;

  const snapshot = projectFortuneSnapshot('daily', circular);
  assert.ok(snapshot);
  // 깊이 상한에서 잘려 JSON 직렬화가 성공해야 한다.
  assert.doesNotThrow(() => JSON.stringify(snapshot));
});

test('상한을 넘기는 결과는 저장하지 않고 null 을 준다', () => {
  const huge = { fortune: { notes: Array.from({ length: 40 }, () => 'ㄱ'.repeat(4000)) } };
  assert.equal(projectFortuneSnapshot('daily', huge), null);
});

test('본문이 없으면 null 이라 요약만으로 계속 간다', () => {
  assert.equal(projectFortuneSnapshot('daily', {}), null);
  assert.equal(projectFortuneSnapshot('daily', null), null);
  assert.equal(projectFortuneSnapshot('daily', '문자열'), null);
});

test('스냅샷 이전에 저장된 행은 null 로 읽혀 폴백으로 넘어간다', () => {
  assert.equal(readFortuneSnapshot({ projectedSummary: { highlights: [], score: null } }), null);
  assert.equal(readFortuneSnapshot(null), null);
  assert.equal(readFortuneSnapshot({ snapshot: { version: 999, fortuneType: 'daily', value: {} } }), null);
});

test('저장한 스냅샷을 그대로 되읽는다', () => {
  const snapshot = projectFortuneSnapshot('daily', { fortune: { score: 83 } });
  assert.ok(snapshot);
  const restored = readFortuneSnapshot({ projectedSummary: {}, snapshot });
  assert.deepEqual(restored, snapshot);
});
