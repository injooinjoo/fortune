import type { EmbeddedResultPayload } from '../../chat-results/types';
import { buildReadingSentences } from './reading-sentences';

const basePayload: EmbeddedResultPayload = {
  widgetType: 'fortune_result_card',
  fortuneType: 'daily',
  resultKind: 'daily-calendar',
  eyebrow: '오늘의 운세',
  title: '오늘의 흐름',
  subtitle: '하늘이가 정리했어요',
  summary: '오늘은 서두르지 않을수록 좋아요. 중요한 말은 한 번 더 고르면 운이 살아나요.',
  score: 82,
  highlights: ['사람 운은 오후에 더 열려요.', '짧은 연락이 따뜻하게 돌아올 수 있어요.'],
  recommendations: ['큰 결정은 바로 확정하지 말고 한 번 더 확인해 보세요.'],
  warnings: ['지출은 작은 새는 곳부터 막는 게 좋아요.'],
  luckyItems: ['따뜻한 차', '파란색'],
  specialTip: '오늘의 키워드는 천천히, 정확하게예요.',
};

const sentences = buildReadingSentences(basePayload, 'daily-calendar');

if (sentences.length < 4) {
  throw new Error('reading sentences should include enough meaningful steps');
}

if (sentences.length > 7) {
  throw new Error('reading sentences should stay compact');
}

if (sentences.some(sentence => sentence.main.length > 64)) {
  throw new Error('reading sentence main text should stay short enough for fullscreen focus');
}

if (new Set(sentences.map(sentence => sentence.main)).size !== sentences.length) {
  throw new Error('reading sentences should be deduplicated');
}

const fallbackSentences = buildReadingSentences({
  ...basePayload,
  summary: '',
  highlights: [],
  recommendations: [],
  warnings: [],
  specialTip: undefined,
  luckyItems: [],
}, 'daily-calendar');

if (fallbackSentences.length < 2) {
  throw new Error('fallback should still produce a short reading sequence');
}
