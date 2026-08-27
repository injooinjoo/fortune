import assert from 'node:assert/strict';
import test from 'node:test';

import { sanitizeAnalyticsProperties } from './analytics.ts';

test('keeps only small non-PII analytics properties', () => {
  assert.deepEqual(
    sanitizeAnalyticsProperties({
      fortune_type: 'daily',
      outcome: 'success',
      email: 'private@example.com',
      message: 'private conversation',
      nested: { secret: true },
      duration_ms: 1200,
    }),
    {
      fortune_type: 'daily',
      outcome: 'success',
      duration_ms: 1200,
    },
  );
});

test('truncates values and rejects unknown keys', () => {
  assert.deepEqual(
    sanitizeAnalyticsProperties({
      path: `/${'a'.repeat(200)}`,
      unexpected: 'no',
      anonymous: true,
    }),
    { path: `/${'a'.repeat(119)}`, anonymous: true },
  );
});
