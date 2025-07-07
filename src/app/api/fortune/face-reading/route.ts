import { NextRequest, NextResponse } from 'next/server';
import { generateImageBasedFortune } from '@/ai/openai-client';
import { withFortuneAuth, createSafeErrorResponse } from '@/lib/security-api-utils';
import { AuthenticatedRequest } from '@/middleware/auth';
import { FortuneService } from '@/lib/services/fortune-service';
import { createSuccessResponse, createErrorResponse, createFortuneResponse, handleApiError } from '@/lib/api-response-utils';

export const POST = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  console.log('📸 관상 운세 API 요청');
  
  try {
    const formData = await request.formData();
    const file = formData.get('image') as File;
    const name = formData.get('name') as string;
    const birthDate = formData.get('birthDate') as string;
    const userId = formData.get('userId') as string || 'guest';

    if (!file) {
      return createErrorResponse('이미지 파일이 필요합니다.', undefined, undefined, 400);
    }

    console.log(`🔍 관상 분석 시작: ${name} (${birthDate})`);

    // 이미지를 Base64로 변환
    const arrayBuffer = await file.arrayBuffer();
    const base64 = Buffer.from(arrayBuffer).toString('base64');

    // 사용자 프로필 구성
    const profile = {
      name: name || '사용자',
      birthDate: birthDate || '1990-01-01'
    };

    // 관상 분석 수행
    const result = await generateImageBasedFortune('face-reading', base64, profile);

    console.log('✅ 관상 분석 완료');

    return createFortuneResponse({ type: 'face-reading', ...result,
        user_info: profile,
        generated_at: new Date().toISOString() }, 'face-reading', req.userId);
    
  } catch (error) {
    console.error('❌ 관상 분석 실패:', error);
    return createSafeErrorResponse(error, '관상 분석 중 오류가 발생했습니다.');
  }
});

// GET 요청 (기본 정보 제공)
export const GET = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  return NextResponse.json({
    name: '관상 운세',
    description: '얼굴 사진을 통한 관상학적 분석',
    required_fields: ['image', 'name', 'birthDate'],
    image_requirements: {
      format: 'JPG, PNG, WebP',
      max_size: '5MB',
      guidelines: [
        '정면에서 찍은 선명한 얼굴 사진',
        '밝은 곳에서 촬영',
        '얼굴이 전체적으로 보이는 사진',
        '선글라스나 마스크 착용 금지'
      ]
    }
  });
});
