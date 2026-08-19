'use client';

import { useState, type FormEvent } from 'react';

import { BirthDateField, BirthTimeChips, GenderChips } from '@/features/fortune/fields';
import { FailureNotice } from '@/features/fortune/result';
import { runFortune, type FortuneFailureKind } from '@/features/fortune/runner';

import { DailyResult } from './daily-result';
import type { DailyFortune, DailyFortuneEnvelope } from './types';

/** 리팩터 전과 같은 값. `/app/f/daily` 는 로그인 후 `/운세/오늘` 로 redirect 한다. */
const LOGIN_HREF = '/auth/login?next=%2Fapp%2Ff%2Fdaily';

type State =
  | { kind: 'idle' }
  | { kind: 'loading' }
  | { kind: 'done'; fortune: DailyFortune; cached: boolean }
  | { kind: 'failed'; failure: FortuneFailureKind; message: string };

export function DailyForm() {
  const [birthDate, setBirthDate] = useState('');
  const [birthTime, setBirthTime] = useState('');
  const [gender, setGender] = useState('');
  const [state, setState] = useState<State>({ kind: 'idle' });

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setState({ kind: 'loading' });

    // 게스트 진입/익명 세션/401·402 분류는 전부 runFortune 안에 있다.
    //
    // userId 는 보내지 않는다 — fortune-daily 는 body.userId 를 무시하고
    // JWT 에서만 파생한다 (index.ts 의 requirePaidFortuneCaller).
    //
    // `date` 도 보내지 않는다: 서버의 idempotency 키가 body 해시라서
    // (`_shared/fortune_charge.ts`, DEFAULT_OMIT_KEYS 에 date 없음) 타임스탬프를
    // 실으면 매 제출이 새 요청이 되어 중복 차감된다. 생략하면 서버가 KST 기준
    // 오늘 날짜를 쓰고, 같은 날 재제출은 캐시로 무료 재생된다.
    const result = await runFortune<DailyFortuneEnvelope>('daily', {
      birthDate,
      birthTime: birthTime || undefined,
      gender: gender || undefined,
    });

    if (!result.ok) {
      setState({ kind: 'failed', failure: result.kind, message: result.message });
      return;
    }

    const fortune = result.data.fortune;
    if (!fortune) {
      setState({
        kind: 'failed',
        failure: 'error',
        message: '운세 응답이 비어 있어요. 잠시 후 다시 시도해 주세요.',
      });
      return;
    }

    setState({ kind: 'done', fortune, cached: result.data.cached === true });
  }

  return (
    <div className="ondo-stack">
      <form className="ondo-stack" onSubmit={handleSubmit}>
        <BirthDateField onChange={setBirthDate} value={birthDate} />
        <BirthTimeChips onChange={setBirthTime} value={birthTime} />
        <GenderChips onChange={setGender} value={gender} />

        <button className="ondo-button" disabled={state.kind === 'loading' || !birthDate} type="submit">
          {state.kind === 'loading' ? '읽는 중…' : '오늘의 운세 보기'}
        </button>
      </form>

      {state.kind === 'failed' ? (
        <FailureNotice kind={state.failure} loginHref={LOGIN_HREF} message={state.message} />
      ) : null}

      {state.kind === 'done' ? <DailyResult cached={state.cached} fortune={state.fortune} /> : null}
    </div>
  );
}
