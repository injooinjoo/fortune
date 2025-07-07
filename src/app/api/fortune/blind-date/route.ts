import { NextRequest, NextResponse } from 'next/server';
import { generateSingleFortune } from '@/ai/openai-client';

interface BlindDateInfo {
    name: string;
    birth_date: string;
    age: string;
    job?: string;
    personality?: string[];
    ideal_type?: string;
    experience_level: string;
    preferred_location?: string;
    preferred_activity: string;
    concerns?: string;
}

export const POST = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  try {
    const body: BlindDateInfo = await req.json();

    if (!body.name || !body.age || !body.experience_level || !body.preferred_activity) {
      return NextResponse.json(
        { error: '필수 정보(이름, 나이, 소개팅 경험, 선호하는 활동)를 모두 입력해주세요.' },
        { status: 400 }
      );
    }

    // Genkit 플로우에 전달할 사용자 정보 객체를 생성합니다.
    const userInfo = {
        name: body.name,
        birth_date: body.birth_date,
        age: body.age,
        job: body.job,
        personality: body.personality,
        ideal_type: body.ideal_type,
        experience_level: body.experience_level,
        preferred_location: body.preferred_location,
        preferred_activity: body.preferred_activity,
        concerns: body.concerns,
    };

    // generateSingleFortune 함수를 호출하여 운세 결과를 받습니다.
    const fortuneResult = await generateSingleFortune(
      'blind-date',
      userInfo
    );

    return NextResponse.json({
      success: true,
      analysis: fortuneResult,
      timestamp: new Date().toISOString()
    });

  } catch (error: any) {
    console.error('Blind date fortune API error:', error);
    return createSafeErrorResponse(error, '소개팅 분석 중 오류가 발생했습니다.');
  }
});
