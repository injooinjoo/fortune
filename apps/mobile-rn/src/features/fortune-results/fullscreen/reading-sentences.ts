import type { EmbeddedResultPayload } from '../../chat-results/types';
import type { ResultKind } from '../types';

export type ReadingSentenceSource =
  | 'summary'
  | 'highlight'
  | 'recommendation'
  | 'warning'
  | 'specialTip'
  | 'luckyItem'
  | 'visual'
  | 'raw'
  | 'fallback';

export interface ReadingSentence {
  id: string;
  main: string;
  sub?: string;
  source: ReadingSentenceSource;
}

interface CandidateSentence {
  text: string | undefined;
  source: ReadingSentenceSource;
  sub?: string;
}

const MAX_SENTENCES = 7;
const MIN_SENTENCES = 2;
// 하늘이 fullscreen reading은 결과 카드의 핵심 요약본이다.
// 카드 텍스트를 그대로 길게 붙이는 게 아니라, 카드의 summary/highlight/warning/lucky/visual
// 단위를 한 장씩 넘겨보는 형태로 압축한다.
const MAX_MAIN_LENGTH = 86;
const MAX_SUB_LENGTH = 88;

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
  const candidates: CandidateSentence[] = [
    ...splitKoreanSentences(payload.summary).map(text => ({
      text,
      source: 'summary' as const,
      sub: sourceSubcopy('summary'),
    })),
    ...buildVisualCandidates(payload),
    ...(payload.highlights ?? []).map(text => ({
      text,
      source: 'highlight' as const,
      sub: sourceSubcopy('highlight'),
    })),
    ...(payload.recommendations ?? []).map(text => ({
      text,
      source: 'recommendation' as const,
      sub: sourceSubcopy('recommendation'),
    })),
    ...(payload.warnings ?? []).map(text => ({
      text,
      source: 'warning' as const,
      sub: sourceSubcopy('warning'),
    })),
    { text: payload.specialTip, source: 'specialTip' as const, sub: sourceSubcopy('specialTip') },
    ...buildLuckyItemCandidates(payload.luckyItems),
    ...extractRawTextCandidates(payload.rawApiResponse),
  ];

  const unique = new Set<string>();
  const sentences: ReadingSentence[] = [];

  for (const candidate of candidates) {
    const main = normalizeReadingText(candidate.text, MAX_MAIN_LENGTH);
    if (!main) continue;
    const key = main.replace(/\s+/g, '');
    if (unique.has(key)) continue;
    unique.add(key);
    sentences.push({
      id: `${candidate.source}-${sentences.length}`,
      main,
      sub: normalizeReadingText(candidate.sub, MAX_SUB_LENGTH),
      source: candidate.source,
    });
    if (sentences.length >= MAX_SENTENCES) break;
  }

  if (sentences.length >= MIN_SENTENCES) {
    return sentences;
  }

  return ensureFallbackSentences(sentences, payload, resultKind);
}

function buildVisualCandidates(payload: EmbeddedResultPayload): CandidateSentence[] {
  const candidates: CandidateSentence[] = [];

  if (payload.score != null) {
    candidates.push({
      text: `오늘의 종합 기운은 ${payload.score}점으로 보여요.`,
      source: 'visual',
      sub: '점수와 함께 빛/입자 효과로 먼저 보여줄 수 있어요.',
    });
  }

  const topMetric = pickTopMetric(payload.metrics);
  if (topMetric) {
    candidates.push({
      text: `${topMetric.label} 흐름이 ${topMetric.value}로 가장 먼저 눈에 들어와요.`,
      source: 'visual',
      sub: '메트릭 카드나 그래프 모션으로 강조할 수 있는 지점이에요.',
    });
  }

  if (payload.spread?.length) {
    candidates.push({
      text: `카드는 ${payload.spread.map(card => card.name).slice(0, 3).join(', ')} 흐름으로 펼쳐졌어요.`,
      source: 'visual',
      sub: '카드 이미지가 한 장씩 뒤집히는 효과로 연결할 수 있어요.',
    });
  }

  if (payload.pillars?.length) {
    candidates.push({
      text: '사주의 네 기둥이 오늘의 균형을 보여주고 있어요.',
      source: 'visual',
      sub: '기둥/오행 시각화가 들어갈 수 있는 요약 장면이에요.',
    });
  }

  if (payload.timeline?.length) {
    candidates.push({
      text: '시간대별 흐름은 한 번에 같지 않고, 올라오는 구간이 따로 보여요.',
      source: 'visual',
      sub: '라인 차트나 파동 모션으로 보여줄 수 있어요.',
    });
  }

  return candidates;
}

function buildLuckyItemCandidates(items: string[] | undefined): CandidateSentence[] {
  const compact = (items ?? [])
    .map(item => item.trim())
    .filter(Boolean)
    .slice(0, 2);

  if (!compact.length) return [];

  return [{
    text: `행운은 ${compact.join(', ')} 쪽에서 먼저 들어와요.`,
    source: 'luckyItem',
    sub: sourceSubcopy('luckyItem'),
  }];
}

function extractRawTextCandidates(raw: Record<string, unknown> | undefined): CandidateSentence[] {
  if (!raw) return [];

  const candidates: CandidateSentence[] = [];
  for (const key of RAW_TEXT_KEYS) {
    const value = raw[key];
    if (typeof value === 'string') {
      candidates.push({
        text: value,
        source: 'raw',
        sub: sourceSubcopy('raw'),
      });
    }
  }

  return candidates;
}

function ensureFallbackSentences(
  existing: ReadingSentence[],
  payload: EmbeddedResultPayload,
  resultKind: ResultKind,
): ReadingSentence[] {
  const output = [...existing];
  const fallbackTexts: CandidateSentence[] = [
    {
      text: payload.title || resultKindFallback(resultKind),
      source: 'fallback',
      sub: payload.subtitle,
    },
    {
      text: resultKindFallback(resultKind),
      source: 'fallback',
      sub: '결과 카드에서 가장 먼저 볼 핵심만 골랐어요.',
    },
  ];

  for (const candidate of fallbackTexts) {
    const main = normalizeReadingText(candidate.text, MAX_MAIN_LENGTH);
    if (!main) continue;
    if (output.some(sentence => sentence.main === main)) continue;
    output.push({
      id: `fallback-${output.length}`,
      main,
      sub: normalizeReadingText(candidate.sub, MAX_SUB_LENGTH),
      source: candidate.source,
    });
    if (output.length >= MIN_SENTENCES) break;
  }
  return output;
}

function splitKoreanSentences(value: string | undefined): string[] {
  const normalized = value?.replace(/\s+/g, ' ').trim();
  if (!normalized) return [];

  const matches = normalized.match(/[^.!?。！？]+[.!?。！？]?/g) ?? [normalized];
  return matches.map(text => text.trim()).filter(Boolean);
}

function normalizeReadingText(value: string | undefined, maxLength: number): string | undefined {
  const normalized = value
    ?.replace(/[\r\n\t]+/g, ' ')
    .replace(/\s+/g, ' ')
    .replace(/^[-•*\d.)\s]+/, '')
    .trim();

  if (!normalized) return undefined;
  if (normalized.length <= maxLength) return normalized;

  const sentence = splitKoreanSentences(normalized).find(part => part.length <= maxLength);
  if (sentence) return sentence;

  return `${normalized.slice(0, maxLength - 1).trim()}…`;
}

function pickTopMetric(metrics: EmbeddedResultPayload['metrics']) {
  return metrics
    ?.filter(metric => metric.value.trim().length > 0)
    .sort((left, right) => metricScore(right.value) - metricScore(left.value))[0];
}

function metricScore(value: string): number {
  const numeric = Number(value.replace(/[^0-9.-]/g, ''));
  return Number.isFinite(numeric) ? numeric : 0;
}

function sourceSubcopy(source: ReadingSentenceSource): string {
  switch (source) {
    case 'summary':
      return '결과 카드의 핵심 요약이에요.';
    case 'highlight':
      return '카드에서 가장 밝게 볼 포인트예요.';
    case 'recommendation':
      return '하늘이가 결과 카드에서 골라낸 행동 힌트예요.';
    case 'warning':
      return '카드 속 조심할 흐름도 먼저 짚어볼게요.';
    case 'specialTip':
      return '결과 카드의 마지막 팁이에요.';
    case 'luckyItem':
      return '이미지나 작은 오브제로도 보여줄 수 있는 행운 신호예요.';
    case 'visual':
      return '이미지/효과로 확장할 수 있는 요약 장면이에요.';
    case 'raw':
      return '서버 결과에서 내려온 세부 리딩이에요.';
    default:
      return '결과 카드에서 뽑은 요약이에요.';
  }
}

function resultKindFallback(resultKind: ResultKind): string {
  switch (resultKind) {
    case 'love':
      return '마음의 흐름은 천천히 확인할수록 더 정확해져요.';
    case 'wealth':
      return '돈의 흐름은 크게 벌리기보다 새는 곳을 먼저 보는 게 좋아요.';
    case 'health':
      return '몸의 신호는 작게 올 때 먼저 챙기는 게 가장 좋아요.';
    default:
      return '오늘의 운은 한 문장보다 몇 개의 신호로 나눠 보는 게 좋아요.';
  }
}
