import { ai } from '@/ai/genkit';
import { z } from 'zod';

// Streaming fortune generation flow
export const generateFortuneFlow = ai.defineFlow(
  {
    name: 'generateFortuneFlow',
    inputSchema: z.object({ prompt: z.string() }),
    streamSchema: z.string(),
  },
  async function* ({ prompt }) {
    const { stream } = ai.generateStream({
      prompt: `Tell a fortune based on this: ${prompt}`,
      model: 'google/gemini-pro',
    });

    for await (const chunk of stream) {
      yield chunk.text;
    }
  }
);
