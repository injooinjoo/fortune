import assert from 'node:assert/strict';
import test from 'node:test';

import { beginGoogleAuth } from './google-auth.ts';

type Call = { method: 'link' | 'sign-in'; redirectTo: string };

function fakeClient(isAnonymous: boolean | null) {
  const calls: Call[] = [];
  const client = {
    auth: {
      async getUser() {
        return {
          data: {
            user: isAnonymous === null ? null : { is_anonymous: isAnonymous },
          },
        };
      },
      async linkIdentity({ options }: { options: { redirectTo: string } }) {
        calls.push({ method: 'link', redirectTo: options.redirectTo });
        return { error: null };
      },
      async signInWithOAuth({ options }: { options: { redirectTo: string } }) {
        calls.push({ method: 'sign-in', redirectTo: options.redirectTo });
        return { error: null };
      },
    },
  };
  return { client, calls };
}

test('links Google identity onto an anonymous account', async () => {
  const { client, calls } = fakeClient(true);
  await beginGoogleAuth(client, 'https://zpzg.co.kr/auth/callback?next=%2Fapp');
  assert.deepEqual(calls, [
    { method: 'link', redirectTo: 'https://zpzg.co.kr/auth/callback?next=%2Fapp' },
  ]);
});

test('starts normal Google OAuth without an anonymous account', async () => {
  for (const state of [false, null]) {
    const { client, calls } = fakeClient(state);
    await beginGoogleAuth(client, 'https://zpzg.co.kr/auth/callback');
    assert.deepEqual(calls, [
      { method: 'sign-in', redirectTo: 'https://zpzg.co.kr/auth/callback' },
    ]);
  }
});
