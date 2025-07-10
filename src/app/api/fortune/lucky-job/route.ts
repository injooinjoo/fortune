import { logger } from '@/lib/logger';
import { NextRequest, NextResponse } from 'next/server';
import { generateSingleFortune } from '@/ai/openai-client';
import { withFortuneAuth, createSafeErrorResponse } from '@/lib/security-api-utils';
import { AuthenticatedRequest } from '@/middleware/auth';
import { FortuneService } from '@/lib/services/fortune-service';
import { createSuccessResponse, createErrorResponse, createFortuneResponse, handleApiError } from '@/lib/api-response-utils';

// 요청 본문의 타입을 정의합니다.
interface JobInfo {
  name: string;
  birth_date: string;
  gender?: string;
  mbti?: string;
  job_experience?: string;
  career_goals?: string[];
  // Genkit 플로우에서 사용하는 다른 필드들
  business_type: string; 
  experience_years: string;
  current_stage: string;
  goals: string[];
}

export const POST = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  try {
    const body: JobInfo = await request.json();
    
    // 필수 필드 검증
    if (!body.name || !body.birth_date || !body.job_experience || !body.career_goals) {
      return createErrorResponse('필수 정보(이름, 생년월일, 경력, 목표)가 누락되었습니다.', undefined, undefined, 400);
    }

    // Genkit 플로우에 전달할 사용자 정보 객체를 생성합니다.
    // BusinessInfoSchema에 맞게 데이터를 변환합니다.
    const userInfo = {
      name: body.name,
      birth_date: body.birth_date,
      gender: body.gender,
      mbti: body.mbti,
      business_type: 'job', // 운세 타입을 명확히 지정
      experience_years: body.job_experience,
      current_stage: body.job_experience, // job_experience를 current_stage로 매핑
      goals: body.career_goals,
    };

    // generateSingleFortune 함수를 호출하여 운세 결과를 받습니다.
    const fortuneResult = await generateSingleFortune(
      'lucky-job',
      userInfo
    );

    return NextResponse.json(fortuneResult);
    
  } catch (error: any) {
    logger.error('Lucky job API error:', error);
    return createSafeErrorResponse(error, '직업운 분석 중 오류가 발생했습니다.');
  }
});
