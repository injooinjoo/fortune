'use client';

/**
 * 타로 입력 폼.
 *
 * 요청 계약 (`supabase/functions/fortune-tarot/index.ts`):
 *  - `selectedCards` 필수. 78장 덱 인덱스(0~77) 배열이거나
 *    `{ index, isReversed }` 객체 배열. 없으면 400 `필수 필드 누락: selectedCards`.
 *  - `spreadType` 은 single / threeCard / relationship / celticCross.
 *    모르는 값이면 서버가 threeCard 로 접는다. 카드 장수는 스프레드 위치 수에
 *    맞춰 순서대로 매핑되므로 뽑은 순서가 곧 위치 순서다.
 *  - `question` 이 비면 `purpose` 로 기본 질문을 만든다 → 질문은 선택 입력.
 *  - `clientChargeId` 는 `^[a-zA-Z0-9:_-]{12,120}$`. 이 함수는 repo 안에서 유일하게
 *    자체 토큰 차감(consume_token_atomic)을 하며 이 값이 idempotency 키가 된다.
 *    같은 값으로 두 번 오면 409 `duplicate_generation_request` 라서, 제출 때마다
 *    새로 만든다 (앱 `chat-results/edge-runtime.ts` 의 createClientChargeId 와 동일).
 */

import { useRef, useState, type FormEvent } from 'react';

import { ChipSelect, TextField, type ChipOption } from '@/features/fortune/fields';
import { FailureNotice } from '@/features/fortune/result';
import { runFortune, type FortuneFailureKind } from '@/features/fortune/runner';

import { TarotResult, type TarotEnvelope, type TarotReading } from './tarot-result';

const LOGIN_HREF = `/auth/login?next=${encodeURIComponent('/운세/타로')}`;

/** 셔플된 카드 더미. 12장 중에서 고르는 건 앱의 TarotDrawWidget 과 같은 수다. */
const SLOT_COUNT = 12;

/** value = 서버 spreadType, cards = 뽑아야 하는 장수 (SPREAD_POSITIONS 길이). */
const SPREADS = [
  { value: 'single', label: '원카드 (1장)', cards: 1 },
  { value: 'threeCard', label: '3카드 (3장)', cards: 3 },
] as const;

const SPREAD_OPTIONS: ChipOption[] = SPREADS.map((spread) => ({
  value: spread.value,
  label: spread.label,
}));

/** 서버 `normalizeQuestion` 이 인식하는 값. 질문을 안 써도 결이 잡히게 한다. */
const PURPOSE_OPTIONS: ChipOption[] = [
  { value: 'guidance', label: '지금 필요한 조언' },
  { value: 'love', label: '연애' },
  { value: 'career', label: '일·커리어' },
  { value: 'decision', label: '선택·결정' },
];

interface DrawnCard {
  index: number;
  isReversed: boolean;
}

/**
 * 슬롯 번호(1~12) → 78장 덱 인덱스.
 *
 * 슬롯 번호 자체를 시드로 쓰는 결정적 매핑이라 같은 자리를 고르면 같은 카드가
 * 나온다 (사용자 입장의 일관성). 앱 `edge-runtime.ts` 의
 * `drawTarotCardsFromSlots` 와 같은 규칙이라 웹/앱 결과가 어긋나지 않는다.
 */
function drawCardsFromSlots(slots: number[]): DrawnCard[] {
  const used = new Set<number>();
  const drawn: DrawnCard[] = [];

  for (const slot of slots) {
    const seed = (Math.imul(slot | 0, 2654435769) ^ 0x9e3779b9) >>> 0;
    let candidate = seed % 78;
    while (used.has(candidate)) {
      candidate = (candidate + 1) % 78;
    }
    used.add(candidate);
    drawn.push({ index: candidate, isReversed: ((seed >>> 16) & 1) === 1 });
  }

  return drawn;
}

/** 제출마다 새로 만든다 — 재사용하면 서버가 409 로 막는다. */
function createClientChargeId(): string {
  return `client:${Date.now().toString(36)}:${Math.random().toString(36).slice(2, 12)}`;
}

type State =
  | { kind: 'idle' }
  | { kind: 'loading' }
  | { kind: 'done'; reading: TarotReading }
  | { kind: 'failed'; failure: FortuneFailureKind; message: string };

/** 뒤집힌 카드 더미. 시각적으로는 전부 같고, 고른 "자리" 만 다르다. */
function CardSlots({
  slots,
  selected,
  onToggle,
  limit,
}: {
  slots: number[];
  selected: number[];
  onToggle: (slot: number) => void;
  limit: number;
}) {
  return (
    <fieldset style={{ border: 'none', margin: 0, padding: 0 }}>
      <legend className="ondo-label">{`카드 고르기 (${selected.length}/${limit})`}</legend>
      <div className="ondo-row">
        {slots.map((slot) => {
          const order = selected.indexOf(slot);
          return (
            <button
              aria-label={`${slot}번 카드`}
              aria-pressed={order >= 0}
              className="ondo-chip ondo-tarot-card-slot"
              key={slot}
              onClick={() => onToggle(slot)}
              type="button"
            >
              {order >= 0 ? `${order + 1}번째` : slot}
            </button>
          );
        })}
      </div>
      <p className="ondo-muted">뒤집힌 카드예요. 고른 순서대로 스프레드 자리에 놓입니다.</p>
    </fieldset>
  );
}

const SLOTS = Array.from({ length: SLOT_COUNT }, (_, index) => index + 1);

export function TarotForm() {
  const [spreadType, setSpreadType] = useState<string>('threeCard');
  const [purpose, setPurpose] = useState('guidance');
  const [question, setQuestion] = useState('');
  const [questionOpen, setQuestionOpen] = useState(false);
  const [selected, setSelected] = useState<number[]>([]);
  const [state, setState] = useState<State>({ kind: 'idle' });
  const questionTriggerRef = useRef<HTMLButtonElement>(null);

  const cardsNeeded = SPREADS.find((spread) => spread.value === spreadType)?.cards ?? 3;
  const ready = selected.length === cardsNeeded;

  function handleSpreadChange(value: string) {
    setSpreadType(value);
    const nextNeeded = SPREADS.find((spread) => spread.value === value)?.cards ?? 3;
    // 장수가 줄면 먼저 고른 카드만 남긴다 (선택을 통째로 날리지 않기).
    setSelected((current) => current.slice(0, nextNeeded));
  }

  function toggleSlot(slot: number) {
    setSelected((current) => {
      if (current.includes(slot)) return current.filter((entry) => entry !== slot);
      if (current.length >= cardsNeeded) return current;
      return [...current, slot];
    });
  }

  function focusQuestionInput() {
    requestAnimationFrame(() => {
      document.getElementById('tarot-question')?.focus();
    });
  }

  function openQuestion() {
    setQuestionOpen(true);
    focusQuestionInput();
  }

  function closeQuestion() {
    setQuestionOpen(false);
    requestAnimationFrame(() => questionTriggerRef.current?.focus());
  }

  function clearQuestion() {
    setQuestion('');
    focusQuestionInput();
  }

  const questionPreview = question.trim().length > 18
    ? `${question.trim().slice(0, 18)}…`
    : question.trim();

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!ready) return;
    setState({ kind: 'loading' });

    const result = await runFortune<TarotEnvelope>('tarot', {
      spreadType,
      purpose,
      question: question.trim() || undefined,
      selectedCards: drawCardsFromSlots(selected),
      clientChargeId: createClientChargeId(),
    });

    if (!result.ok) {
      setState({ kind: 'failed', failure: result.kind, message: result.message });
      return;
    }

    const reading = result.data.data;
    if (!reading) {
      setState({
        kind: 'failed',
        failure: 'error',
        message: '리딩 결과가 비어 있어요. 잠시 후 다시 시도해 주세요.',
      });
      return;
    }

    setState({ kind: 'done', reading });
  }

  return (
    <div className="ondo-stack">
      <form className="ondo-stack" onSubmit={handleSubmit}>
        <ChipSelect
          label="무엇이 궁금한가요?"
          onChange={setPurpose}
          options={PURPOSE_OPTIONS}
          value={purpose}
        />

        {!questionOpen ? (
          <button
            aria-controls="tarot-question-panel"
            aria-expanded="false"
            aria-label={questionPreview ? `질문 수정: ${question.trim()}` : undefined}
            className="ondo-tarot-question-trigger"
            onClick={openQuestion}
            ref={questionTriggerRef}
            type="button"
          >
            {questionPreview ? (
              <>
                <span className="ondo-tarot-question-trigger__preview">“{questionPreview}”</span>
                <span className="ondo-tarot-question-trigger__action">고치기</span>
              </>
            ) : (
              <>
                <span aria-hidden="true" className="ondo-tarot-question-trigger__plus">+</span>
                <span className="ondo-tarot-question-trigger__action">더 구체적으로 적을래요</span>
                <span className="ondo-tarot-question-trigger__optional">(선택)</span>
              </>
            )}
          </button>
        ) : null}

        <div className="ondo-tarot-question-panel" hidden={!questionOpen} id="tarot-question-panel">
          <TextField
            id="tarot-question"
            label="질문 (선택)"
            maxLength={120}
            onChange={setQuestion}
            placeholder="예: 지금 고민 중인 이직, 어떻게 흘러갈까요?"
            value={question}
          />
          <div className="ondo-tarot-question-panel__footer">
            <p className="ondo-field-hint">안 적어도 괜찮아요. 고른 결로 읽어드릴게요.</p>
            <div className="ondo-tarot-question-panel__actions">
              {question ? (
                <button
                  aria-label="질문 지우기"
                  className="ondo-tarot-question-text-button"
                  onClick={clearQuestion}
                  type="button"
                >
                  지우기
                </button>
              ) : null}
              <button
                aria-controls="tarot-question-panel"
                aria-expanded="true"
                aria-label="질문 접기"
                className="ondo-tarot-question-text-button"
                onClick={closeQuestion}
                type="button"
              >
                접기
              </button>
            </div>
          </div>
        </div>

        <ChipSelect
          label="스프레드"
          onChange={handleSpreadChange}
          options={SPREAD_OPTIONS}
          value={spreadType}
        />

        <CardSlots
          limit={cardsNeeded}
          onToggle={toggleSlot}
          selected={selected}
          slots={SLOTS}
        />

        <button className="ondo-button" disabled={state.kind === 'loading' || !ready} type="submit">
          {state.kind === 'loading' ? '카드를 읽는 중…' : '타로 리딩 보기'}
        </button>
      </form>

      {state.kind === 'failed' ? (
        <FailureNotice kind={state.failure} loginHref={LOGIN_HREF} message={state.message} />
      ) : null}

      {state.kind === 'done' ? <TarotResult reading={state.reading} /> : null}
    </div>
  );
}
