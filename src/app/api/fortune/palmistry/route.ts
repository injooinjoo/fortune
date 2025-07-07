import { NextRequest, NextResponse } from 'next/server';
import { generateImageBasedFortune } from '@/ai/openai-client';
import { withFortuneAuth, createSafeErrorResponse } from '@/lib/security-api-utils';
import { AuthenticatedRequest } from '@/middleware/auth';
import { FortuneService } from '@/lib/services/fortune-service';
import { createSuccessResponse, createErrorResponse, createFortuneResponse, handleApiError } from '@/lib/api-response-utils';

export const POST = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  console.log('✋ 손금 운세 API 요청');
  
  try {
    const formData = await request.formData();
    const file = formData.get('image') as File;
    const name = formData.get('name') as string;
    const birthDate = formData.get('birthDate') as string;
    const handType = formData.get('handType') as string || 'right';
    const userId = formData.get('userId') as string || 'guest';

    if (!file) {
      return createErrorResponse('손바닥 이미지 파일이 필요합니다.', undefined, undefined, 400);
    }

    console.log(`🔍 손금 분석 시작: ${name} (${handType}손)`);

    // 이미지를 Base64로 변환
    const arrayBuffer = await file.arrayBuffer();
    const base64 = Buffer.from(arrayBuffer).toString('base64');

    // 사용자 프로필 구성
    const profile = {
      name: name || '사용자',
      birthDate: birthDate || '1990-01-01',
      handType
    };

    // 손금 분석 수행
    const result = await generateImageBasedFortune('palmistry', base64, profile);

    console.log('✅ 손금 분석 완료');

    return createFortuneResponse({ type: 'palmistry', hand_type: handType,
        ...result,
        palmistry_lines: {
          life_line: '생명선 분석 결과',
          heart_line: '감정선 분석 결과', 
          head_line: '두뇌선 분석 결과',
          fate_line: '운명선 분석 결과'
        },
        user_info: profile,
        generated_at: new Date().toISOString() }, 'palmistry', req.userId);
    
  } catch (error) {
    console.error('❌ 손금 분석 실패:', error);
    return createSafeErrorResponse(error, '손금 분석 중 오류가 발생했습니다.');
  }
});

// GET 요청 (기본 정보 제공)
export const GET = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  return NextResponse.json({
    name: '손금 운세',
    description: '손바닥 사진을 통한 손금학적 분석',
    required_fields: ['image', 'name', 'birthDate', 'handType'],
    image_requirements: {
      format: 'JPG, PNG, WebP',
      max_size: '5MB',
      guidelines: [
        '손바닥을 펼친 상태로 촬영',
        '손바닥의 선이 명확히 보이는 사진',
        '밝은 곳에서 촬영',
        '주로 오른손을 사용 (왼손잡이는 왼손)',
        '손목까지 포함하여 촬영'
      ]
    },
    hand_types: {
      right: '오른손 (주로 사용)',
      left: '왼손 (왼손잡이용)'
    }
  });
});
