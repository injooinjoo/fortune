'use client';

import { useState, type FormEvent } from 'react';

import { ChipSelect, type ChipOption } from '@/features/fortune/fields';
import { FailureNotice } from '@/features/fortune/result';
import { runFortune, type FortuneFailureKind } from '@/features/fortune/runner';

import { MbtiResult, type MbtiEnvelope, type MbtiFortune } from './mbti-result';
import { MBTI_TYPES, findMbtiType } from './mbti-types';

const EMPTY_RESPONSE_MESSAGE = 'MBTI 운세 응답이 비어 있어요. 잠시 후 다시 시도해 주세요.';

const OPTIONS: ReadonlyArray<ChipOption> = MBTI_TYPES.map((type) => ({
  value: type.id,
  label: type.id,
}));

/**
 * 존재 검증만 통과시키기 위한 고정값.
 *
 * Edge Function 은 `!mbti || !name || !birthDate` 로 세 값이 **있는지만** 보고
 * (`fortune-mbti/index.ts` 의 400 분기), 그 뒤로 name/birthDate 를 한 번도 쓰지
 * 않는다 — 결과는 오늘 날짜의 전역 8차원 캐시와 mbti 문자열로만 만들어진다.
 * 그래서 웹은 입력을 MBTI 하나로 줄이고 나머지 둘은 여기 고정값을 보낸다.
 * 값이 고정이라 서버의 body 해시(idempotency 키)도 흔들리지 않는다.
 */
const PRESENCE_ONLY_FIELDS = { name: '회원님', birthDate: '2000-01-01' } as const;

type State =
  | { kind: 'idle' }
  | { kind: 'loading' }
  | { kind: 'done'; mbti: string; fortune: MbtiFortune }
  | { kind: 'failed'; failure: FortuneFailureKind; message: string };

function loginHref(mbti: string | undefined): string {
  const path = mbti ? `/운세/엠비티아이/${mbti}` : '/운세/엠비티아이';
  return `/auth/login?next=${encodeURIComponent(path)}`;
}

/**
 * @param initialMbti `/운세/엠비티아이/INTJ` 같은 하위 경로에서 미리 고른 유형.
 *                    목록 페이지에서는 비워 둔다.
 *
 * 하위 경로에서는 칩 선택을 숨긴다 — 제목이 "INTJ 오늘의 운세" 인데 칩으로 다른
 * 유형을 고를 수 있으면 제목과 결과가 어긋난다. 전환은 "다른 유형 보기" 링크로.
 */
export function MbtiForm({ initialMbti }: { initialMbti?: string }) {
  const [mbti, setMbti] = useState(initialMbti ?? '');
  const [state, setState] = useState<State>({ kind: 'idle' });

  const locked = findMbtiType(initialMbti ?? '') !== undefined;

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    const type = findMbtiType(mbti);
    if (!type) return;

    setState({ kind: 'loading' });

    const result = await runFortune<MbtiEnvelope>('mbti', {
      mbti: type.id,
      ...PRESENCE_ONLY_FIELDS,
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

    setState({ kind: 'done', mbti: type.id, fortune });
  }

  return (
    <div className="ondo-stack">
      <form className="ondo-stack" onSubmit={handleSubmit}>
        {locked ? null : (
          <ChipSelect label="MBTI 유형" onChange={setMbti} options={OPTIONS} value={mbti} />
        )}

        <button
          className="ondo-button"
          disabled={state.kind === 'loading' || mbti.length === 0}
          type="submit"
        >
          {state.kind === 'loading'
            ? '읽는 중…'
            : locked
              ? `${mbti} 오늘의 운세 보기`
              : '오늘의 MBTI 운세 보기'}
        </button>
      </form>

      {state.kind === 'failed' ? (
        <FailureNotice
          kind={state.failure}
          loginHref={loginHref(initialMbti)}
          message={state.message}
        />
      ) : null}

      {state.kind === 'done' ? (
        <MbtiResult fortune={state.fortune} mbti={state.mbti} />
      ) : null}
    </div>
  );
}
