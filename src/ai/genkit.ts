import {genkit} from 'genkit';
import { openAI } from 'genkitx-openai';

export const ai = genkit({
  plugins: [
    openAI({
      apiKey: process.env.OPENAI_API_KEY || '',
    }),
  ],
  model: 'openai/gpt-4.1-nano',
  // flows 배열을 제거하여 Genkit CLI가 자동으로 플로우를 찾도록 합니다.
  // 이 방법으로 순환 종속성 문제를 해결합니다.
  // flows: {
  //   generateComprehensiveDailyFortune,
  //   generateLifeProfile,
  //   generateInteractiveFortune,
  // },
});
