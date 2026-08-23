'use client';

import { useState, type FormEvent } from 'react';

import { BirthDateField } from '@/features/fortune/fields';
import { FailureNotice } from '@/features/fortune/result';
import { runFortune, type FortuneFailureKind } from '@/features/fortune/runner';

import {
  BiorhythmResult,
  type BiorhythmEnvelope,
  type BiorhythmFortune,
} from './biorhythm-result';

const LOGIN_HREF = `/auth/login?next=${encodeURIComponent('/운세/바이오리듬')}`;

const EMPTY_RESPONSE_MESSAGE = '바이오리듬 응답이 비어 있어요. 잠시 후 다시 시도해 주세요.';

/**
 * 프롬프트에 `이름: ${name}` 으로 그대로 들어가는 값. 서버에 기본값이 없어서
 * (zodiac 과 달리 '회원님' 치환이 없다) 생략하면 프롬프트에 'undefined' 가
 * 박힌다. 입력을 늘리는 대신 여기서 고정 호칭을 보낸다.
 */
const DEFAULT_NAME = '회원님';

type State =
  | { kind: 'idle' }
  | { kind: 'loading' }
  | { kind: 'done'; fortune: BiorhythmFortune }
  | { kind: 'failed'; failure: FortuneFailureKind; message: string };

export function BiorhythmForm() {
  const [birthDate, setBirthDate] = useState('');
  const [state, setState] = useState<State>({ kind: 'idle' });

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (birthDate.length === 0) return;

    setState({ kind: 'loading' });

    // `targetDate` 는 보내지 않는다 — 서버가 없으면 오늘로 채우고, 실어 보내면
    // 매 제출마다 body 해시(idempotency 키)가 바뀌어 재과금된다.
    const result = await runFortune<BiorhythmEnvelope>('biorhythm', {
      birthDate,
      name: DEFAULT_NAME,
    });

    if (!result.ok) {
      setState({ kind: 'failed', failure: result.kind, message: result.message });
      return;
    }

    const fortune = result.data.data;
    if (!fortune) {
      setState({ kind: 'failed', failure: 'error', message: EMPTY_RESPONSE_MESSAGE });
      return;
    }

    setState({ kind: 'done', fortune });
  }

  return (
    <div className="ondo-stack">
      <form className="ondo-stack" onSubmit={handleSubmit}>
        <BirthDateField onChange={setBirthDate} value={birthDate} />

        <button
          className="ondo-button"
          disabled={state.kind === 'loading' || birthDate.length === 0}
          type="submit"
        >
          {state.kind === 'loading' ? '계산 중…' : '오늘의 바이오리듬 보기'}
        </button>
      </form>

      {state.kind === 'failed' ? (
        <FailureNotice kind={state.failure} loginHref={LOGIN_HREF} message={state.message} />
      ) : null}

      {state.kind === 'done' ? <BiorhythmResult fortune={state.fortune} /> : null}
    </div>
  );
}
