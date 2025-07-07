import { NextRequest, NextResponse } from 'next/server';
import { 
  generateComprehensiveDailyFortune, 
  generateLifeProfile, 
  generateInteractiveFortune,
  generateGroupFortune,
} from '@/ai/flows/generate-specialized-fortune';
import { generateBatchFortunes, generateSingleFortune } from '@/ai/openai-client';

export const POST = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  console.log('🎯 통합 운세 생성 API 요청');
  
  try {
    const body = await req.json();
    const { flowType, request_type, user_profile, requested_categories, additional_input, ...input } = body;

    let result: any;

    // 새로운 플로우 타입 처리
    if (flowType) {
      switch (flowType) {
        case 'generateLifeProfile':
          result = await generateLifeProfile(input);
          break;
        case 'generateComprehensiveDailyFortune':
          result = await generateComprehensiveDailyFortune(input);
          break;
        case 'generateInteractiveFortune':
          result = await generateInteractiveFortune(input);
          break;
        case 'generateGroupFortune':
          result = await generateGroupFortune(input);
          break;
        default:
          return NextResponse.json({ error: 'Invalid flowType provided' }, { status: 400 });
      }
    } 
    // 레거시 요청 타입 처리
    else if (request_type) {
      switch (request_type) {
        case 'onboarding_complete':
          // 온보딩 완료 시 생애 운세 패키지 생성 (배치)
          console.log('🎊 온보딩 완료 - 생애 운세 배치 생성');
          const lifeFortuneCategories = ['saju', 'talent', 'destiny', 'past-life', 'tojeong'];
          result = await generateBatchFortunes({
            user_id: user_profile.userId || 'guest',
            fortunes: lifeFortuneCategories,
            profile: {
              name: user_profile.name,
              birthDate: user_profile.birth_date || user_profile.birthDate,
              gender: user_profile.gender,
              mbti: user_profile.mbti,
              blood_type: user_profile.blood_type
            }
          });
          break;
          
        case 'daily_refresh':
          // 매일 자정 일일 운세 배치 생성
          console.log('🌅 일일 운세 배치 생성');
          const dailyCategories = ['daily', 'today', 'love', 'career', 'money', 'health'];
          result = await generateBatchFortunes({
            user_id: user_profile.userId || 'guest', 
            fortunes: dailyCategories,
            profile: {
              name: user_profile.name,
              birthDate: user_profile.birth_date || user_profile.birthDate,
              gender: user_profile.gender,
              mbti: user_profile.mbti,
              blood_type: user_profile.blood_type
            }
          });
          break;
          
        case 'user_direct_request':
          // 사용자 직접 요청 시 개별 운세 생성
          console.log(`🎯 사용자 직접 요청: ${requested_categories?.[0]}`);
          if (!requested_categories || requested_categories.length === 0) {
            return NextResponse.json({ error: '요청할 운세 카테고리가 필요합니다.' }, { status: 400 });
          }
          
          const category = requested_categories[0];
          const profile = {
            name: user_profile.name || '사용자',
            birthDate: user_profile.birth_date || user_profile.birthDate || '1990-01-01',
            gender: user_profile.gender,
            mbti: user_profile.mbti,
            blood_type: user_profile.blood_type
          };
          
          result = await generateSingleFortune(category, profile, additional_input);
          break;
          
        default:
          return NextResponse.json({ error: 'Invalid request_type provided' }, { status: 400 });
      }
    } else {
      return NextResponse.json({ error: 'flowType 또는 request_type이 필요합니다.' }, { status: 400 });
    }

    console.log('✅ 통합 운세 생성 완료');
    
    return NextResponse.json({
      success: true,
      request_type: request_type || flowType,
      data: result,
      generated_at: new Date().toISOString()
    });
    
  } catch (error: any) {
    console.error('❌ 통합 운세 생성 실패:', error);
    return createSafeErrorResponse(error, '운세 생성 중 오류가 발생했습니다.');
  }
});
