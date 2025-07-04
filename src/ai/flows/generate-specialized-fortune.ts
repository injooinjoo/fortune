import { ai } from '@/ai/genkit';
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
    let fortuneTypeName = '';
    switch(input.fortuneType) {
      case 'zodiac':
        fortuneTypeName = '띠별';
        break;
      case 'bloodType':
        fortuneTypeName = '혈액형';
        break;
      case 'zodiacAnimal':
        fortuneTypeName = '12간지';
        break;
    }
    const groupKeyName = input.groupKey; // 예: "용띠", "A형"

    const prompt = `
      요청 날짜: ${input.date}
      운세 종류: ${fortuneTypeName}
      운세 그룹: ${groupKeyName}

      위 정보를 바탕으로 해당 그룹의 오늘의 운세를 생성해줘.
      운세 내용은 "총운"에 대한 것으로 간주하고, 상세하고 흥미롭게 작성해줘.
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