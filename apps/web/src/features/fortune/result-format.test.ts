import assert from 'node:assert/strict';
import test from 'node:test';

import { createElement } from 'react';
import { renderToStaticMarkup } from 'react-dom/server';

import { ScoreSection } from './result.tsx';

test('multiline fortune advice renders labeled blocks and semantic bullet items', () => {
  const html = renderToStaticMarkup(
    createElement(ScoreSection, {
      label: '애정',
      score: 89,
      text: [
        '💫 애정운 바이브',
        '오늘은 먼저 말을 걸기 좋은 날이에요.',
        '',
        '🎯 실천 꿀팁',
        '• 답장을 미루지 않기',
        '• 취향을 묻는 질문 하나 건네기',
        '',
        '💬 오늘의 한마디',
        '기대해도 좋아요.',
      ].join('\n'),
    }),
  );

  assert.match(html, /ondo-result-copy-title[^>]*>💫 애정운 바이브</);
  assert.match(html, /<ul[^>]*class="ondo-result-copy-list"/);
  assert.match(html, /<li>답장을 미루지 않기<\/li>/);
  assert.match(html, /<li>취향을 묻는 질문 하나 건네기<\/li>/);
  assert.doesNotMatch(html, /<p class="ondo-muted">[\s\S]*• 답장을/);
});

test('plain one-line advice remains a simple paragraph', () => {
  const html = renderToStaticMarkup(
    createElement(ScoreSection, {
      label: '재물',
      score: 70,
      text: '필요한 소비부터 차분히 확인하세요.',
    }),
  );

  assert.match(html, /<p class="ondo-muted">필요한 소비부터 차분히 확인하세요.<\/p>/);
  assert.doesNotMatch(html, /ondo-result-copy-title|ondo-result-copy-list/);
});
