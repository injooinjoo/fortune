export interface FortuneSummaryHighlight {
  label: string;
  value: string;
}

export interface ProjectedFortuneSummary {
  highlights: FortuneSummaryHighlight[];
  score: number | null;
}

const BLOCKED_KEY = /(system|prompt|instruction|secret|token|api.?key|credential|password|control|approval|action)/i;
const DISPLAY_KEY = /(summary|message|advice|description|overall|interpretation|guidance|content|title|result|recommend|caution|lucky)/i;

function cleanLabel(key: string): string {
  return key.replace(/[_-]+/g, ' ').trim().slice(0, 40);
}

function cleanValue(value: unknown): string | null {
  if (typeof value === 'string') {
    const text = value.replace(/[\u0000-\u001f\u007f]/g, ' ').replace(/\s+/g, ' ').trim();
    return text.length > 0 ? text.slice(0, 240) : null;
  }
  if (typeof value === 'number' && Number.isFinite(value)) return String(value);
  if (typeof value === 'boolean') return value ? '예' : '아니요';
  return null;
}

export function projectFortuneSummary(input: unknown): ProjectedFortuneSummary {
  const highlights: FortuneSummaryHighlight[] = [];
  let score: number | null = null;
  const stack: Array<{ value: unknown; depth: number }> = [{ value: input, depth: 0 }];
  let visited = 0;

  while (stack.length > 0 && highlights.length < 8 && visited < 120) {
    const current = stack.pop();
    if (!current) break;
    visited += 1;
    if (current.depth > 4 || current.value === null || typeof current.value !== 'object') continue;

    if (Array.isArray(current.value)) {
      for (const entry of current.value.slice(0, 8).reverse()) {
        stack.push({ value: entry, depth: current.depth + 1 });
      }
      continue;
    }

    const entries = Object.entries(current.value as Record<string, unknown>);
    for (const [key, value] of entries.reverse()) {
      if (BLOCKED_KEY.test(key)) continue;
      if (/score/i.test(key) && typeof value === 'number' && Number.isFinite(value) && value >= 0 && value <= 100) {
        score ??= Math.round(value);
      }
      const primitive = cleanValue(value);
      if (DISPLAY_KEY.test(key) && primitive) {
        highlights.push({ label: cleanLabel(key), value: primitive });
      } else if (Array.isArray(value) && DISPLAY_KEY.test(key)) {
        for (const item of value.slice(0, 3)) {
          const text = cleanValue(item);
          if (text) highlights.push({ label: cleanLabel(key), value: text });
        }
      }
      if (value && typeof value === 'object') stack.push({ value, depth: current.depth + 1 });
      if (highlights.length >= 8) break;
    }
  }

  return { highlights, score };
}

function stableValue(value: unknown): unknown {
  if (Array.isArray(value)) return value.map(stableValue);
  if (value && typeof value === 'object') {
    return Object.fromEntries(
      Object.entries(value as Record<string, unknown>)
        .sort(([left], [right]) => left.localeCompare(right))
        .map(([key, entry]) => [key, stableValue(entry)]),
    );
  }
  return value;
}

export function stableFortuneFingerprintSource(
  fortuneType: string,
  body: Record<string, unknown>,
  day: string,
): string {
  return JSON.stringify({ body: stableValue(body), day, fortuneType });
}

const TITLES: Record<string, string> = {
  daily: '오늘의 운세',
  tarot: '타로 운세',
  love: '연애운',
  compatibility: '궁합 운세',
  'traditional-saju': '사주 운세',
  dream: '꿈 해몽',
  biorhythm: '바이오리듬',
  mbti: 'MBTI 운세',
  'zodiac-animal': '띠별 운세',
  career: '직업운',
  wealth: '재물운',
  health: '건강운',
  'lucky-items': '행운 아이템',
};

export function fortuneTitle(fortuneType: string): string {
  return TITLES[fortuneType] ?? '온도 운세';
}
