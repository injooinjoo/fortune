'use client';

import { useState, type FormEvent } from 'react';

import { BirthDateField, BirthTimeChips, ChipSelect } from '@/features/fortune/fields';
import { FailureNotice } from '@/features/fortune/result';
import { runFortune, type FortuneFailureKind } from '@/features/fortune/runner';

import {
  LUCKY_CATEGORY_OPTIONS,
  LuckyItemsResult,
  type LuckyItemsFortune,
} from './lucky-items-result';
import { readFortunePayload } from './shared';

const LOGIN_HREF = `/auth/login?next=${encodeURIComponent('/운세/행운아이템')}`;

/**
 * 이름은 받지 않고 중립 호칭을 고정으로 보낸다.
 *
 * 이 함수는 생성 결과를 코호트 풀에 그대로 저장하고 (index.ts:529), 재사용할
 * 때는 `{{userName}}` 같은 플레이스홀더만 치환한다
 * (`_shared/cohort/index.ts:619`). 프롬프트가 제목을 "OO님의 오늘 …" 로
 * 만들게 되어 있어서, 실명을 보내면 그 실명이 그대로 풀에 박히고 같은
 * 카테고리를 고른 다른 사용자에게 노출된다. 코호트 키가 카테고리 하나뿐이라
 * (index.ts:216) 노출 범위도 넓다.
 *
 * 비워 보내면 프롬프트/제목에 "undefined님" 이 박히므로 생략도 답이 아니다.
 */
const NEUTRAL_NAME = '회원';

type State =
  | { kind: 'idle' }
  | { kind: 'loading' }
  | { kind: 'done'; fortune: LuckyItemsFortune }
  | { kind: 'failed'; failure: FortuneFailureKind; message: string };

export function LuckyItemsForm() {
  const [birthDate, setBirthDate] = useState('');
  const [birthTime, setBirthTime] = useState('');
  const [category, setCategory] = useState('fashion');
  const [state, setState] = useState<State>({ kind: 'idle' });

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setState({ kind: 'loading' });

    // 카테고리는 `interests` 배열의 첫 값으로 읽는다 (index.ts:264).
    // 날짜/난수는 싣지 않는다 — 서버가 오늘 날짜를 직접 만들고(index.ts:181),
    // body 해시가 idempotency 키라 매번 달라지면 같은 질문도 새로 과금된다.
    const result = await runFortune<unknown>('lucky-items', {
      name: NEUTRAL_NAME,
      birthDate,
      birthTime: birthTime || undefined,
      interests: [category],
    });

    if (!result.ok) {
      setState({ kind: 'failed', failure: result.kind, message: result.message });
      return;
    }

    const fortune = readFortunePayload<LuckyItemsFortune>(result.data);
    if (!fortune) {
      setState({
        kind: 'failed',
        failure: 'error',
        message: '운세 응답이 비어 있어요. 잠시 후 다시 시도해 주세요.',
      });
      return;
    }

    setState({ kind: 'done', fortune });
  }

  return (
    <div className="ondo-stack">
      <form className="ondo-stack" onSubmit={handleSubmit}>
        <BirthDateField id="lucky-birth-date" onChange={setBirthDate} value={birthDate} />
        <BirthTimeChips onChange={setBirthTime} value={birthTime} />
        <ChipSelect
          label="어떤 쪽 아이템이 궁금하세요?"
          onChange={setCategory}
          options={LUCKY_CATEGORY_OPTIONS}
          value={category}
        />

        <button className="ondo-button" disabled={state.kind === 'loading' || !birthDate} type="submit">
          {state.kind === 'loading' ? '읽는 중…' : '행운 아이템 보기'}
        </button>
      </form>

      {state.kind === 'failed' ? (
        <FailureNotice kind={state.failure} loginHref={LOGIN_HREF} message={state.message} />
      ) : null}

      {state.kind === 'done' ? <LuckyItemsResult fortune={state.fortune} /> : null}
    </div>
  );
}
