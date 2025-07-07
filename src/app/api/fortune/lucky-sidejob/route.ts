import { NextRequest, NextResponse } from 'next/server';
import { generateSingleFortune } from '@/ai/openai-client';
import { withFortuneAuth, createSafeErrorResponse } from '@/lib/security-api-utils';
import { AuthenticatedRequest } from '@/middleware/auth';
import { FortuneService } from '@/lib/services/fortune-service';
import { createSuccessResponse, createErrorResponse, createFortuneResponse, handleApiError } from '@/lib/api-response-utils';

// 요청 본문의 타입을 정의합니다.
interface SidejobInfo {
  name: string;
  birth_date: string;
  gender?: string;
  mbti?: string;
  skills?: string[];
  interests?: string[];
  // Genkit 플로우에서 사용하는 다른 필드들
  business_type: string; 
  experience_years: string;
  current_stage: string;
  goals: string[];
}

export const POST = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  try {
    const body: SidejobInfo = await request.json();
    
    // 필수 필드 검증
    if (!body.name || !body.birth_date || !body.skills || !body.interests) {
      return createErrorResponse('필수 정보(이름, 생년월일, 기술, 관심사)가 누락되었습니다.', undefined, undefined, 400);
    }

    // Genkit 플로우에 전달할 사용자 정보 객체를 생성합니다.
    // BusinessInfoSchema에 맞게 데이터를 변환합니다.
    const userInfo = {
      name: body.name,
      birth_date: body.birth_date,
      gender: body.gender,
      mbti: body.mbti,
      business_type: 'sidejob', // 운세 타입을 명확히 지정
      experience_years: '1-3년', // 부업은 대부분 경험이 적다고 가정
      current_stage: 'idea', // 아이디어 단계로 가정
      goals: body.interests, // 관심사를 목표로 매핑
    };

    // generateSingleFortune 함수를 호출하여 운세 결과를 받습니다.
    const fortuneResult = await generateSingleFortune(
      'lucky-sidejob',
      userInfo
    );

    return NextResponse.json(fortuneResult);
    
  } catch (error: any) {
    console.error('Lucky sidejob API error:', error);
    return createSafeErrorResponse(error, '부업운 분석 중 오류가 발생했습니다.');
  }
});
