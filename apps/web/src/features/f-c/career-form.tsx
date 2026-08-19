'use client';

import { useState, type FormEvent } from 'react';

import { ChipSelect, TextField } from '@/features/fortune/fields';
import { FailureNotice } from '@/features/fortune/result';
import { runFortune, type FortuneFailureKind } from '@/features/fortune/runner';

import {
  CAREER_CONCERN_OPTIONS,
  CAREER_PATH_OPTIONS,
  CAREER_TIME_HORIZON_OPTIONS,
  CareerResult,
  type CareerFortune,
} from './career-result';
import { readCached, readFortunePayload } from './shared';

const LOGIN_HREF = `/auth/login?next=${encodeURIComponent('/운세/직업')}`;

type State =
  | { kind: 'idle' }
  | { kind: 'loading' }
  | { kind: 'done'; fortune: CareerFortune; cached: boolean }
  | { kind: 'failed'; failure: FortuneFailureKind; message: string };

export function CareerForm() {
  // currentRole 은 서버가 검사하는 유일한 필수값이다 — currentRole 과
  // careerGoal 이 둘 다 비면 400 을 던진다 (index.ts:574). 직무 문자열은
  // `estimateCareerField` 의 정규식으로 직군을 추정하는 데도 쓰여서
  // (index.ts:337~) 결과 품질을 가장 크게 좌우한다.
  const [currentRole, setCurrentRole] = useState('');
  const [careerGoal, setCareerGoal] = useState('');
  const [timeHorizon, setTimeHorizon] = useState('3년 후');
  const [careerPath, setCareerPath] = useState('전문가 (전문성 심화)');
  const [primaryConcern, setPrimaryConcern] = useState('');
  const [state, setState] = useState<State>({ kind: 'idle' });

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setState({ kind: 'loading' });

    // skills 는 일부러 보내지 않는다 — 보내면 서버가 currentLevel/targetLevel 을
    // Math.random() 으로 채운 skillAnalysis 를 돌려주고 (index.ts:456), 그걸
    // 진단 수치처럼 보여주게 된다.
    //
    // userId/날짜/난수도 보내지 않는다 (idempotency 키가 body 해시라 매번
    // 달라지면 같은 질문도 새로 과금된다).
    const result = await runFortune<unknown>('career', {
      currentRole,
      careerGoal: careerGoal || undefined,
      timeHorizon,
      careerPath,
      primaryConcern: primaryConcern || undefined,
    });

    if (!result.ok) {
      setState({ kind: 'failed', failure: result.kind, message: result.message });
      return;
    }

    const fortune = readFortunePayload<CareerFortune>(result.data);
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
        <TextField
          id="career-current-role"
          label="현재 직무"
          maxLength={40}
          onChange={setCurrentRole}
          placeholder="예: 3년차 간호사, 백엔드 개발자"
          required
          value={currentRole}
        />
        <TextField
          id="career-goal"
          label="커리어 목표 (선택)"
          maxLength={40}
          onChange={setCareerGoal}
          placeholder="예: 팀 리드, 이직, 프리랜서 전환"
          value={careerGoal}
        />
        <ChipSelect
          label="보고 싶은 시점"
          onChange={setTimeHorizon}
          options={CAREER_TIME_HORIZON_OPTIONS}
          value={timeHorizon}
        />
        <ChipSelect
          label="희망 경로"
          onChange={setCareerPath}
          options={CAREER_PATH_OPTIONS}
          value={careerPath}
        />
        <ChipSelect
          label="핵심 고민 (선택)"
          onChange={setPrimaryConcern}
          options={CAREER_CONCERN_OPTIONS}
          value={primaryConcern}
        />

        <button
          className="ondo-button"
          disabled={state.kind === 'loading' || currentRole.trim().length === 0}
          type="submit"
        >
          {state.kind === 'loading' ? '읽는 중…' : '직업운 보기'}
        </button>
      </form>

      {state.kind === 'failed' ? (
        <FailureNotice kind={state.failure} loginHref={LOGIN_HREF} message={state.message} />
      ) : null}

      {state.kind === 'done' ? (
        <CareerResult cached={state.cached} fortune={state.fortune} />
      ) : null}
    </div>
  );
}
