import { NextRequest, NextResponse } from 'next/server';
import { generateSpecializedFortune } from '@/ai/flows/generate-specialized-fortune';
import { generateFortuneInsights } from '@/ai/flows/generate-fortune-insights';
import { DailyFortuneService } from '@/lib/daily-fortune-service';
import { FORTUNE_TYPES } from '@/lib/fortune-data';

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { fortuneType, userInfo, additionalData, useSpecialized = true } = body;

    // 운세 타입 검증
    if (!FORTUNE_TYPES.includes(fortuneType)) {
      return NextResponse.json(
        { error: '지원하지 않는 운세 타입입니다.' },
        { status: 400 }
      );
    }

    // 필수 정보 검증
    if (!userInfo?.name || !userInfo?.birth_date) {
      return NextResponse.json(
        { error: '이름과 생년월일은 필수입니다.' },
        { status: 400 }
      );
    }

    // 오늘 이미 생성된 운세가 있는지 확인
    const userId = await DailyFortuneService.getUserId();
    const existingFortune = await DailyFortuneService.getTodayFortune(userId, fortuneType);
    
    if (existingFortune) {
      return NextResponse.json({
        success: true,
        data: existingFortune.fortune_data,
        cached: true,
        message: '오늘 이미 생성된 운세입니다.'
      });
    }

    let fortuneResult;

    // 특화된 운세 생성 vs 일반 운세 생성
    if (useSpecialized && isSpecializedFortuneType(fortuneType)) {
      fortuneResult = await generateSpecializedFortune(
        fortuneType,
        userInfo,
        additionalData
      );
    } else {
      // 기존 일반 운세 생성 플로우 사용
      const aiInput = {
        birthdate: userInfo.birth_date,
        mbti: userInfo.mbti || 'UNKNOWN',
        gender: userInfo.gender || '선택 안함',
        birthTime: userInfo.birth_time || '모름',
        fortuneTypes: [fortuneType],
      };

      const result = await generateFortuneInsights(aiInput);
      fortuneResult = {
        user_info: userInfo,
        insights: result.insights.reduce((acc, insight) => {
          acc[insight.fortuneType] = insight.insightText;
          return acc;
        }, {} as Record<string, string>),
        metadata: {
          ...additionalData,
          sajuData: result.sajuData,
        },
      };
    }

    // 데이터베이스에 저장
    const savedFortune = await DailyFortuneService.saveTodayFortune(
      userId,
      fortuneType,
      fortuneResult
    );

    if (!savedFortune) {
      throw new Error('운세 저장에 실패했습니다.');
    }

    return NextResponse.json({
      success: true,
      data: fortuneResult,
      cached: false,
      message: '새로운 운세가 생성되었습니다.'
    });

  } catch (error) {
    console.error('운세 생성 API 오류:', error);
    
    return NextResponse.json(
      { 
        error: error instanceof Error ? error.message : '운세 생성 중 오류가 발생했습니다.',
        success: false
      },
      { status: 500 }
    );
  }
}

// 특화된 운세 생성이 가능한 타입들
function isSpecializedFortuneType(fortuneType: string): boolean {
  const specializedTypes = [
    'lucky-hiking', 'lucky-running', 'lucky-cycling', 'lucky-tennis', 'lucky-golf',
    'lucky-baseball', 'lucky-fishing', 'lucky-swimming',
    'lucky-investment', 'lucky-realestate', 'business', 'startup',
    'lucky-color', 'lucky-number', 'lucky-items',
    'mbti', 'saju', 'tarot', 'physiognomy'
  ];
  
  return specializedTypes.includes(fortuneType);
}

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const fortuneType = searchParams.get('type');
    
    if (!fortuneType) {
      return NextResponse.json(
        { error: '운세 타입이 필요합니다.' },
        { status: 400 }
      );
    }

    // 오늘의 운세 조회
    const userId = await DailyFortuneService.getUserId();
    const todayFortune = await DailyFortuneService.getTodayFortune(userId, fortuneType);

    if (todayFortune) {
      return NextResponse.json({
        success: true,
        data: todayFortune.fortune_data,
        exists: true,
        createdAt: todayFortune.created_at
      });
    } else {
      return NextResponse.json({
        success: true,
        data: null,
        exists: false,
        message: '오늘 생성된 운세가 없습니다.'
      });
    }

  } catch (error) {
    console.error('운세 조회 API 오류:', error);
    
    return NextResponse.json(
      { 
        error: '운세 조회 중 오류가 발생했습니다.',
        success: false
      },
      { status: 500 }
    );
  }
} 