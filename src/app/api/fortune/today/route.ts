import { NextRequest, NextResponse } from 'next/server';
import { FortuneService } from '@/lib/services/fortune-service';
import { UserProfile } from '@/lib/types/fortune-system';

export async function POST(request: NextRequest) {
  try {
    console.log('📅 오늘의 운세 API 요청 (POST)');
    
    const body = await request.json();
    const { userInfo } = body;
    
    if (!userInfo || !userInfo.name || !userInfo.birthDate) {
      return NextResponse.json(
        { 
          success: false, 
          error: '사용자 정보가 부족합니다. 이름과 생년월일이 필요합니다.' 
        },
        { status: 400 }
      );
    }
    
    console.log(`🔍 오늘의 운세 요청: 사용자 = ${userInfo.name}`);
    
    // 사용자 정보를 기반으로 일관된 ID 생성
    const generateUserId = (name: string, birthDate: string): string => {
      const crypto = require('crypto');
      const userData = `${name}_${birthDate}`;
      return `user_${crypto.createHash('md5').update(userData).digest('hex').substring(0, 8)}`;
    };
    
    const userProfile: UserProfile = {
      id: generateUserId(userInfo.name, userInfo.birthDate),
      name: userInfo.name,
      birth_date: userInfo.birthDate,
      birth_time: userInfo.birthTime || undefined,
      gender: userInfo.gender || undefined,
      mbti: userInfo.mbti || undefined,
      zodiac_sign: userInfo.zodiacSign || undefined,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };
    
    const fortuneService = FortuneService.getInstance();
    const result = await fortuneService.getOrCreateFortune(
      userProfile.id, 
      'today',
      userProfile
    );
    
    console.log('✅ 오늘의 운세 API 응답 완료:', userProfile.name);
    
    return NextResponse.json({
      success: true,
      data: result.data,
      cached: result.cached,
      cache_source: result.cache_source,
      generated_at: result.generated_at
    });
    
  } catch (error) {
    console.error('❌ 오늘의 운세 API 오류:', error);
    
    return NextResponse.json(
      { 
        success: false, 
        error: '오늘의 운세를 가져오는 중 오류가 발생했습니다.' 
      },
      { status: 500 }
    );
  }
}

// 기존 GET 메서드는 호환성을 위해 유지 (개발용 기본 프로필 사용)
export async function GET(request: NextRequest) {
  try {
    console.log('📅 오늘의 운세 API 요청 (GET - 호환성용)');
    
    // 기본 사용자 프로필 생성
    const userProfile: UserProfile = {
      id: 'demo_user',
      name: '체험 사용자',
      birth_date: '1990-01-01',
      birth_time: '오시',
      gender: '선택 안함',
      mbti: 'ENFP',
      zodiac_sign: '염소자리',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };
    
    const fortuneService = FortuneService.getInstance();
    const result = await fortuneService.getOrCreateFortune(
      userProfile.id, 
      'today',
      userProfile
    );
    
    console.log('✅ 오늘의 운세 API 응답 완료 (기본 프로필)');
    
    return NextResponse.json({
      success: true,
      data: result.data,
      cached: result.cached,
      cache_source: result.cache_source,
      generated_at: result.generated_at
    });
    
  } catch (error) {
    console.error('❌ 오늘의 운세 API 오류:', error);
    
    return NextResponse.json(
      { 
        success: false, 
        error: '오늘의 운세를 가져오는 중 오류가 발생했습니다.' 
      },
      { status: 500 }
    );
  }
} 