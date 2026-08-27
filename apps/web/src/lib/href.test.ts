import assert from 'node:assert/strict';
import test from 'node:test';

import { requiresNativeNavigation } from './href.ts';

test('uses native navigation when the current or destination pathname contains Korean segments', () => {
  assert.equal(requiresNativeNavigation('/', '/%EC%9A%B4%EC%84%B8'), true);
  assert.equal(requiresNativeNavigation('/운세', '/support'), true);
  assert.equal(requiresNativeNavigation('/support', '/terms'), false);
});
