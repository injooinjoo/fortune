'use server';

import { ai } from '@/ai/genkit';
import { z } from 'genkit';

const AnalyzeDreamInputSchema = z.object({
  dreamStory: z.string().min(1).describe('User provided dream text'),
});
export type AnalyzeDreamInput = z.infer<typeof AnalyzeDreamInputSchema>;

const AnalyzeDreamOutputSchema = z.object({
  analysis: z.string().describe('Dream interpretation result'),
});
export type AnalyzeDreamOutput = z.infer<typeof AnalyzeDreamOutputSchema>;

export async function analyzeDream(
  input: AnalyzeDreamInput
): Promise<AnalyzeDreamOutput> {
  return analyzeDreamFlow(input);
}

const prompt = ai.definePrompt({
  name: 'analyzeDreamPrompt',
  input: { schema: AnalyzeDreamInputSchema },
  output: { schema: AnalyzeDreamOutputSchema },
  prompt: `당신은 꿈의 상징을 꿰뚫어 보는 심리 분석가입니다. 다음은 사용자의 꿈 내용입니다: '{{{dreamStory}}}'. 이 꿈에 등장하는 핵심 상징(예: 물, 나는 행위, 쫓기는 상황)들을 찾아내고, 각 상징이 사용자의 현재 감정 상태(불안, 기대, 스트레스)나 현실의 고민과 어떻게 연결될 수 있는지 다각도로 분석해주세요. 단정적인 해설 대신, '이것은 ~를 의미할 수 있어요' 또는 '혹시 최근에 ~와 같은 경험을 하셨나요?'와 같이 사용자가 스스로를 돌아보게 하는 질문을 던지는 방식으로 부드럽게 접근해주세요. 마지막은 따뜻한 격려의 말로 마무리합니다.`,
});

const analyzeDreamFlow = ai.defineFlow(
  {
    name: 'analyzeDreamFlow',
    inputSchema: AnalyzeDreamInputSchema,
    outputSchema: AnalyzeDreamOutputSchema,
  },
  async (input) => {
    const { output } = await prompt(input);
    if (!output) {
      return { analysis: '죄송합니다. 현재 꿈 해석을 제공할 수 없습니다.' };
    }
    return output;
  }
);
