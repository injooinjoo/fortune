'use client';

import { useState, type FormEvent } from 'react';

import { ChipSelect } from '@/features/fortune/fields';
import { FailureNotice } from '@/features/fortune/result';
import { runFortune, type FortuneFailureKind } from '@/features/fortune/runner';

import { MultiChipSelect } from './multi-chips';
import { readCached, readFortunePayload } from './shared';
import {
  WEALTH_CONCERN_OPTIONS,
  WEALTH_EXPENSE_OPTIONS,
  WEALTH_GOAL_OPTIONS,
  WEALTH_INCOME_OPTIONS,
  WEALTH_INTEREST_OPTIONS,
  WEALTH_RISK_OPTIONS,
  WEALTH_URGENCY_OPTIONS,
  WealthResult,
  type WealthFortune,
} from './wealth-result';

const LOGIN_HREF = `/auth/login?next=${encodeURIComponent('/운세/재물')}`;

/**
 * 관심 분야 상한. `fortune-wealth` 는 고른 분야마다 JSON 스키마 블록을
 * 프롬프트에 덧붙이는데 (index.ts:429~437) maxTokens 가 4096 이라
 * 많이 고를수록 응답이 잘릴 위험이 커진다.
 */
const MAX_INTERESTS = 2;

type State =
  | { kind: 'idle' }
  | { kind: 'loading' }
  | { kind: 'done'; fortune: WealthFortune; cached: boolean }
  | { kind: 'failed'; failure: FortuneFailureKind; message: string };

export function WealthForm() {
  // 목표/고민만 직접 고르게 하고 나머지는 기본값을 미리 눌러둔다.
  // Edge Function 이 income/expense/risk/urgency 를 프롬프트에 그대로 넣기
  // 때문에 (index.ts:365~373) 비워 보내면 "수입 상태: undefined" 가 되고,
  // 그렇다고 몰래 채워 보내면 사용자가 고치지 못한다. 그래서 전부 화면에
  // 두되 흔한 값을 선택해 둔다 — 제출까지 두 번만 누르면 된다.
  const [goal, setGoal] = useState('');
  const [concern, setConcern] = useState('');
  const [income, setIncome] = useState('stable');
  const [expense, setExpense] = useState('balanced');
  const [risk, setRisk] = useState('balanced');
  const [urgency, setUrgency] = useState('thisYear');
  const [interests, setInterests] = useState<string[]>([]);
  const [state, setState] = useState<State>({ kind: 'idle' });

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setState({ kind: 'loading' });

    // userId 는 보내지 않는다 — 배포본/신버전 모두 JWT 에서만 파생한다
    // (index.ts:196 / 211). userName 도 생략하면 서버 기본값 '회원' 이 쓰인다.
    // 날짜/난수도 넣지 않는다: 새 서버의 idempotency 키가 body 해시라서
    // 제출마다 달라지는 값을 실으면 같은 질문도 매번 새로 과금된다.
    const result = await runFortune<unknown>('wealth', {
      goal,
      concern,
      income,
      expense,
      risk,
      urgency,
      interests,
    });

    if (!result.ok) {
      setState({ kind: 'failed', failure: result.kind, message: result.message });
      return;
    }

    // 캐시/코호트 경로는 `{ fortune }`, LLM 경로는 `{ success, data }`.
    const fortune = readFortunePayload<WealthFortune>(result.data);
    if (!fortune) {
      setState({
        kind: 'failed',
        failure: 'error',
        message: '운세 응답이 비어 있어요. 잠시 후 다시 시도해 주세요.',
      });
      return;
    }

    setState({ kind: 'done', cached: readCached(result.data), fortune });
  }

  return (
    <div className="ondo-stack">
      <form className="ondo-stack" onSubmit={handleSubmit}>
        <ChipSelect
          label="재물 목표"
          onChange={setGoal}
          options={WEALTH_GOAL_OPTIONS}
          value={goal}
        />
        <ChipSelect
          label="가장 큰 고민"
          onChange={setConcern}
          options={WEALTH_CONCERN_OPTIONS}
          value={concern}
        />
        <MultiChipSelect
          label={`관심 분야 (선택 · 최대 ${MAX_INTERESTS}개)`}
          max={MAX_INTERESTS}
          onChange={setInterests}
          options={WEALTH_INTEREST_OPTIONS}
          values={interests}
        />
        <ChipSelect
          label="투자 성향"
          onChange={setRisk}
          options={WEALTH_RISK_OPTIONS}
          value={risk}
        />
        <ChipSelect
          label="수입 상태"
          onChange={setIncome}
          options={WEALTH_INCOME_OPTIONS}
          value={income}
        />
        <ChipSelect
          label="지출 패턴"
          onChange={setExpense}
          options={WEALTH_EXPENSE_OPTIONS}
          value={expense}
        />
        <ChipSelect
          label="시급성"
          onChange={setUrgency}
          options={WEALTH_URGENCY_OPTIONS}
          value={urgency}
        />

        <button
          className="ondo-button"
          disabled={state.kind === 'loading' || !goal || !concern}
          type="submit"
        >
          {state.kind === 'loading' ? '읽는 중…' : '재물운 보기'}
        </button>
      </form>

      {state.kind === 'failed' ? (
        <FailureNotice kind={state.failure} loginHref={LOGIN_HREF} message={state.message} />
      ) : null}

      {state.kind === 'done' ? (
        <WealthResult cached={state.cached} fortune={state.fortune} />
      ) : null}
    </div>
  );
}
