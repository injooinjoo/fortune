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

당신은 한국의 전문 운세 상담사입니다. 아래 예시들을 참고하여 비슷한 형식과 깊이로 분석해주세요.

=== 예시 1 (20대 여성, ENFP) ===
{
  "overall_score": 87,
  "love_score": 85,
  "weekly_score": 82,
  "monthly_score": 90,
  "summary": "새로운 인연의 기운이 강하게 느껴지는 시기입니다. 특히 이번 달 중순 이후 매력이 상승하여 주변 사람들의 관심을 받게 될 것입니다.",
  "advice": "평소보다 적극적인 자세로 사람들과 교류하세요. 단, 너무 서두르지 말고 상대방을 충분히 알아가는 시간을 가지는 것이 중요합니다.",
  "lucky_time": "오후 2시~5시",
  "lucky_place": "북쪽 방향의 카페, 서점, 문화센터",
  "lucky_color": "#FF69B4",
  "compatibility": {
    "best": "ISTP",
    "good": ["INTJ", "INFJ", "ESTP"],
    "avoid": "ESFJ"
  },
  "predictions": {
    "today": "오늘은 솔직한 대화를 통해 관계가 진전될 수 있는 날입니다. 망설이던 말을 꺼내보세요.",
    "this_week": "주중에 예상치 못한 만남이 있을 수 있습니다. 평소와 다른 장소를 방문해보세요.",
    "this_month": "이번 달은 연애운이 상승세를 타고 있어 새로운 시작에 유리합니다."
  },
  "action_items": [
    "매주 새로운 취미 활동이나 모임에 참여하기",
    "외모 관리에 신경쓰되 자연스러운 매력 살리기",
    "연락이 뜸했던 지인들과 안부 나누기"
  ]
}

=== 예시 2 (30대 남성, ISTJ) ===
{
  "overall_score": 72,
  "love_score": 70,
  "weekly_score": 68,
  "monthly_score": 75,
  "summary": "안정적인 관계 발전을 위한 시기입니다. 급진적인 변화보다는 꾸준한 노력이 필요하며, 기존 관계를 더욱 돈독히 하는 것이 중요합니다.",
  "advice": "상대방의 작은 변화나 노력을 알아차리고 표현해주세요. 당신의 진심 어린 관심이 관계를 한층 깊게 만들 것입니다.",
  "lucky_time": "저녁 7시~9시",
  "lucky_place": "조용한 레스토랑, 산책로, 집 근처 공원",
  "lucky_color": "#4169E1",
  "compatibility": {
    "best": "ESFJ",
    "good": ["ISFJ", "ESTJ", "ENFJ"],
    "avoid": "ENFP"
  },
  "predictions": {
    "today": "오늘은 평소의 루틴을 유지하며 안정감을 주는 것이 좋습니다.",
    "this_week": "주말에 특별한 이벤트를 준비한다면 좋은 반응을 얻을 수 있습니다.",
    "this_month": "월말로 갈수록 연애운이 상승하니 그때를 위한 계획을 세워보세요."
  },
  "action_items": [
    "일주일에 한 번은 특별한 데이트 계획하기",
    "상대방의 관심사에 대해 깊이 알아보기",
    "감정 표현을 조금 더 적극적으로 하기"
  ]
}

위 예시들을 참고하여, 이 사용자에게 맞는 연애운을 분석해주세요.
중요: 반드시 위와 동일한 JSON 구조로 응답하고, 각 필드는 구체적이고 실용적인 내용으로 채워주세요.`;
      
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