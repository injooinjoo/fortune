'use server';

import { ai } from '@/ai/genkit';
import { z } from 'genkit';
import { 
  ActivityFortuneResultSchema, 
  SajuResultSchema, 
  MBTIResultSchema,
  TarotResultSchema,
  PhysiognomyResultSchema,
  LuckyColorResultSchema,
  LuckyNumberResultSchema,
  BusinessFortuneResultSchema
} from '@/lib/schemas';

// 기본 사용자 정보 스키마
const BaseUserInfoSchema = z.object({
  name: z.string(),
  birth_date: z.string(),
  gender: z.string().optional(),
  mbti: z.string().optional(),
  birth_time: z.string().optional(),
});

// 운세 타입별 추가 정보 스키마들
const HikingInfoSchema = BaseUserInfoSchema.extend({
  hiking_level: z.string(),
  current_goal: z.string().optional(),
});

const InvestmentInfoSchema = BaseUserInfoSchema.extend({
  investment_experience: z.string(),
  risk_tolerance: z.string(),
  budget_range: z.string(),
  investment_goals: z.array(z.string()),
});

const BusinessInfoSchema = BaseUserInfoSchema.extend({
  business_type: z.string(),
  experience_years: z.string(),
  current_stage: z.string(),
  goals: z.array(z.string()),
});

// 스포츠/액티비티 운세 생성
export const generateActivityFortune = ai.defineFlow(
  {
    name: 'generateActivityFortune',
    inputSchema: z.object({
      activityType: z.string(),
      userInfo: HikingInfoSchema,
    }),
    outputSchema: ActivityFortuneResultSchema,
  },
  async ({ activityType, userInfo }) => {
    const prompt = `당신은 ${activityType} 전문 운세사입니다.

사용자 정보:
- 이름: ${userInfo.name}
- 생년월일: ${userInfo.birth_date}
- 활동 수준: ${userInfo.hiking_level}
- 목표: ${userInfo.current_goal || '없음'}

${activityType}에 특화된 운세를 생성해주세요:
1. 전체 운세 점수 (50-100)
2. 세부 운세 점수들 (체력운, 안전운, 성취운 등)
3. 행운의 요소들 (시간, 장소, 방향 등)
4. 구체적인 조언과 주의사항
5. 이번 주/월 예측

JSON 형식으로 ActivityFortuneResultSchema에 맞게 응답해주세요.`;

    const { output } = await ai.generate({
      prompt,
      config: { responseMimeType: 'application/json' }
    });

    return JSON.parse(output || '{}');
  }
);

// 투자/비즈니스 운세 생성  
export const generateBusinessFortune = ai.defineFlow(
  {
    name: 'generateBusinessFortune',
    inputSchema: z.object({
      businessType: z.string(),
      userInfo: BusinessInfoSchema,
    }),
    outputSchema: BusinessFortuneResultSchema,
  },
  async ({ businessType, userInfo }) => {
    const prompt = `당신은 ${businessType} 전문 투자/비즈니스 운세사입니다.

사용자 정보:
- 이름: ${userInfo.name}
- 생년월일: ${userInfo.birth_date}
- 사업 유형: ${userInfo.business_type}
- 경험: ${userInfo.experience_years}
- 현재 단계: ${userInfo.current_stage}
- 목표: ${userInfo.goals.join(', ')}

${businessType}에 특화된 운세를 생성해주세요:
1. 투자/사업 각 영역별 운세 점수
2. SWOT 분석 (강점, 약점, 기회, 위험)
3. 행운의 타이밍과 전략
4. 구체적인 투자/사업 조언
5. 단기/중기/장기 전망

JSON 형식으로 BusinessFortuneResultSchema에 맞게 응답해주세요.`;

    const { output } = await ai.generate({
      prompt,
      config: { responseMimeType: 'application/json' }
    });

    return JSON.parse(output || '{}');
  }
);

// 행운 아이템 운세 생성
export const generateLuckyItemFortune = ai.defineFlow(
  {
    name: 'generateLuckyItemFortune', 
    inputSchema: z.object({
      itemType: z.enum(['color', 'number', 'items']),
      userInfo: BaseUserInfoSchema,
      preferences: z.record(z.any()).optional(),
    }),
    outputSchema: z.union([LuckyColorResultSchema, LuckyNumberResultSchema]),
  },
  async ({ itemType, userInfo, preferences = {} }) => {
    const prompts = {
      color: `색채 치료와 운세를 전문으로 하는 전문가로서, ${userInfo.name}님의 생년월일 ${userInfo.birth_date}을 바탕으로 행운의 색깔을 찾아주세요.`,
      number: `수비학과 운세를 전문으로 하는 전문가로서, ${userInfo.name}님의 생년월일 ${userInfo.birth_date}을 바탕으로 행운의 숫자를 찾아주세요.`,
      items: `풍수와 행운의 아이템 전문가로서, ${userInfo.name}님에게 맞는 행운의 아이템들을 추천해주세요.`
    };

    const { output } = await ai.generate({
      prompt: prompts[itemType],
      config: { responseMimeType: 'application/json' }
    });

    return JSON.parse(output || '{}');
  }
);

// MBTI 특화 운세 생성
export const generateMBTIFortune = ai.defineFlow(
  {
    name: 'generateMBTIFortune',
    inputSchema: z.object({
      userInfo: BaseUserInfoSchema.extend({
        mbti: z.string(),
      }),
    }),
    outputSchema: MBTIResultSchema,
  },
  async ({ userInfo }) => {
    const prompt = `당신은 MBTI와 운세를 결합한 전문가입니다.

사용자 정보:
- 이름: ${userInfo.name}
- 생년월일: ${userInfo.birth_date}
- MBTI: ${userInfo.mbti}

${userInfo.mbti} 성격 유형에 특화된 운세를 생성해주세요:
1. MBTI별 성격 분석과 운세
2. 연애, 직업, 인간관계 궁합
3. 이번 주 MBTI 맞춤 조언
4. 성장 포인트와 주의사항
5. MBTI별 행운의 활동과 환경

JSON 형식으로 MBTIResultSchema에 맞게 응답해주세요.`;

    const { output } = await ai.generate({
      prompt,
      config: { responseMimeType: 'application/json' }
    });

    return JSON.parse(output || '{}');
  }
);

// 운세 타입별 라우팅 함수
export async function generateSpecializedFortune(
  fortuneType: string,
  userInfo: any,
  additionalData?: any
) {
  switch (fortuneType) {
    case 'lucky-hiking':
    case 'lucky-running':
    case 'lucky-cycling':
    case 'lucky-tennis':
    case 'lucky-golf':
      return generateActivityFortune({
        activityType: fortuneType.replace('lucky-', ''),
        userInfo,
      });

    case 'lucky-investment':
    case 'lucky-realestate':
    case 'business':
    case 'startup':
      return generateBusinessFortune({
        businessType: fortuneType,
        userInfo,
      });

    case 'lucky-color':
      return generateLuckyItemFortune({
        itemType: 'color',
        userInfo,
        preferences: additionalData,
      });

    case 'lucky-number':
      return generateLuckyItemFortune({
        itemType: 'number', 
        userInfo,
        preferences: additionalData,
      });

    case 'mbti':
      return generateMBTIFortune({ userInfo });

    default:
      throw new Error(`지원하지 않는 운세 타입: ${fortuneType}`);
  }
} 