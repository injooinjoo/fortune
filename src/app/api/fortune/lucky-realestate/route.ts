import { NextRequest, NextResponse } from 'next/server';
import { generateSingleFortune } from '@/ai/openai-client';
import { withFortuneAuth, createSafeErrorResponse } from '@/lib/security-api-utils';
import { AuthenticatedRequest } from '@/middleware/auth';
import { FortuneService } from '@/lib/services/fortune-service';
import { createSuccessResponse, createErrorResponse, createFortuneResponse, handleApiError } from '@/lib/api-response-utils';

// 요청 본문의 타입을 정의합니다.
interface RealEstateRequest {
  name: string;
  birth_date: string;
  gender: string;
  mbti: string;
  investment_experience: string;
  risk_tolerance: string;
  budget_range: string;
  investment_goals: string[];
  // 기존의 다른 필드들도 필요에 따라 추가할 수 있습니다.
  // current_age, investment_purpose, preferred_areas, property_types, 
  // investment_timeline, current_situation, concerns
}

export const POST = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  try {
    const body: RealEstateRequest = await request.json();
    
    // 필수 필드 검증
    const requiredFields: (keyof RealEstateRequest)[] = ['name', 'birth_date', 'investment_experience', 'risk_tolerance', 'budget_range', 'investment_goals'];
    for (const field of requiredFields) {
      if (!body[field]) {
        return createErrorResponse('필수 정보가 누락되었습니다: ${field}', undefined, undefined, 400);
      }
    }

    // Genkit 플로우에 전달할 사용자 정보 객체를 생성합니다.
    // BusinessInfoSchema에 맞게 데이터를 변환합니다.
    const userInfo = {
      name: body.name,
      birth_date: body.birth_date,
      gender: body.gender,
      mbti: body.mbti,
      business_type: 'real_estate', // 운세 타입을 명확히 지정
      experience_years: body.investment_experience,
      current_stage: body.risk_tolerance, // risk_tolerance를 current_stage로 매핑
      goals: body.investment_goals,
    };

    // generateSingleFortune 함수를 호출하여 운세 결과를 받습니다.
    const fortuneResult = await generateSingleFortune(
      'lucky-realestate',
      userInfo
    );

    return NextResponse.json(fortuneResult);
    
  } catch (error: any) {
    console.error('Lucky realestate API error:', error);
    return createSafeErrorResponse(error, '부동산운 분석 중 오류가 발생했습니다.');
  }
});
