import { NextRequest, NextResponse } from 'next/server';
import { FortuneService } from '@/lib/services/fortune-service';
import { withAuth, AuthenticatedRequest } from '@/middleware/auth';

const fortuneService = new FortuneService();

export async function GET(request: NextRequest) {
  return withAuth(request, async (req: AuthenticatedRequest) => {
    console.log('📅 일일 운세 API 요청');
    
    try {
      // 인증된 사용자만 접근 가능
      if (!req.userId || req.userId === 'guest') {
        return NextResponse.json(
          { error: '로그인이 필요합니다.' },
          { status: 401 }
        );
      }
      
      console.log('🔍 일일 운세 요청: 사용자 ID =', req.userId);
      
      const result = await fortuneService.getOrCreateFortune(req.userId, 'daily');
      
      console.log('✅ 일일 운세 API 응답 완료:', req.userId);
      
      return NextResponse.json(result);
      
    } catch (error) {
      console.error('❌ 일일 운세 API 오류:', error);
      return NextResponse.json(
        { error: '일일 운세 분석 중 오류가 발생했습니다.' },
        { status: 500 }
      );
    }
  });
} 