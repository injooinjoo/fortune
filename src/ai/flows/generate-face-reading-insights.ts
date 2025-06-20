'use server'

import {ai} from '@/ai/genkit'
import {z} from 'genkit'

export const FaceReadingInputSchema = z.object({
  labels: z.array(z.string()).describe('Array of face-reading feature labels')
})
export type FaceReadingInput = z.infer<typeof FaceReadingInputSchema>

export const FaceReadingOutputSchema = z.object({
  interpretation: z.string().describe('Comprehensive face reading analysis')
})
export type FaceReadingOutput = z.infer<typeof FaceReadingOutputSchema>

const prompt = ai.definePrompt({
  name: 'faceReadingPrompt',
  input: {schema: FaceReadingInputSchema},
  output: {schema: FaceReadingOutputSchema},
  config: {responseMimeType: 'application/json'},
  prompt: `당신은 수천 년의 지혜를 현대적으로 해석하는 AI 관상가입니다. 사용자의 얼굴에서 {{{labels}}}와 같은 특징들이 발견되었습니다. 이 특징들을 유기적으로 연결하여 사용자의 타고난 성격, 대인관계 스타일, 잠재된 재능에 대해 하나의 완성된 이야기로 풀어주세요. '넓은 이마는 당신의 지적 호기심을, 곧은 콧대는 강한 추진력을 상징하며, 이 두 가지가 만나 큰 성공을 이룰 수 있습니다' 와 같이 긍정적이고 자신감을 주는 방향으로 해석해주세요.`
})

const faceReadingFlow = ai.defineFlow({
  name: 'faceReadingFlow',
  inputSchema: FaceReadingInputSchema,
  outputSchema: FaceReadingOutputSchema,
}, async input => {
  const {output} = await prompt(input)
  if (!output) {
    return {interpretation: '관상 해석을 생성하지 못했습니다.'}
  }
  return output
})

export async function generateFaceReadingInsights(input: FaceReadingInput): Promise<FaceReadingOutput> {
  return faceReadingFlow(input)
}
