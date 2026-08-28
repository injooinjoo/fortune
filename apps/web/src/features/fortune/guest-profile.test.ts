import assert from 'node:assert/strict';
import test from 'node:test';

import {
  calculateAge,
  createBirthYearOptions,
  daysInMonth,
  joinBirthDate,
  splitBirthDate,
} from './guest-profile.ts';

test('연도 선택은 전체 범위를 오름차순으로 유지하고 1990 포커스를 포함한다', () => {
  const years = createBirthYearOptions(2026);
  assert.deepEqual(years.slice(0, 4), [1900, 1901, 1902, 1903]);
  assert.equal(years[90], 1990);
  assert.equal(years.at(-1), 2026);
});

test('월별 일수와 윤년을 반영해 유효한 생년월일만 만든다', () => {
  assert.equal(daysInMonth(2000, 2), 29);
  assert.equal(daysInMonth(1990, 2), 28);
  assert.equal(joinBirthDate('1990', '2', '28'), '1990-02-28');
  assert.equal(joinBirthDate('1990', '2', '29'), '');
  assert.deepEqual(splitBirthDate('1990-02-28'), { year: '1990', month: '2', day: '28' });
});

test('생년월일에서 생일 경계를 반영한 만 나이를 계산한다', () => {
  assert.equal(calculateAge('1990-08-28', new Date('2026-08-28T12:00:00Z')), 36);
  assert.equal(calculateAge('1990-08-29', new Date('2026-08-28T12:00:00Z')), 35);
  assert.equal(calculateAge('', new Date('2026-08-28T12:00:00Z')), null);
});
