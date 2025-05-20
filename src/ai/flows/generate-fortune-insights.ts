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
  fortuneTypes: z
    .array(z.string())
    .describe(
      'An array of fortune types requested by the user (사주팔자, MBTI, 띠운세, 별운세, 연애운, 결혼운, 취업운, etc.).'
    ),
});
export type GenerateFortuneInsightsInput = z.infer<
  typeof GenerateFortuneInsightsInputSchema
>;

const GenerateFortuneInsightsOutputSchema = z.object({
  insights: z
    .record(z.string(), z.string())
    .describe(
      'A record of fortune type to corresponding insights, where keys are fortune types and values are the insights.'
    ),
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
  prompt: `You are an expert fortune teller specializing in 사주팔자, MBTI, 띠운세, 별운세, 연애운, 결혼운, and 취업운.

You will use the user's birthdate and MBTI to generate personalized fortune insights for the requested fortune types.

Birthdate: {{{birthdate}}}
MBTI: {{{mbti}}}

Fortune Types: {{#each fortuneTypes}}{{{this}}}{{#unless @last}}, {{/unless}}{{/each}}

Generate insights for each fortune type requested. Return the insights in JSON format.

Ensure that the keys in the JSON correspond exactly to the fortune types requested.
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
    return output!;
  }
);
