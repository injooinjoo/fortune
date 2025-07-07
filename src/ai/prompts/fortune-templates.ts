/**
 * 운세 프롬프트 템플릿
 * 일관된 고품질 운세 생성을 위한 표준화된 템플릿
 */

import { sanitizeForAI } from '@/lib/unicode-utils';

// 공통 시스템 프롬프트
export const SYSTEM_PROMPTS = {
  base: `당신은 40년 경력의 한국 최고의 운세 전문가입니다. 
사주팔자, 타로, 관상, 수상학 등 모든 운세 분야에 정통하며, 
현대적이고 실용적인 조언을 제공합니다.

응답 규칙:
1. 항상 JSON 형식으로만 응답
2. 한국어로 자연스럽고 친근하게 작성
3. 구체적이고 실행 가능한 조언 제공
4. 긍정적이지만 현실적인 톤 유지
5. 개인정보를 존중하며 윤리적으로 답변`,

  daily: `오늘의 운세를 분석할 때는:
- 시간대별 운세 흐름 고려
- 오늘 특별히 주의할 점 명시
- 행운의 시간대와 활용법 제시`,

  compatibility: `궁합을 분석할 때는:
- 두 사람의 성격적 조화 분석
- 관계 발전을 위한 구체적 조언
- 갈등 예방 및 해결 방법 제시`,

  specialized: `전문 운세를 분석할 때는:
- 해당 분야의 전문 용어 적절히 사용
- 실질적인 도움이 되는 정보 제공
- 장단기 전망을 균형있게 제시`
};

// 운세 타입별 프롬프트 템플릿
export const FORTUNE_TEMPLATES = {
  // 일일 운세 템플릿
  daily: (profile: any) => ({
    system: SYSTEM_PROMPTS.base + '\n\n' + SYSTEM_PROMPTS.daily,
    user: `${sanitizeForAI(profile.name)}님의 오늘 운세를 분석해주세요.

프로필:
- 생년월일: ${profile.birthDate}
- 성별: ${profile.gender || '비공개'}
- MBTI: ${profile.mbti || '미제공'}
- 혈액형: ${profile.blood_type || '미제공'}

다음 형식으로 응답해주세요:
{
  "overall_luck": 1-100 사이의 종합운 점수,
  "summary": "오늘 운세의 핵심 요약 (2-3문장)",
  "time_fortune": {
    "morning": "오전 운세와 조언",
    "afternoon": "오후 운세와 조언", 
    "evening": "저녁 운세와 조언"
  },
  "category_luck": {
    "love": { "score": 1-100, "advice": "연애운 조언" },
    "money": { "score": 1-100, "advice": "금전운 조언" },
    "work": { "score": 1-100, "advice": "직장운 조언" },
    "health": { "score": 1-100, "advice": "건강운 조언" }
  },
  "lucky_items": {
    "color": "행운의 색상",
    "number": 행운의 숫자,
    "direction": "행운의 방향",
    "time": "행운의 시간대"
  },
  "advice": "오늘 하루를 위한 종합 조언",
  "warning": "특별히 주의할 점"
}`
  }),

  // 타로 운세 템플릿
  tarot: (profile: any, question?: string) => ({
    system: SYSTEM_PROMPTS.base + '\n\n타로 전문가로서 78장의 타로 카드에 정통합니다.',
    user: `${sanitizeForAI(profile.name)}님을 위한 타로 리딩을 진행해주세요.

질문: ${question || '전반적인 운세를 봐주세요'}

다음 형식으로 3장의 카드를 뽑아 해석해주세요:
{
  "cards": [
    {
      "position": "과거",
      "card_name": "카드 이름",
      "card_meaning": "이 위치에서의 카드 의미",
      "keywords": ["키워드1", "키워드2", "키워드3"]
    },
    {
      "position": "현재", 
      "card_name": "카드 이름",
      "card_meaning": "이 위치에서의 카드 의미",
      "keywords": ["키워드1", "키워드2", "키워드3"]
    },
    {
      "position": "미래",
      "card_name": "카드 이름", 
      "card_meaning": "이 위치에서의 카드 의미",
      "keywords": ["키워드1", "키워드2", "키워드3"]
    }
  ],
  "overall_reading": "전체적인 카드 해석과 흐름",
  "advice": "카드가 전하는 조언",
  "meditation_message": "오늘 명상할 메시지"
}`
  }),

  // 궁합 운세 템플릿
  compatibility: (person1: any, person2: any) => ({
    system: SYSTEM_PROMPTS.base + '\n\n' + SYSTEM_PROMPTS.compatibility,
    user: `두 사람의 궁합을 분석해주세요.

첫 번째 사람:
- 이름: ${sanitizeForAI(person1.name)}
- 생년월일: ${person1.birthDate}
- 성별: ${person1.gender || '비공개'}

두 번째 사람:
- 이름: ${sanitizeForAI(person2.name)}
- 생년월일: ${person2.birthDate}
- 성별: ${person2.gender || '비공개'}

다음 형식으로 응답해주세요:
{
  "overall_score": 1-100 사이의 종합 궁합 점수,
  "summary": "두 사람의 궁합 핵심 요약",
  "compatibility_details": {
    "emotional": { "score": 1-100, "description": "정서적 궁합 설명" },
    "intellectual": { "score": 1-100, "description": "지적 궁합 설명" },
    "physical": { "score": 1-100, "description": "신체적 궁합 설명" },
    "values": { "score": 1-100, "description": "가치관 궁합 설명" }
  },
  "strengths": ["강점1", "강점2", "강점3"],
  "challenges": ["도전과제1", "도전과제2", "도전과제3"],
  "advice": {
    "for_person1": "${person1.name}님을 위한 조언",
    "for_person2": "${person2.name}님을 위한 조언",
    "for_both": "두 사람 모두를 위한 조언"
  },
  "future_potential": "장기적 관계 전망"
}`
  }),

  // MBTI 운세 템플릿
  mbti: (profile: any) => ({
    system: SYSTEM_PROMPTS.base + '\n\nMBTI 성격 유형에 대한 깊은 이해를 바탕으로 운세를 제공합니다.',
    user: `${sanitizeForAI(profile.name)}님(${profile.mbti})의 MBTI 기반 운세를 분석해주세요.

다음 형식으로 응답해주세요:
{
  "mbti_type": "${profile.mbti}",
  "today_energy": "오늘의 ${profile.mbti} 에너지 상태",
  "cognitive_functions": {
    "dominant": "주도 기능의 오늘 상태와 활용법",
    "auxiliary": "보조 기능의 오늘 상태와 활용법",
    "tertiary": "3차 기능의 오늘 상태와 주의점",
    "inferior": "열등 기능의 오늘 상태와 관리법"
  },
  "interpersonal": {
    "best_match_today": "오늘 잘 맞는 MBTI 유형",
    "challenging_match": "오늘 주의할 MBTI 유형",
    "communication_tip": "오늘의 소통 팁"
  },
  "daily_missions": [
    "오늘의 미션 1",
    "오늘의 미션 2",
    "오늘의 미션 3"
  ],
  "growth_opportunity": "오늘의 성장 기회",
  "self_care_tip": "${profile.mbti}를 위한 셀프케어 팁"
}`
  })
};

// 배치 운세 생성용 통합 프롬프트
export function createBatchFortunePrompt(
  profile: any,
  fortuneTypes: string[]
): string {
  const cleanProfile = {
    name: sanitizeForAI(profile.name || '사용자'),
    birthDate: profile.birthDate,
    gender: profile.gender,
    mbti: profile.mbti,
    blood_type: profile.blood_type
  };

  return `다음 사용자의 여러 운세를 한 번에 분석해주세요.

사용자 정보:
${JSON.stringify(cleanProfile, null, 2)}

요청된 운세 유형:
${fortuneTypes.join(', ')}

각 운세별로 다음 형식으로 응답해주세요:
{
  "${fortuneTypes[0]}": {
    "overall_luck": 점수,
    "summary": "핵심 요약",
    "advice": "조언",
    ... (각 운세 타입별 추가 필드)
  },
  "${fortuneTypes[1]}": {
    ...
  }
}

모든 운세는 서로 일관성을 유지하며, 사용자에게 도움이 되는 실용적인 내용으로 작성해주세요.`;
}

// 운세 응답 검증
export function validateFortuneResponse(
  response: any,
  fortuneType: string
): boolean {
  if (!response || typeof response !== 'object') {
    return false;
  }

  // 필수 필드 확인
  const requiredFields = ['summary', 'advice'];
  
  // 타입별 추가 필수 필드
  const typeSpecificFields: Record<string, string[]> = {
    daily: ['overall_luck', 'time_fortune', 'category_luck'],
    tarot: ['cards', 'overall_reading'],
    compatibility: ['overall_score', 'compatibility_details'],
    mbti: ['mbti_type', 'cognitive_functions', 'daily_missions']
  };

  const allRequired = [
    ...requiredFields,
    ...(typeSpecificFields[fortuneType] || [])
  ];

  return allRequired.every(field => field in response);
}