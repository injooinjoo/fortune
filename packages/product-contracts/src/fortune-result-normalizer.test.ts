import { describe, expect, it } from 'vitest';

import { normalizeFortuneResult } from './fortune-result-normalizer';

describe('normalizeFortuneResult', () => {
  it('unwraps wrapped payloads and legacy aliases', () => {
    const result = normalizeFortuneResult({
      success: true,
      data: {
        type: 'love',
        overallScore: 87,
        mainMessage: '새로운 사랑의 기회가 찾아와요.',
        summary: {
          one_line: '오늘은 감정에 솔직해질수록 좋아요.',
        },
        advice: ['대화를 먼저 열어보세요.'],
      },
    });

    expect(result.fortuneType).toBe('love');
    expect(result.score).toBe(87);
    expect(result.content).toContain('새로운 사랑의 기회');
    expect(result.summary).toBe('오늘은 감정에 솔직해질수록 좋아요.');
    expect(result.advice).toEqual(['대화를 먼저 열어보세요.']);
  });

  it('builds content from sections when content is absent', () => {
    const result = normalizeFortuneResult(
      {
        result: {
          fortune_type: 'moving',
          sections: [
            { title: '총평', content: '차분하게 준비할수록 좋은 흐름입니다.' },
            { title: '조언', description: '남향과 밝은 동선을 우선 보세요.' },
          ],
        },
      },
      { now: new Date('2026-04-06T00:00:00.000Z') },
    );

    expect(result.fortuneType).toBe('moving');
    expect(result.content).toContain('총평');
    expect(result.content).toContain('남향과 밝은 동선');
    expect(result.timestamp).toBe('2026-04-06T00:00:00.000Z');
  });
});
