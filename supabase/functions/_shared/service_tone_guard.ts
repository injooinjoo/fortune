// 캐릭터(특히 스토리/로맨스 페르소나)가 보내면 안 되는 상담봇/서비스 톤 패턴.
// 한 번이라도 매칭되면 페르소나 즉사 — 답변 폐기 후 fallback 또는 발송 스킵.
//
// Slice 2 이전: character-chat/index.ts (LUTS_SERVICE_TONE_PATTERN) 와
// proactive-message-dispatch/index.ts (PROACTIVE_SERVICE_TONE_PATTERN) 가
// 거의 동일한 패턴을 별도 정의하고 있었음. /autoplan A13 결정으로 통합.
//
// 양 호출처에서 import 한다. 패턴 변경은 이 파일 한 곳에서만.

/**
 * 콜센터/상담봇/낯선 인사 톤 패턴.
 * - "무엇을 도와드릴까요" 류 콜센터 인사
 * - "처음 뵙겠습니다" / "안녕하세요, 누구입니다" 같은 첫인사 (이미 친밀한 캐릭터엔 부적합)
 * - "기다리겠습니다", "답은 서두르지 않으셔도" 같은 형식적 응답
 * - LLM 영어/일본어 fallback ("how can I help", "お手伝い") 도 포함
 */
export const SERVICE_TONE_PATTERN: RegExp =
  /(무엇을\s*도와드릴\s*수|(?:무엇을|뭘|어떻게)\s*도와드릴까요\??|도움이\s*필요하시면|문의|지원|how can i help|let me help|assist you|お手伝い|サポート|만나서\s*반가워(?:요|워)|처음\s*뵙(?:겠습니다|네요)|지금\s*뭐\s*하고\s*계세요|답은\s*서두르지\s*않으셔도|기다리겠습니다|저는\s*기다리|요즘\s*가장\s*궁금한\s*건|요즘\s*제일\s*궁금한|안녕하세요[,.\s]+[가-힣]+(?:이|예)요)/i;

/**
 * 텍스트가 서비스 톤이면 true. 짧은 헬퍼.
 */
export function isServiceTone(text: string): boolean {
  return SERVICE_TONE_PATTERN.test(text);
}
