/**
 * 연애 운세 (Love Fortune) Edge Function
 *
 * @description 사용자의 연애 상태와 성향을 분석하여 맞춤형 연애 운세를 제공합니다.
 *
 * @endpoint POST /fortune-love
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - age: number - 나이
 * - gender: string - 성별
 * - relationshipStatus: 'single' | 'dating' | 'breakup' | 'crush' - 연애 상태
 * - datingStyles: string[] - 선호하는 연애 스타일
 * - valueImportance: { 외모, 성격, 경제력, 가치관, 유머감각 } - 중요도 (1-5)
 *
 * @response LoveFortuneResponse
 * - overall_score: number - 연애운 종합 점수
 * - love_luck: { meeting, relationship, attraction } - 연애 운세
 * - ideal_partner: { type, characteristics } - 이상형 분석
 * - timing: { best_time, best_place } - 만남 시기/장소
 * - advice: string - 연애 조언
 * - action_tips: string[] - 실천 팁
 * - percentile: number - 상위 백분위
 *
 * @example
 * curl -X POST https://xxx.supabase.co/functions/v1/fortune-love \
 *   -H "Authorization: Bearer <token>" \
 *   -d '{"userId":"xxx","age":28,"gender":"female","relationshipStatus":"single"}'
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.7.1'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { calculatePercentile, addPercentileToResult } from '../_shared/percentile/calculator.ts'
import {
  extractLoveCohort,
  generateCohortHash,
  getFromCohortPool,
  saveToCohortPool,
  personalize,
} from '../_shared/cohort/index.ts'

// TypeScript 인터페이스 정의
interface LoveFortuneRequest {
  userId: string;
  userName?: string; // ✅ 사용자 이름 (결과에서 "xx세 여성분" 대신 사용)
  birthDate?: string; // ✅ 생년월일 (Cohort 계산용)
  age: number;
  gender: string;
  relationshipStatus: 'single' | 'dating' | 'crush' | 'complicated'; // breakup 제거
  // Step 2: 연애 스타일
  datingStyles: string[];
  valueImportance: {
    외모: number;
    성격: number;
    경제력: number;
    가치관: number;
    유머감각: number;
  };
  // Step 3: 이상형
  preferredAgeRange: {
    min: number;
    max: number;
  };
  idealLooks?: string[]; // ✅ 이상형 외모상 (동물상/남성상)
  preferredPersonality: string[];
  preferredMeetingPlaces: string[];
  relationshipGoal: string;
  // Step 4: 나의 매력
  appearanceConfidence: number;
  charmPoints: string[];
  lifestyle: string;
  hobbies: string[];
  isPremium?: boolean; // ✅ 프리미엄 사용자 여부
}

interface LoveFortuneResponse {
  success: boolean;
  data: {
    fortuneType: string;
    personalInfo: {
      age: number;
      gender: string;
      relationshipStatus: string;
    };
    score: number;           // ✅ 표준화: loveScore → score
    content: string;         // ✅ 표준화: mainMessage → content
    summary: string;         // ✅ 표준화: 한줄 요약 추가
    advice: string;          // ✅ 표준화: 조언 추가
    loveProfile: {
      dominantStyle: string;
      personalityType: string;
      communicationStyle: string;
      conflictResolution: string;
    };
    detailedAnalysis: {
      loveStyle: {
        description: string;
        strengths: string[];
        tendencies: string[];
      };
      charmPoints: {
        primary: string;
        secondary: string;
        details: string[];
      };
      improvementAreas: {
        main: string;
        specific: string[];
        actionItems: string[];
      };
      compatibilityInsights: {
        bestMatch: string;
        avoidTypes: string;
        relationshipTips: string[];
      };
    };
    todaysAdvice: {
      general: string;
      specific: string[];
      luckyAction: string;
      warningArea: string;
    };
    predictions: {
      thisWeek: string;
      thisMonth: string;
      nextThreeMonths: string;
    };
    actionPlan: {
      immediate: string[];
      shortTerm: string[];
      longTerm: string[];
    };
    // ✅ 추천 섹션 (풀 스타일링 - 데이트/패션/그루밍/향수/대화)
    recommendations?: {
      dateSpots: {
        primary: string;            // 메인 추천 장소 (구체적 장소명+분위기+이유)
        alternatives: string[];     // 대안 장소 3개
        reason: string;             // 추천 이유
        timeRecommendation: string; // 추천 시간대
      };
      fashion: {
        style: string;              // 스타일 명칭
        colors: string[];           // 행운 컬러 3개+이유
        topItems: string[];         // 상의 추천 2개
        bottomItems: string[];      // 하의 추천 2개
        outerwear: string;          // 아우터 추천
        shoes: string;              // 신발 추천
        avoidFashion: string[];     // 피해야 할 스타일
        reason: string;             // 추천 이유
      };
      accessories: {
        recommended: string[];      // 추천 악세서리 3개
        avoid: string[];            // 피할 악세서리 2개
        bags: string;               // 가방 추천
        reason: string;             // 추천 이유
      };
      grooming: {
        hair: string;               // 헤어스타일 추천
        makeup: string;             // 메이크업/그루밍 팁
        nails: string;              // 네일 추천
      };
      fragrance: {
        notes: string[];            // 향 노트+브랜드 추천
        mood: string;               // 분위기
        timing: string;             // 사용 팁
      };
      conversation: {
        topics: string[];           // 추천 대화 주제 3개
        openers: string[];          // 대화 시작 문장 2개
        avoid: string[];        // 피할 주제
        tip: string;            // 대화 팁
      };
    };
    isBlurred?: boolean; // ✅ 블러 상태
    blurredSections?: string[]; // ✅ 블러 처리된 섹션 목록
  };
  cachedAt?: string;
}

// Supabase 클라이언트 초기화
const supabase = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
)

// 연애 상태별 기본값 함수
function getStatusDefaults(status: string): {
  bestMatch: string;
  goodMatch: string;
  challengingMatch: string;
  avoidTypes: string;
  relationshipTips: string[];
  thisWeek: string;
  thisMonth: string;
  nextThreeMonths: string;
  keyDates: string[];
} {
  const defaults: Record<string, any> = {
    single: {
      bestMatch: '진실하고 따뜻한 마음을 가진 안정형 성격의 파트너가 잘 맞습니다. 서로의 가치관을 존중하며 함께 성장할 수 있는 사람을 찾아보세요. 특히 유머 감각이 있고 대화가 잘 통하는 사람과의 만남이 좋습니다.',
      goodMatch: '사교적이고 긍정적인 에너지를 가진 사람, 취미나 관심사가 비슷한 사람과도 좋은 관계를 만들 수 있습니다.',
      challengingMatch: '지나치게 독립적이거나 감정 표현에 인색한 사람과는 처음에 거리감을 느낄 수 있으니 천천히 알아가세요.',
      avoidTypes: '감정 기복이 심하거나 진실하지 못한 사람, 과도하게 집착하거나 통제하려는 사람은 피하는 것이 좋습니다.',
      relationshipTips: ['새로운 만남에 열린 마음 갖기', '자신의 매력을 자연스럽게 표현하기', '첫인상에 너무 연연하지 않기'],
      thisWeek: '새로운 만남의 기회가 찾아올 수 있는 시기입니다. 평소 가지 않던 장소에서 뜻밖의 인연을 만날 수 있으니 열린 마음으로 지내보세요.',
      thisMonth: '연애운이 상승하는 달입니다. 주변 지인의 소개나 모임에서 좋은 인연을 만날 가능성이 높아요.',
      nextThreeMonths: '꾸준한 자기 개발과 사회 활동을 통해 매력이 상승하는 시기입니다. 3개월 후에는 지금보다 더 자신감 있게 연애에 임할 수 있을 거예요.',
      keyDates: ['이번 주 금요일 저녁', '다음 달 초', '12월 중순 연말 모임']
    },
    dating: {
      bestMatch: '현재 파트너와의 관계를 더욱 깊게 발전시킬 수 있습니다. 서로의 장점을 인정하고 단점을 보완해주는 관계가 이상적입니다.',
      goodMatch: '함께 성장하고 서로를 응원해주는 관계가 좋습니다. 개인 시간도 존중하면서 함께하는 시간도 소중히 여기세요.',
      challengingMatch: '서로 다른 가치관이나 생활 방식에 대해 열린 대화가 필요합니다. 차이를 인정하는 것이 관계 발전의 열쇠입니다.',
      avoidTypes: '관계에서 일방적인 희생만 요구하거나, 감정적으로 불안정한 패턴을 보이는 경우 주의가 필요합니다.',
      relationshipTips: ['정기적인 데이트 시간 만들기', '서로의 성장을 응원하기', '갈등은 대화로 해결하기'],
      thisWeek: '파트너와 특별한 시간을 보내기 좋은 주입니다. 일상에서 벗어나 둘만의 추억을 만들어보세요.',
      thisMonth: '관계의 다음 단계로 나아갈 수 있는 달입니다. 진지한 대화를 통해 서로의 미래 계획을 공유해보세요.',
      nextThreeMonths: '관계가 더욱 안정되고 깊어지는 시기입니다. 함께 여행을 계획하거나 새로운 도전을 해보는 것도 좋습니다.',
      keyDates: ['이번 주말 데이트', '기념일', '다음 달 여행 계획']
    },
    breakup: {
      bestMatch: '이전 관계에서 배운 것을 바탕으로, 당신을 있는 그대로 받아들여주는 안정적인 파트너가 좋습니다. 급하게 새로운 연애를 시작하기보다 충분히 치유된 후 만나는 것이 좋습니다.',
      goodMatch: '비슷한 경험을 이해해줄 수 있는 성숙한 사람, 조급하지 않고 천천히 관계를 쌓아갈 수 있는 사람과 좋은 인연이 될 수 있습니다.',
      challengingMatch: '너무 빠르게 관계 진전을 원하거나, 이전 연애에 대해 비교하려는 사람과는 거리를 두는 것이 좋습니다.',
      avoidTypes: '리바운드 관계를 원하는 사람이나, 당신의 상처를 이용하려는 사람을 경계하세요.',
      relationshipTips: ['자기 자신을 먼저 돌보기', '급하게 새로운 연애 시작하지 않기', '이전 관계에서 배운 점 정리하기'],
      thisWeek: '자기 자신에게 집중하고 치유하는 시간이 필요합니다. 친구들과 시간을 보내거나 새로운 취미를 시작해보세요.',
      thisMonth: '마음의 상처가 조금씩 아물어가는 달입니다. 무리하게 새로운 만남을 찾기보다 자연스럽게 흘러가는 대로 두세요.',
      nextThreeMonths: '완전히 새로운 시작을 할 준비가 되는 시기입니다. 더 성숙하고 현명한 연애를 시작할 수 있을 거예요.',
      keyDates: ['이번 달 말', '다음 달 보름달', '3개월 후 새로운 계절']
    },
    crush: {
      bestMatch: '상대방의 성격과 가치관을 잘 파악하고 있다면, 진심을 담아 접근해보세요. 당신의 따뜻한 마음이 전달될 것입니다.',
      goodMatch: '자연스럽게 친해질 수 있는 공통 관심사나 모임을 활용해보세요. 급하지 않게 천천히 다가가는 것이 효과적입니다.',
      challengingMatch: '상대방의 반응이 불분명하다면 조급해하지 마세요. 확실한 신호가 올 때까지 여유를 가지고 기다려보세요.',
      avoidTypes: '일방적인 감정에만 빠져 상대방의 신호를 무시하지 마세요. 상대방의 의사도 존중하는 것이 중요합니다.',
      relationshipTips: ['자연스럽게 대화 기회 만들기', '공통 관심사 찾기', '긍정적인 에너지 유지하기'],
      thisWeek: '상대방과 자연스럽게 대화할 기회가 생길 수 있습니다. 평소보다 적극적으로 다가가보세요.',
      thisMonth: '관계 진전의 가능성이 높은 달입니다. 용기를 내어 마음을 표현해보는 것도 좋습니다.',
      nextThreeMonths: '결과가 어떻든 성장하는 시간이 될 것입니다. 진심을 다해 노력한다면 좋은 결과가 있을 거예요.',
      keyDates: ['이번 주 중반', '다음 주 주말', '보름달이 뜨는 날']
    }
  };
  return defaults[status] || defaults.single;
}

// LLM API 호출 함수
async function generateLoveFortune(params: LoveFortuneRequest): Promise<any> {
  // 연애 상태별 맞춤 프롬프트 생성
  const relationshipContexts: Record<string, string> = {
    single: '새로운 만남을 원하는 싱글',
    dating: '현재 연애 중이며 관계 발전을 원하는',
    breakup: '이별을 경험하고 재회나 새출발을 고민하는',
    crush: '짝사랑 중인'
  };

  // 연애 상태별 특별 분석 지시문
  const statusSpecificInstructions: Record<string, string> = {
    single: `
## 싱글을 위한 특별 분석 (반드시 포함)
- compatibilityInsights: 어떤 유형의 파트너를 찾아야 하는지, 만남 가능성이 높은 장소/상황을 구체적으로 설명
- predictions: 새로운 만남 시기, 인연이 될 가능성이 있는 타이밍을 구체적인 날짜/상황으로 제시
- 소개팅/앱 매칭에서 주의할 점 포함`,

    dating: `
## 연애 중인 분을 위한 특별 분석 (반드시 포함)
- compatibilityInsights: 현재 파트너와의 궁합 강화 방법, 관계를 더 깊게 발전시키는 방향 제시
- predictions: 관계 진전 시기 (동거/결혼 논의 등), 중요한 기념일 활용법
- 갈등 예방 및 해결 조언 포함`,

    breakup: `
## 이별 후 힐링을 위한 특별 분석 (반드시 포함)
- compatibilityInsights: 다음 연애에서 찾아야 할 파트너 유형, 반복하지 말아야 할 패턴 분석
- predictions: 마음의 치유 시기, 새로운 시작이 가능한 시점을 구체적으로 제시
- 자기 치유와 성장을 위한 조언 포함`,

    crush: `
## 짝사랑 중인 분을 위한 특별 분석 (반드시 포함)
- compatibilityInsights: 상대방에게 어필할 수 있는 당신만의 매력 포인트, 효과적인 접근 전략
- predictions: 고백하기 좋은 시기, 관계 발전 가능성에 대한 구체적 예측
- 자연스럽게 친해지는 방법 포함`
  };

  // ✅ 강화된 시스템 프롬프트 (연애 심리학 전문가 페르소나 + 분석 프레임워크)
  const systemPrompt = `당신은 20년 경력의 연애 심리학 전문가이자 임상 심리상담사입니다.
애착 이론(Attachment Theory), 사랑의 삼각형 이론(Sternberg's Triangular Theory), 5가지 사랑의 언어(Love Languages)를 깊이 연구했으며, 수천 명의 연애 상담 경험이 있습니다.

# 전문 분야
- 애착 유형 분석 (안정형/불안형/회피형/혼란형)
- 사랑의 3요소 분석 (친밀감/열정/헌신)
- 5가지 사랑의 언어 (인정의 말, 함께하는 시간, 선물, 봉사, 스킨십)
- 관계 역학 및 커플 상담
- 한국 연애 문화 및 MZ세대 데이팅 트렌드

# 분석 철학
1. **과학적 접근**: 심리학 이론에 기반한 객관적 분석
2. **개인화**: 상담자의 상황에 맞는 맞춤형 조언
3. **균형성**: 장점과 개선점을 균형있게 제시
4. **실용성**: 즉시 실천 가능한 구체적 방법
5. **공감**: 따뜻하고 위로가 되는 톤 유지

# 출력 형식 (반드시 JSON 형식으로)
{
  "score": 60-95 사이 정수,
  "content": "핵심 메시지와 상세 분석 내용",
  "summary": "한줄 요약",
  "advice": "핵심 조언",
  "loveProfile": {
    "dominantStyle": "헌신형/열정형/친구형/독립형 중 택1",
    "attachmentType": "안정형/불안형/회피형/혼란형 중 택1",
    "loveLanguage": "5가지 사랑의 언어 중 택1",
    "communicationStyle": "소통 스타일 설명",
    "conflictResolution": "갈등 해결 방식 설명"
  },
  "detailedAnalysis": {
    "loveStyle": {
      "description": "연애 스타일 상세 분석",
      "strengths": ["강점1", "강점2", "강점3"],
      "tendencies": ["연애 경향1", "연애 경향2", "연애 경향3"],
      "psychologyInsight": "심리학적 해석"
    },
    "charmPoints": {
      "primary": "주된 매력 포인트 (50자 이상)",
      "secondary": "부가 매력 포인트 (50자 이상)",
      "hiddenCharm": "숨겨진 매력 (50자 이상)",
      "details": ["구체적 매력 요소 3가지"]
    },
    "improvementAreas": {
      "main": "주요 개선 영역 (50자 이상)",
      "specific": ["구체적 개선점 3가지 (각 30자 이상)"],
      "actionItems": ["실천 방법 3가지 (각 50자 이상)"],
      "psychologyTip": "심리학적 조언 (100자 이상)"
    },
    "compatibilityInsights": {
      "bestMatch": "최적 궁합 유형 상세 설명 (100자 이상)",
      "goodMatch": "좋은 궁합 유형 (50자 이상)",
      "challengingMatch": "주의가 필요한 궁합 유형 (50자 이상)",
      "avoidTypes": "피해야 할 유형과 이유 (100자 이상)",
      "relationshipTips": ["관계 조언 3가지 (각 50자 이상)"]
    }
  },
  "todaysAdvice": {
    "general": "오늘의 연애운 종합 (100자 이상)",
    "specific": ["구체적 조언 3가지 (각 50자 이상)"],
    "luckyAction": "행운을 부르는 행동 (50자 이상)",
    "luckyItem": "오늘의 행운 아이템",
    "luckyTime": "연애에 유리한 시간대",
    "warningArea": "주의해야 할 점 (50자 이상)"
  },
  "predictions": {
    "thisWeek": "이번 주 연애운 예측 (100자 이상)",
    "thisMonth": "이번 달 연애운 예측 (100자 이상)",
    "nextThreeMonths": "향후 3개월 예측 (150자 이상)",
    "keyDates": ["중요한 날짜 또는 시기 2-3개"]
  },
  "actionPlan": {
    "immediate": ["즉시 실천할 것 3가지 (각 50자 이상)"],
    "shortTerm": ["1-2주 내 할 것 3가지 (각 50자 이상)"],
    "longTerm": ["1-3개월 내 목표 3가지 (각 50자 이상)"],
    "dailyHabit": "매일 실천할 연애 습관 (50자 이상)"
  },
  "recommendations": {
    "dateSpots": {
      "primary": "실제 존재하는 구체적 장소명 + 분위기 + 추천 이유 (예: '한남동 블루보틀 카페 - 세련되고 조용한 분위기가 상담자의 차분한 매력과 잘 어울려요', 80자 이상). ⛔ 'OO', 'XX', '○○' 같은 플레이스홀더 절대 금지!",
      "alternatives": ["대안 장소 3개 - 실제 구체적 장소명과 한줄 이유 (예: '성수동 대림창고 - 인스타그래머블한 분위기', '북촌 감고당길 카페거리 - 한옥 분위기', '연남동 연트럴파크 - 여유로운 산책')"],
      "reason": "왜 이 장소가 상담자에게 맞는지 심리학적 분석",
      "timeRecommendation": "추천 시간대와 이유 (예: '오후 3-5시, 햇살이 좋아 첫만남에 좋아요')"
    },
    "fashion": {
      "style": "구체적 스타일 명칭 (미니멀 캐주얼, 시크 페미닌, 스포티 캐주얼, 댄디 캐주얼 등)",
      "colors": ["오늘의 행운 컬러 3개 + 이유 (예: '베이지 - 신뢰감과 따뜻함', '크림화이트 - 순수하고 깔끔한 이미지', '카키 - 세련되고 안정된 느낌')"],
      "topItems": ["상의 추천 2개 - 구체적 아이템+색상 (예: '라운드넥 캐시미어 니트(베이지)', '오버핏 옥스포드 셔츠(화이트)')"],
      "bottomItems": ["하의 추천 2개 - 구체적 아이템+색상 (예: '와이드 슬랙스(차콜)', '스트레이트 데님(인디고)')"],
      "outerwear": "아우터 추천 - 구체적 아이템 (예: '캐멀 롱코트 - 고급스러운 첫인상을 줄 수 있어요')",
      "shoes": "신발 추천 - 구체적 아이템 (예: '화이트 레더 스니커즈 - 깔끔하면서도 편안한 느낌')",
      "avoidFashion": ["피해야 할 스타일 2개와 이유 (예: '과한 로고 플레이 - 부담스러운 인상')"],
      "reason": "왜 이 스타일이 상담자에게 어울리는지 성격/매력 기반 분석"
    },
    "accessories": {
      "recommended": ["추천 악세서리 3개 - 구체적 아이템+효과 (예: '미니멀 실버 시계 - 세련된 느낌', '작은 진주 귀걸이 - 우아한 포인트', '심플한 가죽 벨트 - 깔끔한 마무리')"],
      "avoid": ["피할 악세서리 2개와 이유 (예: '과한 금장식 - 부담스럽고 과시하는 인상')"],
      "bags": "가방 추천 (예: '미니 크로스백(베이지) - 활동적이면서 세련된 느낌, 첫 데이트에 적합')",
      "reason": "악세서리 선택 기준과 전체 코디 밸런스 팁"
    },
    "grooming": {
      "hair": "헤어스타일 추천 - 구체적 스타일+효과 (예: '자연스러운 웨이브 - 부드럽고 다가가기 쉬운 인상', '깔끔한 투블럭 - 단정하고 신뢰감 있는 이미지')",
      "makeup": "메이크업/그루밍 팁 - 성별 맞춤 (예: 여성 '내추럴 코랄 립 + 은은한 광채 베이스', 남성 '깔끔한 눈썹 정리 + 입술 보습')",
      "nails": "네일 추천 (예: '누드톤 젤네일 - 깔끔하고 단정한 인상', '깔끔하게 정돈된 숏네일 - 청결한 이미지')"
    },
    "fragrance": {
      "notes": ["추천 향 노트 2개 + 구체적 향수 추천 (예: '우디 머스크 - 조말론 우드세이지앤씨솔트, 고급스럽고 세련된 분위기', '시트러스 플로럴 - 딥티크 도손, 상쾌하고 밝은 이미지')"],
      "mood": "향수가 상대방에게 주는 인상과 분위기",
      "timing": "향수 사용 팁 (예: '만나기 30분 전, 손목과 귀 뒤에 가볍게 2-3번 뿌리기')"
    },
    "conversation": {
      "topics": ["추천 대화 주제 3개 - 구체적 (예: '최근 본 넷플릭스 드라마나 영화', '요즘 빠진 취미나 관심사', '가고 싶은 여행지나 맛집')"],
      "openers": ["대화 시작 문장 2개 (예: '요즘 뭐 재밌게 보세요?', '이 카페 분위기 진짜 좋다! 자주 오세요?')"],
      "avoid": ["피해야 할 주제 2개와 이유 (예: '전 연인 얘기 - 부정적인 분위기', '정치/종교 - 첫만남에 논쟁적')"],
      "tip": "대화 팁 - 상담자의 성격과 매력을 살리는 방법"
    }
  }
}

# 분량 요구사항 (충실한 분석 제공)
- mainMessage: 80~150자 (핵심 메시지, 설문 결과 반영)
- description, insight 항목: 150~250자 (상세하고 구체적인 분석)
- 리스트 항목 (specific, immediate 등): 각 50~100자
- 예측 항목 (thisWeek, thisMonth): 100~200자
- 전체적으로 상담자가 입력한 설문 정보를 반드시 활용하여 개인화된 분석 제공

# ⭐ 필수 생성 필드 (절대 누락 금지, 반드시 100자 이상 작성)
다음 필드는 반드시 구체적이고 풍부한 내용으로 작성해야 합니다. 빈 문자열이나 짧은 응답 금지:
1. compatibilityInsights.bestMatch - 최적 궁합 유형 (100자 이상, 구체적인 성격/특성 묘사)
2. compatibilityInsights.goodMatch - 좋은 궁합 유형 (80자 이상)
3. compatibilityInsights.challengingMatch - 주의가 필요한 궁합 (80자 이상)
4. compatibilityInsights.avoidTypes - 피해야 할 유형 (80자 이상)
5. compatibilityInsights.relationshipTips - 관계 조언 3가지 (각 50자 이상)
6. predictions.thisWeek - 이번 주 예측 (100자 이상, 구체적인 상황 묘사)
7. predictions.thisMonth - 이번 달 예측 (100자 이상)
8. predictions.nextThreeMonths - 3개월 예측 (150자 이상)
9. predictions.keyDates - 중요한 날짜/시기 2-3개 (각 20자 이상)

# 설문 반영 필수사항 (⭐ 중요)
- 데이팅 스타일 → 연애 성향 분석에 직접 인용
- 가치관 중요도 → 이상형 분석 및 궁합 조언에 반영
- 선호 성격 → 궁합 인사이트에 구체적으로 활용
- 매력 포인트 → 강점 분석에 그대로 활용
- 취미/라이프스타일 → 만남 조언에 반영
- 외모 자신감 점수 → 자기개발 조언에 반영

# ⛔ 절대 금지 표현 (이 표현들은 절대로 사용하지 마세요!)
다음 표현들은 비인격적이고 차갑게 느껴지므로 절대 사용 금지:
- "남자분", "여자분", "남성분", "여성분" → 금지!
- "회원님" → userName이 제공되면 절대 사용 금지!
- "xx세 분", "xx대 분", "xx대 여성", "xx대 남성" → 금지!
- "상담자", "사용자", "고객님" → 금지!

# ✅ 반드시 사용할 호칭 규칙
- 모든 문장에서 상담자를 이름으로 호칭 (예: "철수님", "영희님")
- 2인칭 존칭 사용 (예: "철수님은...", "철수님의...", "철수님께...")
- 따뜻하고 친근한 톤 유지 (예: "철수님, 오늘 정말 좋은 기운이 느껴져요!")

# 주의사항
- 상담자의 나이, 성별, 연애 상태를 고려한 맞춤형 분석
- 심리학 용어를 사용하되 쉽게 풀어서 설명
- 모호한 점술 표현 금지 (구체적 시기, 방법, 행동 제시)
- 과도한 낙관론이나 부정적 단정 금지
- 설문에서 입력한 내용이 결과에 직접 반영되어야 함
- 반드시 유효한 JSON 형식으로 출력

# ⛔ 플레이스홀더 절대 금지
다음과 같은 플레이스홀더 표현은 절대 사용하지 마세요:
- 'OO', 'XX', '○○', '某某', '@@' 같은 마스킹
- '카페 OO', '레스토랑 XX' 같은 가짜 장소명
- 반드시 실제 존재하는 구체적인 장소명을 사용하세요 (예: '한남동 블루보틀', '성수동 대림창고', '을지로 카페거리')`

  // ✅ 상담자 호칭 결정 (userName 있으면 이름, 없으면 성별 기반)
  const clientName = params.userName
    ? `${params.userName}님`
    : params.gender === 'female' ? '회원님' : '회원님';

  const userPrompt = `# 연애 상담 요청 정보

## 상담자 기본 정보
- 이름/호칭: ${clientName}
- 나이: ${params.age}세
- 성별: ${params.gender}
- 현재 연애 상태: ${relationshipContexts[params.relationshipStatus] || '일반'}

## 연애 스타일 분석 자료
- 데이팅 스타일: ${params.datingStyles?.length > 0 ? params.datingStyles.join(', ') : '일반적인 스타일'}
- 가치관 중요도: ${Object.keys(params.valueImportance || {}).length > 0 ? Object.entries(params.valueImportance).map(([key, value]) => `${key}(${value}/5점)`).join(', ') : '균형 중시'}

## 이상형 정보
- 선호 나이대: ${params.preferredAgeRange?.min || 20}~${params.preferredAgeRange?.max || 30}세
- 선호 외모상: ${params.idealLooks?.length > 0 ? params.idealLooks.join(', ') : '미지정'}
- 선호 성격: ${params.preferredPersonality?.length > 0 ? params.preferredPersonality.join(', ') : '미지정'}
- 선호 만남 장소: ${params.preferredMeetingPlaces?.length > 0 ? params.preferredMeetingPlaces.join(', ') : '미지정'}
- 원하는 관계: ${params.relationshipGoal || '진지한 연애'}

## 본인 매력 자기 평가
- 외모 자신감: ${params.appearanceConfidence || 5}/10점
- 매력 포인트: ${params.charmPoints?.length > 0 ? params.charmPoints.join(', ') : '미지정'}
- 라이프스타일: ${params.lifestyle || '미지정'}
- 취미: ${params.hobbies?.length > 0 ? params.hobbies.join(', ') : '미지정'}

${statusSpecificInstructions[params.relationshipStatus] || statusSpecificInstructions.single}

## ⭐ 중요 지시사항
1. 모든 분석에서 상담자를 "${clientName}"으로 호칭하세요 ("xx세 여성분" 같은 표현 금지)
2. 위에서 입력받은 설문 정보(데이팅 스타일, 가치관, 이상형 외모/성격, 매력 포인트 등)를 결과에 직접적으로 반영하세요
3. 추상적인 표현 대신 구체적인 장소명, 아이템명, 색상명을 사용하세요
4. recommendations 섹션은 상담자의 성향과 이상형을 고려한 맞춤 추천으로 작성하세요

위 정보를 바탕으로 ${clientName}에게 전문적이고 구체적인 연애운세 분석을 JSON 형식으로 제공해주세요.
특히 심리학적 관점에서의 분석과 실질적으로 도움이 되는 조언을 부탁드립니다.

⚠️ 주의: compatibilityInsights, predictions, recommendations 필드는 반드시 풍부하고 구체적인 내용으로 작성하세요. 빈 값이나 짧은 응답은 허용되지 않습니다.`

  // ✅ LLM 모듈 사용 (동적 DB 설정 - A/B 테스트 지원)
  const llm = await LLMFactory.createFromConfigAsync('love')

  // ✅ LLM 호출 (Provider 무관)
  const response = await llm.generate([
    { role: 'system', content: systemPrompt },
    { role: 'user', content: userPrompt }
  ], {
    temperature: 1,
    maxTokens: 8192,
    jsonMode: true
  })

  console.log(`✅ LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)

  // ✅ LLM 사용량 로깅 (비용/성능 분석용)
  await UsageLogger.log({
    fortuneType: 'love',
    userId: params.userId,
    provider: response.provider,
    model: response.model,
    response: response,
    metadata: {
      age: params.age,
      gender: params.gender,
      relationshipStatus: params.relationshipStatus,
      isPremium: params.isPremium
    }
  })

  // JSON 파싱
  return JSON.parse(response.content)
}

// 캐시 조회 함수
async function getCachedFortune(userId: string, params: LoveFortuneRequest) {
  try {
    const cacheKey = `love_${userId}_${JSON.stringify({
      age: params.age,
      gender: params.gender,
      relationshipStatus: params.relationshipStatus,
      datingStyles: params.datingStyles.sort(),
      valueImportance: params.valueImportance
    })}`

    const { data, error } = await supabase
      .from('fortune_cache')
      .select('result, created_at')
      .eq('cache_key', cacheKey)
      .gte('created_at', new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString())
      .order('created_at', { ascending: false })
      .limit(1)
      .single()

    if (error) {
      console.log('캐시 조회 결과 없음:', error.message)
      return null
    }

    console.log('캐시된 연애운세 조회 성공')
    return {
      ...data.result,
      cachedAt: data.created_at
    }
  } catch (error) {
    console.error('캐시 조회 오류:', error)
    return null
  }
}

// 캐시 저장 함수
async function saveCachedFortune(userId: string, params: LoveFortuneRequest, result: any) {
  try {
    const cacheKey = `love_${userId}_${JSON.stringify({
      age: params.age,
      gender: params.gender,
      relationshipStatus: params.relationshipStatus,
      datingStyles: params.datingStyles.sort(),
      valueImportance: params.valueImportance
    })}`

    const { error } = await supabase
      .from('fortune_cache')
      .upsert({
        cache_key: cacheKey,
        user_id: userId,
        fortune_type: 'love',
        result: result,
        created_at: new Date().toISOString()
      })

    if (error) {
      console.error('캐시 저장 오류:', error)
    } else {
      console.log('연애운세 캐시 저장 완료')
    }
  } catch (error) {
    console.error('캐시 저장 중 예외:', error)
  }
}

// 메인 핸들러
serve(async (req) => {
  // CORS 헤더 설정
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
  }

  // OPTIONS 요청 처리
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders })
  }

  try {
    if (req.method !== 'POST') {
      return new Response(
        JSON.stringify({ success: false, error: 'POST 메소드만 허용됩니다' }),
        {
          status: 405,
          headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' }
        }
      )
    }

    const requestBody = await req.json()
    console.log('연애운세 요청 데이터:', requestBody)

    // 필수 필드 검증
    const requiredFields = ['userId', 'age', 'gender', 'relationshipStatus', 'datingStyles', 'valueImportance']
    for (const field of requiredFields) {
      if (!requestBody[field]) {
        return new Response(
          JSON.stringify({ success: false, error: `필수 필드 누락: ${field}` }),
          {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' }
          }
        )
      }
    }

    const params: LoveFortuneRequest = requestBody

    // 캐시 확인
    const cachedResult = await getCachedFortune(params.userId, params)
    if (cachedResult) {
      return new Response(
        JSON.stringify({
          success: true,
          data: cachedResult,
          cached: true
        }),
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' }
        }
      )
    }

    // ✅ Cohort Pool 조회 (API 비용 90% 절감)
    // birthDate가 없으면 age로 대략적인 생년 계산
    const effectiveBirthDate = params.birthDate || `${new Date().getFullYear() - params.age}-01-01`;
    const cohortData = extractLoveCohort({
      gender: params.gender,
      relationshipStatus: params.relationshipStatus,
      birthDate: effectiveBirthDate,
    })
    const cohortHash = await generateCohortHash(cohortData)
    console.log(`[fortune-love] 🔍 Cohort: ${JSON.stringify(cohortData)}, Hash: ${cohortHash.substring(0, 16)}...`)

    const cohortPoolResult = await getFromCohortPool(supabase, 'love', cohortHash)
    if (cohortPoolResult) {
      console.log(`[fortune-love] ✅ Cohort Pool HIT! 캐시된 결과 사용`)

      // 개인화 후처리
      const personalizedResult = personalize(cohortPoolResult, {
        userName: params.userName || '회원님',
        age: params.age,
        gender: params.gender,
        relationshipStatus: params.relationshipStatus,
        datingStyles: params.datingStyles,
        charmPoints: params.charmPoints,
      })

      // ✅ Blur 로직 적용
      const isPremium = params.isPremium ?? false
      const isBlurred = !isPremium
      const blurredSections = isBlurred
        ? ['loveProfile', 'detailedAnalysis', 'predictions', 'actionPlan']
        : []

      // ✅ Percentile 계산
      const percentileData = await calculatePercentile(supabase, 'love', personalizedResult.score || 75)
      const resultWithPercentile = addPercentileToResult({
        ...personalizedResult,
        fortuneType: 'love',
        personalInfo: {
          age: params.age,
          gender: params.gender,
          relationshipStatus: params.relationshipStatus,
        },
        isBlurred,
        blurredSections,
      }, percentileData)

      return new Response(
        JSON.stringify({ success: true, data: resultWithPercentile }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
      )
    }

    console.log(`[fortune-love] ⚡ Cohort Pool MISS - LLM 호출 필요`)

    // AI 연애운세 생성
    console.log('AI 연애운세 생성 시작...')
    const fortuneData = await generateLoveFortune(params)

    // ✅ 연애 상태별 기본값 가져오기
    const statusDefaults = getStatusDefaults(params.relationshipStatus);

    // ✅ Blur 로직 적용 (프리미엄이 아니면 상세 분석 블러 처리)
    const isPremium = params.isPremium ?? false;
    const isBlurred = !isPremium;
    const blurredSections = isBlurred
      ? ['loveProfile', 'detailedAnalysis', 'predictions', 'actionPlan']
      : [];

    // ✅ Deep merge 헬퍼: 빈 문자열이나 짧은 값은 기본값으로 대체
    const getValidString = (value: any, fallback: string, minLength: number = 10): string => {
      if (typeof value === 'string' && value.trim().length >= minLength) {
        return value;
      }
      return fallback;
    };

    const getValidArray = (value: any, fallback: string[]): string[] => {
      if (Array.isArray(value) && value.length > 0 && value.every(v => typeof v === 'string' && v.trim().length > 0)) {
        return value;
      }
      return fallback;
    };

    // ✅ Deep merge: compatibilityInsights (각 필드 개별 처리)
    const compatibilityInsights = {
      bestMatch: getValidString(
        fortuneData.detailedAnalysis?.compatibilityInsights?.bestMatch,
        statusDefaults.bestMatch,
        50
      ),
      goodMatch: getValidString(
        fortuneData.detailedAnalysis?.compatibilityInsights?.goodMatch,
        statusDefaults.goodMatch,
        30
      ),
      challengingMatch: getValidString(
        fortuneData.detailedAnalysis?.compatibilityInsights?.challengingMatch,
        statusDefaults.challengingMatch,
        30
      ),
      avoidTypes: getValidString(
        fortuneData.detailedAnalysis?.compatibilityInsights?.avoidTypes,
        statusDefaults.avoidTypes,
        30
      ),
      relationshipTips: getValidArray(
        fortuneData.detailedAnalysis?.compatibilityInsights?.relationshipTips,
        statusDefaults.relationshipTips
      )
    };

    // ✅ Deep merge: predictions (각 필드 개별 처리)
    const predictions = {
      thisWeek: getValidString(
        fortuneData.predictions?.thisWeek,
        statusDefaults.thisWeek,
        50
      ),
      thisMonth: getValidString(
        fortuneData.predictions?.thisMonth,
        statusDefaults.thisMonth,
        50
      ),
      nextThreeMonths: getValidString(
        fortuneData.predictions?.nextThreeMonths,
        statusDefaults.nextThreeMonths,
        50
      ),
      keyDates: getValidArray(
        fortuneData.predictions?.keyDates,
        statusDefaults.keyDates
      )
    };

    // 응답 데이터 구조화 (✅ 표준화된 필드명 사용)
    const response: LoveFortuneResponse = {
      success: true,
      data: {
        fortuneType: 'love',
        personalInfo: {
          age: params.age,
          gender: params.gender,
          relationshipStatus: params.relationshipStatus
        },
        // ✅ 표준화된 필드명: score, content, summary, advice
        score: fortuneData.score || fortuneData.loveScore || Math.floor(Math.random() * 35) + 60,
        content: fortuneData.content || fortuneData.mainMessage || '새로운 사랑의 기회가 찾아올 것입니다.',
        summary: fortuneData.summary || '연애운이 상승하는 시기입니다',
        advice: fortuneData.advice || fortuneData.todaysAdvice?.general || '자신의 매력을 자연스럽게 표현해보세요',

        // 연애 프로필
        loveProfile: {
          dominantStyle: fortuneData.loveProfile?.dominantStyle || '헌신형',
          personalityType: fortuneData.loveProfile?.attachmentType || fortuneData.loveProfile?.personalityType || '안정형',
          communicationStyle: fortuneData.loveProfile?.communicationStyle || '진솔한 소통을 선호합니다.',
          conflictResolution: fortuneData.loveProfile?.conflictResolution || '대화를 통해 해결하려 합니다.'
        },

        // ✅ 상세 분석 (Deep merge 적용)
        detailedAnalysis: {
          loveStyle: {
            description: getValidString(
              fortuneData.detailedAnalysis?.loveStyle?.description,
              '따뜻하고 진실한 연애 스타일을 가지고 있습니다.',
              20
            ),
            strengths: getValidArray(
              fortuneData.detailedAnalysis?.loveStyle?.strengths,
              ['진정성 있는 감정 표현', '상대방을 배려하는 마음', '안정적인 관계 유지 능력']
            ),
            tendencies: getValidArray(
              fortuneData.detailedAnalysis?.loveStyle?.tendencies,
              ['감정을 중시하는 경향', '안정성을 추구하는 성향', '장기적 관점으로 관계를 바라봄']
            )
          },
          charmPoints: {
            primary: getValidString(
              fortuneData.detailedAnalysis?.charmPoints?.primary,
              '진실한 마음과 따뜻한 성격이 가장 큰 매력입니다.',
              20
            ),
            secondary: getValidString(
              fortuneData.detailedAnalysis?.charmPoints?.secondary,
              '상대방을 이해하려는 노력이 돋보입니다.',
              20
            ),
            details: getValidArray(
              fortuneData.detailedAnalysis?.charmPoints?.details,
              ['공감 능력이 뛰어남', '신뢰할 수 있는 성격', '배려심이 깊음']
            )
          },
          improvementAreas: {
            main: getValidString(
              fortuneData.detailedAnalysis?.improvementAreas?.main,
              '자신감 있는 감정 표현력을 키워보세요.',
              20
            ),
            specific: getValidArray(
              fortuneData.detailedAnalysis?.improvementAreas?.specific,
              ['적극적인 감정 표현 연습', '명확한 의사소통 능력 개발', '개인적 성장에 투자']
            ),
            actionItems: getValidArray(
              fortuneData.detailedAnalysis?.improvementAreas?.actionItems,
              ['매일 감사한 점 3가지 적기', '상대방에게 먼저 연락하기', '새로운 취미 시작하기']
            )
          },
          // ✅ 연애 상태별 기본값이 적용된 궁합 인사이트
          compatibilityInsights
        },

        // 오늘의 조언
        todaysAdvice: {
          general: fortuneData.todaysAdvice?.general || '오늘은 사랑에 적극적인 하루가 될 것입니다.',
          specific: fortuneData.todaysAdvice?.specific || ['새로운 만남에 열린 마음 갖기', '솔직한 대화하기', '자신의 매력 표현하기'],
          luckyAction: fortuneData.todaysAdvice?.luckyAction || '좋아하는 사람에게 진심을 담은 메시지 보내기',
          warningArea: fortuneData.todaysAdvice?.warningArea || '과도한 기대는 실망으로 이어질 수 있으니 주의'
        },

        // ✅ 연애 상태별 기본값이 적용된 예측
        predictions,

        // 실천 계획
        actionPlan: fortuneData.actionPlan || {
          immediate: ['자신의 감정 솔직하게 정리하기', '상대방에게 먼저 연락하기'],
          shortTerm: ['데이트 계획 세우기', '관계 발전 방향 대화하기'],
          longTerm: ['서로의 미래 계획 공유하기', '신뢰 관계 더 깊게 구축하기']
        },

        // ✅ 추천 섹션 (풀 스타일링: 데이트/패션/그루밍/향수/대화)
        recommendations: fortuneData.recommendations ? {
          dateSpots: {
            primary: fortuneData.recommendations.dateSpots?.primary || '한남동 블루보틀 카페 - 세련되고 조용한 분위기에서 깊은 대화를 나눠보세요',
            alternatives: getValidArray(fortuneData.recommendations.dateSpots?.alternatives, ['성수동 대림창고 - 인스타그래머블한 분위기', '북촌 한옥마을 - 여유로운 산책', '이태원 경리단길 - 트렌디한 맛집']),
            reason: fortuneData.recommendations.dateSpots?.reason || '차분한 분위기에서 서로를 알아가기 좋아요',
            timeRecommendation: fortuneData.recommendations.dateSpots?.timeRecommendation || '오후 3-5시, 햇살이 따뜻한 시간대가 첫만남에 좋아요'
          },
          fashion: {
            style: fortuneData.recommendations.fashion?.style || '미니멀 캐주얼',
            colors: getValidArray(fortuneData.recommendations.fashion?.colors, ['베이지 - 신뢰감과 따뜻함', '크림화이트 - 순수하고 깔끔한 이미지', '네이비 - 차분하고 지적인 느낌']),
            topItems: getValidArray(fortuneData.recommendations.fashion?.topItems, ['라운드넥 캐시미어 니트(베이지)', '오버핏 옥스포드 셔츠(화이트)']),
            bottomItems: getValidArray(fortuneData.recommendations.fashion?.bottomItems, ['와이드 슬랙스(차콜)', '스트레이트 데님(인디고)']),
            outerwear: fortuneData.recommendations.fashion?.outerwear || '캐멀 롱코트 - 고급스러운 첫인상을 줄 수 있어요',
            shoes: fortuneData.recommendations.fashion?.shoes || '화이트 레더 스니커즈 - 깔끔하면서도 편안한 느낌',
            avoidFashion: getValidArray(fortuneData.recommendations.fashion?.avoidFashion, ['과한 로고 플레이 - 부담스러운 인상', '너무 화려한 패턴 - 산만해 보일 수 있음']),
            reason: fortuneData.recommendations.fashion?.reason || '첫인상에서 신뢰감을 줄 수 있어요'
          },
          accessories: {
            recommended: getValidArray(fortuneData.recommendations.accessories?.recommended, ['미니멀 실버 시계 - 세련된 느낌', '작은 귀걸이 - 우아한 포인트', '심플한 가죽 벨트 - 깔끔한 마무리']),
            avoid: getValidArray(fortuneData.recommendations.accessories?.avoid, ['과한 금장식 - 부담스러운 인상', '너무 많은 액세서리 - 산만해 보임']),
            bags: fortuneData.recommendations.accessories?.bags || '미니 크로스백(베이지) - 활동적이면서 세련된 느낌',
            reason: fortuneData.recommendations.accessories?.reason || '센스있고 세련된 이미지 연출'
          },
          grooming: {
            hair: fortuneData.recommendations.grooming?.hair || '자연스러운 웨이브 - 부드럽고 다가가기 쉬운 인상',
            makeup: fortuneData.recommendations.grooming?.makeup || '내추럴 메이크업 - 은은한 광채와 부드러운 립 컬러',
            nails: fortuneData.recommendations.grooming?.nails || '누드톤 젤네일 - 깔끔하고 단정한 인상'
          },
          fragrance: {
            notes: getValidArray(fortuneData.recommendations.fragrance?.notes, ['우디 머스크 - 조말론 우드세이지앤씨솔트, 세련된 분위기', '시트러스 플로럴 - 딥티크 도손, 상쾌하고 밝은 이미지']),
            mood: fortuneData.recommendations.fragrance?.mood || '차분하면서 고급스러운 분위기',
            timing: fortuneData.recommendations.fragrance?.timing || '만나기 30분 전, 손목과 귀 뒤에 가볍게 2-3번'
          },
          conversation: {
            topics: getValidArray(fortuneData.recommendations.conversation?.topics, ['최근 본 넷플릭스 드라마', '요즘 빠진 취미나 관심사', '가고 싶은 여행지나 맛집']),
            openers: getValidArray(fortuneData.recommendations.conversation?.openers, ['요즘 뭐 재밌게 보세요?', '이 카페 분위기 진짜 좋다! 자주 오세요?']),
            avoid: getValidArray(fortuneData.recommendations.conversation?.avoid, ['전 연인 얘기 - 부정적인 분위기', '정치/종교 - 첫만남에 논쟁적']),
            tip: fortuneData.recommendations.conversation?.tip || '상대방 이야기를 먼저 들어주고, 공감하면서 자연스럽게 대화를 이어가세요'
          }
        } : undefined,

        // ✅ 블러 상태 정보
        isBlurred,
        blurredSections
      }
    }

    console.log(`✅ [연애운] isPremium: ${isPremium}, isBlurred: ${!isPremium}`)

    // ✅ 퍼센타일 계산
    const percentileData = await calculatePercentile(supabase, 'love', response.data.score)
    response.data = addPercentileToResult(response.data, percentileData) as typeof response.data

    // 캐시 저장
    await saveCachedFortune(params.userId, params, response.data)

    // ✅ Cohort Pool에 저장 (비동기, 에러 무시)
    saveToCohortPool(supabase, 'love', cohortHash, cohortData, response.data)
      .then(() => console.log(`[fortune-love] 💾 Cohort Pool에 저장 완료`))
      .catch((err) => console.warn(`[fortune-love] ⚠️ Cohort Pool 저장 실패 (무시됨):`, err.message))

    console.log('연애운세 생성 완료')
    return new Response(
      JSON.stringify(response),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' }
      }
    )

  } catch (error) {
    console.error('연애운세 생성 오류:', error)

    return new Response(
      JSON.stringify({
        success: false,
        error: '연애 인사이트 생성 중 오류가 발생했습니다: ' + error.message
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' }
      }
    )
  }
})