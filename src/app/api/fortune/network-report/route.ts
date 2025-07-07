import { NextRequest, NextResponse } from 'next/server';
import { FortuneService } from '@/lib/services/fortune-service';
import { withFortuneAuth, createSafeErrorResponse } from '@/lib/security-api-utils';
import { AuthenticatedRequest } from '@/middleware/auth';

// 개발용 기본 사용자 프로필 생성 함수
const getDefaultUserProfile = (userId: string) => ({
  id: userId,
  name: '김인주',
  birth_date: '1988-09-05',
  birth_time: '인시',
  gender: '남성' as const,
  mbti: 'ENTJ',
  zodiac_sign: '처녀자리',
  created_at: new Date().toISOString(),
  updated_at: new Date().toISOString()
});

export const GET = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  try {
    console.log('🤝 인맥보고서 API 요청 접수');
    
    const { searchParams } = new URL(request.url);
    const userId = request.userId!;
    
    console.log(`🔍 인맥보고서 요청: 사용자 ID = ${userId}`);

    // 기본 사용자 프로필 생성
    const userProfile = getDefaultUserProfile(userId);

        const result = await fortuneService.getOrCreateFortune(
      userId,
      'network-report',
      userProfile
    );

    console.log('✅ 인맥보고서 API 응답 완료:', userId);

    return NextResponse.json(result);
  } catch (error) {
    console.error('❌ 인맥보고서 API 오류:', error);
    return NextResponse.json(
      { 
        success: false, 
        error: '인맥보고서를 불러오는 중 오류가 발생했습니다.',
        data: {
          score: 75,
          summary: '인맥보고서를 준비 중입니다. 잠시 후 다시 시도해주세요.',
          benefactors: ['준비 중입니다'],
          challengers: ['준비 중입니다'],
          advice: '인맥 분석이 진행 중입니다.',
          actionItems: ['잠시 후 다시 확인해주세요'],
          lucky: { color: '#FFD700', number: 7, direction: '동쪽' }
        }
      },
      { status: 500 }
    );
  }
});
