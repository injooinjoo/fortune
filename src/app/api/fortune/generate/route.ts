import { NextRequest, NextResponse } from 'next/server';
import { runFlow } from 'genkit';
import { generateComprehensiveDailyFortune, generateLifeProfile, generateInteractiveFortune } from '@/ai/flows/generate-specialized-fortune';

export async function POST(req: NextRequest) {
  try {
    const { request_type, requested_categories, user_profile, additional_input, generation_context } = await req.json();

    let result: any;

    switch (request_type) {
      case 'onboarding_complete':
        // 온보딩 완료 시 평생 운세 패키지 생성
        result = await runFlow(generateLifeProfile, { userProfile: user_profile });
        break;
      case 'daily_refresh':
        // 매일 자정 또는 일일 운세 요청 시 종합 일일 운세 생성
        result = await runFlow(generateComprehensiveDailyFortune, { userProfile: user_profile, date: generation_context.target_date });
        break;
      case 'user_direct_request':
        // 사용자 직접 요청 시 특정 운세 생성
        // requested_categories를 기반으로 적절한 플로우 호출
        // 여기서는 예시로 generateInteractiveFortune을 사용하지만, 실제로는 requested_categories에 따라 분기해야 함
        result = await runFlow(generateInteractiveFortune, { userProfile: user_profile, category: requested_categories[0], input: additional_input });
        break;
      default:
        return NextResponse.json({ error: 'Invalid request_type' }, { status: 400 });
    }

    return NextResponse.json(result);
  } catch (error: any) {
    console.error('API 호출 중 오류 발생:', error);
    return NextResponse.json({ error: error.message || 'Internal Server Error' }, { status: 500 });
  }
}