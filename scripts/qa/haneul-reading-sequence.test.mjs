import assert from 'node:assert/strict';
import { buildHaneulReadingSentences } from '../../apps/mobile-rn/src/features/fortune-results/fullscreen/haneul-reading-sequence.ts';

const payload = {
  title: '오늘의 운세',
  summary: '오늘은 서두르지 않을수록 좋아요. 급하게 결정하기보다, 한 번 더 보는 쪽이 운을 살려요.',
  highlights: [
    '사람 운은 오후에 더 열려요. 짧은 연락 하나가 생각보다 따뜻하게 돌아올 수 있어요.',
    '돈은 작은 새는 곳을 막는 날이에요.',
  ],
  recommendations: ['오늘의 키워드는 “천천히, 정확하게”.'],
  specialTip: '하늘이가 보기엔 충분히 괜찮은 하루예요.',
};

const sentences = buildHaneulReadingSentences(payload);

assert.equal(sentences.length, 5, '최대 5개의 리딩 문장으로 압축해야 한다');
assert.deepEqual(sentences.map((sentence) => sentence.id), [
  'reading-0',
  'reading-1',
  'reading-2',
  'reading-3',
  'reading-4',
]);
assert.equal(sentences[0].main, '오늘은 서두르지 않을수록 좋아요.');
assert.equal(sentences[0].sub, '급하게 결정하기보다, 한 번 더 보는 쪽이 운을 살려요.');
assert.equal(sentences[1].main, '사람 운은 오후에 더 열려요.');
assert.equal(sentences[1].sub, '짧은 연락 하나가 생각보다 따뜻하게 돌아올 수 있어요.');
assert.equal(sentences[4].main, '하늘이가 보기엔 충분히 괜찮은 하루예요.');
assert.equal(sentences[4].sub, undefined);

const fallback = buildHaneulReadingSentences({ title: '제목만 있는 결과' });
assert.ok(fallback.length >= 3, '본문이 부족해도 기본 리딩 문장을 제공해야 한다');
assert.ok(fallback.every((sentence) => sentence.main.length > 0), '빈 문장을 만들면 안 된다');

console.log('haneul-reading-sequence tests passed');
