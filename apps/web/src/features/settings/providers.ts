/**
 * 개인 AI 키를 연결할 수 있는 제공자 목록 + `/설정/ai` 경로 상수.
 *
 * id 는 Edge Function 이 그대로 받아 provider 로 쓰는 값이라
 * `supabase/functions/_shared/llm/factory.ts` 의 문자열
 * ("openai" | "gemini" | "anthropic" | "grok") 과 같아야 한다.
 * "openrouter" 만 이번에 새로 생긴 값이다.
 */

import { encodePath } from '@/lib/href';

/**
 * BYOK(개인 키 연결) 노출 스위치. **기본값은 꺼짐.**
 *
 * 켜기 전 조건 — 운세 Edge Function 들이 사용자 키를 실제로 쓰고 있어야 한다.
 * 지금 저장 경로(`user-llm-key`)와 사용 경로(`_shared/llm/user_key.ts` →
 * `LLMFactory.createFromConfigAsync(fortuneType, userId)`)는 다 있지만,
 * `supabase/functions` 의 각 fortune 함수가 아직 userId 를 넘기지 않는다.
 * 그 상태에서 이 화면을 열면 **쓰이지도 않을 서드파티 자격증명을 받아 두는 꼴**이라
 * 헤더 링크도, 연결 폼도 내보내지 않는다.
 *
 * 켜는 법: 빌드 환경에 `NEXT_PUBLIC_ONDO_BYOK_ENABLED=1` (NEXT_PUBLIC_* 는 빌드
 * 타임에 번들로 인라인되므로 값을 바꾸면 재빌드가 필요하다).
 */
export const IS_BYOK_ENABLED =
  process.env.NEXT_PUBLIC_ONDO_BYOK_ENABLED === '1' ||
  process.env.NEXT_PUBLIC_ONDO_BYOK_ENABLED === 'true';

/**
 * `/설정/ai`.
 *
 * 한글 slug 는 반드시 `encodePath` 를 거쳐서만 링크한다 — 디코딩된 한글을
 * `<Link href>` 에 그대로 넣으면 Next 가 RSC 요청 헤더에 실으면서
 * "String contains non ISO-8859-1 code point" 로 터지고 soft navigation 이
 * 전부 죽는다 (`lib/href.ts` 주석에 실제 사례가 적혀 있다).
 */
export const SETTINGS_AI_HREF = encodePath('/설정/ai');

/**
 * 로그인 후 이 페이지로 돌아오는 링크.
 *
 * `SETTINGS_AI_HREF` 는 이미 퍼센트 인코딩된 문자열이라 여기서 한 번 더
 * `encodeURIComponent` 하면 `%` 가 `%25` 가 된다. 그게 맞다 — 쿼리 값은
 * 서버에서 한 번 디코딩되므로 `sanitizeNextPath` 에는 원래의
 * `/%EC%84%A4%EC%A0%95/ai` 가 들어가고, 그대로 redirect 되면 브라우저가
 * `/설정/ai` 로 해석한다.
 */
export const SETTINGS_AI_LOGIN_HREF = `/auth/login?next=${encodeURIComponent(SETTINGS_AI_HREF)}`;

export const USER_LLM_PROVIDERS = [
  { id: 'openai', label: 'GPT (OpenAI)' },
  { id: 'gemini', label: 'Gemini (Google)' },
  { id: 'anthropic', label: 'Claude (Anthropic)' },
  { id: 'grok', label: 'Grok (xAI)' },
  { id: 'openrouter', label: 'OpenRouter' },
] as const;

export type UserLlmProviderId = (typeof USER_LLM_PROVIDERS)[number]['id'];

/** `features/fortune/fields.tsx` 의 ChipSelect 가 그대로 받는 형태. */
export const USER_LLM_PROVIDER_OPTIONS = USER_LLM_PROVIDERS.map((provider) => ({
  value: provider.id,
  label: provider.label,
}));

/** 서버가 우리가 모르는 provider 를 돌려줘도 칸이 비지 않게 raw id 로 폴백한다. */
export function providerLabel(id: string): string {
  return USER_LLM_PROVIDERS.find((provider) => provider.id === id)?.label ?? id;
}

export function isUserLlmProviderId(value: string): value is UserLlmProviderId {
  return USER_LLM_PROVIDERS.some((provider) => provider.id === value);
}
