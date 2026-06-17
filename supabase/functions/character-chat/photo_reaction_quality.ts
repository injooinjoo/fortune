export const PHOTO_REACTION_STRICT_PROMPT = `
[PHOTO REACTION — 사진 메시지에는 반드시 채팅 리액션으로 답한다]
사용자가 사진을 보냈다. 너는 사진을 실제로 본 사람처럼, 캐릭터 말투로 짧게 반응해야 한다.

필수:
1. 첫 문장부터 사진 속 구체적인 시각 단서 1개를 짚어라. 예: 색감/표정/포즈/옷/배경/음식/동물/사물/빛/구도/분위기.
2. "사진 한 장", "사진이네요", "사진을 보냈네", "무슨 사진이야?"처럼 사진이 왔다는 사실만 말하면 실패다.
3. 이미지에 안 보이는 사실, 신원, 장소, 관계, 건강/나이/직업은 추측하지 마라.
4. 답은 1~2문장. 설명문 말고 실제 메신저에서 보내는 리액션처럼 말해라.
5. 캡션이 있으면 캡션의 감정/의도와 사진 속 시각 단서를 함께 받아라.

좋은 예:
- "헐, 뒤에 하늘 색 진짜 예쁘다. 오늘 이거 보려고 잠깐 멈춘 거면 인정."
- "표정 왜 이렇게 뿌듯해 보여 ㅋㅋ 그 손에 든 거 자랑하려고 보낸 거지."
- "이 음식 윤기 미쳤는데? 나 지금 배고파졌어."

나쁜 예:
- "사진 한 장 보냈네."
- "사진을 보니 좋은 것 같아."
- "어떤 사진인지 더 말해줘."
`;

export const PHOTO_REACTION_SAFE_FALLBACK =
  "사진 속 디테일을 제대로 못 짚겠어. 다시 보면 바로 제대로 말할게.";

const GENERIC_PHOTO_REPLY_PATTERNS = [
  /사진\s*(한\s*)?장(만|이네|이네요|을)?/i,
  /사진(을|이|만)?\s*(보냈|보내줬|왔|올렸|첨부했)(네|네요|구나|어)?/i,
  /이미지(를|가|만)?\s*(보냈|왔|첨부|업로드)/i,
  /무슨\s*사진/i,
  /어떤\s*사진/i,
  /사진(을)?\s*설명해/i,
];

const VISUAL_ANCHOR_PATTERNS = [
  /색감|색깔|컬러|빛|조명|그림자|구도|배경|분위기|햇빛/i,
  /하늘|노을|바다|구름|거리|카페|창문/i,
  /밤\s*(하늘|풍경|거리|배경|조명|색감)/i,
  /방\s*(안|분위기|배경|조명|꾸밈|인테리어)|방에\s*(보이는|있는)/i,
  /얼굴|표정|머리|헤어|미소|포즈|셔츠|코트|가방/i,
  /눈빛|눈매|눈이\s*(웃|반짝|커)|웃는\s*얼굴|손에\s*(든|쥔|있는)|손가락|손모양|옷(차림|색|핏|이|은|도)/i,
  /음식|접시|커피|디저트|케이크|고기|국물|윤기/i,
  /밥(상|그릇|알|이|은|도)|컵(에|이|은|도|모양)|라면|국수|면발|파스타/i,
  /강아지|고양이|동물|꽃|나무/i,
  /책(상|장|표지|이|은|도)|화면|글씨/i,
  /사진\s*속|뒤에|앞에|옆에/i,
  /밝(아|은|게|다)|어둡(게|다|고)|파란|빨간|하얀|검은|초록|노란|분홍|보라/i,
];

function hasVisualAnchor(text: string): boolean {
  return VISUAL_ANCHOR_PATTERNS.some((pattern) => pattern.test(text));
}

export interface PhotoReactionQualityResult {
  ok: boolean;
  issues: string[];
}

export function evaluatePhotoReactionQuality(
  text: string,
  options: { hasImageInput: boolean },
): PhotoReactionQualityResult {
  if (!options.hasImageInput) {
    return { ok: true, issues: [] };
  }

  const normalized = text.replace(/\s+/g, " ").trim();
  const issues: string[] = [];
  if (!normalized) {
    issues.push("empty_photo_reaction");
  }

  if (
    GENERIC_PHOTO_REPLY_PATTERNS.some((pattern) => pattern.test(normalized))
  ) {
    issues.push("generic_photo_placeholder");
  }

  if (!hasVisualAnchor(normalized)) {
    issues.push("missing_visual_anchor");
  }

  return { ok: issues.length === 0, issues };
}

export function buildPhotoReactionRetryPrompt(params: {
  previousReply: string;
  issues: string[];
}): string {
  return `${PHOTO_REACTION_STRICT_PROMPT}\n\n[RETRY REQUIRED]\n직전 답변은 사진 채팅 리액션 QA에서 실패했다.\n- 실패 사유: ${
    params.issues.join(", ")
  }\n- 직전 답변: ${params.previousReply}\n\n사진 속 시각 단서 1개를 반드시 짚고, 캐릭터 말투의 자연스러운 채팅 리액션으로 다시 답해라.`;
}
