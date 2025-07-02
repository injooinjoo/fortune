'use server';

import { ai } from '@/ai/genkit';
import { z } from 'zod';
import { 
  ActivityFortuneResultSchema, 
  SajuResultSchema, 
  MBTIResultSchema,
  TarotResultSchema,
  PhysiognomyResultSchema,
  LuckyColorResultSchema,
  LuckyNumberResultSchema,
  BusinessFortuneResultSchema,
  CompatibilityResultSchema,
  BlindDateResultSchema,
  ExLoverResultSchema,
  CoupleMatchResultSchema,
  ChemistryResultSchema,
  CelebrityMatchResultSchema
} from '@/lib/schemas';

// 기본 사용자 정보 스키마
const BaseUserInfoSchema = z.object({
  name: z.string(),
  birth_date: z.string(),
  gender: z.string().optional(),
  mbti: z.string().optional(),
  birth_time: z.string().optional(),
});

// 연예인 궁합 정보를 위한 스키마
const CelebrityMatchInfoSchema = BaseUserInfoSchema.extend({
    celebrity: z.string(),
});

// 케미 정보를 위한 스키마
const ChemistryInfoSchema = z.object({
    person1: BaseUserInfoSchema.extend({ age: z.string().optional(), sign: z.string().optional(), personality_traits: z.array(z.string()).optional(), intimate_preferences: z.string().optional() }),
    person2: BaseUserInfoSchema.extend({ age: z.string().optional(), sign: z.string().optional(), personality_traits: z.array(z.string()).optional(), intimate_preferences: z.string().optional() }),
    relationship_duration: z.string(),
    intimacy_level: z.string(),
    concerns: z.string().optional(),
});

// 커플 매칭 정보를 위한 스키마
const CoupleMatchInfoSchema = z.object({
    person1: BaseUserInfoSchema,
    person2: BaseUserInfoSchema,
    status: z.string().optional(),
    duration: z.string().optional(),
    concern: z.string().optional(),
});

// 전 연인 운세 정보를 위한 스키마
const ExLoverInfoSchema = BaseUserInfoSchema.extend({
    relationship_duration: z.string(),
    breakup_reason: z.string(),
    time_since_breakup: z.string(),
    feelings: z.string().optional(),
});

// 소개팅 정보를 위한 스키마
const BlindDateInfoSchema = BaseUserInfoSchema.extend({
    age: z.string(),
    job: z.string().optional(),
    personality: z.array(z.string()).optional(),
    ideal_type: z.string().optional(),
    experience_level: z.string(),
    preferred_location: z.string().optional(),
    preferred_activity: z.string(),
    concerns: z.string().optional(),
});

// 궁합 분석을 위한 정보 스키마
const CompatibilityInfoSchema = z.object({
    person1: BaseUserInfoSchema,
    person2: BaseUserInfoSchema,
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

// 연예인 궁합 운세 생성
export const generateCelebrityMatchFortune = ai.defineFlow(
    {
        name: 'generateCelebrityMatchFortune',
        inputSchema: CelebrityMatchInfoSchema,
        outputSchema: CelebrityMatchResultSchema,
    },
    async (userInfo) => {
        const prompt = `당신은 전문 연예인 분석가이자 사주명리학자입니다. 다음 사용자와 연예인의 궁합을 재미있게 분석해주세요.\n\n# 사용자 정보\n- 이름: ${userInfo.name}\n- 생년월일: ${userInfo.birth_date}\n- 좋아하는 연예인: ${userInfo.celebrity}\n\n# 분석 요청\nJSON 형식으로 연예인 궁합 분석을 제공해주세요. 각 항목은 구체적이고 현실적인 내용으로 채워주세요.\n\n- score: 20-80 사이의 케미 지수 점수\n- comment: 재미있고 개성있는 한줄 코멘트\n- luckyColor: 행운의 색상 (HEX 코드)\n- luckyItem: 행운의 아이템 (연예인 관련 굿즈나 활동 관련 아이템)\n\n모든 텍스트는 한국어로 작성해야 합니다.`;

        const { output } = await ai.generate({
            prompt,
            config: { responseMimeType: 'application/json' }
        });

        return JSON.parse(output || '{}');
    }
);

// 케미 운세 생성
export const generateChemistryFortune = ai.defineFlow(
    {
        name: 'generateChemistryFortune',
        inputSchema: ChemistryInfoSchema,
        outputSchema: ChemistryResultSchema,
    },
    async (userInfo) => {
        const prompt = `당신은 전문 연애 상담사이자 성심리학자입니다. 다음 커플의 정보를 바탕으로 속궁합(케미)을 상세 분석해주세요.\n\n# 커플 정보\n- 첫 번째 사람: ${userInfo.person1.name} (나이: ${userInfo.person1.age || '미입력'}, 별자리: ${userInfo.person1.sign || '미입력'})\n- 성격 특성: ${userInfo.person1.personality_traits?.join(', ') || '미입력'}\n- 선호도: ${userInfo.person1.intimate_preferences || '미입력'}\n\n- 두 번째 사람: ${userInfo.person2.name} (나이: ${userInfo.person2.age || '미입력'}, 별자리: ${userInfo.person2.sign || '미입력'})\n- 성격 특성: ${userInfo.person2.personality_traits?.join(', ') || '미입력'}\n- 선호도: ${userInfo.person2.intimate_preferences || '미입력'}\n\n# 관계 정보\n- 관계 기간: ${userInfo.relationship_duration}\n- 현재 친밀도 단계: ${userInfo.intimacy_level}\n- 고민사항: ${userInfo.concerns || '없음'}\n\n# 분석 요청\nJSON 형식으로 상세한 속궁합 분석을 제공해주세요. 각 항목은 구체적이고 현실적인 내용으로 채워주세요.\n\n- overall_chemistry: 45-95 사이의 종합 케미 점수\n- physical_attraction: 50-100 사이의 신체적 매력 점수\n- emotional_connection: 45-95 사이의 감정적 연결 점수\n- passion_intensity: 55-100 사이의 열정 강도 점수\n- compatibility_level: 50-95 사이의 궁합 점수\n- intimacy_potential: 60-100 사이의 친밀감 잠재력 점수\n- insights: 강점, 과제, 발전 팁\n- detailed_analysis: 신체적 케미, 감정적 유대감, 열정 역동성, 친밀감 전망 분석\n- recommendations: 관계 향상 활동, 소통 팁, 친밀감 조언 (각 5개)\n- warnings: 주의사항 4개\n- compatibility_percentage: 55-95 사이의 전체 궁합률\n\n모든 텍스트는 한국어로 작성해야 합니다.`;

        const { output } = await ai.generate({
            prompt,
            config: { responseMimeType: 'application/json' }
        });

        return JSON.parse(output || '{}');
    }
);

// 커플 매칭 운세 생성
export const generateCoupleMatchFortune = ai.defineFlow(
    {
        name: 'generateCoupleMatchFortune',
        inputSchema: CoupleMatchInfoSchema,
        outputSchema: CoupleMatchResultSchema,
    },
    async (userInfo) => {
        const prompt = `당신은 전문 연애 상담사이자 사주명리학자입니다. 다음 커플의 정보를 바탕으로 짝궁합을 분석해주세요.\n\n# 커플 정보\n- 첫 번째 사람: ${userInfo.person1.name} (${userInfo.person1.birth_date})\n- 두 번째 사람: ${userInfo.person2.name} (${userInfo.person2.birth_date})\n- 현재 관계: ${userInfo.status || '미입력'}\n- 만난 기간: ${userInfo.duration || '미입력'}\n- 현재 고민: ${userInfo.concern || '없음'}\n\n# 분석 요청\nJSON 형식으로 상세한 짝궁합 분석을 제공해주세요. 각 항목은 구체적이고 현실적인 내용으로 채워주세요.\n\n- currentFlow: 40-95 사이의 현재 관계 흐름 점수\n- futurePotential: 50-100 사이의 미래 발전 가능성 점수\n- advice1: 첫 번째 핵심 조언\n- advice2: 두 번째 핵심 조언\n- tips: 관계 개선 팁 3가지\n\n모든 텍스트는 한국어로 작성해야 합니다.`;

        const { output } = await ai.generate({
            prompt,
            config: { responseMimeType: 'application/json' }
        });

        return JSON.parse(output || '{}');
    }
);

// 전 연인 운세 생성
export const generateExLoverFortune = ai.defineFlow(
    {
        name: 'generateExLoverFortune',
        inputSchema: ExLoverInfoSchema,
        outputSchema: ExLoverResultSchema,
    },
    async (userInfo) => {
        const prompt = `당신은 전문 심리상담사이자 연애 전문가입니다. 다음 헤어진 연인에 대한 정보를 바탕으로 현재 상황을 분석하고 치유 조언을 제공해주세요.\n\n# 관계 정보\n- 헤어진 애인 이름: ${userInfo.name}\n- 교제 기간: ${userInfo.relationship_duration}\n- 이별 사유: ${userInfo.breakup_reason}\n- 이별 후 경과 시간: ${userInfo.time_since_breakup}\n- 현재 감정: ${userInfo.feelings || '미입력'}\n\n# 분석 요청\nJSON 형식으로 상세한 분석을 제공해주세요. 각 항목은 구체적이고 현실적인 내용으로 채워주세요.\n\n- closure_score: 20-100 사이의 감정 정리 점수\n- reconciliation_chance: 10-90 사이의 재결합 가능성\n- emotional_healing: 30-100 사이의 감정 치유 정도\n- future_relationship_impact: 25-95 사이의 향후 연애에 미치는 영향도\n- insights: 현재 상태, 감정 상태, 전문가 조언\n- closure_activities: 감정 정리를 위한 활동 5가지\n- warning_signs: 주의해야 할 신호 4가지\n- positive_aspects: 이 관계에서 얻은 긍정적 측면 4가지\n- timeline: 현재 치유 단계, 예상 기간, 다음 단계 조언\n\n모든 텍스트는 한국어로 작성해야 합니다.`;

        const { output } = await ai.generate({
            prompt,
            config: { responseMimeType: 'application/json' }
        });

        return JSON.parse(output || '{}');
    }
);

// 소개팅 운세 생성
export const generateBlindDateFortune = ai.defineFlow(
    {
        name: 'generateBlindDateFortune',
        inputSchema: BlindDateInfoSchema,
        outputSchema: BlindDateResultSchema,
    },
    async (userInfo) => {
        const prompt = `당신은 전문 연애 상담사이자 소개팅 코치입니다. 다음 정보를 바탕으로 소개팅 성공률을 분석하고 맞춤 조언을 제공해주세요.\n\n# 개인 정보\n- 이름: ${userInfo.name}\n- 나이: ${userInfo.age}세\n- 직업: ${userInfo.job || '미입력'}\n- 성격: ${userInfo.personality?.join(', ') || '미입력'}\n- 이상형: ${userInfo.ideal_type || '미입력'}\n- 소개팅 경험: ${userInfo.experience_level}\n- 선호 장소: ${userInfo.preferred_location || '미입력'}\n- 선호 활동: ${userInfo.preferred_activity}\n- 고민사항: ${userInfo.concerns || '없음'}\n\n# 분석 요청\nJSON 형식으로 상세한 소개팅 분석을 제공해주세요. 각 항목은 구체적이고 현실적인 내용으로 채워주세요.\n\n- success_rate: 45-95 사이의 소개팅 성공률\n- chemistry_score: 50-100 사이의 케미 점수\n- conversation_score: 45-95 사이의 대화 점수\n- impression_score: 55-100 사이의 첫인상 점수\n- insights: 성격, 강점, 개선점 분석\n- recommendations: 추천 장소, 대화 주제, 스타일 팁, 행동 팁\n- timeline: 최적의 시간, 준비 기간, 성공 신호\n- warnings: 주의사항\n\n모든 텍스트는 한국어로 작성해야 합니다.`;

        const { output } = await ai.generate({
            prompt,
            config: { responseMimeType: 'application/json' }
        });

        return JSON.parse(output || '{}');
    }
);

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
    const prompt = `당신은 ${activityType} 전문 운세사입니다.\n\n사용자 정보:\n- 이름: ${userInfo.name}\n- 생년월일: ${userInfo.birth_date}\n- 활동 수준: ${userInfo.hiking_level}\n- 목표: ${userInfo.current_goal || '없음'}\n\n${activityType}에 특화된 운세를 생성해주세요:\n1. 전체 운세 점수 (50-100)\n2. 세부 운세 점수들 (체력운, 안전운, 성취운 등)\n3. 행운의 요소들 (시간, 장소, 방향 등)\n4. 구체적인 조언과 주의사항\n5. 이번 주/월 예측\n\nJSON 형식으로 ActivityFortuneResultSchema에 맞게 응답해주세요.`;

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
    const prompt = `당신은 ${businessType} 전문 투자/비즈니스 운세사입니다.\n\n사용자 정보:\n- 이름: ${userInfo.name}\n- 생년월일: ${userInfo.birth_date}\n- 사업 유형: ${userInfo.business_type}\n- 경험: ${userInfo.experience_years}\n- 현재 단계: ${userInfo.current_stage}\n- 목표: ${userInfo.goals.join(', ')}\n\n${businessType}에 특화된 운세를 생성해주세요:\n1. 투자/사업 각 영역별 운세 점수\n2. SWOT 분석 (강점, 약점, 기회, 위험)\n3. 행운의 타이밍과 전략\n4. 구체적인 투자/사업 조언\n5. 단기/중기/장기 전망\n\nJSON 형식으로 BusinessFortuneResultSchema에 맞게 응답해주세요.`;

    const { output } = await ai.generate({
      prompt,
      config: { responseMimeType: 'application/json' }
    });

    return JSON.parse(output || '{}');
  }
);

// 궁합 운세 생성
export const generateCompatibilityFortune = ai.defineFlow(
  {
    name: 'generateCompatibilityFortune',
    inputSchema: CompatibilityInfoSchema,
    outputSchema: CompatibilityResultSchema,
  },
  async (userInfo) => {
    const prompt = `당신은 관계 전문 사주명리학자입니다. 다음 두 사람의 궁합을 상세히 분석해주세요.\n\n# 첫 번째 사람\n- 이름: ${userInfo.person1.name}\n- 생년월일: ${userInfo.person1.birth_date}\n- 성별: ${userInfo.person1.gender || '미입력'}\n- MBTI: ${userInfo.person1.mbti || '미입력'}\n\n# 두 번째 사람\n- 이름: ${userInfo.person2.name}\n- 생년월일: ${userInfo.person2.birth_date}\n- 성별: ${userInfo.person2.gender || '미입력'}\n- MBTI: ${userInfo.person2.mbti || '미입력'}\n\n# 분석 요청\n두 사람의 사주와 성향을 종합적으로 고려하여, 다음 JSON 형식에 맞춰 상세한 궁합 분석을 제공해주세요. 각 항목은 구체적이고 현실적인 내용으로 채워주세요.\n\n- compatibility_scores: 종합, 연애, 결혼, 사업, 일상생활 궁합 점수를 각각 50-100 사이로 매겨주세요.\n- personality_analysis: 각 사람의 성격 특성을 긍정적 측면과 부정적 측면을 모두 포함하여 상세히 분석해주세요.\n- strengths: 이 관계의 가장 큰 장점 4가지를 구체적인 예시와 함께 설명해주세요.\n- challenges: 이 관계에서 발생할 수 있는 주요 갈등 요소 3가지를 명확히 짚어주세요.\n- advice: 두 사람이 관계를 더 발전시키기 위한 실질적인 조언을 해주세요.\n- lucky_elements: 관계에 긍정적인 영향을 줄 수 있는 행운의 색상(HEX 코드), 숫자, 방향, 날짜 정보를 제공해주세요.\n\n모든 텍스트는 한국어로 작성해야 합니다.`;

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
    const prompt = `당신은 MBTI와 운세를 결합한 전문가입니다.\n\n사용자 정보:\n- 이름: ${userInfo.name}\n- 생년월일: ${userInfo.birth_date}\n- MBTI: ${userInfo.mbti}\n\n${userInfo.mbti} 성격 유형에 특화된 운세를 생성해주세요:\n1. MBTI별 성격 분석과 운세\n2. 연애, 직업, 인간관계 궁합\n3. 이번 주 MBTI 맞춤 조언\n4. 성장 포인트와 주의사항\n5. MBTI별 행운의 활동과 환경\n\nJSON 형식으로 MBTIResultSchema에 맞게 응답해주세요.`;

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

    case 'compatibility':
      return generateCompatibilityFortune(userInfo);

    case 'blind-date':
        return generateBlindDateFortune(userInfo);

    case 'ex-lover':
        return generateExLoverFortune(userInfo);

    case 'couple-match':
        return generateCoupleMatchFortune(userInfo);

    case 'chemistry':
        return generateChemistryFortune(userInfo);

    case 'celebrity-match':
        return generateCelebrityMatchFortune(userInfo);

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