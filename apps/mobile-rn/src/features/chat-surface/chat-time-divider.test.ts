import {
  buildChatRenderItems,
  formatChatTimeDividerLabel,
} from './chat-time-divider.ts';

import type { ChatShellMessage } from '../../lib/chat-shell.ts';

function textMessage(id: string, sender: 'assistant' | 'user' = 'assistant'): ChatShellMessage {
  return {
    id,
    kind: 'text',
    sender,
    text: '테스트 메시지',
  };
}

const HOUR = 60 * 60 * 1000;
const NOW = Date.UTC(2026, 4, 12, 8, 0, 0); // 2026-05-12 08:00 UTC

function idAt(prefix: string, timestamp: number): string {
  return `${prefix}-${timestamp}-test`;
}

function assert(condition: unknown, message: string): asserts condition {
  if (!condition) throw new Error(message);
}

{
  const base = Date.UTC(2026, 4, 12, 4, 0, 0);
  const items = buildChatRenderItems([
    textMessage(idAt('assistant', base)),
    textMessage(idAt('user', base + 30 * 60 * 1000), 'user'),
    textMessage(idAt('assistant', base + 119 * 60 * 1000)),
  ], base + 119 * 60 * 1000);

  assert(
    items.filter((item) => item.kind === 'time-divider').length === 0,
    '2시간 미만의 짧은 대화에는 중앙 시간 라벨을 넣지 않아야 한다',
  );
}

{
  const base = Date.UTC(2026, 4, 12, 4, 0, 0);
  const items = buildChatRenderItems([
    textMessage(idAt('assistant', base)),
    textMessage(idAt('user', base + 2 * HOUR), 'user'),
  ], base + HOUR);
  const dividers = items.filter((item) => item.kind === 'time-divider');

  assert(dividers.length === 1, '2시간 이상 끊긴 메시지 위에는 중앙 시간 라벨이 필요하다');
  assert(dividers[0]?.label === '오후 3:00', '오늘 메시지는 오전/오후 시간만 표시한다');
}

{
  const yesterday = Date.UTC(2026, 4, 11, 14, 50, 0); // KST 2026-05-11 23:50
  const today = Date.UTC(2026, 4, 11, 15, 5, 0); // KST 2026-05-12 00:05
  const items = buildChatRenderItems([
    textMessage(idAt('assistant', yesterday)),
    textMessage(idAt('assistant', today)),
  ], NOW);
  const dividers = items.filter((item) => item.kind === 'time-divider');

  assert(
    dividers.some((divider) => divider.label === '오전 12:05'),
    '날짜가 바뀐 첫 메시지 위에는 오늘 시간 포맷의 중앙 라벨이 필요하다',
  );
}

{
  const yesterday = Date.UTC(2026, 4, 11, 7, 12, 0);
  const label = formatChatTimeDividerLabel(yesterday, NOW);
  assert(label === '어제 오후 4:12', '어제 메시지는 어제 + 오전/오후 시간을 표시한다');
}

{
  const staleFirst = Date.UTC(2026, 4, 11, 7, 12, 0);
  const items = buildChatRenderItems([textMessage(idAt('assistant', staleFirst))], NOW);

  assert(
    items.every((item) => item.kind !== 'time-divider'),
    '중앙 시간 라벨은 메시지 사이 경계에만 넣고 첫 메시지 위에는 넣지 않는다',
  );
}

{
  const sameYearOldDay = Date.UTC(2026, 0, 2, 5, 30, 0); // KST 2026-01-02 14:30
  const label = formatChatTimeDividerLabel(sameYearOldDay, NOW);
  assert(label === '1월 2일 오후 2:30', '같은 해의 오래된 메시지는 월/일 + 시간을 표시한다');
}

{
  const differentYear = Date.UTC(2025, 11, 31, 14, 58, 0); // KST 2025-12-31 23:58
  const label = formatChatTimeDividerLabel(differentYear, NOW);
  assert(
    label === '2025년 12월 31일 오후 11:58',
    '다른 해의 메시지는 연/월/일 + 시간을 표시한다',
  );
}
