import type { FortuneTypeId } from '@fortune/product-contracts';

import type { ChatShellEmbeddedResultMessage } from '../../lib/chat-shell';

const DAILY_REVALIDATED_FORTUNE_TYPES = new Set<FortuneTypeId>(['daily']);
const KST_OFFSET_MS = 9 * 60 * 60 * 1000;

/**
 * Chat result messages do not store createdAt separately; generated result ids are
 * `result-${Date.now()}-${rand}`. Keep this parser narrow so non-generated or
 * legacy ids simply opt out of date-sensitive reuse.
 */
export function parseGeneratedResultTimestampMs(id: string): number | null {
  const match = /^result-(\d{12,})-/.exec(id);
  if (!match) return null;

  const timestamp = Number(match[1]);
  return Number.isFinite(timestamp) ? timestamp : null;
}

function toKstDateKey(timestampMs: number): string {
  return new Date(timestampMs + KST_OFFSET_MS).toISOString().slice(0, 10);
}

export function isSameKstCalendarDay(leftMs: number, rightMs: number): boolean {
  return toKstDateKey(leftMs) === toKstDateKey(rightMs);
}

export function canReuseEmbeddedResultMessage(
  message: ChatShellEmbeddedResultMessage,
  fortuneType: FortuneTypeId,
  nowMs: number = Date.now(),
): boolean {
  if (!DAILY_REVALIDATED_FORTUNE_TYPES.has(fortuneType)) {
    return true;
  }

  const generatedAtMs = parseGeneratedResultTimestampMs(message.id);
  if (generatedAtMs === null) {
    // Date-sensitive fortunes must not be reused when their generation date is
    // unknown; otherwise a stale "today" card can be pinned forever.
    return false;
  }

  return isSameKstCalendarDay(generatedAtMs, nowMs);
}
