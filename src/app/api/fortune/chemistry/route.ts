import { NextRequest, NextResponse } from 'next/server';
import { generateSingleFortune } from '@/ai/openai-client';
import { withFortuneAuth, createSafeErrorResponse } from '@/lib/security-api-utils';
import { AuthenticatedRequest } from '@/middleware/auth';
import { FortuneService } from '@/lib/services/fortune-service';
import { createSuccessResponse, createErrorResponse, createFortuneResponse, handleApiError } from '@/lib/api-response-utils';

interface PersonInfo {
    name: string;
    birth_date: string;
    age?: string;
    sign?: string;
    personality_traits?: string[];
    intimate_preferences?: string;
}

interface ChemistryInfo {
    person1: PersonInfo;
    person2: PersonInfo;
    relationship_duration: string;
    intimacy_level: string;
    concerns?: string;
}

export const POST = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  try {
    const body: ChemistryInfo = await request.json();

    if (!body.person1?.name || !body.person2?.name || !body.relationship_duration || !body.intimacy_level) {
      return createErrorResponse('필수 정보(이름, 관계 기간, 친밀도 단계)를 모두 입력해주세요.', undefined, undefined, 400);
    }

    console.log(`💕 속궁합 분석 시작: ${body.person1.name} ↔️ ${body.person2.name}`);

    // 기본 프로필 구성
    const profile = {
      name: `${body.person1.name} & ${body.person2.name}`,
      birthDate: '1990-01-01' // 기본값
    };

    // OpenAI를 사용한 속궁합 분석
    const fortuneResult = await generateSingleFortune('chemistry', profile, body);

    console.log('✅ 속궁합 분석 완료');

    return createFortuneResponse({ type: 'chemistry', person1: body.person1,
        person2: body.person2,
        relationship_info: {
          duration: body.relationship_duration,
          intimacy_level: body.intimacy_level,
          concerns: body.concerns
        },
        ...fortuneResult,
        generated_at: new Date().toISOString() }, 'chemistry', req.userId);

  } catch (error: any) {
    console.error('Chemistry fortune API error:', error);
    return createSafeErrorResponse(error, '속궁합 분석 중 오류가 발생했습니다.');
  }
});
