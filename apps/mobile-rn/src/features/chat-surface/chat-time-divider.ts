import type { ChatShellMessage } from '../../lib/chat-shell';

export const CHAT_TIME_DIVIDER_LONG_GAP_MS = 2 * 60 * 60 * 1000;
const KST_OFFSET_MS = 9 * 60 * 60 * 1000;

export type ChatRenderItem =
  | {
      kind: 'time-divider';
      id: string;
      timestamp: number;
      label: string;
      accessibilityLabel: string;
    }
  | {
      kind: 'message';
      message: ChatShellMessage;
      showProactiveCaption: boolean;
      timeDividerShownBefore: boolean;
    };

function extractTimestampFromMessageId(id: string): number {
  const match = id.match(/-(\d{13})-/);
  if (!match?.[1]) return 0;
  const ts = Number(match[1]);
  return Number.isFinite(ts) ? ts : 0;
}

export function extractChatMessageTimestamp(message: ChatShellMessage): number {
  const idTimestamp = extractTimestampFromMessageId(message.id);
  if (Number.isFinite(idTimestamp) && idTimestamp > 1_500_000_000_000) {
    return idTimestamp;
  }

  if (message.kind === 'my-saju-context') {
    return message.timestamp;
  }

  if (message.kind === 'text' || message.kind === 'image' || message.kind === 'audio') {
    if (message.proactive?.generatedAt) {
      const proactiveTs = Date.parse(message.proactive.generatedAt);
      if (Number.isFinite(proactiveTs)) return proactiveTs;
    }
  }

  return 0;
}

function getKstDate(timestamp: number): Date {
  return new Date(timestamp + KST_OFFSET_MS);
}

function getKstDayNumber(timestamp: number): number {
  return Math.floor((timestamp + KST_OFFSET_MS) / (24 * 60 * 60 * 1000));
}

function isSameKstDay(aTimestamp: number, bTimestamp: number): boolean {
  return getKstDayNumber(aTimestamp) === getKstDayNumber(bTimestamp);
}

function isYesterdayKst(timestamp: number, nowTimestamp: number): boolean {
  return getKstDayNumber(nowTimestamp) - getKstDayNumber(timestamp) === 1;
}

function formatKoreanMeridiemTime(kstDate: Date): string {
  const hour = kstDate.getUTCHours();
  const minute = kstDate.getUTCMinutes();
  const displayHour = hour === 0 ? 12 : hour > 12 ? hour - 12 : hour;
  const paddedMinute = minute.toString().padStart(2, '0');
  return `${hour >= 12 ? '오후' : '오전'} ${displayHour}:${paddedMinute}`;
}

export function formatChatTimeDividerLabel(timestamp: number, nowTimestamp = Date.now()): string {
  const kstDate = getKstDate(timestamp);
  const nowKstDate = getKstDate(nowTimestamp);

  if (isSameKstDay(timestamp, nowTimestamp)) {
    return formatKoreanMeridiemTime(kstDate);
  }

  if (isYesterdayKst(timestamp, nowTimestamp)) {
    return `어제 ${formatKoreanMeridiemTime(kstDate)}`;
  }

  const month = kstDate.getUTCMonth() + 1;
  const day = kstDate.getUTCDate();
  const time = formatKoreanMeridiemTime(kstDate);

  if (kstDate.getUTCFullYear() === nowKstDate.getUTCFullYear()) {
    return `${month}월 ${day}일 ${time}`;
  }

  return `${kstDate.getUTCFullYear()}년 ${month}월 ${day}일 ${time}`;
}

export function formatChatTimeDividerAccessibilityLabel(timestamp: number, nowTimestamp = Date.now()): string {
  return `시간 구분: ${formatChatTimeDividerLabel(timestamp, nowTimestamp)}`;
}

function shouldShowTimeDivider(
  currentTimestamp: number,
  previousTimestamp: number | null,
): boolean {
  if (!Number.isFinite(currentTimestamp) || currentTimestamp <= 0) return false;

  if (previousTimestamp == null || previousTimestamp <= 0) {
    return false;
  }

  if (!isSameKstDay(previousTimestamp, currentTimestamp)) return true;

  return currentTimestamp - previousTimestamp >= CHAT_TIME_DIVIDER_LONG_GAP_MS;
}

export function buildChatRenderItems(
  messages: readonly ChatShellMessage[],
  nowTimestamp = Date.now(),
): ChatRenderItem[] {
  const items: ChatRenderItem[] = [];
  let previousTimestamp: number | null = null;
  let previousMessage: ChatShellMessage | null = null;

  messages.forEach((message) => {
    const timestamp = extractChatMessageTimestamp(message);
    const showDivider = shouldShowTimeDivider(timestamp, previousTimestamp);

    if (showDivider) {
      items.push({
        kind: 'time-divider',
        id: `time-divider-${message.id}`,
        timestamp,
        label: formatChatTimeDividerLabel(timestamp, nowTimestamp),
        accessibilityLabel: formatChatTimeDividerAccessibilityLabel(timestamp, nowTimestamp),
      });
    }

    const messageHasProactive =
      (message.kind === 'text' || message.kind === 'image' || message.kind === 'audio') &&
      message.proactive != null;
    const prevHasProactive =
      previousMessage != null &&
      (previousMessage.kind === 'text' || previousMessage.kind === 'image' || previousMessage.kind === 'audio') &&
      previousMessage.proactive != null &&
      previousMessage.sender === 'assistant';

    items.push({
      kind: 'message',
      message,
      showProactiveCaption: messageHasProactive && !prevHasProactive,
      timeDividerShownBefore: showDivider,
    });

    if (timestamp > 0) previousTimestamp = timestamp;
    previousMessage = message;
  });

  return items;
}
