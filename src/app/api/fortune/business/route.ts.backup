import { NextRequest, NextResponse } from 'next/server';
import { generateSingleFortune } from '@/ai/openai-client';

// 요청 본문의 타입을 정의합니다.
interface BusinessInfo {
  name: string;
  birth_date: string;
  gender?: string;
  mbti?: string;
  business_type: string;
  industry: string;
  experience_years: string;
  current_stage: string;
  goals: string[];
}

export async function POST(request: NextRequest) {
  try {
    const body: BusinessInfo = await request.json();
    
    // 필수 필드 검증
    const requiredFields: (keyof BusinessInfo)[] = ['name', 'birth_date', 'business_type', 'industry', 'experience_years', 'current_stage', 'goals'];
    for (const field of requiredFields) {
      if (!body[field]) {
        return NextResponse.json(
          { error: `필수 정보가 누락되었습니다: ${field}` },
          { status: 400 }
        );
      }
    }

    // Genkit 플로우에 전달할 사용자 정보 객체를 생성합니다.
    const userInfo = {
      name: body.name,
      birth_date: body.birth_date,
      gender: body.gender,
      mbti: body.mbti,
      business_type: body.business_type,
      experience_years: body.experience_years,
      current_stage: body.current_stage,
      goals: body.goals,
    };

    // OpenAI를 사용한 사업운 분석
    const fortuneResult = await generateSingleFortune('business', userInfo);

    return NextResponse.json(fortuneResult);
    
  } catch (error: any) {
    console.error('Business API error:', error);
    return NextResponse.json(
      { error: '사업운 분석 중 오류가 발생했습니다.', details: error.message },
      { status: 500 }
    );
  }
}
