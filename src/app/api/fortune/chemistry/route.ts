import { NextRequest, NextResponse } from 'next/server';
import { generateSpecializedFortune } from '@/ai/flows/generate-specialized-fortune';

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

export async function POST(req: NextRequest) {
  try {
    const body: ChemistryInfo = await req.json();

    if (!body.person1?.name || !body.person2?.name || !body.relationship_duration || !body.intimacy_level) {
      return NextResponse.json(
        { error: '필수 정보(이름, 관계 기간, 친밀도 단계)를 모두 입력해주세요.' },
        { status: 400 }
      );
    }

    // Genkit 플로우에 전달할 사용자 정보 객체를 생성합니다.
    const userInfo = {
        person1: body.person1,
        person2: body.person2,
        relationship_duration: body.relationship_duration,
        intimacy_level: body.intimacy_level,
        concerns: body.concerns,
    };

    // generateSpecializedFortune 함수를 호출하여 운세 결과를 받습니다.
    const fortuneResult = await generateSpecializedFortune(
      'chemistry',
      userInfo
    );

    return NextResponse.json({
      success: true,
      analysis: fortuneResult,
      timestamp: new Date().toISOString()
    });

  } catch (error: any) {
    console.error('Chemistry fortune API error:', error);
    return NextResponse.json(
      { error: '속궁합 분석 중 오류가 발생했습니다.', details: error.message },
      { status: 500 }
    );
  }
} 