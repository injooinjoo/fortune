import { ai } from '@/ai/genkit';
import { z } from 'zod';
import {
  UserProfileSchema,
  LifeProfileResultSchema,
  DailyFortuneInputSchema,
  DailyFortuneResultSchema,
  InteractiveFortuneInputSchema,
  InteractiveFortuneOutputSchema,
  GroupFortuneInputSchema,
  GroupFortuneOutputSchema,
} from '@/lib/types/fortune-schemas';
import { 
  generateBatchFortunes, 
  generateSingleFortune, 
  generateImageBasedFortune 
} from '../openai-client';

// 운세 결과 스키마 (상세화)
const FortuneResultSchema = z.object({
  overall_luck: z.number().min(0).max(100),
  summary: z.string(),
  advice: z.string(),
  lucky_color: z.string().optional(),
  lucky_number: z.number().optional(),
  love_luck: z.number().min(0).max(100).optional(),
  money_luck: z.number().min(0).max(100).optional(),
  health_luck: z.number().min(0).max(100).optional(),
  work_luck: z.number().min(0).max(100).optional(),
  personality: z.string().optional(),
  strengths: z.array(z.string()).optional(),
  challenges: z.array(z.string()).optional(),
});

// 배치 운세 생성 플로우 (회원가입 시 사용)
export const generateSignupBatchFortunes = ai.defineFlow(
  {
    name: 'generateSignupBatchFortunes',
    inputSchema: z.object({
      userProfile: UserProfileSchema,
    }),
    outputSchema: z.record(z.any()),
  },
  async (input) => {
    try {
      console.log(`🎯 회원가입 배치 운세 생성 시작`);
      
      // 평생 운세 목록
      const signupFortunes = ['saju', 'tojeong', 'past-life', 'personality', 'destiny'];
      
      const batchRequest = {
        user_id: input.userProfile.name, // 실제로는 user ID 사용
        fortunes: signupFortunes,
        profile: input.userProfile
      };
      
      const { data, token_usage } = await generateBatchFortunes(batchRequest);
      
      console.log(`✨ 배치 운세 생성 완료 (토큰 사용: ${token_usage})`);
      return data;
      
    } catch (error) {
      console.error('배치 운세 생성 실패:', error);
      return {};
    }
  }
);

// 일일 배치 운세 생성 플로우
export const generateDailyBatchFortunes = ai.defineFlow(
  {
    name: 'generateDailyBatchFortunes',
    inputSchema: z.object({
      userProfile: UserProfileSchema,
    }),
    outputSchema: z.record(z.any()),
  },
  async (input) => {
    try {
      console.log(`📅 일일 배치 운세 생성 시작`);
      
      // 일일 운세 목록
      const dailyFortunes = ['daily', 'love', 'career', 'wealth', 'health'];
      
      const batchRequest = {
        user_id: input.userProfile.name,
        fortunes: dailyFortunes,
        profile: input.userProfile
      };
      
      const { data, token_usage } = await generateBatchFortunes(batchRequest);
      
      console.log(`✨ 일일 배치 운세 생성 완료 (토큰 사용: ${token_usage})`);
      return data;
      
    } catch (error) {
      console.error('일일 배치 운세 생성 실패:', error);
      return {};
    }
  }
);

// 한국 운세 전문 프롬프트 생성 함수
function createKoreanFortunePrompt(category: string, userProfile: any, additionalInfo?: any): string {
  const baseInfo = `사용자 정보: 이름 ${userProfile.name}, 생년월일 ${userProfile.birthDate}`;
  const extraInfo = userProfile.mbti ? `, MBTI ${userProfile.mbti}` : '';
  const bloodInfo = userProfile.blood_type ? `, 혈액형 ${userProfile.blood_type}` : '';
  
  switch (category) {
    case 'saju':
    case 'traditional-saju':
      return `${baseInfo}${extraInfo}${bloodInfo}를 바탕으로 사주팔자 운세를 분석해주세요. 
      다음 항목들을 포함해서 분석해주세요:
      - 전체적인 운세 점수 (0-100점)
      - 성격과 타고난 기질
      - 장점과 강점
      - 주의해야 할 점
      - 인생 조언
      - 행운의 색깔과 숫자
      한국 전통 사주학에 기반하여 정확하고 현실적인 조언을 해주세요.`;
      
    case 'daily':
    case 'today':
      return `${baseInfo}${extraInfo}${bloodInfo}의 오늘 (${new Date().toLocaleDateString('ko-KR')}) 운세를 분석해주세요.
      다음 항목들을 각각 점수(0-100점)와 함께 분석해주세요:
      - 전체 운세
      - 애정 운세  
      - 금전 운세
      - 건강 운세
      - 직장/학업 운세
      - 오늘의 조언
      - 행운의 색깔과 숫자
      구체적이고 실용적인 조언을 해주세요.`;
      
    case 'love':
    case 'marriage':
      return `${baseInfo}${extraInfo}${bloodInfo}의 연애운과 결혼운을 분석해주세요.
      다음 항목들을 포함해서 분석해주세요:
      - 연애운 점수 (0-100점)
      - 현재 연애 상황 분석
      - 이상형과 궁합
      - 연애할 때 장점과 주의점
      - 결혼 시기와 조건
      - 연애 조언
      구체적이고 현실적인 연애 조언을 해주세요.`;
      
    case 'dream':
      const dreamContent = additionalInfo?.dreamContent || additionalInfo?.input?.dreamContent || '꿈 내용 없음';
      return `${baseInfo}의 꿈 해몽을 해주세요.
      꿈 내용: "${dreamContent}"
      
      다음 항목들을 포함해서 해석해주세요:
      - 꿈의 전체적인 의미
      - 길몽인지 흉몽인지 판단
      - 앞으로의 운세에 미치는 영향
      - 주의사항과 조언
      - 행운 점수 (0-100점)
      한국 전통 꿈해몽 문화를 바탕으로 해석해주세요.`;
      
    case 'tarot':
      const question = additionalInfo?.question || additionalInfo?.input?.question || '일반 운세';
      return `${baseInfo}의 타로 카드 운세를 봐주세요.
      질문: "${question}"
      
      가상의 타로카드 3장을 뽑아서 다음과 같이 해석해주세요:
      - 과거: 현재 상황의 원인
      - 현재: 지금의 상황
      - 미래: 앞으로의 전망
      - 전체적인 조언
      - 운세 점수 (0-100점)
      타로의 상징적 의미를 활용해서 깊이 있는 해석을 해주세요.`;
      
    default:
      return `${baseInfo}${extraInfo}${bloodInfo}의 ${category} 운세를 분석해주세요.
      다음 항목들을 포함해서 분석해주세요:
      - 전체 운세 점수 (0-100점)
      - 현재 상황 분석
      - 장점과 강점
      - 주의사항
      - 구체적인 조언
      - 행운의 색깔과 숫자
      정확하고 실용적인 조언을 해주세요.`;
  }
}

// 1. 평생 운세 패키지 생성 플로우
export const generateLifeProfile = ai.defineFlow(
  {
    name: 'generateLifeProfile',
    inputSchema: UserProfileSchema,
    outputSchema: LifeProfileResultSchema,
  },
  async (userProfile) => {
    const prompt = `
      사용자 프로필:
      - 이름: ${userProfile.name}
      - 생년월일: ${userProfile.birthDate}
      - 성별: ${userProfile.gender}
      ${userProfile.mbti ? `- MBTI: ${userProfile.mbti}` : ''}

      위 프로필을 바탕으로 사용자의 평생 운세 정보를 분석해줘.
      반드시 JSON 객체로만 응답해야 해. 다른 텍스트는 절대 포함하지 마.
    `;
    
    const response = await ai.generate({
        prompt,
        output: { format: 'json', schema: LifeProfileResultSchema },
    });

    const output = response.output;
    if (!output) {
      throw new Error('AI 응답 생성에 실패했습니다.');
    }
    return output;
  }
);

// 2. 종합 일일 운세 생성 플로우
export const generateComprehensiveDailyFortune = ai.defineFlow(
  {
    name: 'generateComprehensiveDailyFortune',
    inputSchema: DailyFortuneInputSchema,
    outputSchema: DailyFortuneResultSchema,
  },
  async (input) => {
    const prompt = `
      사용자 프로필:
      - 이름: ${input.userProfile.name}
      - 생년월일: ${input.userProfile.birthDate}
      - 성별: ${input.userProfile.gender}
      ${input.userProfile.mbti ? `- MBTI: ${input.userProfile.mbti}` : ''}

      요청 날짜: ${input.date}

      ${input.lifeProfileResult ? `
      참고용 평생 운세 데이터:
      - 사주 요약: ${input.lifeProfileResult.saju.summary}
      - 타고난 재능: ${input.lifeProfileResult.talent.summary}
      이 평생 운세 정보를 바탕으로 오늘의 운세를 더 깊이 있게 해석해줘.
      ` : ''}

      위 정보를 종합하여 ${input.date}의 종합적인 일일 운세를 분석해줘.
      반드시 JSON 객체로만 응답해야 해. 다른 텍스트는 절대 포함하지 마.
    `;
    
    const response = await ai.generate({
        prompt,
        output: { format: 'json', schema: DailyFortuneResultSchema },
    });

    const output = response.output;
    if (!output) {
      throw new Error('AI 응답 생성에 실패했습니다.');
    }
    return output;
  }
);

// 3. 인터랙티브 운세 생성 플로우 (예: 타로)
export const generateInteractiveFortune = ai.defineFlow(
  {
    name: 'generateInteractiveFortune',
    inputSchema: InteractiveFortuneInputSchema,
    outputSchema: InteractiveFortuneOutputSchema,
  },
  async (input) => {
    const prompt = `
      사용자 프로필:
      - 이름: ${input.userProfile.name}
      - 생년월일: ${input.userProfile.birthDate}

      운세 종류: ${input.category}
      사용자 질문/내용: ${input.question}

      위 정보를 바탕으로 운세를 해석하고 조언해줘.
      반드시 JSON 객체로만 응답해야 해. 다른 텍스트는 절대 포함하지 마.
    `;

    const response = await ai.generate({
        prompt,
        output: { format: 'json', schema: InteractiveFortuneOutputSchema },
    });
    
    const output = response.output;
    if (!output) {
      throw new Error('AI 응답 생성에 실패했습니다.');
    }
    return output;
  }
);

// 4. 그룹 운세 생성 플로우 (예: 띠별, 혈액형별)
export const generateGroupFortune = ai.defineFlow(
  {
    name: 'generateGroupFortune',
    inputSchema: GroupFortuneInputSchema,
    outputSchema: GroupFortuneOutputSchema,
  },
  async (input) => {
    const prompt = `
      그룹 운세 생성 요청:
      - 카테고리: ${input.category}
      - 그룹 타입: ${input.groupType}
      - 날짜: ${input.date}

      ${input.category}에 대한 ${input.groupType}별 운세를 생성해줘.
      반드시 JSON 객체로만 응답해야 해. 다른 텍스트는 절대 포함하지 마.
    `;

    const response = await ai.generate({
        prompt,
        output: { format: 'json', schema: GroupFortuneOutputSchema },
    });
    
    const output = response.output;
    if (!output) {
      throw new Error('AI 응답 생성에 실패했습니다.');
    }
    return output;
  }
);

// 레거시 지원을 위한 추가 함수들
function parseFortuneResponse(response: string, category: string): any {
  try {
    const parsed = JSON.parse(response);
    return parsed;
  } catch (error) {
    console.error('운세 응답 파싱 실패:', error);
    return createFallbackResponse(category);
  }
}

function createFallbackResponse(category: string, userProfile?: any): any {
  const fallbackResponses = {
    saju: {
      overall_luck: 75,
      summary: '안정적인 운세를 보이고 있습니다.',
      advice: '꾸준함을 유지하시면 좋은 결과가 있을 것입니다.',
      lucky_color: '파란색',
      lucky_number: 7,
      personality: '성실하고 책임감이 강한 성격',
      strengths: ['끈기', '성실함', '책임감'],
      challenges: ['완벽주의', '스트레스 관리']
    },
    daily: {
      overall_luck: 70,
      summary: '평범하지만 안정적인 하루가 될 것 같습니다.',
      advice: '새로운 시도보다는 기존 일에 집중하는 것이 좋겠습니다.',
      love_luck: 65,
      money_luck: 75,
      health_luck: 80,
      work_luck: 70,
      lucky_color: '초록색',
      lucky_number: 3
    }
  };
  
  return fallbackResponses[category as keyof typeof fallbackResponses] || fallbackResponses.daily;
}