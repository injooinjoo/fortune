'use server'

import { ai } from '@/ai/genkit';
import { z } from 'genkit';

const PalmReadingInputSchema = z.object({
  labels: z
    .array(z.string())
    .min(1)
    .describe('Array of palm line classification labels from on-device model'),
});
export type PalmReadingInput = z.infer<typeof PalmReadingInputSchema>;

const PalmReadingOutputSchema = z.object({
  interpretation: z
    .string()
    .describe('Korean personalized palm reading interpretation for the user'),
});
export type PalmReadingOutput = z.infer<typeof PalmReadingOutputSchema>;

const prompt = ai.definePrompt({
  name: 'palmReadingPrompt',
  input: { schema: PalmReadingInputSchema },
  output: { schema: PalmReadingOutputSchema },
  config: { responseMimeType: 'application/json' },
  prompt: `사용자의 손금에서 다음 특징들이 발견되었어: {{{labels}}}. 너는 따뜻한 마음을 가진 손금 전문가야. 각 특징이 무엇을 의미하는지 쉽고 긍정적으로 설명하고, 이들을 종합하여 사용자의 성격, 재능, 그리고 앞으로 나아갈 길에 대한 희망적인 조언을 스토리텔링 형식으로 작성해 줘.`,
});

const palmReadingFlow = ai.defineFlow(
  {
    name: 'palmReadingFlow',
    inputSchema: PalmReadingInputSchema,
    outputSchema: PalmReadingOutputSchema,
  },
  async input => {
    const { output } = await prompt(input);
    if (!output) {
      throw new Error('AI did not return output');
    }
    return output;
  },
);

export async function generatePalmReading(
  input: PalmReadingInput,
): Promise<PalmReadingOutput> {
  return palmReadingFlow(input);
}
