
'use server';

/**
 * @fileOverview AI agent for generating personalized fortune insights.
 *
 * - generateFortuneInsights - A function that generates fortune insights based on user profile information.
 * - GenerateFortuneInsightsInput - The input type for the generateFortuneInsights function.
 * - GenerateFortuneInsightsOutput - The return type for the generateFortuneInsights function.
 */

import {ai} from '@/ai/genkit';
import {z} from 'genkit';

const GenerateFortuneInsightsInputSchema = z.object({
  birthdate: z
    .string()
    .describe('The user birthdate in ISO format (YYYY-MM-DD).'),
  mbti: z.string().describe('The user MBTI type.'),
  gender: z.string().describe('User gender (e.g., 남성, 여성, 선택 안함).'),
  birthTime: z.string().describe('User birth time (e.g., 자시 (23:30 ~ 01:29), 모름).'),
  fortuneTypes: z
    .array(z.string())
    .describe(
      'An array of fortune types requested by the user (사주팔자, MBTI, 띠운세, 별운세, 연애운, 결혼운, 취업운, etc.).'
    ),
});
export type GenerateFortuneInsightsInput = z.infer<
  typeof GenerateFortuneInsightsInputSchema
>;

const FortuneInsightItemSchema = z.object({
  fortuneType: z.string().describe("The type of fortune, e.g., '사주팔자', matching one of the requested types."),
  insightText: z.string().describe("The personalized fortune insight text for this specific type."),
});

const GenerateFortuneInsightsOutputSchema = z.object({
  insights: z.array(FortuneInsightItemSchema)
    .describe('A list of fortune insights, where each item corresponds to one of the requested fortune types and contains the fortuneType and its insightText.'),
});
export type GenerateFortuneInsightsOutput = z.infer<
  typeof GenerateFortuneInsightsOutputSchema
>;

export async function generateFortuneInsights(
  input: GenerateFortuneInsightsInput
): Promise<GenerateFortuneInsightsOutput> {
  return generateFortuneInsightsFlow(input);
}

const prompt = ai.definePrompt({
  name: 'generateFortuneInsightsPrompt',
  input: {schema: GenerateFortuneInsightsInputSchema},
  output: {schema: GenerateFortuneInsightsOutputSchema},
  config: {
    responseMimeType: 'application/json', // Explicitly request JSON output
  },
  prompt: `You are an expert fortune teller specializing in 사주팔자, MBTI, 띠운세, 별자리운세, 연애운, 결혼운, and 취업운.

You will use the user's birthdate, MBTI, gender, and birth time to generate personalized fortune insights for the requested fortune types.

User Profile:
Birthdate: {{{birthdate}}}
MBTI: {{{mbti}}}
Gender: {{{gender}}}
Birth Time: {{{birthTime}}}

Requested Fortune Types: {{#each fortuneTypes}}"{{{this}}}"{{#unless @last}}, {{/unless}}{{/each}}

Generate insights for each of the requested Fortune Types.
Return the result as a JSON object with a single key "insights".
The value of "insights" MUST be an array of objects.
Each object in the array MUST have exactly two keys:
1.  "fortuneType": A string, which MUST be one of the "Requested Fortune Types" listed above.
2.  "insightText": A string, containing the personalized fortune insight for that fortuneType.

Example of one item in the "insights" array:
{
  "fortuneType": "사주팔자",
  "insightText": "..."
}

Ensure you generate one object in the "insights" array for each of the "Requested Fortune Types".
The output must be valid JSON that strictly adheres to this structure.
`,
});

const generateFortuneInsightsFlow = ai.defineFlow(
  {
    name: 'generateFortuneInsightsFlow',
    inputSchema: GenerateFortuneInsightsInputSchema,
    outputSchema: GenerateFortuneInsightsOutputSchema,
  },
  async input => {
    const {output} = await prompt(input);
    if (!output || !output.insights) {
      // This case should ideally be handled by Zod schema validation if the model returns completely wrong structure
      // or if the output is null.
      console.error("AI output is null or insights array is missing. Input was:", input);
      // Construct a valid empty response or a response indicating error for each type
      const errorInsights = input.fortuneTypes.map(type => ({
        fortuneType: type,
        insightText: "죄송합니다, 현재 이 운세에 대한 정보를 생성할 수 없습니다."
      }));
      return { insights: errorInsights };
    }
    return output;
  }
);
