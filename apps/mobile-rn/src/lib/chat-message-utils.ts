/**
 * 채팅 메시지 순수 함수 모음.
 *
 * chat-screen.tsx 분해 (Step B) — message append/read 로직이 chat-screen 안
 * module-level 에 박혀 있어 use-message-queue hook 분리 시 import 어려움.
 * 순수 함수만 추출 (state 의존 0, 다른 화면에서도 재사용 가능).
 */

import type { ChatShellMessage } from './chat-shell';

/**
 * 미읽음 user kind='text' 메시지 전부에 `readAt` 을 도장찍어 돌려준다.
 *
 * AI 응답 시점에 호출되므로, 그 전까지 쌓인 모든 유저 메시지를 한꺼번에 읽음
 * 처리 (연속으로 보낸 경우에도 "1" 배지가 남지 않도록). iMessage / 카톡의
 * "상대방이 답장 시작 = 그 전 내 메시지들 일괄 읽음" 표준 동작.
 *
 * 동일 array 반환 시 (변경된 게 없으면) 같은 reference — React state 비교
 * 최적화 친화적.
 */
export function markLatestUserMessageAsRead(
  messages: ChatShellMessage[],
  readAt: string = new Date().toISOString(),
): ChatShellMessage[] {
  let patched = false;
  const next = messages.map((message) => {
    if (
      message.kind === 'text' &&
      message.sender === 'user' &&
      !message.readAt
    ) {
      patched = true;
      return { ...message, readAt };
    }
    return message;
  });
  return patched ? next : messages;
}

/**
 * setTimeout Promise wrapper. 카톡 리듬 emulation 에서 segment 간 자연스러운
 * 타이핑/대기 시간 만들 때 사용.
 */
export function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

/**
 * [minMs, maxMs] 사이 정수 ms 랜덤. randomInRange(200, 600) → 200~600 사이.
 */
export function randomInRange(minMs: number, maxMs: number): number {
  return minMs + Math.floor(Math.random() * Math.max(1, maxMs - minMs + 1));
}

/**
 * 두 메시지 리스트가 id 기준으로 같은지 얕은 비교. hydrate 결과가 캐시와
 * 동일할 때 불필요한 re-render (= old→new 플래시) 를 막기 위해 사용.
 */
export function chatThreadsEqualById(
  a: ChatShellMessage[],
  b: ChatShellMessage[],
): boolean {
  if (a === b) return true;
  if (a.length !== b.length) return false;
  for (let i = 0; i < a.length; i += 1) {
    if (a[i].id !== b[i].id) return false;
  }
  return true;
}
