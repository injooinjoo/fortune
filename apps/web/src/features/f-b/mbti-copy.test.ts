import assert from 'node:assert/strict';
import test from 'node:test';

import { getFortuneCostPoints } from '../../../../../packages/product-contracts/src/fortune-pricing.ts';

import { mbtiButtonLabel } from './mbti-copy.ts';

const cost = getFortuneCostPoints('mbti');

test('MBTI idle CTA discloses the current cost on list and direct-type routes', () => {
  assert.equal(
    mbtiButtonLabel({ costPoints: cost, loading: false }),
    `온도 ${cost}개로 오늘의 MBTI 운세 보기`,
  );
  assert.equal(
    mbtiButtonLabel({ costPoints: cost, loading: false, lockedMbti: 'INTJ' }),
    `온도 ${cost}개로 INTJ 오늘의 운세 보기`,
  );
});

test('MBTI loading CTA keeps the concise progress label', () => {
  assert.equal(mbtiButtonLabel({ costPoints: cost, loading: true }), '읽는 중…');
  assert.equal(
    mbtiButtonLabel({ costPoints: cost, loading: true, lockedMbti: 'INTJ' }),
    '읽는 중…',
  );
});
