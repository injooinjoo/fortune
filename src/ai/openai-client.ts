import OpenAI from 'openai';

// OpenAI 클라이언트 초기화
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// GPT 4.1 Nano 모델 설정 (실제로는 gpt-3.5-turbo 또는 gpt-4를 사용)
// GPT 4.1 Nano는 가상의 모델명이므로 실제 사용 가능한 경제적인 모델 사용
export const GPT_MODEL = 'gpt-3.5-turbo'; // 비용 효율적인 모델

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
      temperature: 0.7,
      max_tokens: 2000, // 토큰 제한으로 비용 절감
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
        return `"daily": 오늘의 운세 (총운, 애정운, 금전운, 건강운)`;
      case 'love':
        return `"love": 연애운`;
      case 'career':
        return `"career": 직업운`;
      default:
        return `"${fortune}": ${fortune} 운세`;
    }
  }).join(', ');

  return `
사용자 정보: ${baseInfo}${extraInfo}${bloodInfo}

다음 운세들을 한 번에 분석해주세요:
${fortuneDescriptions}

각 운세는 다음 형식으로 작성:
- overall_luck: 0-100 점수 (해당되는 경우)
- summary: 간단한 요약 (50자 이내)
- advice: 실용적 조언 (50자 이내)
- 기타 운세별 특화 정보

JSON 형식으로 응답하되, 각 운세를 키로 하는 객체로 반환하세요.
토큰을 절약하기 위해 짧고 핵심적으로 작성하세요.
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
  
  // 기본 구조 생성
  return {
    type: fortuneType,
    analysis: response,
    overall_luck: Math.floor(Math.random() * 21) + 70, // 70-90
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
          content: "You are a Korean traditional fortune teller expert. Provide accurate analysis in Korean language. Always respond in JSON format."
        },
        {
          role: "user",
          content: prompt
        }
      ],
      response_format: { type: "json_object" },
      temperature: 0.7,
      max_tokens: 500,
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
          temperature: 0.7,
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
      temperature: 0.7,
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
      temperature: 0.7,
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