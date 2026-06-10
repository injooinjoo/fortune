/**
 * 푸시 알림 richContent.image 에 사용할 캐릭터 아바타 공개 URL 빌더.
 *
 * 매핑은 정적 — characterId 가 그대로 storage object key 의 prefix 로 사용된다
 * (`<characterId>.webp`). scripts/upload_character_avatars.sh 가 앱 내 WebP 원본과
 * 푸시용 PNG 백업본을 업로드하므로, 새 캐릭터 추가 시
 *   1) apps/mobile-rn/src/assets/character/avatars/<id>.webp 추가
 *   2) chat-character-avatar.ts 매핑 추가
 *   3) 업로드 스크립트 재실행
 *   4) 아래 KNOWN_AVATAR_IDS 에 id 추가
 * 네 단계만 하면 자동으로 푸시에도 얼굴이 붙는다.
 *
 * 미등록 characterId 는 null 반환 → notification_push.ts 에서 richContent
 * 자체를 생략 (텍스트 푸시로 graceful fallback).
 */

const KNOWN_AVATAR_IDS = new Set<string>([
  "luts",
  "jung_tae_yoon",
  "seo_yoonjae",
  "kang_harin",
  "jayden_angel",
  "ciel_butler",
  "lee_doyoon",
  "han_seojun",
  "baek_hyunwoo",
  "min_junhyuk",
  "fortune_haneul",
  "fortune_muhyeon",
  "fortune_stella",
  "fortune_dr_mind",
  "fortune_rose",
  "fortune_james_kim",
  "fortune_lucky",
  "fortune_marco",
  "fortune_lina",
  "fortune_luna",
]);

const BUCKET = "character-avatars";

/**
 * 정적 호스트 prefix. SUPABASE_URL 이 없는 환경(로컬 deno test)에서도 깨지지
 * 않도록 null 을 반환한다 — 호출 측에서 image 를 생략한다.
 */
function getBaseUrl(): string | null {
  const url = Deno.env.get("SUPABASE_URL");
  if (!url) return null;
  // 끝 슬래시 정규화: storage URL 조합 시 // 발생 방지
  const trimmed = url.endsWith("/") ? url.slice(0, -1) : url;
  return `${trimmed}/storage/v1/object/public/${BUCKET}`;
}

export function getCharacterAvatarUrl(
  characterId: string | null | undefined,
): string | null {
  if (!characterId) return null;
  if (!KNOWN_AVATAR_IDS.has(characterId)) return null;
  const base = getBaseUrl();
  if (!base) return null;
  return `${base}/${characterId}.webp`;
}
