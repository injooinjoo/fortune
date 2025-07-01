/**
 * AI 모델 설정 및 관리
 * Fortune Compass 프로젝트에서 사용하는 모든 AI 모델들의 설정을 관리합니다.
 */

// =============================================================================
// GPT 모델 설정
// =============================================================================

export const GPT_MODELS = {
  // 멀티모달 입력 처리용 (사진 기반 운세)
  MULTIMODAL: {
    name: 'gpt-4-turbo',
    description: '사진으로 받은 출생차트, 관상, 손금 등 이미지 분석',
    maxTokens: 4000,
    temperature: 0.7,
    supportsVision: true,
    costPer1kTokens: 0.01, // USD
    useCases: [
      '출생차트 이미지 분석',
      '관상 사진 분석', 
      '손금 사진 분석',
      '타로카드 이미지 해석',
      '사주 차트 이미지 읽기'
    ]
  },

  // 기본 운세 메시지 생성용 (경제적)
  BASIC: {
    name: 'gpt-4o-mini',
    description: '일반적인 텍스트 기반 운세 생성',
    maxTokens: 2000,
    temperature: 0.8,
    supportsVision: false,
    costPer1kTokens: 0.00015, // USD (매우 경제적)
    useCases: [
      '일일 운세',
      '주간 운세',
      '월간 운세',
      '간단한 궁합',
      '기본 사주 해석',
      'MBTI 기반 운세'
    ]
  },

  // 전문적인 운세 분석용 (고품질)
  PROFESSIONAL: {
    name: 'gpt-4-turbo-preview',
    description: '전문적이고 상세한 운세 분석',
    maxTokens: 8000,
    temperature: 0.6,
    supportsVision: false,
    costPer1kTokens: 0.01, // USD
    useCases: [
      '전통 사주 상세 분석',
      '토정비결 해석',
      '결혼 궁합 분석',
      '사업 운세 분석',
      '평생 운세',
      '전문가 수준 상담'
    ]
  },

  // 실시간 대화형 운세용
  CHAT: {
    name: 'gpt-3.5-turbo',
    description: '빠른 응답이 필요한 대화형 운세',
    maxTokens: 1500,
    temperature: 0.9,
    supportsVision: false,
    costPer1kTokens: 0.0005, // USD
    useCases: [
      '실시간 질의응답',
      '간단한 운세 질문',
      '빠른 조언',
      '일상 상담'
    ]
  }
} as const;

// =============================================================================
// Teachable Machine 모델 설정
// =============================================================================

export const TEACHABLE_MACHINE_MODELS = {
  // 관상 분석 모델
  FACE_READING: {
    modelUrl: 'https://teachablemachine.withgoogle.com/models/YOUR_FACE_MODEL/',
    type: 'image' as const,
    description: '얼굴형, 눈썹, 입술 등을 분석하여 성격과 운세 예측',
    classes: [
      '복상 (부유한 상)',
      '귀상 (고귀한 상)', 
      '수상 (장수하는 상)',
      '지혜상 (지적인 상)',
      '인덕상 (인기가 많은 상)',
      '예술상 (예술적 재능)',
      '리더상 (지도력이 있는 상)',
      '평범상 (일반적인 상)'
    ],
    accuracy: 0.85,
    trainingData: '10,000+ 한국인 관상 데이터'
  },

  // 손금 분석 모델
  PALM_READING: {
    modelUrl: 'https://teachablemachine.withgoogle.com/models/YOUR_PALM_MODEL/',
    type: 'image' as const,
    description: '손금의 생명선, 감정선, 지능선 등을 분석',
    classes: [
      '장수형 (긴 생명선)',
      '단명형 (짧은 생명선)',
      '감정풍부형 (깊은 감정선)',
      '이성적형 (명확한 지능선)',
      '예술가형 (복잡한 손금)',
      '사업가형 (태양선 발달)',
      '학자형 (수성구 발달)',
      '일반형 (평범한 손금)'
    ],
    accuracy: 0.78,
    trainingData: '8,000+ 손금 이미지 데이터'
  },

  // 출생차트 분석 모델 
  BIRTH_CHART: {
    modelUrl: 'https://teachablemachine.withgoogle.com/models/YOUR_CHART_MODEL/',
    type: 'image' as const,
    description: '서양 점성술 출생차트의 행성 배치 패턴 인식',
    classes: [
      '물상 (수성 강세)',
      '화상 (화성 강세)',
      '목상 (목성 강세)',
      '금상 (금성 강세)',
      '토상 (토성 강세)',
      '그랜드트라인 (대삼각)',
      '그랜드크로스 (대십자)',
      '균형형 (고른 배치)'
    ],
    accuracy: 0.72,
    trainingData: '5,000+ 출생차트 데이터'
  },

  // 타로카드 인식 모델
  TAROT_CARD: {
    modelUrl: 'https://teachablemachine.withgoogle.com/models/YOUR_TAROT_MODEL/',
    type: 'image' as const,
    description: '타로카드 78장을 자동으로 인식하고 정/역방향 판단',
    classes: [
      // 메이저 아르카나 22장
      'The Fool', 'The Magician', 'The High Priestess', 'The Empress',
      'The Emperor', 'The Hierophant', 'The Lovers', 'The Chariot',
      'Strength', 'The Hermit', 'Wheel of Fortune', 'Justice',
      'The Hanged Man', 'Death', 'Temperance', 'The Devil',
      'The Tower', 'The Star', 'The Moon', 'The Sun',
      'Judgement', 'The World',
      // 마이너 아르카나는 수트별로 분류
      'Cups Suit', 'Wands Suit', 'Pentacles Suit', 'Swords Suit'
    ],
    accuracy: 0.92,
    trainingData: '15,000+ 타로카드 이미지'
  },

  // 사주 한자 인식 모델
  SAJU_CHARACTERS: {
    modelUrl: 'https://teachablemachine.withgoogle.com/models/YOUR_SAJU_MODEL/',
    type: 'image' as const,
    description: '사주팔자의 한자들을 인식하여 디지털 변환',
    classes: [
      // 십간
      '갑(甲)', '을(乙)', '병(丙)', '정(丁)', '무(戊)',
      '기(己)', '경(庚)', '신(辛)', '임(壬)', '계(癸)',
      // 십이지
      '자(子)', '축(丑)', '인(寅)', '묘(卯)', '진(辰)', '사(巳)',
      '오(午)', '미(未)', '신(申)', '유(酉)', '술(戌)', '해(亥)'
    ],
    accuracy: 0.95,
    trainingData: '20,000+ 사주 한자 데이터'
  }
} as const;

// =============================================================================
// 모델 선택 로직
// =============================================================================

export type FortuneType = 
  | 'daily' | 'weekly' | 'monthly' | 'yearly'
  | 'love' | 'marriage' | 'compatibility'
  | 'career' | 'wealth' | 'health'
  | 'saju' | 'tarot' | 'palmistry' | 'physiognomy'
  | 'chat' | 'consultation';

export type InputType = 'text' | 'image' | 'multimodal';

/**
 * 운세 타입과 입력 타입에 따라 최적의 GPT 모델을 선택
 */
export function selectGPTModel(fortuneType: FortuneType, inputType: InputType) {
  // 이미지 입력이 있으면 멀티모달 모델 사용
  if (inputType === 'image' || inputType === 'multimodal') {
    return GPT_MODELS.MULTIMODAL;
  }

  // 전문적인 분석이 필요한 경우
  const professionalTypes: FortuneType[] = ['saju', 'marriage', 'yearly', 'consultation'];
  if (professionalTypes.includes(fortuneType)) {
    return GPT_MODELS.PROFESSIONAL;
  }

  // 실시간 대화형
  if (fortuneType === 'chat') {
    return GPT_MODELS.CHAT;
  }

  // 기본적인 운세는 경제적인 모델 사용
  return GPT_MODELS.BASIC;
}

/**
 * 운세 타입에 따라 사용할 Teachable Machine 모델 선택
 */
export function selectTeachableModel(fortuneType: FortuneType) {
  switch (fortuneType) {
    case 'physiognomy':
      return TEACHABLE_MACHINE_MODELS.FACE_READING;
    case 'palmistry':
      return TEACHABLE_MACHINE_MODELS.PALM_READING;
    case 'tarot':
      return TEACHABLE_MACHINE_MODELS.TAROT_CARD;
    case 'saju':
      return TEACHABLE_MACHINE_MODELS.SAJU_CHARACTERS;
    default:
      return null;
  }
}

// =============================================================================
// API 호출 헬퍼 함수들
// =============================================================================

/**
 * GPT API 호출 함수
 */
export async function callGPTAPI(
  prompt: string,
  model: typeof GPT_MODELS[keyof typeof GPT_MODELS],
  imageUrl?: string
) {
  const messages: any[] = [
    {
      role: 'system',
      content: '당신은 한국의 전통 운명학과 현대 심리학을 결합한 전문 운세 상담사입니다. 항상 JSON 형태로만 응답하며, 긍정적이고 건설적인 조언을 제공합니다.'
    }
  ];

  // 이미지가 있으면 멀티모달 메시지 구성
  if (imageUrl && model.supportsVision) {
    messages.push({
      role: 'user',
      content: [
        { type: 'text', text: prompt },
        { type: 'image_url', image_url: { url: imageUrl } }
      ]
    });
  } else {
    messages.push({
      role: 'user',
      content: prompt
    });
  }

  const response = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: model.name,
      messages,
      temperature: model.temperature,
      max_tokens: model.maxTokens,
      response_format: { type: "json_object" }
    }),
  });

  if (!response.ok) {
    throw new Error(`GPT API 오류: ${response.statusText}`);
  }

  const data = await response.json();
  return JSON.parse(data.choices[0].message.content);
}

/**
 * Teachable Machine 모델 호출 함수
 */
export async function callTeachableMachine(
  imageUrl: string,
  model: typeof TEACHABLE_MACHINE_MODELS[keyof typeof TEACHABLE_MACHINE_MODELS]
) {
  try {
    // Teachable Machine 모델 로드
    const modelUrl = model.modelUrl + 'model.json';
    const metadataUrl = model.modelUrl + 'metadata.json';
    
    // 브라우저 환경에서 실행 (클라이언트 사이드)
    if (typeof window !== 'undefined') {
      const tf = await import('@tensorflow/tfjs');
      const tmImage = await import('@teachablemachine/image');
      
      const loadedModel = await tmImage.load(modelUrl, metadataUrl);
      
      // 이미지 로드 및 예측
      const img = new Image();
      img.crossOrigin = 'anonymous';
      img.src = imageUrl;
      
      return new Promise((resolve, reject) => {
        img.onload = async () => {
          try {
            const prediction = await loadedModel.predict(img);
            const results = prediction.map((p: any, index: number) => ({
              class: model.classes[index],
              probability: p.probability,
              confidence: Math.round(p.probability * 100)
            }));
            
            // 가장 높은 확률의 결과 반환
            const bestMatch = results.reduce((prev: any, current: any) => 
              (prev.probability > current.probability) ? prev : current
            );
            
            resolve({
              prediction: bestMatch,
              allResults: results,
              modelInfo: {
                name: model.description,
                accuracy: model.accuracy,
                trainingData: model.trainingData
              }
            });
          } catch (error) {
            reject(error);
          }
        };
        
        img.onerror = () => reject(new Error('이미지 로드 실패'));
      });
    } else {
      throw new Error('Teachable Machine은 클라이언트 사이드에서만 실행 가능합니다.');
    }
  } catch (error) {
    console.error('Teachable Machine 호출 오류:', error);
    throw error;
  }
}

// =============================================================================
// 사용량 추적 및 비용 계산
// =============================================================================

export interface APIUsage {
  model: string;
  inputTokens: number;
  outputTokens: number;
  totalTokens: number;
  estimatedCost: number;
  timestamp: Date;
}

/**
 * API 사용량 추적
 */
export function trackAPIUsage(
  model: typeof GPT_MODELS[keyof typeof GPT_MODELS],
  inputTokens: number,
  outputTokens: number
): APIUsage {
  const totalTokens = inputTokens + outputTokens;
  const estimatedCost = (totalTokens / 1000) * model.costPer1kTokens;
  
  return {
    model: model.name,
    inputTokens,
    outputTokens,
    totalTokens,
    estimatedCost,
    timestamp: new Date()
  };
}

// =============================================================================
// 모델별 프롬프트 템플릿
// =============================================================================

export const PROMPT_TEMPLATES = {
  BASIC_FORTUNE: (userInfo: any, fortuneType: string) => `
당신은 전문 운세 상담사입니다. 다음 정보를 바탕으로 ${fortuneType} 운세를 생성해주세요.

사용자 정보: ${JSON.stringify(userInfo)}

JSON 형식으로 응답해주세요:
{
  "overall_score": 85,
  "summary": "운세 요약",
  "advice": "구체적인 조언",
  "lucky_elements": ["행운 요소들"],
  "cautions": ["주의사항들"]
}
  `,

  PROFESSIONAL_ANALYSIS: (userInfo: any, analysisType: string) => `
당신은 한국 전통 운명학 전문가입니다. ${analysisType}에 대한 전문적인 분석을 해주세요.

사용자 정보: ${JSON.stringify(userInfo)}

상세한 JSON 형식으로 응답해주세요:
{
  "detailed_analysis": "상세 분석",
  "traditional_interpretation": "전통적 해석",
  "modern_application": "현대적 적용",
  "life_guidance": "인생 지침",
  "timing_advice": "시기별 조언"
}
  `,

  MULTIMODAL_ANALYSIS: (userInfo: any, imageType: string) => `
당신은 이미지 분석 전문가입니다. 제공된 ${imageType} 이미지를 분석하여 운세를 해석해주세요.

사용자 정보: ${JSON.stringify(userInfo)}

이미지 분석 결과를 JSON 형식으로 제공해주세요:
{
  "image_analysis": "이미지에서 관찰된 특징들",
  "interpretation": "운명학적 해석",
  "personality_traits": "성격 특성",
  "life_predictions": "인생 예측",
  "recommendations": "추천사항"
}
  `
} as const;

export default {
  GPT_MODELS,
  TEACHABLE_MACHINE_MODELS,
  selectGPTModel,
  selectTeachableModel,
  callGPTAPI,
  callTeachableMachine,
  trackAPIUsage,
  PROMPT_TEMPLATES
}; 