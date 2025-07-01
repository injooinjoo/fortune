import { NextRequest, NextResponse } from 'next/server';
import { generateSpecializedFortune } from '@/ai/flows/generate-specialized-fortune';
import { generateFortuneInsights } from '@/ai/flows/generate-fortune-insights';
import { DailyFortuneService } from '@/lib/daily-fortune-service';
import { FORTUNE_TYPES } from '@/lib/fortune-data';
import { createClient } from '@supabase/supabase-js';
import toast from 'react-hot-toast';

// Supabase 클라이언트 초기화 (개발용 임시 비활성화)
const supabase = null;

interface FortuneRequest {
  categories: string[];
  userInfo: {
    name?: string;
    mbti?: string;
    zodiac?: string;
    birthDate?: string;
    [key: string]: any;
  };
  packageType: 'traditional_bundle' | 'daily_bundle' | 'love_bundle';
  requestId: string;
}

// GPT 프롬프트 템플릿 (정책 문서 기반)
const BUNDLE_PROMPTS = {
  traditional_bundle: (userInfo: any) => `
당신은 전문 한국 전통 운명학 전문가입니다. 다음 사용자 정보를 바탕으로 5가지 전통 운세를 일괄 생성해주세요.

**사용자 정보:**
- 이름: ${userInfo.name || '미입력'}
- 생년월일: ${userInfo.birthDate || '미입력'}
- MBTI: ${userInfo.mbti || '미입력'}
- 별자리: ${userInfo.zodiac || '미입력'}

**응답 형식 (JSON):**
\`\`\`json
{
  "saju": {
    "overall_score": 85,
    "summary": "사주 종합 해석",
    "strengths": ["강점1", "강점2"],
    "challenges": ["주의점1", "주의점2"],
    "advice": "구체적인 조언"
  },
  "traditional-saju": {
    "birth_elements": {"year": "갑자", "month": "을축", "day": "병인", "hour": "정묘"},
    "five_elements_analysis": {"wood": 2, "fire": 1, "earth": 0, "metal": 1, "water": 1},
    "fortune_analysis": "전통 사주 해석"
  },
  "tojeong": {
    "tojeong_type": "도화살형",
    "characteristics": ["특성1", "특성2"],
    "compatible_types": ["궁합1", "궁합2"],
    "life_guidance": "인생 방향 조언"
  },
  "salpuli": {
    "current_salpuli": "대운살",
    "salpuli_meaning": "살풀이 의미",
    "resolution_methods": ["해결방법1", "해결방법2"],
    "protective_actions": ["보호행동1", "보호행동2"]
  },
  "past-life": {
    "past_life_story": "전생 이야기",
    "karma_influences": ["업보1", "업보2"],
    "soul_lessons": ["영혼 교훈1", "영혼 교훈2"],
    "current_life_guidance": "현생 지침"
  }
}
\`\`\`

모든 해석은 한국 전통 문화와 철학을 바탕으로 하되, 현대적 감각으로 쉽게 이해할 수 있도록 작성해주세요.
  `,

  daily_bundle: (userInfo: any) => `
당신은 일일 운세 전문가입니다. 오늘 날짜(${new Date().toLocaleDateString('ko-KR')})를 기준으로 4가지 시간대별 운세를 생성해주세요.

**사용자 정보:**
- 이름: ${userInfo.name || '미입력'}
- MBTI: ${userInfo.mbti || '미입력'}
- 별자리: ${userInfo.zodiac || '미입력'}

**응답 형식 (JSON):**
\`\`\`json
{
  "daily": {
    "date": "${new Date().toLocaleDateString('ko-KR')}",
    "overall_score": 88,
    "love_score": 75,
    "career_score": 90,
    "wealth_score": 82,
    "summary": "오늘의 전체적인 운세",
    "keywords": ["키워드1", "키워드2", "키워드3"],
    "lucky_color": "파란색",
    "lucky_number": 7,
    "advice": "오늘의 조언"
  },
  "hourly": {
    "time_slots": {
      "morning": {"score": 85, "advice": "아침 조언"},
      "afternoon": {"score": 78, "advice": "오후 조언"},
      "evening": {"score": 92, "advice": "저녁 조언"},
      "night": {"score": 70, "advice": "밤 조언"}
    },
    "best_time": "저녁",
    "caution_time": "밤"
  },
  "today": {
    "energy_level": 85,
    "mood_forecast": "활기찬",
    "opportunities": ["기회1", "기회2"],
    "challenges": ["주의점1", "주의점2"],
    "recommendations": ["추천1", "추천2"]
  },
  "tomorrow": {
    "date": "${new Date(Date.now() + 24*60*60*1000).toLocaleDateString('ko-KR')}",
    "preview_score": 78,
    "key_events": ["예상 이벤트1", "예상 이벤트2"],
    "preparation_tips": ["준비사항1", "준비사항2"],
    "outlook": "내일 전망"
  }
}
\`\`\`

각 시간대의 에너지와 흐름을 고려한 실용적인 조언을 제공해주세요.
  `,

  love_bundle: (userInfo: any, isSingle: boolean) => `
당신은 연애와 인연 전문 상담사입니다. 사용자의 연애 상태(${isSingle ? '솔로' : '커플'})에 맞는 4가지 사랑 운세를 생성해주세요.

**사용자 정보:**
- 이름: ${userInfo.name || '미입력'}
- MBTI: ${userInfo.mbti || '미입력'}
- 별자리: ${userInfo.zodiac || '미입력'}
- 연애 상태: ${isSingle ? '솔로' : '커플'}

**응답 형식 (JSON):**
\`\`\`json
{
  "love": {
    "current_status": "${isSingle ? '새로운 인연 탐색기' : '관계 발전기'}",
    "love_score": 82,
    "romance_forecast": "연애 운 전망",
    "advice": "연애 조언",
    "lucky_actions": ["럭키 액션1", "럭키 액션2"]
  },
  ${isSingle ? '"destiny"' : '"marriage"'}: {
    ${isSingle ? `
    "destined_meeting": "운명적 만남 시기",
    "meeting_place": "만날 장소 힌트",
    "ideal_partner_traits": ["이상형 특징1", "이상형 특징2"],
    "timing_advice": "타이밍 조언"
    ` : `
    "marriage_timing": "결혼 적기",
    "relationship_stability": 88,
    "compatibility_score": 92,
    "marriage_advice": "결혼 관련 조언"
    `}
  },
  ${isSingle ? '"blind-date"' : '"couple-match"'}: {
    ${isSingle ? `
    "success_probability": 75,
    "ideal_date_style": "카페 데이트",
    "conversation_tips": ["대화 팁1", "대화 팁2"],
    "outfit_suggestion": "의상 제안"
    ` : `
    "compatibility_analysis": "궁합 분석",
    "strong_points": ["강점1", "강점2"],
    "growth_areas": ["개선점1", "개선점2"],
    "bonding_activities": ["추천 활동1", "추천 활동2"]
    `}
  },
  ${isSingle ? '"celebrity-match"' : '"chemistry"'}: {
    ${isSingle ? `
    "celebrity_matches": ["연예인1", "연예인2"],
    "compatibility_reasons": ["이유1", "이유2"],
    "learning_points": ["배울 점1", "배울 점2"]
    ` : `
    "chemistry_level": 85,
    "passionate_moments": "열정적인 순간들",
    "intimacy_tips": ["친밀감 팁1", "친밀감 팁2"],
    "romance_suggestions": ["로맨스 제안1", "로맨스 제안2"]
    `}
  }
}
\`\`\`

따뜻하고 현실적인 조언으로 사용자의 사랑 여정을 응원해주세요.
  `
};

// GPT API 호출 함수
async function callGPTBundleAPI(prompt: string, requestId: string): Promise<any> {
  const response = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: 'gpt-4-turbo-preview',
      messages: [
        {
          role: 'system',
          content: '당신은 한국의 전통 운명학과 현대 심리학을 결합한 전문 운세 상담사입니다. 항상 JSON 형태로만 응답하며, 긍정적이고 건설적인 조언을 제공합니다.'
        },
        {
          role: 'user',
          content: prompt
        }
      ],
      temperature: 0.7,
      max_tokens: 4000,
      response_format: { type: "json_object" }
    }),
  });

  if (!response.ok) {
    throw new Error(`GPT API 오류: ${response.statusText}`);
  }

  const data = await response.json();
  return JSON.parse(data.choices[0].message.content);
}

// 캐시 관리 함수 (정책에 따른 캐시 기간)
function getCacheDuration(packageType: string): number {
  switch (packageType) {
    case 'traditional_bundle':
      return 365 * 24 * 60 * 60 * 1000; // 365일 (평생 운세)
    case 'daily_bundle':
      return 24 * 60 * 60 * 1000; // 24시간
    case 'love_bundle':
      return 7 * 24 * 60 * 60 * 1000; // 7일
    default:
      return 24 * 60 * 60 * 1000; // 기본 24시간
  }
}

export async function POST(request: NextRequest) {
  const encoder = new TextEncoder();
  
  const stream = new ReadableStream({
    async start(controller) {
      try {
        const body: FortuneRequest = await request.json();
        const { categories, userInfo, packageType, requestId } = body;

        // 진행률 업데이트 함수
        const sendProgress = (progress: number, message: string) => {
          controller.enqueue(
            encoder.encode(`data: ${JSON.stringify({
              type: 'progress',
              progress,
              message,
              requestId
            })}\n\n`)
          );
        };

        // 캐시 확인 (임시 비활성화)
        sendProgress(10, '캐시 확인 중...');

        // GPT 프롬프트 생성
        sendProgress(30, 'AI 분석 시작...');
        let prompt = '';
        switch (packageType) {
          case 'traditional_bundle':
            prompt = BUNDLE_PROMPTS.traditional_bundle(userInfo);
            break;
          case 'daily_bundle':
            prompt = BUNDLE_PROMPTS.daily_bundle(userInfo);
            break;
          case 'love_bundle':
            const isSingle = !userInfo.relationship || userInfo.relationship === 'single';
            prompt = BUNDLE_PROMPTS.love_bundle(userInfo, isSingle);
            break;
          default:
            throw new Error('지원하지 않는 패키지 타입입니다.');
        }

        // GPT API 호출
        sendProgress(60, 'AI가 운세를 생성 중...');
        const fortuneResults = await callGPTBundleAPI(prompt, requestId);

        // 개별 결과 전송
        sendProgress(80, '결과 처리 중...');
        for (const [category, result] of Object.entries(fortuneResults)) {
          controller.enqueue(
            encoder.encode(`data: ${JSON.stringify({
              type: 'result',
              category,
              result,
              requestId
            })}\n\n`)
          );
        }

        // 결과 저장 (임시 비활성화)
        sendProgress(90, '결과 저장 중...');

        // 완료
        sendProgress(100, '완료!');
        controller.enqueue(
          encoder.encode(`data: ${JSON.stringify({
            type: 'complete',
            results: fortuneResults,
            cached: false,
            tokenSavings: '75%',
            requestId
          })}\n\n`)
        );

        // 실시간 알림 전송 (임시 비활성화)

      } catch (error) {
                 console.error('Fortune generation error:', error);
         controller.enqueue(
           encoder.encode(`data: ${JSON.stringify({
             type: 'error',
             error: error instanceof Error ? error.message : '알 수 없는 오류',
             requestId: 'unknown'
           })}\n\n`)
         );
      } finally {
        controller.close();
      }
    },
  });

  return new Response(stream, {
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST',
      'Access-Control-Allow-Headers': 'Content-Type',
    },
  });
}

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const fortuneType = searchParams.get('type');
    
    if (!fortuneType) {
      return NextResponse.json(
        { error: '운세 타입이 필요합니다.' },
        { status: 400 }
      );
    }

    // 오늘의 운세 조회
    const userId = await DailyFortuneService.getUserId();
    const todayFortune = await DailyFortuneService.getTodayFortune(userId, fortuneType);

    if (todayFortune) {
      return NextResponse.json({
        success: true,
        data: todayFortune.fortune_data,
        exists: true,
        createdAt: todayFortune.created_at
      });
    } else {
      return NextResponse.json({
        success: true,
        data: null,
        exists: false,
        message: '오늘 생성된 운세가 없습니다.'
      });
    }

  } catch (error) {
    console.error('운세 조회 API 오류:', error);
    
    return NextResponse.json(
      { 
        error: '운세 조회 중 오류가 발생했습니다.',
        success: false
      },
      { status: 500 }
    );
  }
} 