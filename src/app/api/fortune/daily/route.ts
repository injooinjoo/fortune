import { NextRequest, NextResponse } from 'next/server';
import { FortuneService } from '@/lib/services/fortune-service';
import { withAuth, AuthenticatedRequest } from '@/middleware/auth';

const fortuneService = new FortuneService();

export async function GET(request: NextRequest) {
  return withAuth(request, async (req: AuthenticatedRequest) => {
    console.log('📅 일일 운세 API 요청');
    
    try {
      // Use authenticated userId if available, otherwise use guest identifier
      const userId = req.userId || `guest_${req.headers.get('x-forwarded-for') || 'unknown'}`;
      
      console.log('🔍 일일 운세 요청: 사용자 ID =', userId, '(Guest:', req.isGuest, ')');
      
      // For guest users, add cache headers to reduce API calls
      const result = await fortuneService.getOrCreateFortune(userId, 'daily');
      
      console.log('✅ 일일 운세 API 응답 완료:', userId);
      
      const response = NextResponse.json(result);
      
      // Add cache headers for guest users
      if (req.isGuest) {
        response.headers.set('Cache-Control', 'public, max-age=3600'); // 1 hour cache
      }
      
      return response;
      
    } catch (error) {
      console.error('❌ 일일 운세 API 오류:', error);
      return NextResponse.json(
        { error: '일일 운세 분석 중 오류가 발생했습니다.' },
        { status: 500 }
      );
    }
  });
} 