
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

const MBTI_TYPES = [
  'INTJ',
  'INTP',
  'ENTJ',
  'ENTP',
  'INFJ',
  'INFP',
  'ENFJ',
  'ENFP',
  'ISTJ',
  'ISFJ',
  'ESTJ',
  'ESFJ',
  'ISTP',
  'ISFP',
  'ESTP',
  'ESFP',
] as const;

const GenerateFortuneInsightsInputSchema = z.object({
  birthdate: z
    .string()
    .min(1, { message: 'birthdate cannot be empty' })
    .regex(/^\d{4}-\d{2}-\d{2}$/, {
      message: 'birthdate must be in YYYY-MM-DD format',
    })
    .describe('The user birthdate in ISO format (YYYY-MM-DD).'),
  mbti: z
    .enum(MBTI_TYPES)
    .describe('The user MBTI type (one of the 16 valid four-letter codes).'),
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

// Schema for Saju Palja (Four Pillars) data
const SajuPillarInfoSchema = z.object({
  label: z.string().describe("해당 주의 이름 (예: 시주, 일주, 월주, 년주)"),
  heavenlyStem: z.string().describe("천간 한자 (예: 壬). 출생 시간을 모를 경우 시주는 '모름' 또는 빈 값."),
  heavenlyStemElement: z.string().describe("천간 오행 (한자, 한글 형식 예: 水, 물). 출생 시간을 모를 경우 시주는 '모름' 또는 빈 값."),
  earthlyBranch: z.string().describe("지지 한자 (예: 子). 출생 시간을 모를 경우 시주는 '모름' 또는 빈 값."),
  earthlyBranchElement: z.string().describe("지지 오행 (한자, 한글 형식 예: 水, 물). 출생 시간을 모를 경우 시주는 '모름' 또는 빈 값."),
  sibsin: z.string().describe("해당 주의 십신 (예: 겁재). 출생 시간을 모를 경우 시주는 '모름' 또는 빈 값."),
  sibbiUnseong: z.string().describe("해당 주의 십이운성 (예: 건록). 출생 시간을 모를 경우 시주는 '모름' 또는 빈 값."),
});

const SajuDataSchema = z.object({
  myElementNameKorean: z.string().describe("나의 오행 한글 이름 (예: 수)"),
  myElementHanja: z.string().describe("나의 오행 대표 한자 (일간의 오행, 예: 水)"),
  dayMasterHanja: z.string().describe("일간 한자 (본인을 나타내는 천간 한자, 예: 壬)"),
  pillars: z.array(SajuPillarInfoSchema).length(4).describe("사주 네 기둥 정보. 반드시 시주, 일주, 월주, 년주 순서로 배열에 4개의 객체를 포함해야 합니다."),
});
export type SajuDataType = z.infer<typeof SajuDataSchema>;


const GenerateFortuneInsightsOutputSchema = z.object({
  insights: z.array(FortuneInsightItemSchema)
    .describe('A list of fortune insights, where each item corresponds to one of the requested fortune types and contains the fortuneType and its insightText.'),
  sajuData: SajuDataSchema.optional().describe("사주 명식 데이터. '사주팔자' 운세 유형이 요청된 경우에만 포함됩니다."),
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
    responseMimeType: 'application/json', 
  },
  prompt: `You are an expert Korean fortune teller and Saju Palja (사주팔자) master.
You will use the user's birthdate, MBTI, gender, and birth time to generate personalized fortune insights for the requested fortune types.

User Profile:
Birthdate: {{{birthdate}}}
MBTI: {{{mbti}}}
Gender: {{{gender}}}
Birth Time: {{{birthTime}}}

Requested Fortune Types: {{#each fortuneTypes}}"{{{this}}}"{{#unless @last}}, {{/unless}}{{/each}}

Generate insights for each of the "Requested Fortune Types" and structure them in the "insights" array as specified in the output schema. Each item in the array must have "fortuneType" and "insightText".

If "사주팔자" is one of the "Requested Fortune Types", you MUST also calculate and provide the Saju Palja (Four Pillars) information.
The Saju data should be structured in the 'sajuData' field according to its Zod schema.
- 'myElementNameKorean': The Korean name of the user's Day Master element (e.g., 수, 목, 화, 토, 금).
- 'myElementHanja': The Hanja character for the user's Day Master element (e.g., 水, 木, 火, 土, 金).
- 'dayMasterHanja': The Hanja for the user's Day Master (일간).
- 'pillars': An array of exactly 4 pillar objects, in this specific order: Hour pillar (시주), Day pillar (일주), Month pillar (월주), Year pillar (년주).
  - For each pillar object, provide:
    - 'label': The name of the pillar (e.g., "시주", "일주", "월주", "년주").
    - 'heavenlyStem': The Hanja for the Heavenly Stem. If birth time is '모름' (unknown), the Hour pillar's heavenlyStem should be '모름' or an empty string.
    - 'heavenlyStemElement': The element of the Heavenly Stem in "Hanja, KoreanName" format (e.g., "水, 물"). If birth time is '모름', handle appropriately for the Hour pillar ('모름' or empty).
    - 'earthlyBranch': The Hanja for the Earthly Branch. If birth time is '모름', the Hour pillar's earthlyBranch should be '모름' or an empty string.
    - 'earthlyBranchElement': The element of the Earthly Branch in "Hanja, KoreanName" format (e.g., "水, 물"). If birth time is '모름', handle appropriately for the Hour pillar ('모름' or empty).
    - 'sibsin': The Sibsin (십신) for this pillar (e.g., "겁재"). If birth time is '모름', handle appropriately for the Hour pillar ('모름' or empty).
    - 'sibbiUnseong': The Sibbi Unseong (십이운성) for this pillar (e.g., "건록"). If birth time is '모름', handle appropriately for the Hour pillar ('모름' or empty).
The Saju calculations must be accurate based on traditional Saju Palja principles.

Return the entire result as a single JSON object adhering strictly to the GenerateFortuneInsightsOutputSchema.
The "insights" array must always be present. The "sajuData" field should only be present if "사주팔자" was requested.
Example of one item in the "insights" array:
{
  "fortuneType": "사주팔자",
  "insightText": "당신의 사주팔자 전반적인 해석은..."
}
Example of sajuData.pillars array item (for '일주'):
{
  "label": "일주",
  "heavenlyStem": "壬",
  "heavenlyStemElement": "水, 물",
  "earthlyBranch": "子",
  "earthlyBranchElement": "水, 물",
  "sibsin": "비견",
  "sibbiUnseong": "제왕"
}
Ensure the output is valid JSON.
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
    if (!output) {
      console.error("AI output is null. Input was:", input);
      const errorInsights = input.fortuneTypes.map(type => ({
        fortuneType: type,
        insightText: "죄송합니다, 현재 이 운세에 대한 정보를 생성할 수 없습니다."
      }));
      return { insights: errorInsights };
    }
    
    // Ensure insights array is always present, even if AI fails to generate sajuData
     if (!output.insights) {
        console.warn("AI output missing insights array. Constructing error insights. Input was:", input, "Output was:", output);
        const errorInsights = input.fortuneTypes.map(type => ({
          fortuneType: type,
          insightText: "죄송합니다, 현재 이 운세에 대한 정보를 생성할 수 없습니다."
        }));
        return { insights: errorInsights, sajuData: output.sajuData };
     }

    return output;
  }
);
