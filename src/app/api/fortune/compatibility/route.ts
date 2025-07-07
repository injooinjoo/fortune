import { NextRequest, NextResponse } from 'next/server';
import { generateCompatibilityFortune } from '@/ai/openai-client';

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

export const POST = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  console.log('💕 궁합 운세 API 요청');
  
  try {
    const body: CompatibilityRequest = await req.json();
    const { person1, person2 } = body;

    if (!person1?.name || !person1?.birth_date || !person2?.name || !person2?.birth_date) {
      return NextResponse.json(
        { error: '두 사람의 이름과 생년월일이 모두 필요합니다.' },
        { status: 400 }
      );
    }

    console.log(`🔍 궁합 분석 시작: ${person1.name} ↔️ ${person2.name}`);

    // OpenAI를 사용한 궁합 분석
    const fortuneResult = await generateCompatibilityFortune(person1, person2);

    console.log('✅ 궁합 분석 완료');

    return NextResponse.json({
      success: true,
      data: {
        type: 'compatibility',
        person1: {
          name: person1.name,
          birth_date: person1.birth_date
        },
        person2: {
          name: person2.name,
          birth_date: person2.birth_date
        },
        ...fortuneResult,
        generated_at: new Date().toISOString()
      }
    });

  } catch (error: any) {
    console.error('❌ 궁합 분석 실패:', error);
    return createSafeErrorResponse(error, '궁합 분석 중 오류가 발생했습니다.');
  }
}

// GET 요청 (기본 정보 제공)
export const GET = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  return NextResponse.json({
    name: '궁합 운세',
    description: '두 사람의 궁합을 종합적으로 분석',
    required_fields: ['person1', 'person2'],
    person_fields: {
      required: ['name', 'birth_date'],
      optional: ['gender', 'mbti']
    },
    analysis_areas: [
      '성격 궁합',
      '소통 스타일',
      '연애 케미스트리',
      '미래 발전 가능성'
    ],
    example_request: {
      person1: {
        name: '김영희',
        birth_date: '1990-05-15',
        gender: 'female',
        mbti: 'ENFP'
      },
      person2: {
        name: '박철수',
        birth_date: '1988-10-20',
        gender: 'male',
        mbti: 'INTJ'
      }
    }
  });
});
