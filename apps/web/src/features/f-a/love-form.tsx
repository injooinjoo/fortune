'use client';

/**
 * 연애운 입력 폼.
 *
 * 요청 계약 (`supabase/functions/fortune-love/index.ts`):
 * 필수 필드 검증이 `!requestBody[field]` 라서 다음 5개가 **반드시 falsy 가 아니어야**
 * 한다 — age, gender, relationshipStatus, datingStyles, valueImportance.
 * 배열/객체는 비어 있어도 truthy 라서 통과하고(그때는 프롬프트가 "미지정" 으로
 * 처리한다), 그래서 화면에서 실제로 받는 필수 입력은 나이·성별·연애 상태 셋뿐이다.
 *
 * `userId` 는 보내지 않는다. 서버가 Authorization JWT 에서 파생해서 캐시 키
 * (`love_<userId>_...`)와 차감에 쓴다 — 클라가 준 id 는 무시된다.
 */

import { useState, type FormEvent } from 'react';

import { ChipSelect, NumberField, type ChipOption } from '@/features/fortune/fields';
import { FailureNotice } from '@/features/fortune/result';
import { runFortune, type FortuneFailureKind } from '@/features/fortune/runner';

import { LoveResult, type LoveEnvelope, type LoveFortune } from './love-result';

const LOGIN_HREF = `/auth/login?next=${encodeURIComponent('/운세/연애')}`;

/** 서버 프롬프트가 아는 값. `complicated` 는 기본(single) 분기로 떨어져서 뺐다. */
const STATUS_OPTIONS: ChipOption[] = [
  { value: 'single', label: '솔로' },
  { value: 'dating', label: '연애 중' },
  { value: 'crush', label: '짝사랑' },
  { value: 'breakup', label: '이별 후' },
];

/** 서버는 gender 를 프롬프트에 그대로 넣는다. 빈 값이면 400 이라 선택 필수. */
const GENDER_OPTIONS: ChipOption[] = [
  { value: 'female', label: '여성' },
  { value: 'male', label: '남성' },
];

/** `valueImportance` 는 `{ 항목: 1~5 }`. 고른 하나만 5점으로 강조해 보낸다. */
const VALUE_OPTIONS: ChipOption[] = [
  { value: '', label: '고루 중요' },
  { value: '성격', label: '성격' },
  { value: '가치관', label: '가치관' },
  { value: '유머감각', label: '유머감각' },
  { value: '외모', label: '외모' },
  { value: '경제력', label: '경제력' },
];

type State =
  | { kind: 'idle' }
  | { kind: 'loading' }
  | { kind: 'done'; fortune: LoveFortune; cached: boolean }
  | { kind: 'failed'; failure: FortuneFailureKind; message: string };

export function LoveForm() {
  const [age, setAge] = useState('');
  const [gender, setGender] = useState('');
  const [status, setStatus] = useState('single');
  const [valued, setValued] = useState('');
  const [state, setState] = useState<State>({ kind: 'idle' });

  const ageNumber = Number(age);
  const ready = Number.isFinite(ageNumber) && ageNumber > 0 && gender !== '';

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!ready) return;
    setState({ kind: 'loading' });

    const result = await runFortune<LoveEnvelope>('love', {
      age: ageNumber,
      gender,
      relationshipStatus: status,
      // 아래 둘은 서버 필수 필드지만 빈 값도 통과한다 (프롬프트에서 "미지정" 처리).
      datingStyles: [],
      valueImportance: valued ? { [valued]: 5 } : {},
    });

    if (!result.ok) {
      setState({ kind: 'failed', failure: result.kind, message: result.message });
      return;
    }

    const fortune = result.data.data;
    if (!fortune) {
      setState({
        kind: 'failed',
        failure: 'error',
        message: '연애운 결과가 비어 있어요. 잠시 후 다시 시도해 주세요.',
      });
      return;
    }

    setState({ kind: 'done', fortune, cached: result.data.cached === true });
  }

  return (
    <div className="ondo-stack">
      <form className="ondo-stack" onSubmit={handleSubmit}>
        <NumberField
          id="love-age"
          label="나이"
          max={120}
          min={1}
          onChange={setAge}
          placeholder="예: 28"
          required
          value={age}
        />

        <ChipSelect label="성별" onChange={setGender} options={GENDER_OPTIONS} value={gender} />

        <ChipSelect
          label="지금 연애 상태"
          onChange={setStatus}
          options={STATUS_OPTIONS}
          value={status}
        />

        <ChipSelect
          label="연애에서 가장 중요한 것 (선택)"
          onChange={setValued}
          options={VALUE_OPTIONS}
          value={valued}
        />

        <button className="ondo-button" disabled={state.kind === 'loading' || !ready} type="submit">
          {state.kind === 'loading' ? '연애운을 읽는 중…' : '연애운 보기'}
        </button>
      </form>

      {state.kind === 'failed' ? (
        <FailureNotice kind={state.failure} loginHref={LOGIN_HREF} message={state.message} />
      ) : null}

      {state.kind === 'done' ? (
        <LoveResult cached={state.cached} fortune={state.fortune} />
      ) : null}
    </div>
  );
}
