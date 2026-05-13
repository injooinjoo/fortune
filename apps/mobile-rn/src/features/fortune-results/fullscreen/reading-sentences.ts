import type { EmbeddedResultPayload } from '../../chat-results/types';
import type { ResultKind } from '../types';

export type ReadingSentenceSource =
  | 'summary'
  | 'highlight'
  | 'recommendation'
  | 'warning'
  | 'specialTip'
  | 'luckyItem'
  | 'raw'
  | 'fallback';

export interface ReadingSentence {
  id: string;
  main: string;
  sub?: string;
  source: ReadingSentenceSource;
}

const MAX_SENTENCES = 7;
const MIN_SENTENCES = 2;
const MAX_MAIN_LENGTH = 64;

const RAW_TEXT_KEYS = [
  'mainMessage',
  'main_message',
  'oneLine',
  'one_line',
  'finalMessage',
  'final_message',
  'overallReading',
  'overall_reading',
  'content',
  'description',
  'guidance',
  'message',
] as const;

export function buildReadingSentences(
  payload: EmbeddedResultPayload,
  resultKind: ResultKind,
): ReadingSentence[] {
  const candidates: { text: string | undefined; source: ReadingSentenceSource; sub?: string }[] = [
    ...splitKoreanSentences(payload.summary).map(text => ({ text, source: 'summary' as const })),
    ...(payload.highlights ?? []).map(text => ({ text, source: 'highlight' as const })),
    ...(payload.recommendations ?? []).map(text => ({ text, source: 'recommendation' as const })),
    ...(payload.warnings ?? []).map(text => ({ text, source: 'warning' as const, sub: '주의할 흐름도 부드럽게 짚어볼게요.' })),
    { text: payload.specialTip, source: 'specialTip' as const },
    ...buildLuckyItemCandidates(payload.luckyItems),
    ...extractRawTextCandidates(payload.rawApiResponse),
  ];

  const unique = new Set<string>();
  const sentences: ReadingSentence[] = [];

  for (const candidate of candidates) {
    const main = normalizeMainText(candidate.text);
    if (!main) continue;
    const key = main.replace(/\s+/g, '');
    if (unique.has(key)) continue;
    unique.add(key);
    sentences.push({
      id: `${candidate.source}-${sentences.length}`,
      main,
      sub: candidate.sub,
      source: candidate.source,
    });
    if (sentences.length >= MAX_SENTENCES) break;
  }

  if (sentences.length >= MIN_SENTENCES) {
    return sentences;
  }

  return ensureFallbackSentences(sentences, payload, resultKind);
}

function splitKoreanSentences(value: string | undefined): string[] {
  const normalized = value?.replace(/\s+/g, ' ').trim();
  if (!normalized) return [];

  const matches = normalized.match(/[^.!?。！？]+[.!?。！？]?/g) ?? [normalized];
  return matches.map(text => text.trim()).filter(Boolean);
}

function normalizeMainText(value: string | undefined): string | undefined {
  const normalized = value
    ?.replace(/[\r\n\t]+/g, ' ')
    .replace(/\s+/g, ' ')
    .replace(/^[-•*\d.)\s]+/, '')
    .trim();

  if (!normalized) return undefined;
  if (normalized.length <= MAX_MAIN_LENGTH) return normalized;

  const sentence = splitKoreanSentences(normalized).find(part => part.length <= MAX_MAIN_LENGTH);
  if (sentence) return sentence;

  return `${normalized.slice(0, MAX_MAIN_LENGTH - 1).trim()}…`;
}

function buildLuckyItemCandidates(items: string[] | undefined): { text: string; source: 'luckyItem' }[] {
  const compactItems = (items ?? [])
    .map(item => item.trim())
    .filter(Boolean)
    .slice(0, 2);

  if (!compactItems.length) return [];

  return [{ text: `오늘의 행운 포인트는 ${compactItems.join(', ')}예요.`, source: 'luckyItem' }];
}

function extractRawTextCandidates(
  raw: Record<string, unknown> | undefined,
): { text: string; source: 'raw' }[] {
  if (!raw) return [];

  const unwrapped = unwrapRaw(raw);
  const texts: string[] = [];

  for (const key of RAW_TEXT_KEYS) {
    const value = unwrapped[key];
    if (typeof value === 'string') {
      texts.push(value);
    }
  }

  return texts.flatMap(text => splitKoreanSentences(text).map(sentence => ({ text: sentence, source: 'raw' as const })));
}

function unwrapRaw(raw: Record<string, unknown>): Record<string, unknown> {
  for (const key of ['data', 'fortune', 'result', 'payload']) {
    const value = raw[key];
    if (isRecord(value)) return value;
  }
  return raw;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}

function ensureFallbackSentences(
  existing: ReadingSentence[],
  payload: EmbeddedResultPayload,
  resultKind: ResultKind,
): ReadingSentence[] {
  const fallbackTexts = [
    normalizeMainText(payload.title) ?? resultKindToFallbackTitle(resultKind),
    normalizeMainText(payload.subtitle) ?? '하늘이가 읽은 흐름을 하나씩 정리해볼게요.',
    '자세한 내용은 이어서 전체 결과로 보여드릴게요.',
  ];

  const output = [...existing];
  for (const text of fallbackTexts) {
    if (!text) continue;
    if (output.some(sentence => sentence.main === text)) continue;
    output.push({ id: `fallback-${output.length}`, main: text, source: 'fallback' });
    if (output.length >= MIN_SENTENCES) break;
  }
  return output;
}

function resultKindToFallbackTitle(resultKind: ResultKind): string {
  switch (resultKind) {
    case 'love':
      return '오늘의 마음 흐름을 차분히 읽어볼게요.';
    case 'wealth':
      return '오늘의 돈 흐름을 조용히 짚어볼게요.';
    case 'health':
      return '오늘의 컨디션 흐름을 무리 없이 살펴볼게요.';
    default:
      return '하늘이가 읽은 흐름을 하나씩 보여드릴게요.';
  }
}
