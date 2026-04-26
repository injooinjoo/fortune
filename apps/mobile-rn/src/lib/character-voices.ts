/**
 * 캐릭터 → Gemini 3.1 Flash TTS preview voice ID 매핑.
 *
 * - Story 캐릭터 7명에 각자 어울리는 보이스 고정. 동일한 voice 가 두 캐릭터
 *   에 매핑되지 않게 분산. 추후 캐릭터가 늘어나면 ROTATING_VOICE_POOL 에서
 *   해시 기반으로 안정적 분배.
 * - Fortune 캐릭터 + 사용자 생성 friend 는 default 'Kore' 로 폴백.
 *
 * Gemini TTS 의 30개 voice 중 검증된 10개만 사용 (`character-tts` Edge
 * Function 의 ALLOWED_VOICES 와 1:1 일치 유지).
 */

export type GeminiVoiceId =
  | 'Kore'
  | 'Puck'
  | 'Charon'
  | 'Zephyr'
  | 'Fenrir'
  | 'Aoede'
  | 'Leda'
  | 'Enceladus'
  | 'Achernar'
  | 'Achird';

const STORY_CHARACTER_VOICES: Record<string, GeminiVoiceId> = {
  // 명탐정 / 위장결혼 — 깊고 절제된 남성 톤
  luts: 'Charon',
  // 사기결혼 / 복수 — 친근하고 날카로운 남성 톤
  jung_tae_yoon: 'Puck',
  // 게임 NPC / 개발자 — 따뜻하고 접근성 있는 톤
  seo_yoonjae: 'Fenrir',
  // 비서 / 그림자 — 부드럽고 음악적인 여성
  kang_harin: 'Aoede',
  // 천사 / 구원 — 다른 세계 같은 음색
  jayden_angel: 'Achernar',
  // 집사 — 정중하고 차분한 톤
  ciel_butler: 'Enceladus',
  // 미정 — 중성적 차분
  lee_doyoon: 'Achird',
};

const DEFAULT_VOICE: GeminiVoiceId = 'Kore';

/**
 * 캐릭터별 voice 결정. story 매핑이 있으면 그걸로, 없으면 DEFAULT_VOICE.
 * 사용자 생성 친구 / fortune 캐릭터는 모두 default 로 떨어진다.
 */
export function getCharacterVoice(characterId: string): GeminiVoiceId {
  return STORY_CHARACTER_VOICES[characterId] ?? DEFAULT_VOICE;
}

/**
 * 응답 emotion 태그 → Gemini TTS 인라인 스타일 instruction.
 * 실제 instruction prefix 적용은 Edge Function (character-tts/index.ts) 에서
 * 한다. 여기서는 클라이언트가 emotion 을 그대로 패스스루 하기만 하면 됨.
 *
 * `character-chat/index.ts` 의 EMOTION_CONFIG 6종 + 미지정 케이스 (undefined) 를 다룬다.
 */
export const SUPPORTED_EMOTIONS = new Set([
  '일상',
  '애정',
  '기쁨',
  '고민',
  '분노',
  '당황',
]);

export function normalizeEmotion(raw: string | undefined | null): string | undefined {
  if (!raw) return undefined;
  const trimmed = raw.trim();
  if (!trimmed) return undefined;
  if (!SUPPORTED_EMOTIONS.has(trimmed)) return undefined;
  if (trimmed === '일상') return undefined; // 기본값 — instruction prefix 안 붙임
  return trimmed;
}
