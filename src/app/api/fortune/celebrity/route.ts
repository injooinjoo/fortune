import { NextRequest, NextResponse } from 'next/server';
import { selectGPTModel, callGPTAPI } from '@/config/ai-models';
import { withFortuneAuth, createSafeErrorResponse } from '@/lib/security-api-utils';
import { AuthenticatedRequest } from '@/middleware/auth';
import { FortuneService } from '@/lib/services/fortune-service';
import { DeterministicRandom, createDeterministicRandom, getTodayDateString } from "@/lib/deterministic-random";
import { createSuccessResponse, createErrorResponse, createFortuneResponse, handleApiError } from '@/lib/api-response-utils';

export const POST = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  try {
    const body = await request.json();
    const { celebrity_name, user_name, birth_date, category } = body;

    if (!celebrity_name) {
      return createErrorResponse('유명인 이름이 필요합니다.', undefined, undefined, 400);
    }

    // GPT 모델 선택 (유명인 운세용)
    const model = selectGPTModel('daily', 'text');

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
  "todayScore": 80,
  "weeklyScore": 75,
  "monthlyScore": 85,
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

    try {
      // GPT API 호출
      const gptResult = await callGPTAPI(prompt, model);
      
      // GPT 응답이 올바른 형식인지 검증 및 변환
      if (gptResult && typeof gptResult === 'object' && 
          gptResult.celebrity && typeof gptResult.todayScore === 'number') {
        console.log('GPT API 호출 성공');
        
        return NextResponse.json({
      success: true,
      fortune: gptResult,
      cached: false,
      generated_at: new Date().toISOString()
    });
      } else {
        throw new Error('GPT 응답 형식 오류');
      }
      
    } catch (error) {
      console.error('GPT API 호출 실패, 백업 로직 사용:', error);
      
      // 백업 로직: Mock 응답
      const userId = request.userId || 'anonymous';
      const date = getTodayDateString();
      const rng = new DeterministicRandom(userId, date, `celebrity-${celebrity_name}`);
      
      const mockResponse = {
        celebrity: {
          name: celebrity_name,
          category: category || getAutoCategoryKor(celebrity_name),
          description: `${celebrity_name}님의 기운이 매우 밝고 창의적인 에너지로 가득 차 있어, 주변에 긍정적인 영향을 미치고 있는 시기입니다.`,
          emoji: getCategoryEmoji(category || getAutoCategoryEng(celebrity_name))
        },
        todayScore: rng.randomInt(70, 100),
        weeklyScore: rng.randomInt(70, 100), 
        monthlyScore: rng.randomInt(70, 100),
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
      cached: false,
      generated_at: new Date().toISOString()
    });
    }

  } catch (error) {
    console.error('Celebrity fortune API error:', error);
    return createSafeErrorResponse(error, '운세 생성 중 오류가 발생했습니다.');
  }
});

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
