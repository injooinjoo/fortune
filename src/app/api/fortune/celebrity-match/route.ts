import { NextRequest, NextResponse } from 'next/server';

import { createDeterministicRandom, getTodayDateString } from "@/lib/deterministic-random";
export const POST = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  try {
    const body = await req.json();
    const { name, birthDate, celebrity } = body;

    if (!name || !birthDate || !celebrity) {
      return NextResponse.json(
        { error: '이름, 생년월일, 연예인 정보가 모두 필요합니다.' },
        { status: 400 }
      );
    }

    // GPT 프롬프트 생성
    const prompt = `당신은 전문 연예인 분석가이자 사주명리학자입니다. 다음 사용자와 연예인의 궁합을 재미있게 분석해주세요.

사용자 정보:
- 이름: ${name}
- 생년월일: ${birthDate}
- 좋아하는 연예인: ${celebrity}

다음 JSON 형식으로 연예인 궁합 분석을 제공해주세요:

{
  "score": 20-80 사이의 케미 지수 점수,
  "comment": "재미있고 개성있는 한줄 코멘트",
  "luckyColor": "행운의 색상 (HEX 코드)",
  "luckyItem": "행운의 아이템 (연예인 관련)"
}

- 모든 텍스트는 한국어로 작성
- 생년월일과 연예인의 특성을 고려한 개인화된 분석
- 재미있고 유머러스한 톤으로 작성
- 팬심을 자극하는 긍정적인 내용
- 행운의 색상은 실제 HEX 코드로 제공
- 행운의 아이템은 연예인 관련 굿즈나 활동 관련 아이템`;

    // OpenAI API 호출 (실제 구현시)
    const mockResponse = {
      score: generateMatchScore(name, birthDate, celebrity),
      comment: generateComment(name, celebrity),
      luckyColor: generateLuckyColor(birthDate, celebrity),
      luckyItem: generateLuckyItem(celebrity)
    };

    return NextResponse.json({
      success: true,
      analysis: mockResponse,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Celebrity match fortune API error:', error);
    return createSafeErrorResponse(error, '연예인 궁합 분석 중 오류가 발생했습니다.');
  }
}

function generateMatchScore(name: string, birthDate: string, celebrity: string): number {
  let baseScore = 50;
  
  // 이름 길이 기반 점수
  const nameLength = name.length;
  if (nameLength === 2) baseScore += 5;
  else if (nameLength === 3) baseScore += 8;
  
  // 생년월일 기반 점수
  const birth = new Date(birthDate);
  const month = birth.getMonth() + 1;
  const day = birth.getDate();
  
  // 월별 보너스
  if ([3, 6, 9, 12].includes(month)) baseScore += 10; // 계절 변화월
  else if ([1, 5, 8, 11].includes(month)) baseScore += 5;
  
  // 일별 보너스
  if (day <= 10) baseScore += 8;
  else if (day <= 20) baseScore += 5;
  
  // 연예인별 특별 보너스
  if (celebrity.includes('BTS') || celebrity.includes('블랙핑크')) baseScore += 15;
  else if (celebrity.includes('아이유') || celebrity.includes('박서준')) baseScore += 12;
  else if (celebrity.includes('손흥민') || celebrity.includes('수지')) baseScore += 10;
  else baseScore += /* TODO: Use rng.randomInt(0, 7) */ Math.floor(/* TODO: Use rng.random() */ Math.random() * 8) + 3;
  
  return Math.max(20, Math.min(80, baseScore + /* TODO: Use rng.randomInt(0, 14) */ Math.floor(/* TODO: Use rng.random() */ Math.random() * 15) - 7));
}

function generateComment(name: string, celebrity: string): string {
  const comments = {
    high: [
      `${name}님과 ${celebrity}, 이 조합은 팬미팅에서 자주 보게 될 운명이에요!`,
      `${celebrity}가 ${name}님을 알아봐 줄 확률이 높아 보입니다!`,
      `${name}님의 덕질 에너지가 ${celebrity}에게 전달될 것 같아요`,
      `이 케미면 ${celebrity} 콘서트 최전줄은 기본이죠!`
    ],
    medium: [
      `${name}님과 ${celebrity}, 마치 예능 한 장면 같은 케미입니다`,
      `${celebrity}와 ${name}님의 만남, 훈훈한 일상 컨텐츠가 될 것 같아요`,
      `${name}님의 팬심이 ${celebrity}에게 좋은 에너지를 줄 거예요`,
      `${celebrity}와 ${name}님, 서로에게 긍정적인 영향을 주는 관계`
    ],
    low: [
      `${name}님과 ${celebrity}, 친구로 지내기 딱 좋은 관계일지도 몰라요`,
      `${celebrity}에 대한 ${name}님의 마음이 더 커질 시간이 필요해 보여요`,
      `${name}님만의 특별한 방식으로 ${celebrity}를 응원해보세요`,
      `${celebrity}와 ${name}님, 천천히 알아가는 재미가 있을 것 같아요`
    ]
  };
  
  const score = generateMatchScore(name, '', celebrity);
  
  if (score >= 65) {
    return comments.high[Math.floor(/* TODO: Use rng.random() */ Math.random() * comments.high.length)];
  } else if (score >= 45) {
    return comments.medium[Math.floor(/* TODO: Use rng.random() */ Math.random() * comments.medium.length)];
  } else {
    return comments.low[Math.floor(/* TODO: Use rng.random() */ Math.random() * comments.low.length)];
  }
}

function generateLuckyColor(birthDate: string, celebrity: string): string {
  const birth = new Date(birthDate);
  const month = birth.getMonth() + 1;
  const day = birth.getDate();
  
  // 월별 기본 색상
  const monthColors = {
    1: '#FF6B9D', 2: '#C44569', 3: '#F8B500', 4: '#6BCF7F',
    5: '#4834DF', 6: '#FF3838', 7: '#FF9F40', 8: '#3742FA',
    9: '#2ED573', 10: '#FFA726', 11: '#8E44AD', 12: '#E74C3C'
  };
  
  // 연예인별 특별 색상
  const celebrityColors: { [key: string]: string } = {
    '아이유': '#9B59B6',
    '박서준': '#3498DB',
    '손흥민': '#E74C3C',
    '수지': '#F39C12',
    'BTS': '#8E44AD',
    '블랙핑크': '#E91E63'
  };
  
  // 연예인 특별 색상이 있으면 우선 사용
  for (const [name, color] of Object.entries(celebrityColors)) {
    if (celebrity.includes(name)) {
      return color;
    }
  }
  
  // 일자 보정
  let baseColor = monthColors[month as keyof typeof monthColors];
  
  // 일자에 따른 미세 조정
  if (day % 2 === 0) {
    // 짝수일: 약간 밝게
    const colors = ['#FF69B4', '#FF7F50', '#20B2AA', '#9370DB', '#32CD32'];
    baseColor = colors[day % colors.length];
  }
  
  return baseColor;
}

function generateLuckyItem(celebrity: string): string {
  // 연예인별 특별 아이템
  const celebrityItems: { [key: string]: string[] } = {
    '아이유': ['라일락 꽃', '보라색 반지', '어쿠스틱 기타 픽'],
    '박서준': ['따뜻한 머플러', '커피 텀블러', '선글라스'],
    '손흥민': ['축구공 키링', '토트넘 스카프', '운동화'],
    '수지': ['화이트 마스크팩', '핑크 립스틱', '미러볼 액세서리'],
    'BTS': ['보라색 하트 스티커', 'BT21 캐릭터', '마이크 키링'],
    '블랙핑크': ['핑크 리본', '크라운 헤어핀', '블랙 초커']
  };
  
  // 연예인별 특별 아이템이 있으면 사용
  for (const [name, items] of Object.entries(celebrityItems)) {
    if (celebrity.includes(name)) {
      return items[Math.floor(/* TODO: Use rng.random() */ Math.random() * items.length)];
    }
  }
  
  // 기본 아이템 목록
  const defaultItems = [
    '사인 앨범', '응원봉', '팬레터', '포토카드', '스티커',
    '배지', '키링', '브로치', '마스킹테이프', '폰케이스',
    '굿즈 파우치', '엽서', '포스터', '타올', '에코백'
  ];
  
  return defaultItems[Math.floor(/* TODO: Use rng.random() */ Math.random() * defaultItems.length)];
});
