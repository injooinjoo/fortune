// 사용자 프로필 관리 API
// 작성일: 2024-12-19

import { NextRequest, NextResponse } from 'next/server';
import { saveUserProfile, getUserProfile, getAllProfiles } from '@/lib/mock-storage';

// 임시로 인증 우회 (개발용)
async function getCurrentUser(request?: NextRequest) {
  const userId = request?.nextUrl.searchParams.get('userId') || `guest_${Date.now()}`;
  return {
    id: userId,
    email: 'dev@example.com'
  };
}

export async function POST(request: NextRequest) {
  try {
    const user = await getCurrentUser(request);
    const profileData = await request.json();

    console.log('프로필 저장 요청:', profileData);

    // 필수 필드 검증
    if (!profileData.name || !profileData.birth_date) {
      return NextResponse.json(
        { 
          success: false, 
          error: '이름과 생년월일은 필수입니다.' 
        },
        { status: 400 }
      );
    }

    // 생년월일 형식 검증
    const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
    if (!dateRegex.test(profileData.birth_date)) {
      return NextResponse.json(
        { 
          success: false, 
          error: '생년월일 형식이 올바르지 않습니다. (YYYY-MM-DD)' 
        },
        { status: 400 }
      );
    }

    // 프로필 데이터 구성
    const userProfile = {
      id: user.id,
      name: profileData.name.trim(),
      birth_date: profileData.birth_date,
      birth_time: profileData.birth_time || undefined,
      gender: profileData.gender || '선택 안함',
      mbti: profileData.mbti || undefined,
      zodiac_sign: getZodiacSign(profileData.birth_date),
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    // 메모리에 저장 (실제로는 DB에 저장)
    saveUserProfile(user.id, userProfile);

    console.log('프로필 저장 완료:', userProfile);

    return NextResponse.json({
      success: true,
      data: userProfile,
      message: '프로필이 성공적으로 저장되었습니다.'
    });

  } catch (error) {
    console.error('프로필 저장 오류:', error);
    return NextResponse.json(
      { 
        success: false, 
        error: error instanceof Error ? error.message : '서버 오류가 발생했습니다.' 
      },
      { status: 500 }
    );
  }
}

export async function GET(request: NextRequest) {
  try {
    const user = await getCurrentUser(request);
    const profile = getUserProfile(user.id);

    if (!profile) {
      return NextResponse.json(
        { userId: user.id, found: false, profile: undefined },
        { status: 404 }
      );
    }

    return NextResponse.json({
      userId: user.id,
      found: true,
      profile: profile
    });

  } catch (error) {
    console.error('프로필 조회 오류:', error);
    return NextResponse.json(
      { 
        success: false, 
        error: error instanceof Error ? error.message : '서버 오류가 발생했습니다.' 
      },
      { status: 500 }
    );
  }
}

// 생년월일로 별자리 계산
function getZodiacSign(birthDate: string): string {
  const date = new Date(birthDate);
  const month = date.getMonth() + 1;
  const day = date.getDate();

  if ((month === 3 && day >= 21) || (month === 4 && day <= 19)) return '양자리';
  if ((month === 4 && day >= 20) || (month === 5 && day <= 20)) return '황소자리';
  if ((month === 5 && day >= 21) || (month === 6 && day <= 20)) return '쌍둥이자리';
  if ((month === 6 && day >= 21) || (month === 7 && day <= 22)) return '게자리';
  if ((month === 7 && day >= 23) || (month === 8 && day <= 22)) return '사자자리';
  if ((month === 8 && day >= 23) || (month === 9 && day <= 22)) return '처녀자리';
  if ((month === 9 && day >= 23) || (month === 10 && day <= 22)) return '천칭자리';
  if ((month === 10 && day >= 23) || (month === 11 && day <= 21)) return '전갈자리';
  if ((month === 11 && day >= 22) || (month === 12 && day <= 21)) return '사수자리';
  if ((month === 12 && day >= 22) || (month === 1 && day <= 19)) return '염소자리';
  if ((month === 1 && day >= 20) || (month === 2 && day <= 18)) return '물병자리';
  return '물고기자리';
} 