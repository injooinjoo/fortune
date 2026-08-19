'use client';

import { useState, type FormEvent } from 'react';

import { TextArea } from '@/features/fortune/fields';
import { FailureNotice } from '@/features/fortune/result';
import { runFortune, type FortuneFailureKind } from '@/features/fortune/runner';

import { DreamResult, type DreamEnvelope, type DreamFortune } from './dream-result';

const LOGIN_HREF = `/auth/login?next=${encodeURIComponent('/운세/꿈해몽')}`;

/** 프롬프트에 그대로 들어가는 값이라 상한을 둔다. 서버에는 별도 상한이 없다. */
const MAX_DREAM_LENGTH = 600;

const EMPTY_RESPONSE_MESSAGE = '해몽 결과가 비어 있어요. 잠시 후 다시 시도해 주세요.';

type State =
  | { kind: 'idle' }
  | { kind: 'loading' }
  | { kind: 'done'; fortune: DreamFortune }
  | { kind: 'failed'; failure: FortuneFailureKind; message: string };

export function DreamForm() {
  const [dream, setDream] = useState('');
  const [state, setState] = useState<State>({ kind: 'idle' });

  const trimmed = dream.trim();

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (trimmed.length === 0) return;

    setState({ kind: 'loading' });

    // 보내는 필드는 `dream` 하나다.
    //
    // - `date` 는 보내지 않는다: 서버 idempotency 키가 body 해시라서 날짜를 실으면
    //   같은 꿈을 다시 물어도 매번 새 요청(=재과금)이 된다. 생략하면 서버가 채운다.
    // - `inputType` 도 생략한다 ('text' 가 기본값이고 결과 문구에만 쓰인다).
    // - `dreamEmotion` 은 프롬프트에 안 들어가고 cohort 해시에만 쓰여서
    //   입력을 하나 더 받을 값어치가 없다.
    const result = await runFortune<DreamEnvelope>('dream', { dream: trimmed });

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
        <TextArea
          id="dream"
          label="어떤 꿈이었나요"
          maxLength={MAX_DREAM_LENGTH}
          onChange={setDream}
          placeholder="예: 높은 건물 옥상에서 아래를 내려다보다가 갑자기 하늘을 날았어요."
          required
          rows={6}
          value={dream}
        />

        <button
          className="ondo-button"
          disabled={state.kind === 'loading' || trimmed.length === 0}
          type="submit"
        >
          {state.kind === 'loading' ? '읽는 중…' : '꿈 풀이 보기'}
        </button>
      </form>

      {state.kind === 'failed' ? (
        <FailureNotice kind={state.failure} loginHref={LOGIN_HREF} message={state.message} />
      ) : null}

      {state.kind === 'done' ? <DreamResult fortune={state.fortune} /> : null}
    </div>
  );
}
