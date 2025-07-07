import { NextRequest, NextResponse } from 'next/server';
import { generateSingleFortune } from '@/ai/openai-client';

interface ExLoverInfo {
    name: string;
    birth_date: string;
    relationship_duration: string;
    breakup_reason: string;
    time_since_breakup: string;
    feelings?: string;
}

export const POST = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  try {
    const body: ExLoverInfo = await req.json();

    if (!body.name || !body.relationship_duration || !body.breakup_reason || !body.time_since_breakup) {
      return NextResponse.json(
        { error: '필수 정보(이름, 교제기간, 이별사유, 이별후 시간)를 모두 입력해주세요.' },
        { status: 400 }
      );
    }

    // Genkit 플로우에 전달할 사용자 정보 객체를 생성합니다.
    const userInfo = {
        name: body.name,
        birth_date: body.birth_date,
        relationship_duration: body.relationship_duration,
        breakup_reason: body.breakup_reason,
        time_since_breakup: body.time_since_breakup,
        feelings: body.feelings,
    };

    // generateSingleFortune 함수를 호출하여 운세 결과를 받습니다.
    const fortuneResult = await generateSingleFortune(
      'ex-lover',
      userInfo
    );

    return NextResponse.json({
      success: true,
      analysis: fortuneResult,
      timestamp: new Date().toISOString()
    });

  } catch (error: any) {
    console.error('Ex-lover fortune API error:', error);
    return createSafeErrorResponse(error, '헤어진 애인 분석 중 오류가 발생했습니다.');
  }
});
