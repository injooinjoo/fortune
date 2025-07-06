// 사용자 프로필 관리 API (Supabase 기반)
// 수정일: 2024-12-19

import { NextRequest, NextResponse } from 'next/server';
import { supabase, userProfileService, type UserProfile } from '@/lib/supabase';

// 서버 사이드에서 사용자 확인 (쿠키 기반 세션 또는 요청 파라미터)
async function getCurrentUser(request: NextRequest) {
  try {
    // 1. URL 파라미터에서 사용자 ID 확인 (개발/테스트용)
    const userId = request.nextUrl.searchParams.get('userId');
    if (userId) {
      console.log('📍 URL 파라미터에서 사용자 ID 추출:', userId);
      return { id: userId, email: `${userId}@temp.com` };
    }

    // 2. 쿠키에서 세션 확인 시도
    const cookies = request.headers.get('cookie');
    if (cookies) {
      // Supabase 세션 쿠키 확인
      const sessionMatch = cookies.match(/sb-[^=]+-auth-token=([^;]+)/);
      if (sessionMatch) {
        try {
          const sessionToken = decodeURIComponent(sessionMatch[1]);
          const sessionData = JSON.parse(sessionToken);
          
          if (sessionData.user) {
            console.log('✅ 쿠키에서 사용자 세션 확인:', sessionData.user.email);
            return sessionData.user;
          }
        } catch (e) {
          console.log('⚠️ 세션 쿠키 파싱 실패');
        }
      }
    }

    // 3. Authorization 헤더 확인 (API 호출용)
    const authHeader = request.headers.get('authorization');
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.substring(7);
      
      const { data, error } = await supabase.auth.getUser(token);
      
      if (!error && data.user) {
        console.log('✅ Authorization 헤더에서 사용자 확인:', data.user.email);
        return data.user;
      }
    }

    console.log('❌ 인증된 사용자를 찾을 수 없음');
    return null;
  } catch (error) {
    console.error('🚨 사용자 인증 오류:', error);
    return null;
  }
}

// 인증되지 않은 요청에 대한 응답
function unauthorizedResponse() {
  return NextResponse.json(
    { 
      success: false, 
      error: '인증이 필요합니다. 로그인 후 다시 시도해주세요.' 
    },
    { status: 401 }
  );
}

// 프로필 조회 (GET)
export async function GET(request: NextRequest) {
  try {
    const user = await getCurrentUser(request);
    
    if (!user) {
      return unauthorizedResponse();
    }

    console.log('🔍 프로필 조회 요청:', user.id);
    
    const profile = await userProfileService.getProfile(user.id);

    if (!profile) {
      return NextResponse.json(
        { 
          success: false,
          error: '프로필을 찾을 수 없습니다.',
          userId: user.id,
          found: false 
        },
        { status: 404 }
      );
    }

    console.log('✅ 프로필 조회 성공:', profile.name);

    return NextResponse.json({
      success: true,
      data: profile,
      userId: user.id,
      found: true
    });

  } catch (error) {
    console.error('🚨 프로필 조회 오류:', error);
    return NextResponse.json(
      { 
        success: false, 
        error: error instanceof Error ? error.message : '서버 오류가 발생했습니다.' 
      },
      { status: 500 }
    );
  }
}

// 프로필 생성/수정 (POST)
export async function POST(request: NextRequest) {
  try {
    const user = await getCurrentUser(request);
    
    if (!user) {
      return unauthorizedResponse();
    }

    const profileData = await request.json();

    console.log('💾 프로필 저장 요청:', { userId: user.id, data: profileData });

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

    // 프로필 데이터 구성 (UserProfile 인터페이스에 맞춤)
    const userProfile: Partial<UserProfile> = {
      id: user.id,
      email: user.email,
      name: profileData.name.trim(),
      birth_date: profileData.birth_date,
      birth_time: profileData.birth_time || undefined,
      gender: profileData.gender as 'male' | 'female' | 'other' || undefined,
      mbti: profileData.mbti || undefined,
      blood_type: profileData.blood_type as 'A' | 'B' | 'AB' | 'O' || undefined,
      zodiac_sign: getZodiacSign(profileData.birth_date),
      chinese_zodiac: getChineseZodiac(profileData.birth_date),
      job: profileData.job || undefined,
      location: profileData.location || undefined,
      onboarding_completed: profileData.onboarding_completed ?? true,
      avatar_url: user.user_metadata?.avatar_url || undefined,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    // Supabase를 통해 프로필 저장
    const savedProfile = await userProfileService.upsertProfile(userProfile);

    if (!savedProfile) {
      return NextResponse.json(
        { 
          success: false, 
          error: '프로필 저장에 실패했습니다.' 
        },
        { status: 500 }
      );
    }

    console.log('✅ 프로필 저장 완료:', savedProfile.name);

    return NextResponse.json({
      success: true,
      data: savedProfile,
      message: '프로필이 성공적으로 저장되었습니다.'
    });

  } catch (error) {
    console.error('🚨 프로필 저장 오류:', error);
    return NextResponse.json(
      { 
        success: false, 
        error: error instanceof Error ? error.message : '서버 오류가 발생했습니다.' 
      },
      { status: 500 }
    );
  }
}

// 프로필 업데이트 (PUT)
export async function PUT(request: NextRequest) {
  try {
    const user = await getCurrentUser(request);
    
    if (!user) {
      return unauthorizedResponse();
    }

    const updateData = await request.json();

    console.log('📝 프로필 업데이트 요청:', { userId: user.id, data: updateData });

    // 기존 프로필 확인
    const existingProfile = await userProfileService.getProfile(user.id);
    
    if (!existingProfile) {
      return NextResponse.json(
        { 
          success: false, 
          error: '업데이트할 프로필을 찾을 수 없습니다.' 
        },
        { status: 404 }
      );
    }

    // 업데이트할 데이터 구성
    const updatedProfile: Partial<UserProfile> = {
      ...existingProfile,
      ...updateData,
      id: user.id, // ID는 변경 불가
      email: user.email, // 이메일은 변경 불가
      updated_at: new Date().toISOString()
    };

    // 생년월일이 변경된 경우 별자리/띠 재계산
    if (updateData.birth_date && updateData.birth_date !== existingProfile.birth_date) {
      updatedProfile.zodiac_sign = getZodiacSign(updateData.birth_date);
      updatedProfile.chinese_zodiac = getChineseZodiac(updateData.birth_date);
    }

    const savedProfile = await userProfileService.upsertProfile(updatedProfile);

    if (!savedProfile) {
      return NextResponse.json(
        { 
          success: false, 
          error: '프로필 업데이트에 실패했습니다.' 
        },
        { status: 500 }
      );
    }

    console.log('✅ 프로필 업데이트 완료:', savedProfile.name);

    return NextResponse.json({
      success: true,
      data: savedProfile,
      message: '프로필이 성공적으로 업데이트되었습니다.'
    });

  } catch (error) {
    console.error('🚨 프로필 업데이트 오류:', error);
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

// 생년월일로 띠 계산
function getChineseZodiac(birthDate: string): string {
  const year = new Date(birthDate).getFullYear();
  const animals = ['원숭이', '닭', '개', '돼지', '쥐', '소', '호랑이', '토끼', '용', '뱀', '말', '양'];
  return animals[year % 12];
}