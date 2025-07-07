import { NextRequest, NextResponse } from 'next/server';
import { generateMovingFortune } from '@/ai/openai-client';

// POST 요청 (상세 이사 정보로 분석)
export async function POST(request: NextRequest) {
  console.log('🏠 이사운 API 요청 (상세 분석)');
  
  try {
    const body = await request.json();
    const { 
      name, 
      birthDate, 
      currentLocation, 
      newLocation, 
      movingDate, 
      reason,
      userId = 'guest'
    } = body;

    if (!name || !birthDate) {
      return NextResponse.json(
        { error: '이름과 생년월일이 필요합니다.' },
        { status: 400 }
      );
    }

    console.log(`🔍 이사운 분석 시작: ${name} (${currentLocation} → ${newLocation})`);

    // 사용자 프로필 구성
    const profile = {
      name,
      birthDate
    };

    // 이사 상세 정보
    const movingDetails = {
      currentLocation: currentLocation || '현재 거주지',
      newLocation: newLocation || '새로운 거주지',
      movingDate: movingDate || '미정',
      reason: reason || '일반 이사'
    };

    // OpenAI를 사용한 이사 운세 분석
    const result = await generateMovingFortune(profile, movingDetails);

    console.log('✅ 이사운 분석 완료');

    return NextResponse.json({
      success: true,
      data: {
        type: 'moving',
        user_info: profile,
        moving_details: movingDetails,
        ...result,
        generated_at: new Date().toISOString()
      }
    });
    
  } catch (error) {
    console.error('❌ 이사운 분석 실패:', error);
    return NextResponse.json(
      { error: '이사운 분석 중 오류가 발생했습니다.' },
      { status: 500 }
    );
  }
}

// GET 요청 (기본 정보 제공)
export async function GET() {
  return NextResponse.json({
    name: '이사 운세',
    description: '이사 시기와 방향을 종합적으로 분석하여 최적의 이사 조언 제공',
    required_fields: ['name', 'birthDate'],
    optional_fields: ['currentLocation', 'newLocation', 'movingDate', 'reason'],
    analysis_areas: [
      '이사 시기 분석',
      '방향/위치 운세',
      '재정적 영향',
      '가족 화목도',
      '직업/사업 영향'
    ],
    moving_reasons: [
      '일반 이사',
      '직장 이전',
      '결혼',
      '자녀 교육',
      '투자/사업',
      '건강상 이유'
    ],
    example_request: {
      name: '김영희',
      birthDate: '1990-05-15',
      currentLocation: '서울 강남구',
      newLocation: '경기 수원시',
      movingDate: '2025-03-15',
      reason: '직장 이전'
    }
  });
} 