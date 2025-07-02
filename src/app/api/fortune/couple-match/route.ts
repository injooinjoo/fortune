import { NextRequest, NextResponse } from 'next/server';
import { generateSpecializedFortune } from '@/ai/flows/generate-specialized-fortune';

interface PersonInfo {
    name: string;
    birthDate: string;
}

interface CoupleMatchInfo {
    person1: PersonInfo;
    person2: PersonInfo;
    status?: string;
    duration?: string;
    concern?: string;
}

export async function POST(req: NextRequest) {
  try {
    const body: CoupleMatchInfo = await req.json();
    const { person1, person2, status, duration, concern } = body;

    if (!person1?.name || !person1?.birthDate || !person2?.name || !person2?.birthDate) {
      return NextResponse.json(
        { error: '두 사람의 이름과 생년월일이 모두 필요합니다.' },
        { status: 400 }
      );
    }

    // Genkit 플로우에 전달할 사용자 정보 객체를 생성합니다.
    const userInfo = {
        person1: {
            name: person1.name,
            birth_date: person1.birthDate,
        },
        person2: {
            name: person2.name,
            birth_date: person2.birthDate,
        },
        status: status,
        duration: duration,
        concern: concern,
    };

    // generateSpecializedFortune 함수를 호출하여 운세 결과를 받습니다.
    const fortuneResult = await generateSpecializedFortune(
      'couple-match',
      userInfo
    );

    return NextResponse.json({
      success: true,
      analysis: fortuneResult,
      timestamp: new Date().toISOString()
    });

  } catch (error: any) {
    console.error('Couple match fortune API error:', error);
    return NextResponse.json(
      { error: '짝궁합 분석 중 오류가 발생했습니다.', details: error.message },
      { status: 500 }
    );
  }
} 