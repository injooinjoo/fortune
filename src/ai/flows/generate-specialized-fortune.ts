import { defineFlow } from 'genkit';
import { z } from 'zod';
import { 
  generateBatchFortunes, 
  generateSingleFortune, 
  generateImageBasedFortune 
} from '../openai-client';

// 사용자 프로필 스키마 (상세화)
const UserProfileSchema = z.object({
  name: z.string(),
  birthDate: z.string(),
  gender: z.string().optional(),
  mbti: z.string().optional(),
  blood_type: z.string().optional(),
});

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
export const generateSignupBatchFortunes = defineFlow(
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
export const generateDailyBatchFortunes = defineFlow(
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
export const generateLifeProfile = defineFlow(
  {
    name: 'generateLifeProfile',
    inputSchema: z.object({
      userProfile: UserProfileSchema,
      category: z.string().optional(),
    }),
    outputSchema: FortuneResultSchema,
  },
  async (input) => {
    try {
      const category = input.category || 'saju';
      const prompt = createKoreanFortunePrompt(category, input.userProfile);
      
      console.log(`🔮 평생 운세 생성 중: ${category}`);
      
      // OpenAI GPT로 단일 운세 생성
      const result = await generateSingleFortune(category, input.userProfile);
      
      console.log(`✨ 평생 운세 생성 완료: ${category}`);
      return result;
      
    } catch (error) {
      console.error('평생 운세 생성 실패:', error);
      return createFallbackResponse(input.category || 'saju', input.userProfile);
    }
  }
);

// 2. 종합 일일 운세 생성 플로우
export const generateComprehensiveDailyFortune = defineFlow(
  {
    name: 'generateComprehensiveDailyFortune',
    inputSchema: z.object({
      userProfile: UserProfileSchema,
      date: z.string(),
      category: z.string().optional(),
    }),
    outputSchema: FortuneResultSchema,
  },
  async (input) => {
    try {
      const category = input.category || 'daily';
      const prompt = createKoreanFortunePrompt(category, input.userProfile, { date: input.date });
      
      console.log(`📅 일일 운세 생성 중: ${category} (${input.date})`);
      
      // OpenAI GPT로 단일 운세 생성
      const result = await generateSingleFortune(category, input.userProfile);
      
      console.log(`✨ 일일 운세 생성 완료: ${category}`);
      return result;
      
    } catch (error) {
      console.error('일일 운세 생성 실패:', error);
      return createFallbackResponse(input.category || 'daily', input.userProfile);
    }
  }
);

// 3. 인터랙티브 운세 생성 플로우
export const generateInteractiveFortune = defineFlow(
  {
    name: 'generateInteractiveFortune',
    inputSchema: z.object({
      userProfile: UserProfileSchema,
      category: z.string(),
      input: z.any(),
    }),
    outputSchema: FortuneResultSchema,
  },
  async (input) => {
    try {
      console.log(`🎯 인터랙티브 운세 생성 중: ${input.category}`);
      
      // OpenAI GPT로 인터랙티브 운세 생성
      const result = await generateSingleFortune(
        input.category, 
        input.userProfile, 
        input.input
      );
      
      console.log(`✨ 인터랙티브 운세 생성 완료: ${input.category}`);
      return result;
      
    } catch (error) {
      console.error('인터랙티브 운세 생성 실패:', error);
      return createFallbackResponse(input.category, input.userProfile);
    }
  }
);

// AI 응답 파싱 함수
function parseFortuneResponse(response: string, category: string): any {
  try {
    // AI 응답에서 숫자와 텍스트 추출
    const overallLuckMatch = response.match(/(?:전체|종합|운세).*?(?:점수|점|수치).*?(\d+)/i);
    const loveLuckMatch = response.match(/(?:애정|연애|사랑).*?(?:점수|점|수치).*?(\d+)/i);
    const moneyLuckMatch = response.match(/(?:금전|재물|돈|경제).*?(?:점수|점|수치).*?(\d+)/i);
    const healthLuckMatch = response.match(/(?:건강|몸|체력).*?(?:점수|점|수치).*?(\d+)/i);
    const workLuckMatch = response.match(/(?:직장|업무|학업|일).*?(?:점수|점|수치).*?(\d+)/i);
    
    const colorMatch = response.match(/(?:행운|럭키).*?(?:색깔|색상|컬러).*?([가-힣]+색?|red|blue|green|yellow|purple|orange|pink|black|white)/i);
    const numberMatch = response.match(/(?:행운|럭키).*?(?:숫자|번호|수).*?(\d+)/i);
    
    // 응답을 적절한 길이로 요약
    const summaryMatch = response.match(/(.{50,200})/);
    const summary = summaryMatch ? summaryMatch[1].trim() : response.substring(0, 150) + '...';
    
    const adviceMatch = response.match(/(?:조언|추천|권유|팁).*?([^\.]+\.)/i);
    const advice = adviceMatch ? adviceMatch[1].trim() : "긍정적인 마음가짐으로 하루를 시작하세요.";

    return {
      overall_luck: overallLuckMatch ? parseInt(overallLuckMatch[1]) : Math.floor(Math.random() * 21) + 70,
      summary: summary,
      advice: advice,
      lucky_color: colorMatch ? colorMatch[1] : ["파란색", "빨간색", "노란색", "초록색"][Math.floor(Math.random() * 4)],
      lucky_number: numberMatch ? parseInt(numberMatch[1]) : Math.floor(Math.random() * 9) + 1,
      love_luck: loveLuckMatch ? parseInt(loveLuckMatch[1]) : undefined,
      money_luck: moneyLuckMatch ? parseInt(moneyLuckMatch[1]) : undefined,
      health_luck: healthLuckMatch ? parseInt(healthLuckMatch[1]) : undefined,
      work_luck: workLuckMatch ? parseInt(workLuckMatch[1]) : undefined,
    };
    
  } catch (error) {
    console.error('AI 응답 파싱 실패:', error);
    return createFallbackResponse(category);
  }
}

// Fallback 응답 생성 함수
function createFallbackResponse(category: string, userProfile?: any): any {
  const userName = userProfile?.name || '사용자';
  
  return {
    overall_luck: Math.floor(Math.random() * 21) + 70, // 70-90점
    summary: `${userName}님의 ${category} 운세 분석이 준비되었습니다. AI 분석을 통해 더 정확한 결과를 제공하겠습니다.`,
    advice: "긍정적인 마음가짐이 좋은 운을 가져다 줍니다.",
    lucky_color: ["파란색", "빨간색", "노란색", "초록색", "보라색"][Math.floor(Math.random() * 5)],
    lucky_number: Math.floor(Math.random() * 9) + 1,
  };
}