import { NextRequest, NextResponse } from 'next/server';
import { generateSpecializedFortune } from '@/ai/flows/generate-specialized-fortune';

interface PersonInfo {
    name: string;
    birth_date: string;
    gender?: string;
    mbti?: string;
}

interface CompatibilityRequest {
    person1: PersonInfo;
    person2: PersonInfo;
}

export async function POST(req: NextRequest) {
  try {
    const body: CompatibilityRequest = await req.json();
    const { person1, person2 } = body;

    if (!person1?.name || !person1?.birth_date || !person2?.name || !person2?.birth_date) {
      return NextResponse.json(
        { error: '두 사람의 이름과 생년월일이 모두 필요합니다.' },
        { status: 400 }
      );
    }

    // Genkit 플로우에 전달할 사용자 정보 객체를 생성합니다.
    const userInfo = {
        person1: {
            name: person1.name,
            birth_date: person1.birth_date,
            gender: person1.gender,
            mbti: person1.mbti,
        },
        person2: {
            name: person2.name,
            birth_date: person2.birth_date,
            gender: person2.gender,
            mbti: person2.mbti,
        },
    };

    // generateSpecializedFortune 함수를 호출하여 운세 결과를 받습니다.
    const fortuneResult = await generateSpecializedFortune(
      'compatibility',
      userInfo
    );

    return NextResponse.json({
      success: true,
      compatibility: fortuneResult,
      timestamp: new Date().toISOString()
    });

  } catch (error: any) {
    console.error('Compatibility fortune API error:', error);
    return NextResponse.json(
      { error: '궁합 분석 중 오류가 발생했습니다.', details: error.message },
      { status: 500 }
    );
  }
} 