'use client';

import { useState, type FormEvent } from 'react';

import { BirthDateField, ChipSelect } from '@/features/fortune/fields';
import { FailureNotice } from '@/features/fortune/result';
import { runFortune, type FortuneFailureKind } from '@/features/fortune/runner';

import {
  HEALTH_BODY_PART_OPTIONS,
  HEALTH_CONDITION_OPTIONS,
  HEALTH_EXERCISE_OPTIONS,
  HEALTH_MEAL_OPTIONS,
  HEALTH_SLEEP_OPTIONS,
  HEALTH_STRESS_OPTIONS,
  HealthResult,
  type HealthFortune,
} from './health-result';
import { MultiChipSelect } from './multi-chips';
import { readCached, readFortunePayload } from './shared';

const LOGIN_HREF = `/auth/login?next=${encodeURIComponent('/운세/건강')}`;

type State =
  | { kind: 'idle' }
  | { kind: 'loading' }
  | { kind: 'done'; fortune: HealthFortune; cached: boolean }
  | { kind: 'failed'; failure: FortuneFailureKind; message: string };

export function HealthForm() {
  // 컨디션만 필수다 (비면 서버가 400 — index.ts:398).
  //
  // 생활 습관 4개는 기본값 '보통'(3) 으로 미리 눌러둔다. 점수를 서버가 이
  // 네 값으로 직접 계산하기 때문에 (index.ts:849~853) 빼면 모두가 같은 70점을
  // 받게 되고, 몰래 채우면 사용자가 고칠 수 없다. 그래서 화면에 두되 기본값을
  // 선택해 둔다 — 컨디션 한 번만 누르면 제출된다.
  const [condition, setCondition] = useState('');
  const [bodyParts, setBodyParts] = useState<string[]>([]);
  const [sleep, setSleep] = useState('3');
  const [exercise, setExercise] = useState('3');
  const [stress, setStress] = useState('3');
  const [meal, setMeal] = useState('3');
  const [birthDate, setBirthDate] = useState('');
  const [state, setState] = useState<State>({ kind: 'idle' });

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setState({ kind: 'loading' });

    // birthDate 를 보내면 서버가 오행을 계산해 element_advice 를 얹어준다
    // (index.ts:386). 없으면 그 블록만 빠지고 나머지는 그대로 나온다.
    //
    // health_app_data / previousSurvey / isPremium 은 앱 전용 입력이라 웹은
    // 보내지 않는다. userId·날짜·난수도 보내지 않는다 (body 해시가 idempotency
    // 키라 매번 달라지면 같은 질문도 새로 과금된다).
    const result = await runFortune<unknown>('health', {
      current_condition: condition,
      concerned_body_parts: bodyParts,
      sleepQuality: Number(sleep),
      exerciseFrequency: Number(exercise),
      stressLevel: Number(stress),
      mealRegularity: Number(meal),
      birthDate: birthDate || undefined,
    });

    if (!result.ok) {
      setState({ kind: 'failed', failure: result.kind, message: result.message });
      return;
    }

    const fortune = readFortunePayload<HealthFortune>(result.data);
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
          label="요즘 컨디션"
          onChange={setCondition}
          options={HEALTH_CONDITION_OPTIONS}
          value={condition}
        />
        <MultiChipSelect
          label="신경 쓰이는 부위 (선택)"
          onChange={setBodyParts}
          options={HEALTH_BODY_PART_OPTIONS}
          values={bodyParts}
        />
        <ChipSelect
          label="수면의 질"
          onChange={setSleep}
          options={HEALTH_SLEEP_OPTIONS}
          value={sleep}
        />
        <ChipSelect
          label="운동 빈도"
          onChange={setExercise}
          options={HEALTH_EXERCISE_OPTIONS}
          value={exercise}
        />
        <ChipSelect
          label="스트레스"
          onChange={setStress}
          options={HEALTH_STRESS_OPTIONS}
          value={stress}
        />
        <ChipSelect
          label="식사 규칙성"
          onChange={setMeal}
          options={HEALTH_MEAL_OPTIONS}
          value={meal}
        />
        <BirthDateField
          id="health-birth-date"
          label="생년월일 (선택 · 오행 분석)"
          onChange={setBirthDate}
          required={false}
          value={birthDate}
        />

        <button
          className="ondo-button"
          disabled={state.kind === 'loading' || !condition}
          type="submit"
        >
          {state.kind === 'loading' ? '읽는 중…' : '건강운 보기'}
        </button>
      </form>

      {state.kind === 'failed' ? (
        <FailureNotice kind={state.failure} loginHref={LOGIN_HREF} message={state.message} />
      ) : null}

      {state.kind === 'done' ? (
        <HealthResult cached={state.cached} fortune={state.fortune} />
      ) : null}
    </div>
  );
}
