import OpenAI from 'openai';
import { DeterministicRandom, getTodayDateString } from '@/lib/deterministic-random';
import { preprocessPrompt, postprocessAIResponse, sanitizeForAI } from '@/lib/unicode-utils';
import { SYSTEM_PROMPTS, FORTUNE_TEMPLATES, validateFortuneResponse } from './prompts/fortune-templates';

// OpenAI 클라이언트 초기화
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// GPT 4.1 Nano 모델 설정 - 더 똑똑하고 훨씬 저렴한 최신 모델
export const GPT_MODEL = 'gpt-4.1-nano'; // 고성능 + 저비용 최적화 모델

// 배치 운세 생성을 위한 인터페이스
export interface BatchFortuneRequest {
  user_id: string;
  fortunes: string[];
  profile: {
    name: string;
    birthDate: string;
    gender?: string;
    mbti?: string;
    blood_type?: string;
  };
}

// 배치 운세 응답 인터페이스
export interface BatchFortuneResponse {
  [fortuneType: string]: {
    overall_luck?: number;
    summary: string;
    advice: string;
    lucky_color?: string;
    lucky_number?: number;
    [key: string]: any;
  };
}

// 효율적인 배치 운세 생성 함수
export async function generateBatchFortunes(
  request: BatchFortuneRequest
): Promise<{ data: BatchFortuneResponse; token_usage: number }> {
  try {
    const prompt = createBatchFortunePrompt(request);
    
    const completion = await openai.chat.completions.create({
      model: GPT_MODEL,
      messages: [
        {
          role: "system",
          content: "당신은 한국 전통 운세 전문가입니다. 정확하고 실용적인 운세 분석을 제공합니다. JSON 형식으로만 응답하세요."
        },
        {
          role: "user",
          content: prompt
        }
      ],
      response_format: { type: "json_object" },
      temperature: 0.5, // 낮춘 temperature로 일관성 향상
      max_tokens: 2500, // GPT-4.1-nano는 더 효율적이므로 토큰 증가
    });

    const response = JSON.parse(completion.choices[0].message.content || '{}');
    const tokenUsage = completion.usage?.total_tokens || 0;

    return { data: response, token_usage: tokenUsage };
  } catch (error) {
    console.error('배치 운세 생성 실패:', error);
    throw error;
  }
}

// 배치 운세 프롬프트 생성
function createBatchFortunePrompt(request: BatchFortuneRequest): string {
  const { profile, fortunes } = request;
  const baseInfo = `이름: ${profile.name}, 생년월일: ${profile.birthDate}`;
  const extraInfo = profile.mbti ? `, MBTI: ${profile.mbti}` : '';
  const bloodInfo = profile.blood_type ? `, 혈액형: ${profile.blood_type}` : '';
  
  const fortuneDescriptions = fortunes.map(fortune => {
    switch (fortune) {
      case 'saju':
        return `"saju": 사주팔자 분석 (전체운, 성격, 장단점, 조언)`;
      case 'tojeong':
        return `"tojeong": 토정비결 연간 운세`;
      case 'past-life':
        return `"past-life": 전생 분석`;
      case 'personality':
        return `"personality": 성격 분석`;
      case 'destiny':
        return `"destiny": 운명 분석`;
      case 'daily':
      case 'today':
        return `"${fortune}": 오늘의 상세 운세 분석`;
      case 'love':
        return `"love": 연애운`;
      case 'career':
        return `"career": 직업운`;
      case 'wealth':
        return `"wealth": 금전운`;
      default:
        return `"${fortune}": ${fortune} 운세`;
    }
  }).join(', ');

  return `
사용자 정보: ${baseInfo}${extraInfo}${bloodInfo}

다음 운세들을 한 번에 분석해주세요:
${fortuneDescriptions}

중요: 각 운세는 반드시 구체적이고 개인화된 내용으로 작성하세요. 뻔한 조언이나 일반적인 말은 피하세요.

daily/today 운세는 다음 형식으로 작성:
{
  "score": 75,
  "keywords": ["구체적키워드1", "구체적키워드2", "구체적키워드3"],
  "summary": "오늘 ${profile.name}님께는 [구체적인 상황]이 예상됩니다. [실제적인 조언]",
  "luckyColor": "#색상코드",
  "luckyNumber": 숫자,
  "energy": 에너지레벨(0-100),
  "mood": "구체적인 감정상태",
  "advice": "${profile.name}님의 성격을 고려할 때, [맞춤형 조언]",
  "caution": "오늘은 특히 [구체적 주의사항]",
  "bestTime": "시간대와 이유",
  "compatibility": "${profile.name}님과 잘 맞는 [구체적인 유형]의 사람",
  "elements": {
    "love": 점수,
    "career": 점수,
    "money": 점수,
    "health": 점수
  }
}

다른 운세들도 각각의 특성에 맞게 구체적이고 실용적인 내용으로 작성하세요.
"좋은 사람들과 함께"같은 뻔한 표현 대신, 사용자의 MBTI나 생년월일을 고려한 맞춤형 조언을 제공하세요.

JSON 형식으로 응답하되, 각 운세를 키로 하는 객체로 반환하세요.
`;
}

// 이미지 기반 운세 생성 (Vision API)
export async function generateImageBasedFortune(
  fortuneType: 'face-reading' | 'palmistry',
  imageBase64: string,
  profile: any
): Promise<any> {
  try {
    const prompt = fortuneType === 'face-reading' 
      ? "이 얼굴 사진을 보고 관상학적 분석을 해주세요. 인상, 성격, 운세를 분석하세요."
      : "이 손바닥 사진을 보고 손금을 분석해주세요. 생명선, 두뇌선, 감정선을 중심으로 운세를 분석하세요.";

    const completion = await openai.chat.completions.create({
      model: "gpt-4-vision-preview",
      messages: [
        {
          role: "user",
          content: [
            { type: "text", text: prompt },
            {
              type: "image_url",
              image_url: {
                url: `data:image/jpeg;base64,${imageBase64}`
              }
            }
          ]
        }
      ],
      max_tokens: 500,
    });

    const response = completion.choices[0].message.content;
    return parseImageFortuneResponse(response, fortuneType);
  } catch (error) {
    console.error('이미지 기반 운세 생성 실패:', error);
    throw error;
  }
}

// 이미지 운세 응답 파싱
function parseImageFortuneResponse(response: string | null, fortuneType: string): any {
  if (!response) return null;
  
  // Deterministic random for consistent results
  const rng = new DeterministicRandom('system', getTodayDateString(), fortuneType);
  
  // 기본 구조 생성
  return {
    type: fortuneType,
    analysis: response,
    overall_luck: rng.randomInt(70, 90), // 70-90
    summary: response.substring(0, 100) + '...',
    advice: "더 자세한 분석을 원하시면 전문가와 상담하세요.",
    generated_at: new Date().toISOString()
  };
}

// 단일 운세 생성 (온디맨드용) - 한글 이름 지원 개선
export async function generateSingleFortune(
  fortuneType: string,
  profile: any,
  additionalInput?: any
): Promise<any> {
  try {
    console.log(`🤖 단일 운세 생성 시작: ${fortuneType}, 사용자: ${profile.name}`);
    
    const prompt = createSingleFortunePrompt(fortuneType, profile, additionalInput);
    console.log(`📝 생성된 프롬프트 길이: ${prompt.length}자`);
    
    const completion = await openai.chat.completions.create({
      model: GPT_MODEL,
      messages: [
        {
          role: "system",
          content: `당신은 30년 경력의 한국 전통 운세 전문가입니다. 
사주, 타로, 별자리, MBTI 등을 종합적으로 분석하여 실용적이고 구체적인 조언을 제공합니다.
항상 JSON 형식으로 정확하게 응답하며, 긍정적이면서도 현실적인 관점을 유지합니다.
모든 응답은 한국어로 작성하되, 사용자의 상황과 성격을 고려한 맞춤형 조언을 제공합니다.`
        },
        {
          role: "user",
          content: prompt
        }
      ],
      response_format: { type: "json_object" },
      temperature: 0.8,  // 다양성을 위해 약간 높임
      max_tokens: fortuneType === 'love' ? 2000 : 500,  // 연애운은 더 상세한 응답 필요
    });

    const result = JSON.parse(completion.choices[0].message.content || '{}');
    console.log(`✅ 단일 운세 생성 성공: ${fortuneType}`);
    return result;
    
  } catch (error) {
    console.error(`❌ 단일 운세 생성 실패 (${fortuneType}):`, error);
    
    // 인코딩 오류인 경우 특별한 처리
    if (error instanceof Error && error.message.includes('ByteString')) {
      console.error('🔍 인코딩 오류 감지 - 영어 프롬프트로 재시도');
      
      try {
        // 영어 전용 폴백 프롬프트
        const fallbackPrompt = `Please provide ${fortuneType} fortune reading for a person born on ${profile.birthDate || '1990-01-01'}.
Please respond in Korean language with JSON format: { overall_score, summary, advice }`;
        
        const completion = await openai.chat.completions.create({
          model: GPT_MODEL,
          messages: [
            {
              role: "system", 
              content: "You are a Korean traditional fortune teller expert. Provide accurate analysis in Korean language. Always respond in JSON format."
            },
            {
              role: "user",
              content: fallbackPrompt
            }
          ],
          response_format: { type: "json_object" },
          temperature: 0.5, // 낮춘 temperature로 일관성 향상
          max_tokens: 500,
        });
        
        const result = JSON.parse(completion.choices[0].message.content || '{}');
        console.log(`✅ 폴백 프롬프트로 운세 생성 성공: ${fortuneType}`);
        return result;
        
      } catch (fallbackError) {
        console.error('❌ 폴백 프롬프트도 실패:', fallbackError);
        throw error; // 원래 오류를 던짐
      }
    }
    
    throw error;
  }
}

// 안전한 문자열 인코딩 함수 - 한글 지원
function safeEncode(text: string): string {
  try {
    // 유니코드 정규화를 통해 한글 문자를 안전하게 처리
    const normalized = text.normalize('NFC');
    // JSON에서 안전한 형태로 변환 (이스케이프 처리)
    return JSON.stringify(normalized).slice(1, -1); // 앞뒤 따옴표 제거
  } catch (error) {
    console.warn('문자열 인코딩 실패, 기본값 사용:', error);
    // 폴백: 한글은 유지하되 제어 문자만 제거
    return text.replace(/[\x00-\x1F\x7F]/g, '');
  }
}

// 단일 운세 프롬프트 생성 - 한글 이름 지원 개선
function createSingleFortunePrompt(fortuneType: string, profile: any, additionalInput?: any): string {
  try {
    // 안전한 문자열 처리
    const safeName = safeEncode(profile.name || '사용자');
    const safeBirthDate = safeEncode(profile.birthDate || '1990-01-01');
    const baseInfo = `Name: ${safeName}, Birth Date: ${safeBirthDate}`;
    
    console.log(`🔍 프롬프트 생성: ${fortuneType}, 사용자: ${safeName}`);
    
    switch (fortuneType) {
      case 'dream':
        const dreamContent = safeEncode(additionalInput?.dreamContent || 'No dream content');
        return `Please interpret the dream for person with ${baseInfo}.
Dream content: "${dreamContent}"
Please respond in Korean language with JSON format: { overall_score, summary, interpretation, advice }`;
        
      case 'tarot':
        const question = safeEncode(additionalInput?.question || 'General fortune');
        return `Please provide tarot reading for person with ${baseInfo}.
Question: "${question}"
Please respond in Korean language with JSON format: { overall_score, summary, past, present, future, advice }`;
        
      case 'compatibility':
        const partnerBirthDate = safeEncode(additionalInput?.partnerBirthDate || '1990-01-01');
        return `Please analyze compatibility between person with ${baseInfo} and partner.
Partner birth date: ${partnerBirthDate}
Please respond in Korean language with JSON format: { compatibility_score, summary, strengths, challenges, advice }`;
        
      case 'love':
      case 'marriage':
        const mbti = profile.mbti ? `, MBTI: ${profile.mbti}` : '';
        const gender = profile.gender ? `, Gender: ${profile.gender}` : '';
        return `당신은 한국의 전문 운세 상담사입니다. 사용자 정보: ${baseInfo}${mbti}${gender}

아래 예시를 참고하여 사용자의 기본 운세 데이터를 따뜻하고 깊이 있는 조언으로 재구성해주세요.

=== 새로운 응답 형식 예시 ===
{
  "overall_score": 75,
  "love_score": 75,
  "weekly_score": 70,
  "monthly_score": 80,
  "summary": "연애운이 상승세를 보이고 있습니다",
  "emotional_tagline": "진심이 이끄는 설레는 하루",
  "advice": "진정성 있는 마음으로 상대방에게 다가가세요",
  "lucky_time": "오후 3시 ~ 6시",
  "lucky_place": "카페, 공원",
  "lucky_color": "#FF69B4",
  "compatibility": {
    "best": "물병자리",
    "good": ["쌍둥이자리", "천칭자리"],
    "avoid": "전갈자리"
  },
  "predictions": {
    "today": "좋은 만남의 기회가 있을 것입니다",
    "this_week": "특별한 인연을 만날 수 있습니다",
    "this_month": "중요한 결정을 내리게 될 것입니다"
  },
  "action_items": [
    "적극적인 자세로 임하기",
    "새로운 활동에 참여하기", 
    "진솔한 대화 나누기"
  ],
  "solo_fortune": {
    "new_meeting_stars": 4,
    "new_meeting_detail": "예상치 못한 곳에서 인연의 실마리를 발견할 수 있습니다. 평소에 잘 가지 않던 서점이나 동네 카페를 방문해 보세요. 우연이 필연이 되는 날입니다.",
    "charm_appeal": "꾸민 모습보다는 당신의 솔직하고 진솔한 대화가 상대방의 마음을 움직일 거예요. 오늘만큼은 마음을 열고 다가가세요.",
    "person_to_watch": "차분하고 지적인 분위기를 가진 물병자리와 좋은 대화가 통할 수 있습니다. 당신의 이야기에 귀 기울여줄 사람이에요."
  },
  "couple_fortune": {
    "relationship_stars": 4,
    "relationship_detail": "안정적인 흐름 속에서 서로에 대한 신뢰가 깊어지는 날입니다. 사소한 칭찬 한마디가 관계의 윤활유가 될 거예요.",
    "conflict_warning": "사소한 약속을 잊지 않도록 주의하세요. 특히 전갈자리 지인과의 만남에서 불필요한 오해가 생길 수 있으니 유의하는 것이 좋습니다.",
    "relationship_tip": "함께 공원을 산책하며 미래에 대한 가벼운 대화를 나눠보세요. 핑크 계열의 커플 아이템을 착용하면 애정운이 더욱 상승합니다."
  },
  "reunion_fortune": {
    "reconciliation_stars": 3,
    "reconciliation_detail": "과거의 인연과 다시 연결될 수 있는 시기입니다. 용기를 내어 첫걸음을 떼어보세요.",
    "approach_advice": "진솔한 마음으로 다가가되, 서두르지 말고 천천히 관계를 회복해 나가는 것이 중요합니다."
  },
  "lucky_booster": {
    "time_detail": "이 시간에 보내는 연락은 성공률 UP!",
    "place_detail": "마음이 편안해지고 대화가 잘 풀려요",
    "color_detail": "부드럽고 온화한 매력을 더해줘요"
  },
  "action_mission": [
    {
      "action": "새로운 활동에 참여하기",
      "meaning": "예상치 못한 기회가 숨어있어요"
    },
    {
      "action": "진솔한 대화 나누기", 
      "meaning": "마음의 거리가 가까워져요"
    },
    {
      "action": "나를 위한 작은 선물 사기",
      "meaning": "나의 자존감이 가장 강력한 매력!"
    }
  ],
  "deeper_advice": "오늘은 감수성이 풍부해지는 날입니다. 이 에너지를 상대를 의심하는 데 쓰기보다, 영화를 보거나 음악을 들으며 당신의 마음을 먼저 채워보세요. 스스로가 행복해야 좋은 인연도 끌어당기는 법입니다. '진정성 있는 마음'은 꾸며내는 것이 아니라, 스스로를 아끼는 마음에서 시작됩니다."
}

위 형식을 반드시 따라서 이 사용자에게 맞는 연애운을 분석해주세요. 모든 필드를 포함하되, 구체적이고 실용적이며 감성적인 내용으로 채워주세요. 별점은 1-5점으로 표현하고, 각 상황(솔로/커플/재회)에 맞는 현실적인 조언을 제공해주세요.`;

      case 'today':
        return `Please provide today's comprehensive fortune reading for person with ${baseInfo}.
Include detailed analysis for love, career, health, and money.
Please respond in Korean language with JSON format: { 
  overall_score: number, 
  summary: string, 
  love_score: number, 
  career_score: number, 
  health_score: number, 
  money_score: number,
  advice: string,
  lucky_items: string[]
}`;
        
      default:
        return `Please provide ${fortuneType} fortune reading for person with ${baseInfo}.
Please respond in Korean language with JSON format: { overall_score, summary, advice }`;
    }
  } catch (error) {
    console.error('프롬프트 생성 중 오류:', error);
    // 폴백 프롬프트 (영어만 사용)
    return `Please provide ${fortuneType} fortune reading for a person born on ${profile.birthDate || '1990-01-01'}.
Please respond in Korean language with JSON format: { overall_score, summary, advice }`;
  }
}

// 궁합 운세 생성 함수
export async function generateCompatibilityFortune(
  person1: any,
  person2: any
): Promise<any> {
  try {
    console.log('💕 GPT 궁합 분석 시작');
    
    const prompt = `두 사람의 궁합을 전문적으로 분석해주세요:

사람 1: ${person1.name} (생년월일: ${person1.birth_date})
성별: ${person1.gender || '미상'}, MBTI: ${person1.mbti || '미상'}

사람 2: ${person2.name} (생년월일: ${person2.birth_date})
성별: ${person2.gender || '미상'}, MBTI: ${person2.mbti || '미상'}

아래 JSON 형식으로 응답해주세요:
{
  "compatibility_score": 85,
  "overall_summary": "전체적인 궁합 요약",
  "personality_match": {
    "score": 80,
    "analysis": "성격 궁합 분석"
  },
  "communication_style": {
    "score": 90,
    "analysis": "소통 스타일 분석"
  },
  "love_chemistry": {
    "score": 85,
    "analysis": "연애 케미스트리 분석"
  },
  "future_potential": {
    "score": 80,
    "analysis": "미래 발전 가능성"
  },
  "strengths": ["서로의 장점들"],
  "challenges": ["극복해야 할 과제들"],
  "advice": "관계 발전을 위한 조언",
  "lucky_activities": ["함께하면 좋은 활동들"],
  "best_dates": ["데이트하기 좋은 날들"]
}`;

    const completion = await openai.chat.completions.create({
      model: GPT_MODEL,
      messages: [
        {
          role: "system",
          content: "당신은 한국 전통 궁합학과 현대 심리학을 결합한 전문 궁합 상담사입니다. 사주, MBTI, 생년월일을 종합적으로 분석하여 정확한 궁합을 제공합니다."
        },
        {
          role: "user",
          content: prompt
        }
      ],
      temperature: 0.5, // 낮춘 temperature로 일관성 향상
      max_tokens: 1000
    });

    const result = JSON.parse(completion.choices[0].message.content || '{}');
    
    console.log('✅ GPT 궁합 분석 완료');
    
    return {
      ...result,
      generated_at: new Date().toISOString(),
      ai_model: GPT_MODEL,
      token_usage: completion.usage?.total_tokens || 0
    };
    
  } catch (error) {
    console.error('❌ 궁합 분석 실패:', error);
    throw error;
  }
}

// 이사 운세 생성 함수  
export async function generateMovingFortune(
  profile: any,
  movingDetails?: any
): Promise<any> {
  try {
    console.log('🏠 GPT 이사 운세 분석 시작');
    
    const currentLocation = movingDetails?.currentLocation || '현재 거주지';
    const newLocation = movingDetails?.newLocation || '새로운 거주지';
    const movingDate = movingDetails?.movingDate || '미정';
    const reason = movingDetails?.reason || '일반 이사';
    
    const prompt = `${profile.name}님의 이사 운세를 전문적으로 분석해주세요:

기본 정보:
- 이름: ${profile.name}
- 생년월일: ${profile.birthDate}
- 현재 거주지: ${currentLocation}
- 이사할 곳: ${newLocation}
- 이사 예정일: ${movingDate}
- 이사 이유: ${reason}

아래 JSON 형식으로 응답해주세요:
{
  "overall_fortune": 85,
  "summary": "전체적인 이사 운세 요약",
  "timing_analysis": {
    "score": 80,
    "analysis": "이사 시기 분석",
    "best_dates": ["좋은 이사 날짜들"]
  },
  "direction_luck": {
    "score": 90,
    "analysis": "방향/위치 운세 분석",
    "favorable_directions": ["좋은 방향들"]
  },
  "financial_impact": {
    "score": 75,
    "analysis": "재정적 영향 분석"
  },
  "family_harmony": {
    "score": 85,
    "analysis": "가족 화목에 미치는 영향"
  },
  "career_impact": {
    "score": 80,
    "analysis": "직업/사업에 미치는 영향"
  },
  "precautions": ["이사 시 주의사항들"],
  "lucky_items": ["이사 시 가져가면 좋은 물건들"],
  "advice": "이사를 위한 종합 조언",
  "ritual_suggestions": ["이사 관련 의식이나 풍수 조언"]
}`;

    const completion = await openai.chat.completions.create({
      model: GPT_MODEL,
      messages: [
        {
          role: "system",
          content: "당신은 한국 전통 풍수지리학과 이사 운세 전문가입니다. 사주, 방향학, 택일학을 종합하여 최적의 이사 조언을 제공합니다."
        },
        {
          role: "user",
          content: prompt
        }
      ],
      temperature: 0.5, // 낮춘 temperature로 일관성 향상
      max_tokens: 1000
    });

    const result = JSON.parse(completion.choices[0].message.content || '{}');
    
    console.log('✅ GPT 이사 운세 분석 완료');
    
    return {
      ...result,
      generated_at: new Date().toISOString(),
      ai_model: GPT_MODEL,
      token_usage: completion.usage?.total_tokens || 0
    };
    
  } catch (error) {
    console.error('❌ 이사 운세 분석 실패:', error);
    throw error;
  }
}

export { openai };