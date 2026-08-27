import assert from 'node:assert/strict';
import test from 'node:test';

import {
  displayAccountName,
  normalizeBalance,
  normalizeFortuneHistory,
} from './account-data.ts';

test('uses Korean account labels without exposing an email address by default', () => {
  assert.equal(
    displayAccountName({
      email: 'private@example.com',
      user_metadata: { full_name: '인주' },
    }),
    '인주님',
  );
  assert.equal(displayAccountName({ email: 'private@example.com', user_metadata: {} }), '내 계정');
});

test('normalizes a missing or invalid balance to zero', () => {
  assert.equal(normalizeBalance({ balance: 45 }), 45);
  assert.equal(normalizeBalance({ balance: -3 }), 0);
  assert.equal(normalizeBalance(null), 0);
});

test('normalizes fortune history newest-first and falls back to a safe title', () => {
  assert.deepEqual(
    normalizeFortuneHistory([
      {
        id: 'older',
        fortune_type: 'daily',
        title: '',
        score: null,
        created_at: '2026-08-26T01:00:00.000Z',
      },
      {
        id: 'newer',
        fortune_type: 'love',
        title: '연애운',
        score: 88,
        created_at: '2026-08-27T01:00:00.000Z',
      },
    ]),
    [
      {
        id: 'newer',
        fortuneType: 'love',
        title: '연애운',
        score: 88,
        createdAt: '2026-08-27T01:00:00.000Z',
      },
      {
        id: 'older',
        fortuneType: 'daily',
        title: '운세 결과',
        score: null,
        createdAt: '2026-08-26T01:00:00.000Z',
      },
    ],
  );
});
