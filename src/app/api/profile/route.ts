import { logger } from '@/lib/logger';
import { NextRequest } from 'next/server';
import { withAuth, AuthenticatedRequest } from '@/middleware/auth';
import { userProfileService, type UserProfile } from '@/lib/supabase';
import { createSuccessResponse, createErrorResponse } from '@/lib/api-response-utils';

// 프로필 조회 (GET)
export async function GET(request: NextRequest) {
  return withAuth(request, async (req: AuthenticatedRequest) => {
    try {
      logger.debug('🔍 프로필 조회 요청:', req.userId);
      
      const profile = await userProfileService.getProfile(req.userId!);

      if (!profile) {
        return createErrorResponse(
          '프로필을 찾을 수 없습니다.',
          undefined,
          { userId: req.userId, found: false },
          404
        );
      }

      logger.debug('✅ 프로필 조회 성공:', profile.name);

      return createSuccessResponse(profile, undefined, {
        userId: req.userId,
        found: true
      });

    } catch (error) {
      logger.error('🚨 프로필 조회 오류:', error);
      return createErrorResponse(
        error instanceof Error ? error.message : '서버 오류가 발생했습니다.',
        undefined,
        undefined,
        500
      );
    }
  });
}

// 프로필 생성/수정 (POST)
export async function POST(request: NextRequest) {
  return withAuth(request, async (req: AuthenticatedRequest) => {
    try {
      const profileData = await request.json();

      logger.debug('💾 프로필 저장 요청:', { userId: req.userId, data: profileData });

      // 필수 필드 검증
      if (!profileData.name || !profileData.birth_date) {
        return createErrorResponse(
          '이름과 생년월일은 필수입니다.',
          undefined,
          undefined,
          400
        );
      }

      // 생년월일 형식 검증
      const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
      if (!dateRegex.test(profileData.birth_date)) {
        return createErrorResponse(
          '생년월일 형식이 올바르지 않습니다. (YYYY-MM-DD)',
          undefined,
          undefined,
          400
        );
      }

      // 프로필 데이터 구성 (UserProfile 인터페이스에 맞춤)
      const userProfile: Partial<UserProfile> = {
        id: req.userId!,
        email: req.userEmail,
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
        avatar_url: profileData.avatar_url || undefined,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      };

      // Supabase를 통해 프로필 저장
      const savedProfile = await userProfileService.upsertProfile(userProfile);

      if (!savedProfile) {
        return createErrorResponse(
          '프로필 저장에 실패했습니다.',
          undefined,
          undefined,
          500
        );
      }

      logger.debug('✅ 프로필 저장 완료:', savedProfile.name);

      return createSuccessResponse(savedProfile, '프로필이 성공적으로 저장되었습니다.');

    } catch (error) {
      logger.error('🚨 프로필 저장 오류:', error);
      return createErrorResponse(
        error instanceof Error ? error.message : '서버 오류가 발생했습니다.',
        undefined,
        undefined,
        500
      );
    }
  });
}

// 프로필 업데이트 (PUT)
export async function PUT(request: NextRequest) {
  return withAuth(request, async (req: AuthenticatedRequest) => {
    try {
      const updateData = await request.json();

      logger.debug('📝 프로필 업데이트 요청:', { userId: req.userId, data: updateData });

      // 기존 프로필 확인
      const existingProfile = await userProfileService.getProfile(req.userId!);
      
      if (!existingProfile) {
        return createErrorResponse(
          '업데이트할 프로필을 찾을 수 없습니다.',
          undefined,
          undefined,
          404
        );
      }

      // 업데이트할 데이터 구성
      const updatedProfile: Partial<UserProfile> = {
        ...existingProfile,
        ...updateData,
        id: req.userId!, // ID는 변경 불가
        email: req.userEmail, // 이메일은 변경 불가
        updated_at: new Date().toISOString()
      };

      // 생년월일이 변경된 경우 별자리/띠 재계산
      if (updateData.birth_date && updateData.birth_date !== existingProfile.birth_date) {
        updatedProfile.zodiac_sign = getZodiacSign(updateData.birth_date);
        updatedProfile.chinese_zodiac = getChineseZodiac(updateData.birth_date);
      }

      const savedProfile = await userProfileService.upsertProfile(updatedProfile);

      if (!savedProfile) {
        return createErrorResponse(
          '프로필 업데이트에 실패했습니다.',
          undefined,
          undefined,
          500
        );
      }

      logger.debug('✅ 프로필 업데이트 완료:', savedProfile.name);

      return createSuccessResponse(savedProfile, '프로필이 성공적으로 업데이트되었습니다.');

    } catch (error) {
      logger.error('🚨 프로필 업데이트 오류:', error);
      return createErrorResponse(
        error instanceof Error ? error.message : '서버 오류가 발생했습니다.',
        undefined,
        undefined,
        500
      );
    }
  });
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