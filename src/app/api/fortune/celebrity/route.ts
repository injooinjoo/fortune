import { NextRequest, NextResponse } from 'next/server';

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const { celebrity_name, user_name = "게스트", birth_date, category } = body;

    if (!celebrity_name) {
      return NextResponse.json(
        { error: '유명인 이름이 필요합니다.' },
        { status: 400 }
      );
    }

    // GPT 프롬프트 생성
    const prompt = `당신은 전문 사주명리학자입니다. 다음 정보를 바탕으로 유명인 운세를 분석해주세요.

유명인: ${celebrity_name}
카테고리: ${category || '연예인'}
사용자: ${user_name}
생년월일: ${birth_date}

다음 JSON 형식으로 상세한 유명인 운세를 제공해주세요:

{
  "celebrity": {
    "name": "${celebrity_name}",
    "category": "자동 분류된 카테고리 (K-POP 그룹/가수/배우/스포츠 스타/방송인 등)",
    "description": "유명인의 현재 기운과 에너지 상태 설명",
    "emoji": "카테고리에 맞는 이모지"
  },
  "todayScore": 70-100 사이의 오늘 점수,
  "weeklyScore": 70-100 사이의 주간 점수,
  "monthlyScore": 70-100 사이의 월간 점수,
  "summary": "유명인의 전반적인 운세 요약",
  "luckyTime": "행운의 시간대",
  "luckyColor": "행운의 색상 (색상명 또는 HEX 코드)",
  "luckyItem": "행운의 아이템",
  "advice": "유명인을 롤모델로 삼을 때의 구체적인 조언",
  "predictions": {
    "love": "연애운 예측",
    "career": "사업/경력운 예측", 
    "wealth": "재물운 예측",
    "health": "건강운 예측"
  }
}

- 모든 텍스트는 한국어로 작성
- 구체적이고 개인화된 내용 제공
- 긍정적이면서도 현실적인 조언
- 유명인의 실제 특성과 이미지를 반영`;

    // OpenAI API 호출 (실제 구현시)
    const mockResponse = {
      celebrity: {
        name: celebrity_name,
        category: category || getAutoCategoryKor(celebrity_name),
        description: `${celebrity_name}님의 기운이 매우 밝고 창의적인 에너지로 가득 차 있어, 주변에 긍정적인 영향을 미치고 있는 시기입니다.`,
        emoji: getCategoryEmoji(category || getAutoCategoryEng(celebrity_name))
      },
      todayScore: Math.floor(Math.random() * 31) + 70,
      weeklyScore: Math.floor(Math.random() * 31) + 70, 
      monthlyScore: Math.floor(Math.random() * 31) + 70,
      summary: `${celebrity_name}님의 영향으로 창의적 영감과 도전 정신이 높아지는 시기입니다. 꾸준한 노력으로 목표를 달성할 수 있을 것입니다.`,
      luckyTime: "오후 2시-5시",
      luckyColor: "#FFD700",
      luckyItem: "골드 액세서리",
      advice: `${celebrity_name}님처럼 진정성 있는 자세로 꾸준히 노력하고, 팬들과의 소통을 중요하게 여기는 마음가짐이 성공의 열쇠입니다.`,
      predictions: {
        love: "진실한 마음으로 다가가면 좋은 인연을 만날 수 있고, 기존 관계도 더욱 깊어질 것입니다.",
        career: "창의적인 아이디어와 도전 정신으로 새로운 기회를 잡을 수 있으며, 협업에서 좋은 결과를 얻을 것입니다.",
        wealth: "꾸준한 노력의 결실로 안정적인 수입이 보장되고, 새로운 수익 기회도 생길 것입니다.",
        health: "규칙적인 생활 습관과 적절한 휴식으로 컨디션이 좋아지며, 스트레스 관리에 신경 써야 합니다."
      }
    };

    return NextResponse.json({
      success: true,
      fortune: mockResponse,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Celebrity fortune API error:', error);
    return NextResponse.json(
      { error: '운세 생성 중 오류가 발생했습니다.' },
      { status: 500 }
    );
  }
}

function getAutoCategoryKor(name: string): string {
  if (name.includes("BTS") || name.includes("블랙핑크") || name.includes("뉴진스") || 
      name.includes("aespa") || name.includes("스트레이키즈") || name.includes("레드벨벳")) {
    return "K-POP 그룹";
  }
  if (["아이유", "태연", "박효신", "이승기", "임영웅", "이찬원"].includes(name)) {
    return "가수";
  }
  if (["손흥민", "김연아", "박세리", "류현진", "김민재", "황희찬"].includes(name)) {
    return "스포츠 스타";
  }
  if (["박서준", "김고은", "이병헌", "전지현", "송중기", "박보영", "이종석", "송혜교"].includes(name)) {
    return "배우";
  }
  if (["유재석", "강호동", "박나래", "김구라", "신동엽", "이수근"].includes(name)) {
    return "방송인";
  }
  return "연예인";
}

function getAutoCategoryEng(name: string): string {
  if (name.includes("BTS") || name.includes("블랙핑크") || name.includes("뉴진스") || 
      name.includes("aespa") || name.includes("스트레이키즈") || name.includes("레드벨벳")) {
    return "kpop";
  }
  if (["아이유", "태연", "박효신", "이승기", "임영웅", "이찬원"].includes(name)) {
    return "singer";
  }
  if (["손흥민", "김연아", "박세리", "류현진", "김민재", "황희찬"].includes(name)) {
    return "sports";
  }
  if (["박서준", "김고은", "이병헌", "전지현", "송중기", "박보영", "이종석", "송혜교"].includes(name)) {
    return "actor";
  }
  if (["유재석", "강호동", "박나래", "김구라", "신동엽", "이수근"].includes(name)) {
    return "entertainer";
  }
  return "celebrity";
}

function getCategoryEmoji(category: string): string {
  switch (category) {
    case "kpop": return "🎤";
    case "singer": return "🎵";
    case "sports": return "🏆";
    case "actor": return "🎭";
    case "entertainer": return "📺";
    default: return "⭐";
  }
} 