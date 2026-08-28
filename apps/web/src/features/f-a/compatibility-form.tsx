'use client';

/**
 * 궁합 입력 폼 — 두 사람의 이름 + 생년월일.
 *
 * 요청 계약 (`supabase/functions/fortune-compatibility/index.ts`):
 *  - flat(`person1_name`, `person1_birth_date`) 과 nested(`person1.name`,
 *    `person1.birth_date`) 를 모두 받는다. 여기서는 flat 을 쓴다 — nested 쪽 키가
 *    `birthDate` 가 아니라 `birth_date` 라서 헷갈리기 쉽다.
 *  - 이름이 하나라도 비면 서버가 throw → 500. 그래서 이름 두 개가 필수다.
 *  - 생년월일은 `YYYY-MM-DD` 문자열을 substring 으로 잘라 띠/별자리/계절/나이차를
 *    직접 계산한다. 즉 이 값은 LLM 과 무관하게 결과에 그대로 반영된다.
 *  - `person1_gender` / `person2_gender` 는 cohort 버킷 계산에만 쓰이고 없으면
 *    서버가 male/female 로 채운다 → 입력을 늘리지 않으려고 보내지 않는다.
 */

import { useState, type FormEvent } from 'react';

import { BirthDateField, TextField } from '@/features/fortune/fields';
import { FailureNotice } from '@/features/fortune/result';
import { runFortune, type FortuneFailureKind } from '@/features/fortune/runner';

import {
  CompatibilityResult,
  type CompatibilityEnvelope,
  type CompatibilityFortune,
} from './compatibility-result';

const LOGIN_HREF = `/auth/login?next=${encodeURIComponent('/운세/궁합')}`;

type State =
  | { kind: 'idle' }
  | { kind: 'loading' }
  | { kind: 'done'; fortune: CompatibilityFortune }
  | { kind: 'failed'; failure: FortuneFailureKind; message: string };

/** 한 사람 입력 묶음. 두 번 반복되는 마크업이라 여기서 한 번만 쓴다. */
function PersonFields({
  heading,
  idPrefix,
  name,
  birthDate,
  rememberBirthDate,
  onNameChange,
  onBirthDateChange,
}: {
  heading: string;
  idPrefix: string;
  name: string;
  birthDate: string;
  rememberBirthDate: boolean;
  onNameChange: (value: string) => void;
  onBirthDateChange: (value: string) => void;
}) {
  return (
    <div className="ondo-card ondo-stack" style={{ gap: 'var(--ondo-spacing-sm)' }}>
      <p className="ondo-kicker">{heading}</p>
      <TextField
        id={`${idPrefix}-name`}
        label="이름"
        maxLength={20}
        onChange={onNameChange}
        placeholder="예: 김온도"
        required
        value={name}
      />
      <BirthDateField
        id={`${idPrefix}-birth-date`}
        name={`${idPrefix}BirthDate`}
        onChange={onBirthDateChange}
        remember={rememberBirthDate}
        value={birthDate}
      />
    </div>
  );
}

export function CompatibilityForm() {
  const [firstName, setFirstName] = useState('');
  const [firstBirthDate, setFirstBirthDate] = useState('');
  const [secondName, setSecondName] = useState('');
  const [secondBirthDate, setSecondBirthDate] = useState('');
  const [state, setState] = useState<State>({ kind: 'idle' });

  const ready =
    firstName.trim() !== '' &&
    secondName.trim() !== '' &&
    firstBirthDate !== '' &&
    secondBirthDate !== '';

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!ready) return;
    setState({ kind: 'loading' });

    const result = await runFortune<CompatibilityEnvelope>('compatibility', {
      person1_name: firstName.trim(),
      person1_birth_date: firstBirthDate,
      person2_name: secondName.trim(),
      person2_birth_date: secondBirthDate,
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
        message: '궁합 결과가 비어 있어요. 잠시 후 다시 시도해 주세요.',
      });
      return;
    }

    setState({ kind: 'done', fortune });
  }

  return (
    <div className="ondo-stack">
      <form className="ondo-stack" onSubmit={handleSubmit}>
        <PersonFields
          birthDate={firstBirthDate}
          heading="첫 번째 사람"
          idPrefix="person1"
          name={firstName}
          onBirthDateChange={setFirstBirthDate}
          onNameChange={setFirstName}
          rememberBirthDate
        />

        <PersonFields
          birthDate={secondBirthDate}
          heading="두 번째 사람"
          idPrefix="person2"
          name={secondName}
          onBirthDateChange={setSecondBirthDate}
          onNameChange={setSecondName}
          rememberBirthDate={false}
        />

        <button className="ondo-button" disabled={state.kind === 'loading' || !ready} type="submit">
          {state.kind === 'loading' ? '궁합을 보는 중…' : '궁합 보기'}
        </button>
      </form>

      {state.kind === 'failed' ? (
        <FailureNotice kind={state.failure} loginHref={LOGIN_HREF} message={state.message} />
      ) : null}

      {state.kind === 'done' ? <CompatibilityResult fortune={state.fortune} /> : null}
    </div>
  );
}
