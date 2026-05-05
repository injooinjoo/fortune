/**
 * POSTER_REGISTRY — generic 7종 포스터 가이드 운세 설정.
 *
 * @description
 *   `generate-poster-guide` Edge Function 이 posterType 별로 분기할 때
 *   참조하는 단일 출처. 각 entry 의 `buildPrompt` 는 Generator C 가
 *   타입별 한국어 프롬프트로 교체한다 (현재는 placeholder).
 *
 *   타입 정의는 Edge Function + RN 양쪽에서 share 가능 — 단,
 *   Deno (`https://...`) import 와 Node (`@/...`) 의 module resolution 이 다르므로
 *   실제 RN 측은 `packages/product-contracts/src/fortunes.ts` 의 FortuneTypeId
 *   union 을 통해 동일한 7종을 미러링한다.
 */

// =====================================================
// 핵심 타입
// =====================================================

/**
 * 7종 포스터 가이드 식별자 (literal union).
 * 새 타입 추가 시:
 *   1. 이 union 에 ID 추가
 *   2. ALL_POSTER_TYPES 에 push
 *   3. POSTER_REGISTRY 에 entry 추가
 *   TypeScript exhaustive check 가 누락 entry 를 컴파일 타임에 잡아낸다.
 */
export type PosterType =
  | "palm-reading"
  | "beauty-simulation"
  | "hair-style-guide"
  | "face-reading-guide"
  | "ootd-guide"
  | "blind-date-guide"
  | "past-life-guide";

export const ALL_POSTER_TYPES: readonly PosterType[] = [
  "palm-reading",
  "beauty-simulation",
  "hair-style-guide",
  "face-reading-guide",
  "ootd-guide",
  "blind-date-guide",
  "past-life-guide",
] as const;

/**
 * 사용자 사진의 종류. picker UX 분기에 사용.
 *   - 'palm': 손바닥
 *   - 'face': 얼굴 정면 셀카
 *   - 'face-and-body': 전신 또는 상반신
 *   - 'none': 사진 입력 불필요 (텍스트 컨텍스트만)
 */
export type PhotoKind = "palm" | "face" | "face-and-body" | "none";

/**
 * 출력 이미지 사이즈. gpt-image-2 가 지원하는 portrait / square.
 */
export type PosterOutputSize = "1024x1536" | "1024x1024";

/**
 * Prompt 빌드 시 주입되는 컨텍스트.
 * 향후 확장: userProfile, season, gender 등 — 새 필드 추가 시 buildPrompt 시그니처
 * 일치 검증을 위해 모든 entry 가 새 필드를 명시적으로 무시하거나 사용하도록.
 */
export interface PromptBuildContext {
  /**
   * 사용자가 입력한 자유 텍스트. e.g. blind-date 의 상황 설명, past-life 의 추가 단서.
   * 매우 긴 입력은 `MAX_CONTEXT_TEXT_LENGTH` 로 truncate 후 전달.
   */
  contextText?: string;
}

/**
 * 한 종류의 포스터 가이드를 정의하는 config.
 */
export interface PosterTypeConfig {
  /** literal ID — Record key 와 동일. */
  posterType: PosterType;
  /** 한국어 표시명 (UI 라벨용). */
  displayName: string;
  /** poster-guide-assets 버킷 내 템플릿 파일 경로. e.g. 'palm-reading.png'. */
  templatePath: string;
  /**
   * 템플릿 fetch 실패 시 사용할 fallback 경로.
   * undefined 면 fallback 없음 → 500 with 명확한 한국어 에러.
   */
  fallbackTemplatePath?: string;
  /** true 면 imageBase64 가 request 에 필수. */
  requiresUserPhoto: boolean;
  /** picker UX 분기용. */
  photoKind: PhotoKind;
  /** Generator C 가 작성한 한국어 프롬프트 빌더. */
  buildPrompt: (ctx: PromptBuildContext) => string;
  /**
   * 포스터에 포함될 한국어 섹션 라벨.
   * UI 메타 (로딩 화면 hint, 디버깅) 용도. prompt 안의 섹션과 일치 필수.
   */
  sections: readonly string[];
  /** gpt-image-2 출력 사이즈. */
  outputSize: PosterOutputSize;
  /** 토큰 비용 (FORTUNE_POINT_COSTS 와 일치 필수). */
  tokenCost: number;
}

// =====================================================
// 상수
// =====================================================

/**
 * contextText 최대 길이. 너무 긴 입력은 prompt 비용/품질 저하 + DoS 방지를 위해 자른다.
 */
export const MAX_CONTEXT_TEXT_LENGTH = 1_000;

// =====================================================
// 7종 entry — buildPrompt + sections 는 Generator C 가 작성.
// 메타(displayName/templatePath/photoKind/outputSize/tokenCost) 는 Generator A 가 확정.
// =====================================================

// ----- 1. palm-reading (기존 검증된 prompt 그대로 재사용) -----
const PALM_READING_SECTIONS = [
  "한눈에 보는 요약",
  "손바닥 상태 안내",
  "손금 지도",
  "주요 손금",
  "손바닥 특징",
  "이것이 당신에게 의미하는 것",
  "당신의 길",
] as const;

const PALM_READING_PROMPT = [
  "Create a one-page Korean palm-reading guide poster.",
  "",
  "Image 1 = blank layout template. Use exactly this layout from Image 1.",
  "Image 2 = user's palm photo. Analyze the actual palm lines for content.",
  "",
  "CRITICAL — palm photo handling:",
  "- When placing Image 2 into the photo slot, the ENTIRE hand MUST be visible:",
  "  all 5 fingers (including thumb), the full palm, and the wrist edge.",
  "- If Image 2's aspect ratio differs from the slot, scale-to-fit with white",
  "  ivory padding around the hand. NEVER crop fingers, thumb, or palm edges.",
  "- Maintain the user's actual skin tone, hand shape, and visible palm lines.",
  "- Do NOT replace with a generic stock hand.",
  "",
  "CRITICAL — palm contour drawing (section 3 손금 지도):",
  "- Trace the contour from Image 2's actual hand outline (full hand, no crop).",
  "- Draw 5 main palm lines (감정선/지능선/생명선/운명선/태양선) following the",
  "  positions visible in Image 2.",
  "",
  "Title: 손금 리딩 가이드 / Subtitle: 통찰 · 강점 · 방향을 찾아서",
  "",
  "Sections (fill all in Korean):",
  "1. 한눈에 보는 요약 — 2 sentences.",
  "2. 손바닥 상태 안내 — 5 short bullets (색감, 온기, 균형, 결, 손가락 비율).",
  "3. 손금 지도 — black contour drawing (see CRITICAL note above).",
  "4. 주요 손금 — 5 cards, one per line, 2-line interpretation each.",
  "5. 손바닥 특징 — 3 bullets.",
  "6. 이것이 당신에게 의미하는 것 — 4 bullets.",
  "7. 당신의 길 — 2 sentences.",
  "",
  "Style: warm ivory background, thin black lines, rounded cards, generous white space, Korean serif typography. Editorial premium, not mystical.",
  "All visible text in Korean.",
].join("\n");

const palmReading: PosterTypeConfig = {
  posterType: "palm-reading",
  displayName: "손금가이드",
  templatePath: "palm-reading.png",
  requiresUserPhoto: true,
  photoKind: "palm",
  buildPrompt: () => PALM_READING_PROMPT,
  sections: PALM_READING_SECTIONS,
  outputSize: "1024x1536",
  tokenCost: 10,
};

// ----- 2. beauty-simulation -----
const BEAUTY_SIMULATION_SECTIONS = [
  "한눈에 보기",
  "현재 스타일 메모",
  "부드러운 스타일링 방향",
  "집중 영역",
  "스타일 플랜",
  "변화되는 인상",
  "부드러운 리마인드",
] as const;

const BEAUTY_SIMULATION_PROMPT = [
  "Create a Korean beauty-simulation poster with before/after layout.",
  "",
  "Image 1 = blank template (LEFT=현재, RIGHT=스타일링 후). Use exactly this layout from Image 1.",
  "Image 2 = user's selfie. Preserve identity (same face, same age, same ethnicity, same bone structure); only soften lighting, hair, makeup on the RIGHT side.",
  "",
  "CRITICAL — face placement (both LEFT and RIGHT):",
  "- Show the ENTIRE face: forehead, full chin, both ears, full hair silhouette, neckline.",
  "- NEVER crop forehead, ears, chin, or hair edges.",
  "- If Image 2 aspect differs from the photo slot, scale-to-fit with ivory padding around the face.",
  "",
  "Title: 뷰티 시뮬레이션 / Subtitle: 균형 · 스타일링 · 빛",
  "",
  "Sections (Korean):",
  "1. 한눈에 보기 — 2 sentences.",
  "2. 현재 스타일 메모 — 6 bullets (헤어 볼륨 / 눈매 / 피부 톤 / 얼굴형 / 입술 / 전체 인상).",
  "3. 부드러운 스타일링 방향 — same 6 dimensions, suggestion each.",
  "4. 집중 영역 — 6 mini-cards.",
  "5. 스타일 플랜 — 6 bullets (헤어 / 컬러 / 피부 / 메이크업 / 립 / 팁).",
  "6. 변화되는 인상 — 6 bullets, before/after 무드 변화.",
  "7. 부드러운 리마인드 — 2 lines, 따뜻한 마무리.",
  "",
  "Footer (작은 글씨): 비의료 목적의 스타일링 시뮬레이션입니다. 결과는 빛과 각도에 따라 달라질 수 있습니다.",
  "Style: warm ivory editorial, thin black lines, rounded cards, generous white space.",
  "All visible text in Korean.",
].join("\n");

const beautySimulation: PosterTypeConfig = {
  posterType: "beauty-simulation",
  displayName: "뷰티 시뮬레이션",
  templatePath: "beauty-simulation.png",
  requiresUserPhoto: true,
  photoKind: "face",
  buildPrompt: () => BEAUTY_SIMULATION_PROMPT,
  sections: BEAUTY_SIMULATION_SECTIONS,
  outputSize: "1024x1536",
  tokenCost: 10,
};

// ----- 3. hair-style-guide -----
const HAIR_STYLE_GUIDE_SECTIONS = [
  "한눈에 보기",
  "얼굴과 모발 분석",
  "모발 상태",
  "10가지 헤어스타일 제안",
  "스타일 메모",
  "추천 방향",
  "당신의 스타일 방향",
] as const;

const HAIR_STYLE_GUIDE_PROMPT = [
  "Create a Korean hair-style diagnostic poster with 10 personalized hairstyle suggestions.",
  "",
  "Image 1 = filled example poster. Copy its layout and 10-card grid exactly; replace example photos and text.",
  "Image 2 = user's selfie. Every face (including all 10 cards) = same person, same bone structure, age, ethnicity.",
  "",
  "CRITICAL — face placement (every photo slot, all 10 hairstyle cards):",
  "- Show the ENTIRE face + the FULL hairstyle silhouette (forehead, ears, chin, hair edges).",
  "- NEVER crop top of hair, ears, chin, or forehead — hairstyle preview must be complete.",
  "- Scale-to-fit with ivory padding if Image 2 aspect differs from slot.",
  "",
  "Title: 헤어스타일 진단 가이드 / Subtitle: 형태 · 분위기 · 스타일링 방향",
  "",
  "Sections (Korean):",
  "1. 한눈에 보기 — 2-3 sentences + 추천 방향 1 line.",
  "2. 얼굴과 모발 분석 — 5 sub-cards (얼굴형 / 이마 / 눈썹·눈 / 코·입 / 턱선), 1-2 lines each.",
  "3. 모발 상태 — 4 sub-cards (굵기 / 숱 / 직모·웨이브 / 두피), 1 line each.",
  "4. 10가지 헤어스타일 제안 — 10-card grid. Each: same user + a different hairstyle, Korean style name, 1-line note. All 10 distinct in length/shape/mood (예: 클래식 단발, 레이어드 미디엄, 시스루 뱅 롱, 내추럴 웨이브, 숏컷).",
  "5. 스타일 메모 — 5 sub-cards (이미지 키워드 / 어울리는 분위기 / 강점 / 스타일 팁 / 관리 포인트).",
  "6. 추천 방향 — pick 1-3 of the 10, highlight why.",
  "7. 당신의 스타일 방향 — warm 1-paragraph closing.",
  "",
  "Footer (작은 글씨): 본 가이드는 참고용이며, 개인의 취향과 모발 상태에 따라 결과는 달라질 수 있습니다.",
  "Style: warm ivory editorial, thin black lines, rounded cards. Realistic salon styling.",
  "All visible text in Korean.",
].join("\n");

const hairStyleGuide: PosterTypeConfig = {
  posterType: "hair-style-guide",
  displayName: "헤어스타일 가이드",
  templatePath: "hair-style-guide.png",
  requiresUserPhoto: true,
  photoKind: "face",
  buildPrompt: () => HAIR_STYLE_GUIDE_PROMPT,
  sections: HAIR_STYLE_GUIDE_SECTIONS,
  outputSize: "1024x1536",
  tokenCost: 10,
};

// ----- 4. face-reading-guide -----
const FACE_READING_GUIDE_SECTIONS = [
  "한 줄 요약",
  "종합 인상",
  "눈 / 코 / 입 / 얼굴형",
  "분위기",
  "관계 스타일",
  "가치관 무드",
  "앞으로의 흐름",
  "스타일 플랜",
  "변화되는 인상",
  "최종 메모",
  "럭키 아이템",
  "럭키 컬러",
] as const;

const FACE_READING_GUIDE_PROMPT = [
  "Create a Korean face-reading impression report poster — calm, observational.",
  "",
  "Image 1 = filled example. Copy its layout, star ratings, density; replace example photos/text.",
  "Image 2 = user's selfie. Every face = same person (same bone structure, age, ethnicity). Emphasize 매력 / 분위기.",
  "",
  "CRITICAL — face placement:",
  "- Show the ENTIRE face: forehead, full chin, both ears, hair edges.",
  "- NEVER crop forehead/ears/chin — full impression requires the complete face.",
  "- Scale-to-fit with ivory padding if Image 2 aspect differs from slot.",
  "",
  "Title: 얼굴 인상 리포트 / Subtitle: 첫인상 · 분위기 · 존재감",
  "",
  "Sections (Korean):",
  "1. 한 줄 요약 — 1 sentence.",
  "2. 종합 인상 — 7 star ratings (0-5★): 시각적 매력 / 분위기 무드 / 매력 포인트 / 사회적 편안함 / 로맨틱 무드 / 조용한 신뢰감 / 숨은 매력. 1-line each.",
  "3. 눈 / 코 / 입 / 얼굴형 — 4 cards, 관찰 (1-2 문장) + 포인트 (1 줄).",
  "4. 분위기 — 4 bullets (평소 / 첫인상 / 미소 / 잔잔함).",
  "5. 관계 스타일 — 4 bullets (가까워지는 방식 / 거리감 / 신뢰 / 갈등 모드).",
  "6. 가치관 무드 — 4 bullets (중요한 것 / 양보 못하는 것 / 끌리는 사람 / 멀어지는 사람).",
  "7. 앞으로의 흐름 — 4 bullets (다가올 분위기 / 주목할 시기 / 조심할 점 / 빛나는 순간).",
  "8. 스타일 플랜 — 4 sub-cards (조명 / 메이크업 / 헤어 / 사진 각도).",
  "9. 변화되는 인상 — 3 sub-cards (이전 / 이후 / 추천 활용).",
  "10. 최종 메모 — 1-2 sentence closing.",
  "11. 럭키 아이템 — keyword + 1 줄.",
  "12. 럭키 컬러 — color name + swatch + 1 줄.",
  "",
  "Footer (작은 글씨): 이 리포트는 엔터테인먼트와 자기 관찰을 위한 참고용입니다.",
  "Style: warm ivory editorial, thin black lines, rounded cards, small filled/empty stars.",
  "All visible text in Korean.",
].join("\n");

const faceReadingGuide: PosterTypeConfig = {
  posterType: "face-reading-guide",
  displayName: "페이스리딩 가이드",
  templatePath: "face-reading-guide.png",
  // 전용 템플릿 미준비 → beauty-simulation 으로 임시 fallback. 이후 업로드 시 자동 우선.
  fallbackTemplatePath: "beauty-simulation.png",
  requiresUserPhoto: true,
  photoKind: "face",
  buildPrompt: () => FACE_READING_GUIDE_PROMPT,
  sections: FACE_READING_GUIDE_SECTIONS,
  outputSize: "1024x1536",
  tokenCost: 12,
};

// ----- 5. ootd-guide -----
const OOTD_GUIDE_SECTIONS = [
  "한눈에 보기",
  "오늘의 무드",
  "컬러 팔레트",
  "추천 코디 3가지",
  "피해야 할 조합",
  "스타일링 팁",
  "마무리 한마디",
] as const;

function buildOotdGuidePrompt(ctx: PromptBuildContext): string {
  const contextLine = ctx.contextText
    ? `Situation context (tune outfit recommendations to this): "${ctx.contextText}"`
    : "No specific situation — assume an everyday Korean urban setting and current season.";

  return [
    "Create a Korean OOTD (오늘의 옷차림) styling poster with 3 concrete outfit recommendations.",
    "",
    "Image 1 = layout template. Use exactly this layout from Image 1.",
    "Image 2 = user photo. Read skin undertone, proportions, and vibe; any figure shown = same person.",
    contextLine,
    "",
    "Title: 오늘의 옷차림 가이드 / Subtitle: 색감 · 핏 · 상황",
    "",
    "Sections (Korean):",
    "1. 한눈에 보기 — 1-2 sentences on today's recommended mood.",
    "2. 오늘의 무드 — 3 sub-cards (계절 / 날씨 / 분위기).",
    "3. 컬러 팔레트 — 3-5 color chips (swatch + color name) + 1 line.",
    "4. 추천 코디 3가지 — 3 outfit cards. Each: 톱 / 보텀 / 신발 / 액세서리 (4 lines) + 1-line comment + small illustration.",
    "5. 피해야 할 조합 — 2-3 bullets, light tone.",
    "6. 스타일링 팁 — 3-4 short bullets.",
    "7. 마무리 한마디 — warm 1 sentence.",
    "",
    "Style: warm ivory editorial, thin black lines, rounded cards — Korean fashion magazine spread, no brand names or logos.",
    "All visible text in Korean.",
  ].join("\n");
}

const ootdGuide: PosterTypeConfig = {
  posterType: "ootd-guide",
  displayName: "OOTD 가이드",
  templatePath: "ootd-guide.png",
  // 사용자 별도 템플릿 미준비 시 beauty 템플릿으로 fallback (contract §1.F)
  fallbackTemplatePath: "beauty-simulation.png",
  requiresUserPhoto: true,
  photoKind: "face-and-body",
  buildPrompt: buildOotdGuidePrompt,
  sections: OOTD_GUIDE_SECTIONS,
  outputSize: "1024x1536",
  tokenCost: 10,
};

// ----- 6. blind-date-guide -----
const BLIND_DATE_GUIDE_SECTIONS = [
  "한눈에 보기",
  "첫인상 분석",
  "옷차림 추천",
  "헤어·메이크업 가이드",
  "말투·대화 톤",
  "첫 만남 5가지 행동 가이드",
  "마무리 한마디",
] as const;

function buildBlindDateGuidePrompt(ctx: PromptBuildContext): string {
  const contextLine = ctx.contextText
    ? `Situation context (tailor every recommendation to this): "${ctx.contextText}"`
    : "No specific situation — assume a first-meeting blind date in a relaxed café.";

  return [
    "Create a Korean 소개팅 (blind-date) preparation poster — supportive coach briefing.",
    "",
    "Image 1 = layout template. Use exactly this layout.",
    "Image 2 = user's selfie. Any figure shown = same person, same age, same ethnicity.",
    contextLine,
    "",
    "Title: 소개팅 가이드 / Subtitle: 옷차림 · 헤어 · 말투 · 첫인상",
    "",
    "Sections (Korean, supportive coaching tone):",
    "1. 한눈에 보기 — 1-2 sentence overall coaching.",
    "2. 첫인상 분석 — 2 sub-cards: 강점 (3-4 bullets) / 보완점 (2-3 bullets, gentle).",
    "3. 옷차림 추천 — Top / Bottom / Accessory / Color (4 lines) + 1-line tone guide.",
    "4. 헤어·메이크업 가이드 — 2 columns (헤어 / 메이크업), 3-4 bullets each.",
    "5. 말투·대화 톤 — 3 sub-cards: 피해야 할 말 / 효과적인 말 / 분위기 만드는 한마디.",
    "6. 첫 만남 5가지 행동 가이드 — 5 numbered bullets (도착 / 첫 인사 / 음료 주문 / 대화 흐름 / 헤어질 때).",
    "7. 마무리 한마디 — warm, confidence-building 1 sentence.",
    "",
    "Footer (작은 글씨): 이 가이드는 자기 표현과 자신감을 위한 참고용입니다.",
    "Style: warm ivory editorial, thin black lines, rounded cards. 선호: 자연스럽게 / 가볍게 / 너답게.",
    "All visible text in Korean.",
  ].join("\n");
}

const blindDateGuide: PosterTypeConfig = {
  posterType: "blind-date-guide",
  displayName: "소개팅 가이드",
  templatePath: "blind-date-guide.png",
  fallbackTemplatePath: "beauty-simulation.png",
  requiresUserPhoto: true,
  photoKind: "face",
  buildPrompt: buildBlindDateGuidePrompt,
  sections: BLIND_DATE_GUIDE_SECTIONS,
  outputSize: "1024x1536",
  tokenCost: 12,
};

// ----- 7. past-life-guide -----
const PAST_LIFE_GUIDE_SECTIONS = [
  "한눈에 보기",
  "전생의 시대",
  "전생의 역할",
  "전생의 성격",
  "전생에서의 결정적 순간",
  "이어져 온 결",
  "풀어야 할 매듭",
  "다음 결을 위한 한마디",
] as const;

function buildPastLifeGuidePrompt(ctx: PromptBuildContext): string {
  const contextLine = ctx.contextText
    ? `Personal context (use as narrative seed — name, birth year, MBTI, recent life themes, etc.): "${ctx.contextText}"`
    : "No personal context provided — generate a thoughtful narrative from universal themes.";

  return [
    "Create a Korean 전생 (past-life) narrative report poster — gentle storytelling, softly evocative.",
    "",
    "Image 1 = layout template. Use exactly this layout.",
    "Image 2 = OPTIONAL user selfie. If no user image, render a symbolic illustration (silhouette, era motif, calm landscape) instead. If provided, use only as a vibe muse — never paste the modern selfie into a historical scene.",
    contextLine,
    "",
    "Title: 전생 리포트 / Subtitle: 시대 · 역할 · 이어진 결",
    "",
    "Sections (Korean, 옛이야기 narrator voice):",
    "1. 한눈에 보기 — 1 line summarizing 시대 / 장소 / 역할.",
    "2. 전생의 시대 — 2-3 sentence narrative on era, region, social backdrop.",
    "3. 전생의 역할 — 2-3 sentences on occupation, status, daily scene.",
    "4. 전생의 성격 — 4-5 keyword chips + 1-2 sentences.",
    "5. 전생에서의 결정적 순간 — short scene story, 3-4 sentences.",
    "6. 이어져 온 결 — 4 bullets (강점 / 약점 / 관계 패턴 / 가치관), each in form '전생의 [X]가 지금의 너에게 [Y]로 이어진다'.",
    "7. 풀어야 할 매듭 — 1-2 gentle self-reflection points.",
    "8. 다음 결을 위한 한마디 — warm 1-sentence closing.",
    "",
    "Include 1-2 small period-appropriate line-art illustrations on ivory bg. Use plausible archetypes (e.g. 작은 어촌의 그물 짜는 사람, 고려시대 변방 마을의 약초꾼) — never name real historical figures.",
    "Footer (작은 글씨): 이 리포트는 상상과 자기 성찰을 위한 참고용입니다. 사실의 기록이 아닙니다.",
    "Style: warm ivory editorial, thin black lines, rounded cards.",
    "All visible text in Korean.",
  ].join("\n");
}

const pastLifeGuide: PosterTypeConfig = {
  posterType: "past-life-guide",
  displayName: "전생 가이드",
  templatePath: "past-life-guide.png",
  // No fallback: past-life narrative layout 은 palm/beauty 와 너무 달라
  // fallback 으로 잘못된 구조 출력되면 UX 깨짐. template 미업로드 시 명확한 에러로 운영자에게 알림.
  // past-life-guide 전용 템플릿 미준비 → beauty-simulation 으로 fallback.
  // narrative 레이아웃은 다르지만 portrait + section 구조는 호환. 이후 전용
  // 템플릿 업로드 시 자동 우선 사용.
  fallbackTemplatePath: "beauty-simulation.png",
  // 전생은 사진 없이도 가능 (contextText 만으로 narrative 생성)
  requiresUserPhoto: false,
  // photoKind 는 RN survey 분기용 메타. 'none' 으로 정확히 표기 (실제 photo step 미노출).
  photoKind: "none",
  buildPrompt: buildPastLifeGuidePrompt,
  sections: PAST_LIFE_GUIDE_SECTIONS,
  outputSize: "1024x1536",
  tokenCost: 10,
};

/**
 * Generator C 는 위 const 의 buildPrompt + sections 만 교체하면 됨 (메타는 손대지 X).
 * Record literal 로 TypeScript 가 7종 모두 존재 여부를 검증한다.
 */
export const POSTER_REGISTRY: Record<PosterType, PosterTypeConfig> = {
  "palm-reading": palmReading,
  "beauty-simulation": beautySimulation,
  "hair-style-guide": hairStyleGuide,
  "face-reading-guide": faceReadingGuide,
  "ootd-guide": ootdGuide,
  "blind-date-guide": blindDateGuide,
  "past-life-guide": pastLifeGuide,
};

// =====================================================
// 헬퍼
// =====================================================

/**
 * 외부 (untrusted) 입력이 PosterType union 에 속하는지 검증.
 * Edge Function 의 body 파싱 직후 호출.
 */
export function isValidPosterType(value: unknown): value is PosterType {
  return (
    typeof value === "string" &&
    (ALL_POSTER_TYPES as readonly string[]).includes(value)
  );
}

/**
 * posterType 으로 config lookup. validated 된 PosterType 만 받으므로 항상 성공.
 */
export function getPosterConfig(posterType: PosterType): PosterTypeConfig {
  return POSTER_REGISTRY[posterType];
}

/**
 * contextText 정규화 — trim + 길이 cap.
 * Edge Function 이 buildPrompt 호출 전에 1회 적용.
 */
export function normalizeContextText(raw: unknown): string | undefined {
  if (typeof raw !== "string") {
    return undefined;
  }
  const trimmed = raw.trim();
  if (!trimmed) {
    return undefined;
  }
  return trimmed.length > MAX_CONTEXT_TEXT_LENGTH
    ? trimmed.slice(0, MAX_CONTEXT_TEXT_LENGTH)
    : trimmed;
}
