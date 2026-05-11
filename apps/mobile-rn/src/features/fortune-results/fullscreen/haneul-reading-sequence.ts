export interface HaneulReadingSentence {
  id: string;
  main: string;
  sub?: string;
}

interface ReadingPayload {
  title?: string;
  summary?: string;
  highlights?: string[];
  recommendations?: string[];
  specialTip?: string;
}

const MAX_SENTENCES = 5;

const FALLBACK_SENTENCES: HaneulReadingSentence[] = [
  {
    id: 'fallback-0',
    main: '오늘은 서두르지 않을수록 좋아요.',
    sub: '급하게 결정하기보다, 한 번 더 보는 쪽이 운을 살려요.',
  },
  {
    id: 'fallback-1',
    main: '사람 운은 오후에 더 열려요.',
    sub: '짧은 연락 하나가 생각보다 따뜻하게 돌아올 수 있어요.',
  },
  {
    id: 'fallback-2',
    main: '하늘이가 보기엔 충분히 괜찮은 하루예요.',
    sub: '무리하지 말고, 할 수 있는 만큼만 해도 좋아요.',
  },
];

const KOREAN_SENTENCE_END_RE = /[가-힣](요|다|죠|네|함|됨|음|임|봄|습니다|봅니다|세요|예요)\./g;

function cleanText(value: unknown): string | undefined {
  if (typeof value !== 'string') return undefined;
  const normalized = value.replace(/\s+/g, ' ').trim();
  return normalized.length > 0 ? normalized : undefined;
}

function findFirstSentenceEnd(text: string): number {
  const punctuationCandidates = ['. ', '! ', '? ', '。', '！', '？']
    .map((marker) => text.indexOf(marker))
    .filter((index) => index >= 0)
    .map((index) => index + 1);

  const koreanCandidates: number[] = [];
  KOREAN_SENTENCE_END_RE.lastIndex = 0;
  let match = KOREAN_SENTENCE_END_RE.exec(text);
  while (match) {
    koreanCandidates.push(match.index + match[0].length);
    match = KOREAN_SENTENCE_END_RE.exec(text);
  }

  const candidates = [...punctuationCandidates, ...koreanCandidates].filter(
    (index) => index > 0 && index < text.length,
  );

  return candidates.length ? Math.min(...candidates) : -1;
}

function splitIntoMainAndSub(text: string): Omit<HaneulReadingSentence, 'id'> {
  const endIndex = findFirstSentenceEnd(text);
  if (endIndex > 0) {
    const main = cleanText(text.slice(0, endIndex));
    const sub = cleanText(text.slice(endIndex));
    if (main && sub) return { main, sub };
  }

  return { main: text };
}

export function buildHaneulReadingSentences(
  payload: Partial<ReadingPayload>,
): HaneulReadingSentence[] {
  const candidates = [
    cleanText(payload.summary),
    ...(payload.highlights ?? []).map(cleanText),
    ...(payload.recommendations ?? []).map(cleanText),
    cleanText(payload.specialTip),
  ].filter((text): text is string => Boolean(text));

  const sentences = candidates
    .map(splitIntoMainAndSub)
    .filter((sentence) => sentence.main.length > 0)
    .slice(0, MAX_SENTENCES)
    .map((sentence, index) => ({
      id: `reading-${index}`,
      ...sentence,
    }));

  if (sentences.length > 0) return sentences;

  const title = cleanText(payload.title);
  if (title) {
    return [
      { id: 'reading-0', main: title },
      ...FALLBACK_SENTENCES.slice(0, 2).map((sentence, index) => ({
        ...sentence,
        id: `reading-${index + 1}`,
      })),
    ];
  }

  return FALLBACK_SENTENCES.map((sentence, index) => ({
    ...sentence,
    id: `reading-${index}`,
  }));
}
