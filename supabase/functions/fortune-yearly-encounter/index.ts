/**
 * 2026 올해의 인연 (Yearly Encounter) Edge Function
 *
 * 미래 애인 얼굴을 AI로 생성하고, 만남 예측 정보를 제공하는 운세 기능
 *
 * Cost: 10 tokens
 * - Image: Gemini 2.5 Flash Image (gemini-2.5-flash-image) - 이미지 생성
 * - Text: Gemini 2.0 Flash Lite (gemini-2.0-flash-lite)
 *
 * Self-contained: 공유 모듈 없이 독립 실행 가능
 */

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { UsageLogger } from "../_shared/llm/usage-logger.ts";
import {
  GEMINI_IMAGE_MODEL,
  GEMINI_SAFE_TEXT_MODEL,
} from "../_shared/llm/models.ts";
import { assertLlmRequestAllowed } from "../_shared/llm/safety.ts";

const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const GEMINI_TEXT_MODEL = GEMINI_SAFE_TEXT_MODEL;
const GEMINI_IMAGE_MODEL_NAME = GEMINI_IMAGE_MODEL;

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// ============================================================================
// Types
// ============================================================================

interface YearlyEncounterRequest {
  userId: string;
  targetGender: "male" | "female";
  userAge: string; // '20대 초반', '20대 중반', etc.
  idealMbti: string; // MBTI or '상관없음'
  idealStyle?: string; // 선택한 스타일 ID (dandy, sporty, casual, prep, street, innocent, career, girlcrush, pure, glamour)
  idealType: string; // 자유 텍스트 이상형 설명
  isPremium?: boolean;
}

interface YearlyEncounterResponse {
  success: boolean;
  data?: {
    imageUrl: string;
    appearanceHashtags: string[];
    // 첫만남 장소
    encounterSpotTitle: string;
    encounterSpotStory: string;
    // 인연의 시그널
    fateSignalTitle: string;
    fateSignalStory: string;
    // 성격/특징
    personalityTitle: string;
    personalityStory: string;
    // 궁합 점수
    compatibilityScore: string;
    compatibilityDescription: string;
    targetGender: string;
    createdAt: string;
  };
  error?: string;
}

interface TelemetryContext {
  userId: string;
  requestId: string;
}

// ============================================================================
// DB Constants (고정값)
// ============================================================================

const ENCOUNTER_SPOTS = [
  {
    id: "station",
    title: "비 오는 날 지하철역",
    story:
      '갑자기 쏟아진 비를 피해 지하철역 3번 출구로 뛰어들었을 때, 같은 생각을 한 그 사람과 눈이 마주칠 거예요. 우산 하나를 사이에 두고 "같이 쓰실래요?"라는 말이 두 사람의 시작이 됩니다.',
  },
  {
    id: "party",
    title: "친구 모임 술자리",
    story:
      "귀찮다고 안 가려던 친구 모임. 결국 억지로 끌려간 그 술자리 구석에서, 시끄러운 음악 사이로 유독 또렷하게 들리는 그 사람 목소리에 마음을 빼앗길 거예요.",
  },
  {
    id: "office",
    title: "회사 미팅룸",
    story:
      "긴장되는 프로젝트 첫 미팅. 회의실 문을 열고 들어선 순간 마주친 따뜻한 눈빛이 업무용 인사가 아닌 무언가 다른 느낌으로 다가올 거예요. 그렇게 매일 기다려지는 출근길이 시작됩니다.",
  },
  {
    id: "cafe",
    title: "단골 카페 합석",
    story:
      '주말 오후, 단골 카페의 유일한 남은 자리 앞에서 동시에 멈춰 섭니다. "먼저 앉으세요"라는 양보 대신 "같이 앉아도 될까요?"라는 용기 있는 한마디가 새로운 인연을 열어줄 거예요.',
  },
  {
    id: "library",
    title: "도서관 옆자리",
    story:
      "시험 기간, 조용한 도서관 열람실. 고개를 들 때마다 계속 눈이 마주치는 옆자리 그 사람. 며칠째 같은 시간, 같은 자리를 찾게 되고, 어느 날 휴게실에서 우연히 마주친 척 대화가 시작될 거예요.",
  },
  {
    id: "park",
    title: "한강 공원 산책로",
    story:
      "노을 지는 한강 공원에서 산책하던 중, 갑자기 강아지 줄이 꼬여버렸어요. 급하게 사과하며 풀어주다 손이 스치는 순간, 어색한 웃음과 함께 자연스럽게 연락처를 교환하게 됩니다.",
  },
  {
    id: "concert",
    title: "콘서트 옆자리",
    story:
      '좋아하는 가수의 콘서트장, 설레는 마음으로 티켓을 꺼내다 그만 떨어뜨렸어요. "이거요!" 하고 주워준 그 사람이 바로 옆자리였다는 걸 깨달은 순간, 3시간 동안 같은 노래를 부르며 운명을 확신하게 됩니다.',
  },
  {
    id: "elevator",
    title: "회사 엘리베이터",
    story:
      '지각할 것 같아 후다닥 탄 엘리베이터. 숨을 고르는데 같은 층 버튼을 누르는 손이 보여요. "혹시 신입사원이세요?" "아, 네... 오늘 첫 출근이에요." 그렇게 매일 아침이 기대되는 출근이 시작됩니다.',
  },
  {
    id: "travel",
    title: "여행지 게스트하우스",
    story:
      '혼자 떠난 여행지의 게스트하우스. 공용 라운지에서 맥주 한 캔을 앞에 두고 멍하니 있을 때, "혼자 여행이세요? 저도요."라는 말과 함께 시작된 밤새 대화가 평생 인연으로 이어질 거예요.',
  },
  {
    id: "workshop",
    title: "원데이 클래스",
    story:
      '심심해서 신청한 원데이 클래스. 서툰 손길로 무언가를 만들다 옆 사람과 눈이 마주쳐 웃음이 터졌어요. 수업이 끝나고 "다음에 또 같이 들을래요?"라는 말에 번호를 교환하게 됩니다.',
  },
];

const FATE_SIGNALS = [
  {
    id: "scent",
    title: "향수 냄새",
    story:
      "그 사람이 가까이 올 때마다 은은하게 풍기는 우디향 향수 냄새가 날 거예요. 나중에 길을 걷다가 같은 향을 맡으면, 자연스럽게 그 사람 생각이 나서 미소 짓게 될 거예요.",
  },
  {
    id: "color",
    title: "파란색 옷",
    story:
      "유난히 눈에 들어오는 파란색 셔츠를 입은 사람이 보일 거예요. 이상하게 그날따라 그 색이 선명하게 느껴지고, 나중에 그게 인연의 시작이었다는 걸 깨닫게 됩니다.",
  },
  {
    id: "item",
    title: "같은 소지품",
    story:
      '우연히 그 사람의 가방에서 나와 똑같은 키링이나 핸드폰 케이스를 발견하게 될 거예요. "어, 저도 그거 있어요!"라는 말로 시작된 대화가 점점 길어질 거예요.',
  },
  {
    id: "habit",
    title: "수줍은 습관",
    story:
      "말을 걸 때 살짝 뒷머리를 긁적이거나, 미소 지을 때 눈을 살짝 피하는 수줍은 습관이 보일 거예요. 그 어색한 제스처에서 진심이 느껴져 마음이 녹을 거예요.",
  },
  {
    id: "drink",
    title: "커피 한 잔",
    story:
      '별 말 없이 건네주는 시원한 아이스 아메리카노 한 잔. "뭐 마시는지 봤어요"라는 말에 심장이 쿵 내려앉을 거예요. 그 사소한 관심이 큰 감동으로 다가옵니다.',
  },
  {
    id: "sound",
    title: "다정한 목소리",
    story:
      "대화 중 들려오는 낮고 차분한 중저음 목소리. 시끄러운 곳에서도 유독 또렷하게 들리는 그 목소리에 귀가 기울여지고, 어느새 그 음색에 익숙해진 자신을 발견하게 돼요.",
  },
  {
    id: "weather",
    title: "특별한 날씨",
    story:
      "첫눈이 내리는 날이거나, 갑자기 비가 쏟아지는 날 그 사람을 만나게 될 거예요. 날씨 덕분에 생긴 예기치 못한 상황이 두 사람을 가깝게 만들어 줄 거예요.",
  },
  {
    id: "gesture",
    title: "경청하는 자세",
    story:
      "내가 말할 때 몸을 살짝 기울이며 집중해서 듣는 모습이 보일 거예요. 형식적인 대화가 아닌, 진심으로 경청하는 그 자세에서 특별함을 느끼게 됩니다.",
  },
  {
    id: "eyes",
    title: "따뜻한 눈빛",
    story:
      '눈이 마주쳤을 때 피하지 않고 3초 이상 머무는 따뜻한 시선. 그 눈빛 속에서 "당신이 궁금해요"라는 무언의 메시지를 읽게 되고, 가슴이 두근거리기 시작할 거예요.',
  },
  {
    id: "time",
    title: "반복되는 숫자",
    story:
      "우연히 시계를 봤는데 11:11, 또는 4:44 같은 반복되는 숫자가 보이는 날 그 사람을 만나게 될 거예요. 마치 우주가 준비해 둔 것 같은 타이밍에 운명을 확신하게 됩니다.",
  },
];

const PERSONALITY_TRAITS = [
  {
    id: "contrast",
    title: "낮져밤이 타입",
    story:
      '평소엔 연락도 뜸하고 무뚝뚝해 보이지만, 막상 만나면 누구보다 다정하게 챙겨주는 반전 매력의 소유자예요. 사소한 것까지 기억해서 감동을 주고, 헤어질 땐 "집에 잘 들어갔어?"라는 연락을 꼭 하는 사람이에요.',
  },
  {
    id: "care",
    title: "츤데레 정석",
    story:
      '겉으론 "에이, 뭘 그런 걸로 고민해"라고 툭툭 던지지만, 돌아서면 몰래 걱정하고 챙겨주는 타입이에요. 표현은 서툴러도 행동으로 진심을 보여주니까, 시간이 지날수록 더 깊이 빠지게 될 거예요.',
  },
  {
    id: "hobby",
    title: "집돌이 너드",
    story:
      "자기 일에 몰입할 땐 진지하고 섹시한 모습이지만, 쉬는 날엔 침대에서 넷플릭스 보며 하루를 보내는 순수한 집돌이예요. 함께 소파에서 뒹굴며 아무것도 안 하는 그 시간이 제일 행복할 거예요.",
  },
  {
    id: "social",
    title: "유죄인간",
    story:
      "처음엔 조용하고 낯을 가리지만, 내 사람이라고 생각하면 갑자기 장난기가 폭발하는 타입이에요. 카톡으로 아재개그 보내고, 몰래 사진 찍어 놀리고, 그런 유치한 모습이 점점 귀여워질 거예요.",
  },
  {
    id: "loyalty",
    title: "해바라기 서사남",
    story:
      '한 번 마음을 주면 쉽게 흔들리지 않는 진국이에요. 바쁜 와중에도 "밥은 먹었어?"라고 물어봐 주고, 아플 땐 약 사들고 달려오는 서사 맛집. 이 사람이랑은 오래 갈 수 있겠다는 확신이 들 거예요.',
  },
  {
    id: "polite",
    title: "어른스러운 연하남",
    story:
      "평소엔 예의 바르고 선을 잘 지키는 신사지만, 결정적인 순간엔 과감하게 다가오는 어른스러운 타입이에요. 밀당 없이 솔직하게 마음을 표현하니까, 연애가 편하고 안정적일 거예요.",
  },
  {
    id: "passion",
    title: "조용한 열정남",
    story:
      "평소엔 말수가 적고 조용한 편이지만, 좋아하는 것에 대해선 눈이 반짝거리며 열정적으로 이야기하는 타입이에요. 그리고 은근한 소유욕도 있어서, 내가 특별하다는 느낌을 받게 될 거예요.",
  },
  {
    id: "healing",
    title: "힐링 대화 천재",
    story:
      "같이 있기만 해도 편안하고 힐링 되는 사람이에요. 힘든 일이 있어도 이 사람 목소리만 들으면 괜찮아지고, 대화하다 보면 어느새 웃고 있는 자신을 발견하게 될 거예요. 정서적 안정감 만렙.",
  },
  {
    id: "sharp",
    title: "반전남",
    story:
      "예민하고 섬세한 감각을 가져서 남들이 못 보는 걸 잘 캐치하는 타입이에요. 하지만 나 앞에서만큼은 무장해제되어 편하게 어리광 부리는 반전 매력이 있어요. 그 갭에 심쿵할 거예요.",
  },
  {
    id: "classic",
    title: "댄디한 취향남",
    story:
      "유행을 좇지 않고 본인만의 확고한 취향과 스타일이 있는 사람이에요. 옷, 음악, 카페 취향까지 하나하나 자기 색깔이 뚜렷해서, 함께 다니는 것만으로도 뭔가 멋있어지는 기분이 들 거예요.",
  },
];

const COMPATIBILITY_SCORES: { score: string; description: string }[] = [
  {
    score: "98%",
    description: "전생부터 정해진 역대급 비주얼 합! (SNS 공유 필수 지수)",
  },
  {
    score: "92%",
    description: "첫눈에 서로 '내 사람이다' 느낄 찰떡 비주얼 조합",
  },
  {
    score: "88%",
    description: "같이 서 있기만 해도 화보가 되는 비주얼 완성형 궁합",
  },
  {
    score: "85%",
    description: "서로의 매력을 극대화해 주는 가장 이상적인 밸런스",
  },
  {
    score: "79%",
    description: "닮은 듯 다른 느낌이 주는 묘한 끌림, 케미 폭발 지수",
  },
];

// ============================================================================
// Helper Functions
// ============================================================================

function getAgeRange(userAge: string): string {
  const ageMap: Record<string, string> = {
    "20대 초반": "early 20s",
    "20대 중반": "mid 20s",
    "20대 후반": "late 20s",
    "30대 초반": "early 30s",
    "30대 중반": "mid 30s",
    "30대 후반": "late 30s",
    "40대 이상": "early 40s",
  };
  return ageMap[userAge] || "mid 20s";
}

function randomPick<T>(array: T[]): T {
  return array[Math.floor(Math.random() * array.length)];
}

function toFinishReason(reason?: string): "stop" | "length" | "error" {
  if (reason === "STOP") return "stop";
  if (reason === "MAX_TOKENS") return "length";
  return "error";
}

function extractUsageMetadata(result: any) {
  return {
    promptTokens: result?.usageMetadata?.promptTokenCount ?? 0,
    completionTokens: result?.usageMetadata?.candidatesTokenCount ?? 0,
    totalTokens: result?.usageMetadata?.totalTokenCount ?? 0,
  };
}

// ============================================================================
// Image Prompt Variations (다양한 이미지 생성을 위한 배열)
// ============================================================================

const FACE_VARIATIONS = {
  male: [
    "sharp jawline with gentle features",
    "soft masculine features with kind eyes",
    "defined cheekbones with warm smile",
    "boyish face with mature eyes",
    "refined features with subtle dimples",
  ],
  female: [
    "delicate oval face with bright eyes",
    "heart-shaped face with soft features",
    "elegant bone structure with gentle smile",
    "youthful round face with expressive eyes",
    "refined features with radiant complexion",
  ],
};

const HAIR_VARIATIONS = {
  male: [
    "natural wavy dark brown hair, slightly tousled",
    "neat side-parted black hair, well-groomed",
    "textured comma hair with soft bangs",
    "natural straight hair with light brown highlights",
    "two-block cut with volume on top",
  ],
  female: [
    "long flowing black hair with soft waves",
    "shoulder-length layered cut, natural brown",
    "elegant updo with face-framing strands",
    "short bob with subtle highlights",
    "natural wavy mid-length hair with shine",
  ],
};

const ACCESSORY_VARIATIONS = {
  male: [
    "thin silver necklace visible",
    "simple stud earring",
    "stylish thin-rimmed glasses",
    "classic wristwatch visible",
    "", // 없음
  ],
  female: [
    "delicate drop earrings",
    "simple pendant necklace",
    "elegant hair clip",
    "minimal gold jewelry",
    "", // 없음
  ],
};

// 스타일별 프롬프트 매핑
const STYLE_PROMPTS: Record<string, string> = {
  // 남성 스타일
  dandy:
    "wearing a tailored navy blazer over crisp white dress shirt, refined grooming, sophisticated gentleman look",
  sporty:
    "athletic build visible, wearing a sleek sports jacket or performance wear, healthy tan, energetic vibe",
  casual:
    "wearing an oversized soft cardigan or cozy sweater, relaxed cafe aesthetic, comfortable elegance",
  prep:
    "wearing a classic button-down oxford shirt with a light sweater, preppy style, clean-cut scholarly look",
  street:
    "wearing trendy streetwear hoodie or designer jacket, subtle accessories, artistic urban vibe",
  // 여성 스타일
  innocent:
    "wearing a soft pastel dress or delicate blouse, natural minimal makeup, sweet innocent smile",
  career:
    "wearing a sharp professional blazer, elegant styling, confident sophisticated aura",
  girlcrush:
    "wearing edgy stylish outfit, bold confident makeup, charismatic powerful presence",
  pure:
    "wearing comfortable casual clothes, minimal natural look, warm friendly approachable vibe",
  glamour:
    "wearing elegant statement outfit, polished glamorous styling, radiant celebrity-like presence",
};

// 남성/여성 스타일 키 배열 (없음 선택 시 랜덤용)
const MALE_STYLE_KEYS = ["dandy", "sporty", "casual", "prep", "street"];
const FEMALE_STYLE_KEYS = [
  "innocent",
  "career",
  "girlcrush",
  "pure",
  "glamour",
];

// ============================================================================
// Image Prompt Builders (다양화된 프롬프트 생성)
// ============================================================================

function buildMalePrompt(
  ageRange: string,
  idealStyle: string | undefined,
  idealType: string,
  mbti: string,
): string {
  const mbtiHint = mbti !== "상관없음"
    ? `, personality vibe matching ${mbti}`
    : "";
  const face = randomPick(FACE_VARIATIONS.male);
  const hair = randomPick(HAIR_VARIATIONS.male);
  const accessory = randomPick(ACCESSORY_VARIATIONS.male);
  // "없음(none)" 선택 시 랜덤 스타일 적용
  const effectiveStyle = (!idealStyle || idealStyle === "none")
    ? randomPick(MALE_STYLE_KEYS)
    : idealStyle;
  const stylePrompt = STYLE_PROMPTS[effectiveStyle] || STYLE_PROMPTS.casual;
  const accessoryLine = accessory ? `Accessory: ${accessory}.` : "";

  return `Ultra-realistic portrait photograph of a handsome young Korean man in his ${ageRange}.
Professional headshot with hyper-realistic skin texture, natural pores, and subtle skin imperfections for authenticity.
Face: ${face}.
Hair: ${hair}.
${stylePrompt}.
${accessoryLine}
${idealType ? `Additional preference: ${idealType}.` : ""}
${mbtiHint}
Warm and inviting expression with a genuine smile that shows "boyfriend material" charm.
Clear, kind eyes with natural eye reflections and catchlights. Fresh, healthy complexion with natural skin tone.
Pose: natural confident pose, slight head tilt or direct warm gaze at camera.
Lighting: soft natural window light or golden hour lighting, creating gentle shadows.
Background: clean, slightly blurred indoor setting or neutral studio backdrop.
Camera: shot on Sony A7R IV, 85mm portrait lens, f/1.8 aperture, shallow depth of field.
Quality: 8K UHD, photorealistic, professional portrait photography, magazine quality.
Aspect ratio: 1:1 (square portrait).
MUST be hyper-realistic like a real photograph, NOT illustration or CGI.
DO NOT include: text, logos, watermarks, blurry, cartoon, anime, illustrated, CGI, artificial looking.`;
}

function buildFemalePrompt(
  ageRange: string,
  idealStyle: string | undefined,
  idealType: string,
  mbti: string,
): string {
  const mbtiHint = mbti !== "상관없음"
    ? `, personality vibe matching ${mbti}`
    : "";
  const face = randomPick(FACE_VARIATIONS.female);
  const hair = randomPick(HAIR_VARIATIONS.female);
  const accessory = randomPick(ACCESSORY_VARIATIONS.female);
  // "없음(none)" 선택 시 랜덤 스타일 적용
  const effectiveStyle = (!idealStyle || idealStyle === "none")
    ? randomPick(FEMALE_STYLE_KEYS)
    : idealStyle;
  const stylePrompt = STYLE_PROMPTS[effectiveStyle] || STYLE_PROMPTS.innocent;
  const accessoryLine = accessory ? `Accessory: ${accessory}.` : "";

  return `Ultra-realistic portrait photograph of a beautiful young Korean woman in her ${ageRange}.
Professional headshot with hyper-realistic skin texture, natural pores, and subtle skin imperfections for authenticity.
Face: ${face}.
Hair: ${hair}.
${stylePrompt}.
${accessoryLine}
${idealType ? `Additional preference: ${idealType}.` : ""}
${mbtiHint}
Sophisticated yet approachable elegance, embodying "girlfriend material" charm with a radiant, genuine smile.
Bright, expressive eyes with natural eye reflections and catchlights. Fresh, glowing complexion with natural skin tone.
Pose: elegant natural pose, warm inviting expression, gentle smile.
Lighting: soft natural window light or golden hour lighting, creating flattering soft shadows.
Background: clean, slightly blurred indoor setting or neutral studio backdrop.
Camera: shot on Sony A7R IV, 85mm portrait lens, f/1.8 aperture, shallow depth of field.
Quality: 8K UHD, photorealistic, professional portrait photography, magazine quality.
Aspect ratio: 1:1 (square portrait).
MUST be hyper-realistic like a real photograph, NOT illustration or CGI.
DO NOT include: text, logos, watermarks, blurry, cartoon, anime, illustrated, CGI, artificial looking.`;
}

// ============================================================================
// Text Generation (Gemini 2.0 Flash Lite - Direct API Call)
// ============================================================================

async function generateAppearanceHashtags(
  targetGender: string,
  idealType: string,
  mbti: string,
  telemetry: TelemetryContext,
): Promise<string[]> {
  console.log(
    "📝 Generating appearance hashtags with Gemini 2.0 Flash Lite...",
  );
  const startTime = Date.now();
  let responseStatus = 0;

  try {
    const systemPrompt =
      `You are a creative Korean content writer for a "2026 Destiny Finder" app.
Generate 3 trendy Korean hashtags describing a ${
        targetGender === "male" ? "charming man" : "beautiful woman"
      }'s appearance.
The hashtags should be fun, trendy, and relate to Korean dating culture.

Examples:
- #무쌍_강아지상
- #셔츠가잘어울리는
- #너드미
- #따뜻한_아우라
- #생기있는_미소
- #도서관에서볼듯한
- #첫사랑_느낌

Output ONLY a JSON array of 3 hashtags, nothing else.
Example: ["#무쌍_강아지상", "#셔츠가잘어울리는", "#너드미"]`;

    const userPrompt = `Generate 3 appearance hashtags for:
- Gender: ${targetGender === "male" ? "남성" : "여성"}
- Ideal type description: ${idealType || "특별한 선호 없음"}
- MBTI preference: ${mbti}`;

    await assertLlmRequestAllowed({
      provider: "gemini",
      model: GEMINI_TEXT_MODEL,
      featureName: "yearly-encounter",
      mode: "text",
      requestId: telemetry.requestId,
      metadata: {
        phase: "appearance_hashtags",
      },
    });

    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_TEXT_MODEL}:generateContent?key=${GEMINI_API_KEY}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          contents: [{
            role: "user",
            parts: [{ text: `${systemPrompt}\n\n${userPrompt}` }],
          }],
          generationConfig: {
            temperature: 0.9,
            maxOutputTokens: 200,
          },
        }),
      },
    );
    responseStatus = response.status;

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(
        `Gemini API error: ${response.status} - ${errorText.substring(0, 500)}`,
      );
    }

    const data = await response.json();
    const content = data.candidates?.[0]?.content?.parts?.[0]?.text || "";
    const usage = extractUsageMetadata(data);

    await UsageLogger.log({
      fortuneType: "yearly-encounter",
      userId: telemetry.userId,
      requestId: telemetry.requestId,
      provider: "gemini",
      model: GEMINI_TEXT_MODEL,
      response: {
        content,
        finishReason: toFinishReason(data.candidates?.[0]?.finishReason),
        usage,
        latency: Date.now() - startTime,
        provider: "gemini",
        model: GEMINI_TEXT_MODEL,
      },
      metadata: {
        phase: "appearance_hashtags",
        targetGender,
        statusCode: responseStatus,
      },
    });

    // Parse JSON array from response
    const match = content.match(/\[.*\]/s);
    if (match) {
      return JSON.parse(match[0]);
    }

    // Fallback
    return ["#따뜻한_미소", "#눈빛이_다정한", "#설렘유발자"];
  } catch (error) {
    console.error("❌ Hashtag generation error:", error);

    await UsageLogger.logError(
      "yearly-encounter",
      "gemini",
      GEMINI_TEXT_MODEL,
      error instanceof Error ? error.message : "Unknown error",
      telemetry.userId,
      {
        phase: "appearance_hashtags",
        requestId: telemetry.requestId,
        statusCode: responseStatus,
        latencyMs: Date.now() - startTime,
        targetGender,
      },
    );

    return ["#따뜻한_미소", "#눈빛이_다정한", "#설렘유발자"];
  }
}

// ============================================================================
// Gemini 2.5 Flash Image Image Generation (이미지 생성)
// ============================================================================

async function generateImageWithGemini(
  prompt: string,
  telemetry: TelemetryContext,
  attempt: number,
): Promise<string> {
  const startTime = Date.now();
  console.log("🎨 Generating portrait with Gemini 2.5 Flash Image...");
  let responseStatus = 0;

  if (!GEMINI_API_KEY) {
    throw new Error("Gemini API key not configured");
  }

  await assertLlmRequestAllowed({
    provider: "gemini",
    model: GEMINI_IMAGE_MODEL_NAME,
    featureName: "yearly-encounter",
    mode: "image",
    requestId: telemetry.requestId,
    metadata: {
      attempt,
    },
  });

  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_IMAGE_MODEL_NAME}:generateContent?key=${GEMINI_API_KEY}`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        contents: [{
          role: "user",
          parts: [{ text: prompt }],
        }],
        generationConfig: {
          responseModalities: ["image", "text"],
          responseMimeType: "text/plain",
        },
      }),
    },
  );
  responseStatus = response.status;

  if (!response.ok) {
    const errorText = await response.text();
    console.error("❌ Gemini API 에러:", {
      status: response.status,
      body: errorText.substring(0, 500),
    });

    await UsageLogger.logError(
      "yearly-encounter",
      "gemini",
      GEMINI_IMAGE_MODEL_NAME,
      `Gemini API failed: ${response.status} - ${errorText.substring(0, 500)}`,
      telemetry.userId,
      {
        phase: "image_generation",
        requestId: telemetry.requestId,
        attempt,
        promptLength: prompt.length,
        statusCode: responseStatus,
        latencyMs: Date.now() - startTime,
      },
    );

    throw new Error(`Gemini API failed: ${response.status} - ${errorText}`);
  }

  const result = await response.json();
  const usage = extractUsageMetadata(result);

  // Gemini 응답에서 이미지 데이터 추출
  const parts = result.candidates?.[0]?.content?.parts || [];
  const imagePart = parts.find((
    part: { inlineData?: { mimeType: string; data: string } },
  ) => part.inlineData?.mimeType?.startsWith("image/"));

  if (!imagePart?.inlineData?.data) {
    console.error(
      "❌ Gemini 응답에 이미지 없음:",
      JSON.stringify(result).substring(0, 500),
    );

    await UsageLogger.logError(
      "yearly-encounter",
      "gemini",
      GEMINI_IMAGE_MODEL_NAME,
      "No image data in Gemini response",
      telemetry.userId,
      {
        phase: "image_generation",
        requestId: telemetry.requestId,
        attempt,
        promptLength: prompt.length,
        statusCode: responseStatus,
        latencyMs: Date.now() - startTime,
      },
    );

    throw new Error("No image data in Gemini response");
  }

  const latency = Date.now() - startTime;
  console.log(`✅ Image generated successfully in ${latency}ms`);

  await UsageLogger.log({
    fortuneType: "yearly-encounter",
    userId: telemetry.userId,
    requestId: telemetry.requestId,
    provider: "gemini",
    model: GEMINI_IMAGE_MODEL_NAME,
    response: {
      content: "[image-generated]",
      finishReason: toFinishReason(result.candidates?.[0]?.finishReason),
      usage,
      latency,
      provider: "gemini",
      model: GEMINI_IMAGE_MODEL_NAME,
    },
    metadata: {
      phase: "image_generation",
      requestId: telemetry.requestId,
      attempt,
      promptLength: prompt.length,
      statusCode: responseStatus,
    },
  });

  return imagePart.inlineData.data;
}

// ============================================================================
// Retry Logic with Exponential Backoff
// ============================================================================

async function generateImageWithRetry(
  prompt: string,
  telemetry: TelemetryContext,
  maxRetries = 3,
): Promise<string> {
  let lastError: Error | null = null;

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      console.log(`🎨 이미지 생성 시도 ${attempt}/${maxRetries}...`);
      return await generateImageWithGemini(prompt, telemetry, attempt);
    } catch (error) {
      lastError = error instanceof Error ? error : new Error(String(error));
      console.error(`❌ 시도 ${attempt} 실패:`, lastError.message);

      if (attempt < maxRetries) {
        const delay = Math.min(1000 * Math.pow(2, attempt - 1), 5000); // 1초, 2초, 4초 (max 5초)
        console.log(`⏳ ${delay}ms 후 재시도...`);
        await new Promise((resolve) => setTimeout(resolve, delay));
      }
    }
  }

  throw lastError || new Error("이미지 생성 실패 (모든 재시도 소진)");
}

// ============================================================================
// Supabase Storage Upload
// ============================================================================

async function uploadToSupabase(
  imageBase64: string,
  userId: string,
): Promise<string> {
  console.log("📤 Uploading to Supabase Storage...");

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

  // Convert base64 to blob
  const imageBuffer = Uint8Array.from(
    atob(imageBase64),
    (c) => c.charCodeAt(0),
  );
  const fileName = `${userId}/yearly_encounter_${Date.now()}.png`;

  const { error } = await supabase.storage
    .from("yearly-encounter-images")
    .upload(fileName, imageBuffer, {
      contentType: "image/png",
      upsert: false,
    });

  if (error) {
    console.error("❌ Upload error:", error);
    throw new Error(`Upload failed: ${error.message}`);
  }

  const { data: publicUrlData } = supabase.storage
    .from("yearly-encounter-images")
    .getPublicUrl(fileName);

  console.log("✅ Upload successful:", publicUrlData.publicUrl);
  return publicUrlData.publicUrl;
}

// ============================================================================
// Database Record
// ============================================================================

async function saveYearlyEncounterRecord(
  userId: string,
  result: YearlyEncounterResponse["data"],
): Promise<string> {
  console.log("💾 Saving yearly encounter record...");

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

  const { data, error } = await supabase
    .from("fortunes")
    .insert({
      user_id: userId,
      fortune_data: {
        fortune_type: "yearly-encounter",
        ...result,
      },
      created_at: new Date().toISOString(),
    })
    .select("id")
    .single();

  if (error) {
    console.error("❌ Database error:", error);
    throw new Error(`Database insert failed: ${error.message}`);
  }

  console.log("✅ Record saved with ID:", data.id);
  return data.id;
}

// ============================================================================
// Main Handler
// ============================================================================

serve(async (req) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: CORS_HEADERS });
  }

  const requestId = req.headers.get("x-request-id") || crypto.randomUUID();

  try {
    const request: YearlyEncounterRequest = await req.json();
    console.log("📥 Yearly Encounter request:", {
      requestId,
      userId: request.userId,
      targetGender: request.targetGender,
      userAge: request.userAge,
      idealMbti: request.idealMbti,
    });

    if (
      !request.userId ||
      !request.userAge ||
      !request.idealMbti ||
      (request.targetGender !== "male" && request.targetGender !== "female")
    ) {
      return new Response(
        JSON.stringify({
          success: false,
          error:
            "필수 입력값이 누락되었어요. userId/targetGender/userAge/idealMbti를 확인해주세요.",
        }),
        {
          status: 400,
          headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
        },
      );
    }

    const telemetry: TelemetryContext = {
      userId: request.userId,
      requestId,
    };

    const isPremium = request.isPremium ?? false;

    // 1. Build image prompt based on target gender
    const ageRange = getAgeRange(request.userAge);
    const imagePrompt = request.targetGender === "male"
      ? buildMalePrompt(
        ageRange,
        request.idealStyle,
        request.idealType,
        request.idealMbti,
      )
      : buildFemalePrompt(
        ageRange,
        request.idealStyle,
        request.idealType,
        request.idealMbti,
      );

    console.log("📝 Image prompt length:", imagePrompt.length);

    // 2. Generate image with Gemini 2.5 Flash Image (with retry logic)
    const imageBase64 = await generateImageWithRetry(imagePrompt, telemetry, 3);

    // 3. Upload to Supabase Storage
    const imageUrl = await uploadToSupabase(imageBase64, request.userId);

    // 4. Generate appearance hashtags using LLM
    const appearanceHashtags = await generateAppearanceHashtags(
      request.targetGender,
      request.idealType,
      request.idealMbti,
      telemetry,
    );

    // 5. Pick random values from constants
    const encounterSpot = randomPick(ENCOUNTER_SPOTS);
    const fateSignal = randomPick(FATE_SIGNALS);
    const personality = randomPick(PERSONALITY_TRAITS);
    const compatibility = randomPick(COMPATIBILITY_SCORES);

    // 6. Build result
    const resultData: YearlyEncounterResponse["data"] = {
      imageUrl,
      appearanceHashtags,
      encounterSpotTitle: encounterSpot.title,
      encounterSpotStory: encounterSpot.story,
      fateSignalTitle: fateSignal.title,
      fateSignalStory: fateSignal.story,
      personalityTitle: personality.title,
      personalityStory: personality.story,
      compatibilityScore: compatibility.score,
      compatibilityDescription: compatibility.description,
      targetGender: request.targetGender,
      createdAt: new Date().toISOString(),
    };

    // 7. Save to database
    await saveYearlyEncounterRecord(request.userId, resultData);

    const response: YearlyEncounterResponse = {
      success: true,
      data: resultData,
    };

    return new Response(JSON.stringify(response), {
      headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("❌ Error:", error);

    await UsageLogger.logError(
      "yearly-encounter",
      "gemini",
      GEMINI_IMAGE_MODEL_NAME,
      error instanceof Error ? error.message : "Unknown error",
      undefined,
      { phase: "handler", requestId },
    );

    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : "Unknown error",
      }),
      {
        status: 500,
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      },
    );
  }
});
