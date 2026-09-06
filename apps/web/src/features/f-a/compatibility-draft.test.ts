import assert from 'node:assert/strict';
import test from 'node:test';

import {
  clearCompatibilityDraft,
  readCompatibilityDraft,
  writeCompatibilityDraft,
  type CompatibilityDraftStorage,
} from './compatibility-draft.ts';

function memoryStorage(): CompatibilityDraftStorage & { values: Map<string, string> } {
  const values = new Map<string, string>();
  return {
    values,
    getItem: (key) => values.get(key) ?? null,
    setItem: (key, value) => values.set(key, value),
    removeItem: (key) => values.delete(key),
  };
}

const draft = {
  firstName: '테스트A',
  firstBirthDate: '2000-02-29',
  secondName: '테스트B',
  secondBirthDate: '1999-01-01',
};

test('compatibility draft round-trips within the provided tab storage', () => {
  const storage = memoryStorage();

  writeCompatibilityDraft(storage, draft);

  assert.deepEqual(readCompatibilityDraft(storage), draft);
});

test('compatibility draft clears when all fields are empty or the reading succeeds', () => {
  const storage = memoryStorage();
  writeCompatibilityDraft(storage, draft);

  writeCompatibilityDraft(storage, {
    firstName: '',
    firstBirthDate: '',
    secondName: '',
    secondBirthDate: '',
  });
  assert.equal(readCompatibilityDraft(storage), null);

  writeCompatibilityDraft(storage, draft);
  clearCompatibilityDraft(storage);
  assert.equal(readCompatibilityDraft(storage), null);
});

test('compatibility draft rejects malformed stored values', () => {
  const storage = memoryStorage();
  storage.values.set('ondo:compatibility-draft', '{not-json');
  assert.equal(readCompatibilityDraft(storage), null);

  storage.values.set('ondo:compatibility-draft', JSON.stringify({ ...draft, secondName: 42 }));
  assert.equal(readCompatibilityDraft(storage), null);
});
