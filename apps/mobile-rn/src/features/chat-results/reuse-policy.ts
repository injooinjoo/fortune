import type { FortuneTypeId } from '@fortune/product-contracts';

import type { ChatShellEmbeddedResultMessage } from '../../lib/chat-shell';

const DAILY_REVALIDATED_FORTUNE_TYPES = new Set<FortuneTypeId>([
  'daily',
  'daily-calendar',
]);
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

function parseIsoTimestampMs(value: unknown): number | null {
  if (typeof value !== 'string' || !value.trim()) return null;
  const timestamp = Date.parse(value);
  return Number.isFinite(timestamp) ? timestamp : null;
}

function readNestedRecordValue(record: unknown, path: string[]): unknown {
  let current: unknown = record;
  for (const key of path) {
    if (!current || typeof current !== 'object') return undefined;
    current = (current as Record<string, unknown>)[key];
  }
  return current;
}

function parsePayloadGeneratedTimestampMs(
  message: ChatShellEmbeddedResultMessage,
): number | null {
  return (
    parseIsoTimestampMs(message.payload.generatedAt) ??
    parseIsoTimestampMs(readNestedRecordValue(message.payload.rawApiResponse, ['timestamp'])) ??
    parseIsoTimestampMs(readNestedRecordValue(message.payload.rawApiResponse, ['generatedAt'])) ??
    parseIsoTimestampMs(readNestedRecordValue(message.payload.rawApiResponse, ['createdAt'])) ??
    parseIsoTimestampMs(readNestedRecordValue(message.payload.rawApiResponse, ['fortune', 'timestamp'])) ??
    parseIsoTimestampMs(readNestedRecordValue(message.payload.rawApiResponse, ['data', 'timestamp']))
  );
}

export function canReuseEmbeddedResultMessage(
  message: ChatShellEmbeddedResultMessage,
  fortuneType: FortuneTypeId,
  nowMs: number = Date.now(),
): boolean {
  if (!DAILY_REVALIDATED_FORTUNE_TYPES.has(fortuneType)) {
    return true;
  }

  const generatedAtMs = parsePayloadGeneratedTimestampMs(message);
  if (generatedAtMs === null) {
    // Date-sensitive fortunes must use the payload generation date, not the
    // wrapper message id. Reopening an old payload creates a fresh message id;
    // trusting that id pins stale "today" content under a new date.
    return false;
  }

  return isSameKstCalendarDay(generatedAtMs, nowMs);
}
