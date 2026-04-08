import type { FortuneTypeId } from '@fortune/product-contracts';

export type TarotPurpose = 'guidance' | 'love' | 'career' | 'decision';

export type TarotSpreadType = 'single' | 'threeCard' | 'relationship' | 'celticCross';

export interface TarotSelectedCard {
  index: number;
  isReversed?: boolean;
}

export interface TarotDeckSelectionContext {
  deckId: string;
  purpose?: TarotPurpose | null;
  questionText?: string | null;
  selectedCards: readonly TarotSelectedCard[];
  extraAnswers?: Record<string, unknown>;
}

export interface TarotSelectionPayload {
  fortuneType: FortuneTypeId;
  deckId: string;
  deck: string;
  purpose: TarotPurpose;
  questionText: string;
  question: string;
  spreadType: TarotSpreadType;
  selectedCards: Array<{ index: number; isReversed: boolean }>;
  selectedCardIndices: number[];
  cardCount: number;
  displayText: string;
  tarotSelection: {
    deck: string;
    deckId: string;
    purpose: TarotPurpose;
    questionText: string;
    question: string;
    spreadType: TarotSpreadType;
    selectedCards: Array<{ index: number; isReversed: boolean }>;
    selectedCardIndices: number[];
    cardCount: number;
    displayText: string;
  };
  answers: {
    tarotSelection: {
      deck: string;
      deckId: string;
      purpose: TarotPurpose;
      questionText: string;
      question: string;
      spreadType: TarotSpreadType;
      selectedCards: Array<{ index: number; isReversed: boolean }>;
      selectedCardIndices: number[];
      cardCount: number;
      displayText: string;
    };
    [key: string]: unknown;
  };
  [key: string]: unknown;
}

const tarotPurposeToSpreadType: Record<TarotPurpose, TarotSpreadType> = {
  guidance: 'threeCard',
  love: 'relationship',
  career: 'threeCard',
  decision: 'threeCard',
};

const tarotPurposeToQuestion: Record<TarotPurpose, string> = {
  guidance: '지금 제게 필요한 조언이 궁금해요.',
  love: '연애와 관계의 흐름이 궁금해요.',
  career: '일과 커리어의 방향이 궁금해요.',
  decision: '지금 앞에 놓인 선택의 흐름이 궁금해요.',
};

const tarotPositionNames: Record<TarotSpreadType, readonly string[]> = {
  single: ['핵심 메시지'],
  threeCard: ['과거', '현재', '미래'],
  relationship: ['나의 마음', '상대의 마음', '과거의 연결', '현재 관계', '미래 전망'],
  celticCross: [
    '현재 상황',
    '도전',
    '먼 과거',
    '최근 과거',
    '가능한 미래',
    '가까운 미래',
    '당신의 태도',
    '외부 영향',
    '희망과 두려움',
    '최종 결과',
  ],
};

export function resolveTarotSpreadType(purpose?: TarotPurpose | null): TarotSpreadType {
  if (!purpose) {
    return tarotPurposeToSpreadType.guidance;
  }

  return tarotPurposeToSpreadType[purpose] ?? tarotPurposeToSpreadType.guidance;
}

export function resolveTarotCardCount(purpose?: TarotPurpose | null): number {
  return resolveTarotSpreadType(purpose) === 'relationship' ? 5 : 3;
}

export function getTarotPositionNames(
  purpose?: TarotPurpose | null,
): readonly string[] {
  return tarotPositionNames[resolveTarotSpreadType(purpose)];
}

export function buildTarotQuestion(
  purpose: TarotPurpose | null | undefined,
  questionText?: string | null,
): string {
  const trimmed = questionText?.trim();
  if (trimmed) {
    return trimmed;
  }

  if (!purpose) {
    return tarotPurposeToQuestion.guidance;
  }

  return tarotPurposeToQuestion[purpose] ?? tarotPurposeToQuestion.guidance;
}

export function normalizeTarotSelectedCards(
  selectedCards: readonly (TarotSelectedCard | number | null | undefined)[],
): Array<{ index: number; isReversed: boolean }> {
  return selectedCards
    .map((card) => {
      if (typeof card === 'number' && Number.isFinite(card)) {
        return { index: Math.trunc(card), isReversed: false };
      }

      if (card && typeof card === 'object') {
        const rawIndex = card.index;
        if (!Number.isFinite(rawIndex)) {
          return null;
        }

        return {
          index: Math.trunc(rawIndex),
          isReversed: card.isReversed === true,
        };
      }

      return null;
    })
    .filter(
      (card): card is { index: number; isReversed: boolean } =>
        card !== null && card.index >= 0,
    );
}

export function buildTarotSelectionPayload(
  context: TarotDeckSelectionContext,
): TarotSelectionPayload {
  const purpose = context.purpose ?? 'guidance';
  const spreadType = resolveTarotSpreadType(purpose);
  const question = buildTarotQuestion(purpose, context.questionText);
  const normalizedCards = normalizeTarotSelectedCards(context.selectedCards);
  const selectedCardIndices = normalizedCards.map((card) => card.index);
  const cardCount = normalizedCards.length;
  const displayText = `🃏 ${cardCount}장 선택 완료 · ${
    spreadType === 'relationship' ? '관계 스프레드' : '3카드 스프레드'
  }`;

  const tarotSelection = {
    deck: context.deckId,
    deckId: context.deckId,
    purpose,
    questionText: context.questionText?.trim() ?? '',
    question,
    spreadType,
    selectedCards: normalizedCards,
    selectedCardIndices,
    cardCount,
    displayText,
  };

  return {
    fortuneType: 'tarot',
    deckId: context.deckId,
    deck: context.deckId,
    purpose,
    questionText: context.questionText?.trim() ?? '',
    question,
    spreadType,
    selectedCards: normalizedCards,
    selectedCardIndices,
    cardCount,
    displayText,
    tarotSelection,
    answers: {
      ...(context.extraAnswers ?? {}),
      deckId: context.deckId,
      purpose,
      questionText: context.questionText?.trim() ?? '',
      question,
      deck: context.deckId,
      spreadType,
      selectedCards: normalizedCards,
      selectedCardIndices,
      tarotSelection,
    },
  };
}

export function normalizeTarotRequestBody(
  raw: Record<string, unknown>,
): TarotSelectionPayload {
  const deckId =
    typeof raw.deckId === 'string' && raw.deckId.trim().length > 0
      ? raw.deckId.trim()
      : typeof raw.deck === 'string' && raw.deck.trim().length > 0
        ? raw.deck.trim()
        : 'rider_waite';
  const purpose =
    raw.purpose === 'love' ||
    raw.purpose === 'career' ||
    raw.purpose === 'decision' ||
    raw.purpose === 'guidance'
      ? raw.purpose
      : 'guidance';
  const questionText =
    typeof raw.questionText === 'string' ? raw.questionText : '';
  const spreadType = resolveTarotSpreadType(purpose);
  const nestedTarotSelection =
    isPlainObject(raw.tarotSelection) ? raw.tarotSelection : {};
  const selectedCards = normalizeTarotSelectedCards(
    [
      ...(Array.isArray(raw.selectedCards) ? raw.selectedCards : []),
      ...(Array.isArray(nestedTarotSelection.selectedCards)
        ? nestedTarotSelection.selectedCards
        : []),
      ...(Array.isArray(raw.selectedCardIndices) ? raw.selectedCardIndices : []),
      ...(Array.isArray(nestedTarotSelection.selectedCardIndices)
        ? nestedTarotSelection.selectedCardIndices
        : []),
    ] as Array<TarotSelectedCard | number | null | undefined>,
  );

  return buildTarotSelectionPayload({
    deckId,
    purpose,
    questionText,
    selectedCards,
    extraAnswers: isPlainObject(raw.answers) ? raw.answers : undefined,
  });
}

function isPlainObject(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}
