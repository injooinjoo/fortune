import { NextRequest, NextResponse } from 'next/server';
import { selectGPTModel, callGPTAPI } from '@/config/ai-models';

interface StartupRequest {
  name: string;
  birth_date: string;
  mbti: string;
  capital: string;
  experience: string;
  interests: string[];
}

interface StartupFortune {
  score: number;
  best_industries: string[];
  best_start_time: string;
  partners: string[];
  tips: string[];
  cautions: string[];
}

// MBTI별 추천 업종 맵핑
const mbtiIndustryMap: { [key: string]: string[] } = {
  'E': ['마케팅/광고', '컨설팅', '교육/강의', 'F&B', '엔터테인먼트', '이벤트/기획'],
  'I': ['IT/소프트웨어', '연구개발', '콘텐츠 제작', '디자인', '온라인 비즈니스', '프리랜싱'],
  'N': ['스타트업', 'IT/테크', '크리에이티브', '혁신기술', '바이오/헬스케어', '인공지능'],
  'S': ['제조업', '유통/물류', '금융', '부동산', '서비스업', '프랜차이즈'],
  'T': ['엔지니어링', 'IT/개발', '금융/투자', '컨설팅', '데이터 분석', '법률/회계'],
  'F': ['교육', '헬스케어', '소셜 임팩트', '문화/예술', '상담/코칭', '사회적 기업'],
  'J': ['경영/관리', '금융', '교육', '의료', '법률', '전통 사업'],
  'P': ['크리에이티브', '스타트업', '프리랜싱', '여행/레저', '엔터테인먼트', '혁신 사업']
};

function generateStartupScore(request: StartupRequest): number {
  let baseScore = 70;
  
  // 창업 경험에 따른 점수
  if (request.experience === 'expert') baseScore += 15;
  else if (request.experience === 'little') baseScore += 8;
  else if (request.experience === 'none') baseScore -= 5;
  
  // 자본금 적정성 (단위: 만원)
  const capital = parseInt(request.capital) || 0;
  if (capital >= 5000 && capital <= 20000) baseScore += 10; // 적정 범위
  else if (capital >= 1000 && capital < 5000) baseScore += 5; // 소자본
  else if (capital > 50000) baseScore -= 5; // 과도한 자본
  else if (capital < 500) baseScore -= 10; // 자본 부족
  
  // 관심 분야 다양성
  if (request.interests.length >= 3) baseScore += 8;
  else if (request.interests.length >= 2) baseScore += 5;
  else if (request.interests.length === 0) baseScore -= 5;
  
  // MBTI 특성 반영
  if (request.mbti.includes('E')) baseScore += 5; // 외향적 - 네트워킹 유리
  if (request.mbti.includes('N')) baseScore += 8; // 직관적 - 창업에 유리
  if (request.mbti.includes('P')) baseScore += 5; // 인식형 - 유연성
  
  return Math.max(40, Math.min(95, baseScore + Math.floor(Math.random() * 15) - 7));
}

function generateBestIndustries(request: StartupRequest): string[] {
  const allIndustries = [
    'IT/소프트웨어', '마케팅/광고', '교육/강의', 'F&B', '컨설팅', 
    '이커머스', '콘텐츠 제작', '디자인', '헬스케어', '핀테크',
    '바이오텍', '에너지', '부동산테크', '푸드테크', '에듀테크'
  ];
  
  let recommendedIndustries = [...request.interests];
  
  // MBTI 기반 추천 업종 추가
  for (let char of request.mbti) {
    if (mbtiIndustryMap[char]) {
      const mbtiRecommendations = mbtiIndustryMap[char]
        .filter(industry => !recommendedIndustries.includes(industry))
        .slice(0, 2);
      recommendedIndustries = [...recommendedIndustries, ...mbtiRecommendations];
    }
  }
  
  // 자본금에 따른 추천
  const capital = parseInt(request.capital) || 0;
  if (capital < 2000 && !recommendedIndustries.includes('온라인 비즈니스')) {
    recommendedIndustries.push('온라인 비즈니스');
  }
  if (capital >= 10000 && !recommendedIndustries.includes('프랜차이즈')) {
    recommendedIndustries.push('프랜차이즈');
  }
  
  // 경험에 따른 추천
  if (request.experience === 'none' && !recommendedIndustries.includes('프리랜싱')) {
    recommendedIndustries.push('프리랜싱');
  }
  
  // 3개로 제한하되, 사용자 관심사를 우선
  return recommendedIndustries.slice(0, 3);
}

function generateBestStartTime(request: StartupRequest): string {
  const birthDate = new Date(request.birth_date);
  const birthMonth = birthDate.getMonth() + 1;
  const currentYear = new Date().getFullYear();
  
  // 생월 기반 행운의 월 계산
  let luckyMonth = birthMonth;
  if (luckyMonth <= 3) luckyMonth += 9; // 1-3월 -> 10-12월
  else if (luckyMonth <= 6) luckyMonth += 6; // 4-6월 -> 10-12월, 1-3월
  else if (luckyMonth <= 9) luckyMonth -= 6; // 7-9월 -> 1-3월
  else luckyMonth -= 3; // 10-12월 -> 7-9월
  
  const months = ['1월', '2월', '3월', '4월', '5월', '6월', 
                 '7월', '8월', '9월', '10월', '11월', '12월'];
  
  // 경험에 따른 시기 조정
  let targetYear = currentYear + 1;
  if (request.experience === 'none') {
    targetYear = currentYear + 2; // 초보자는 더 늦은 시기 권장
  } else if (request.experience === 'expert') {
    targetYear = currentYear + 1; // 경험자는 빠른 시기 가능
  }
  
  return `${targetYear}년 ${months[luckyMonth - 1]}`;
}

function generateBestPartners(request: StartupRequest): string[] {
  // MBTI 보완 관계 계산
  const complementaryMbti: { [key: string]: string[] } = {
    'ENFP': ['INTJ', 'INFJ', 'ISTJ'],
    'ENFJ': ['INFP', 'ISFP', 'INTP'],
    'ENTP': ['INFJ', 'INTJ', 'ISFJ'],
    'ENTJ': ['INFP', 'ISFP', 'INTP'],
    'INFP': ['ENFJ', 'ESFJ', 'ENTJ'],
    'INFJ': ['ENFP', 'ESFP', 'ENTP'],
    'INTP': ['ENFJ', 'ESFJ', 'ENTJ'],
    'INTJ': ['ENFP', 'ESFP', 'ENTP'],
    'ESFP': ['INTJ', 'INFJ', 'ISTJ'],
    'ESFJ': ['INFP', 'ISFP', 'INTP'],
    'ESTP': ['INFJ', 'INTJ', 'ISFJ'],
    'ESTJ': ['INFP', 'ISFP', 'INTP'],
    'ISFP': ['ENFJ', 'ESFJ', 'ENTJ'],
    'ISFJ': ['ENFP', 'ESFP', 'ENTP'],
    'ISTP': ['ENFJ', 'ESFJ', 'ENTJ'],
    'ISTJ': ['ENFP', 'ESFP', 'ENTP']
  };
  
  const userMbti = request.mbti.toUpperCase();
  let partners = complementaryMbti[userMbti] || ['ENFP', 'ISTJ', 'ENTJ'];
  
  // 창업 경험에 따른 파트너 추천
  if (request.experience === 'none') {
    partners = partners.filter(p => ['ENTJ', 'ESTJ', 'ENFJ'].includes(p));
    if (partners.length < 2) {
      partners.push('ENTJ', 'ESTJ'); // 리더십 있는 유형 추가
    }
  }
  
  return partners.slice(0, 2);
}

function generateTipsAndCautions(request: StartupRequest) {
  const baseTips = [
    '시장 조사를 철저히 하세요',
    '초기 자금 관리를 신중히 하세요',
    '네트워크를 적극 활용하세요'
  ];
  
  const baseCautions = [
    '과도한 확장에 주의',
    '파트너와의 갈등 관리 필요'
  ];
  
  let customTips = [...baseTips];
  let customCautions = [...baseCautions];
  
  // 창업 경험별 맞춤 조언
  if (request.experience === 'none') {
    customTips.push('멘토나 창업 전문가의 조언을 구하세요');
    customTips.push('소규모로 시작하여 점진적으로 확장하세요');
    customCautions.push('복잡한 사업 모델은 피하고 단순한 것부터 시작');
  } else if (request.experience === 'expert') {
    customTips.push('기존 경험을 살려 차별화 전략을 수립하세요');
    customTips.push('과거 실패 경험을 교훈으로 활용하세요');
    customCautions.push('과도한 자신감으로 인한 성급한 확장 주의');
  }
  
  // 자본금별 조언
  const capital = parseInt(request.capital) || 0;
  if (capital < 2000) {
    customTips.push('저비용 고효율 비즈니스 모델을 고려하세요');
    customCautions.push('자금 부족으로 인한 조급한 수익화 시도 주의');
  } else if (capital > 20000) {
    customTips.push('충분한 자본을 활용한 차별화된 서비스 제공');
    customCautions.push('큰 자본에 대한 심리적 부담과 위험 관리 필수');
  }
  
  // MBTI별 조언
  if (request.mbti.includes('I')) {
    customTips.push('온라인 마케팅과 디지털 채널을 적극 활용하세요');
  }
  if (request.mbti.includes('E')) {
    customTips.push('직접적인 고객 접촉과 네트워킹을 강화하세요');
  }
  if (request.mbti.includes('P')) {
    customCautions.push('계획성 부족으로 인한 일정 지연 주의');
  }
  if (request.mbti.includes('J')) {
    customCautions.push('과도한 완벽주의로 인한 출시 지연 주의');
  }
  
  return {
    tips: customTips.slice(0, 4),
    cautions: customCautions.slice(0, 3)
  };
}

async function analyzeStartupFortune(request: StartupRequest): Promise<StartupFortune> {
  try {
    // GPT 모델 선택 (창업 상담용)
    const model = selectGPTModel('daily', 'text');
    
    // 전문 창업 운세 프롬프트 생성
    const prompt = `
당신은 창업 전문가이자 운세 상담사입니다. 다음 정보를 바탕으로 창업 운세를 상세히 분석해주세요.

사용자 정보:
- 이름: ${request.name}
- 생년월일: ${request.birth_date}
- MBTI: ${request.mbti}
- 예상 자본금: ${request.capital}만원
- 창업 경험: ${request.experience}
- 관심 분야: ${request.interests.join(', ')}

다음 JSON 형식으로 응답해주세요:
{
  "score": 85,
  "best_industries": ["추천 업종 1", "추천 업종 2", "추천 업종 3"],
  "best_start_time": "창업에 적합한 시기",
  "partners": ["적합한 파트너 MBTI 1", "적합한 파트너 MBTI 2"],
  "tips": ["창업 성공을 위한 조언들"],
  "cautions": ["주의해야 할 사항들"]
}
`;

    // GPT API 호출
    const gptResult = await callGPTAPI(prompt, model);
    
    // GPT 응답이 올바른 형식인지 검증 및 변환
    if (gptResult && typeof gptResult === 'object' && 
        typeof gptResult.score === 'number') {
      console.log('GPT API 호출 성공');
      
      return {
        score: gptResult.score,
        best_industries: gptResult.best_industries || generateBestIndustries(request),
        best_start_time: gptResult.best_start_time || generateBestStartTime(request),
        partners: gptResult.partners || generateBestPartners(request),
        tips: gptResult.tips || ['시장 조사를 철저히 하세요', '초기 자금 관리를 신중히 하세요'],
        cautions: gptResult.cautions || ['과도한 확장에 주의', '파트너와의 갈등 관리 필요']
      };
    } else {
      throw new Error('GPT 응답 형식 오류');
    }
    
  } catch (error) {
    console.error('GPT API 호출 실패, 백업 로직 사용:', error);
    
    // 백업 로직: 기존 알고리즘 실행
    return generatePersonalizedStartupFortune(request);
  }
}

function generatePersonalizedStartupFortune(request: StartupRequest): StartupFortune {
  const tipsAndCautions = generateTipsAndCautions(request);
  
  return {
    score: generateStartupScore(request),
    best_industries: generateBestIndustries(request),
    best_start_time: generateBestStartTime(request),
    partners: generateBestPartners(request),
    tips: tipsAndCautions.tips,
    cautions: tipsAndCautions.cautions
  };
}

export async function POST(request: NextRequest) {
  try {
    const body: StartupRequest = await request.json();
    
    // 필수 필드 검증
    if (!body.name || !body.birth_date || !body.mbti) {
      return NextResponse.json(
        { error: '필수 정보가 누락되었습니다.' },
        { status: 400 }
      );
    }

    // MBTI 형식 검증
    if (!/^[A-Z]{4}$/.test(body.mbti)) {
      return NextResponse.json(
        { error: 'MBTI는 4자리 영문 대문자로 입력해주세요.' },
        { status: 400 }
      );
    }

    const fortuneResult = await analyzeStartupFortune(body);

    return NextResponse.json(fortuneResult);
    
  } catch (error) {
    console.error('Startup API error:', error);
    return NextResponse.json(
      { error: '창업운 분석 중 오류가 발생했습니다.' },
      { status: 500 }
    );
  }
} 