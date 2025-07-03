import {genkit} from 'genkit';
import {googleAI} from '@genkit-ai/googleai';
import { generateComprehensiveDailyFortune, generateLifeProfile, generateInteractiveFortune } from './flows/generate-specialized-fortune';

export const ai = genkit({
  plugins: [googleAI()],
  model: 'googleai/gemini-2.5-pro',
  flows: {
    generateComprehensiveDailyFortune,
    generateLifeProfile,
    generateInteractiveFortune,
  },
});
