'use client';

import Link from 'next/link';
import { useState, type FormEvent } from 'react';

import { invokeEdgeFunction } from '@/lib/edge-invoke';
import { getBrowserSupabase } from '@/lib/supabase/client';

import { DailyResult } from './daily-result';
import type { DailyFortune, DailyFortuneEnvelope } from './types';

/** `apps/mobile-rn/src/screens/profile-edit-screen.tsx` 의 슬롯과 동일한 문자열. */
const BIRTH_TIME_SLOTS = [
  '모름',
  '00:00~02:00',
  '02:00~04:00',
  '04:00~06:00',
  '06:00~08:00',
  '08:00~10:00',
  '10:00~12:00',
  '12:00~14:00',
  '14:00~16:00',
  '16:00~18:00',
  '18:00~20:00',
  '20:00~22:00',
  '22:00~24:00',
] as const;

const GENDER_OPTIONS = [
  { value: '', label: '선택 안 함' },
  { value: 'male', label: '남성' },
  { value: 'female', label: '여성' },
] as const;

type State =
  | { kind: 'idle' }
  | { kind: 'loading' }
  | { kind: 'done'; fortune: DailyFortune; cached: boolean }
  | { kind: 'auth' }
  | { kind: 'tokens' }
  | { kind: 'error'; message: string };

/**
 * 코드 문자열은 대소문자를 무시하고 본다 — fortune-tarot 은 `auth_required`,
 * `_shared/fortune_charge.ts` 는 `AUTH_REQUIRED` 를 내려준다.
 */
function matchesCode(errorCode: string | undefined, expected: string): boolean {
  return errorCode?.toLowerCase() === expected;
}

function isAuthFailure(status: number | undefined, errorCode: string | undefined): boolean {
  return status === 401 || matchesCode(errorCode, 'auth_required');
}

function isTokenFailure(status: number | undefined, errorCode: string | undefined): boolean {
  return status === 402 || matchesCode(errorCode, 'insufficient_tokens');
}

export function DailyForm() {
  const [birthDate, setBirthDate] = useState('');
  const [birthTime, setBirthTime] = useState('');
  const [gender, setGender] = useState('');
  const [state, setState] = useState<State>({ kind: 'idle' });

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    const supabase = getBrowserSupabase();
    if (!supabase) {
      setState({ kind: 'error', message: '서비스 설정이 아직 준비되지 않았어요.' });
      return;
    }

    setState({ kind: 'loading' });

    // userId 는 보내지 않는다 — fortune-daily 는 body.userId 를 무시하고
    // JWT 에서만 파생한다 (index.ts 의 requirePaidFortuneCaller).
    //
    // `date` 도 보내지 않는다: 서버의 idempotency 키가 body 해시라서
    // (`_shared/fortune_charge.ts`, DEFAULT_OMIT_KEYS 에 date 없음) 타임스탬프를
    // 실으면 매 제출이 새 요청이 되어 중복 차감된다. 생략하면 서버가 KST 기준
    // 오늘 날짜를 쓰고, 같은 날 재제출은 캐시로 무료 재생된다.
    const result = await invokeEdgeFunction<DailyFortuneEnvelope>(supabase, 'fortune-daily', {
      birthDate,
      birthTime: birthTime || undefined,
      gender: gender || undefined,
    });

    if (!result.ok) {
      if (isAuthFailure(result.status, result.errorCode)) {
        setState({ kind: 'auth' });
        return;
      }
      if (isTokenFailure(result.status, result.errorCode)) {
        // 402 바디는 { code, required, available } 뿐 — 사용자용 문구가 없어서
        // 여기서 직접 쓴다.
        setState({ kind: 'tokens' });
        return;
      }
      setState({ kind: 'error', message: result.message });
      return;
    }

    const fortune = result.data?.fortune;
    if (!fortune) {
      setState({ kind: 'error', message: '운세 응답이 비어 있어요. 잠시 후 다시 시도해 주세요.' });
      return;
    }

    setState({ kind: 'done', fortune, cached: result.data?.cached === true });
  }

  return (
    <div className="ondo-stack">
      <form className="ondo-stack" onSubmit={handleSubmit}>
        <div>
          <label className="ondo-label" htmlFor="birth-date">
            생년월일 <span aria-hidden="true">*</span>
          </label>
          <input
            className="ondo-input"
            id="birth-date"
            max={new Date().toISOString().slice(0, 10)}
            name="birthDate"
            onChange={(event) => setBirthDate(event.target.value)}
            required
            type="date"
            value={birthDate}
          />
        </div>

        <fieldset style={{ border: 'none', margin: 0, padding: 0 }}>
          <legend className="ondo-label">태어난 시간 (선택)</legend>
          <div className="ondo-row">
            {BIRTH_TIME_SLOTS.map((slot) => {
              const slotValue = slot === '모름' ? '' : slot;
              return (
                <button
                  aria-pressed={birthTime === slotValue}
                  className="ondo-chip"
                  key={slot}
                  onClick={() => setBirthTime(slotValue)}
                  type="button"
                >
                  {slot}
                </button>
              );
            })}
          </div>
        </fieldset>

        <fieldset style={{ border: 'none', margin: 0, padding: 0 }}>
          <legend className="ondo-label">성별 (선택)</legend>
          <div className="ondo-row">
            {GENDER_OPTIONS.map((option) => (
              <button
                aria-pressed={gender === option.value}
                className="ondo-chip"
                key={option.label}
                onClick={() => setGender(option.value)}
                type="button"
              >
                {option.label}
              </button>
            ))}
          </div>
        </fieldset>

        <button className="ondo-button" disabled={state.kind === 'loading' || !birthDate} type="submit">
          {state.kind === 'loading' ? '읽는 중…' : '오늘의 운세 보기'}
        </button>
      </form>

      {state.kind === 'auth' ? (
        <div className="ondo-notice ondo-stack" role="alert" style={{ gap: 'var(--ondo-spacing-sm)' }}>
          <p className="ondo-h3">로그인이 필요해요</p>
          <p className="ondo-muted">세션이 만료됐어요. 다시 로그인하면 이어서 볼 수 있어요.</p>
          <Link className="ondo-button" href="/auth/login?next=%2Fapp%2Ff%2Fdaily">
            다시 로그인
          </Link>
        </div>
      ) : null}

      {state.kind === 'tokens' ? (
        <div className="ondo-notice ondo-stack" role="alert" style={{ gap: 'var(--ondo-spacing-sm)' }}>
          <p className="ondo-h3">온도가 부족해요</p>
          <p className="ondo-muted">
            잔액이 모자라서 운세를 생성하지 못했어요. 앱에서 온도를 충전한 뒤 다시 시도해 주세요.
          </p>
        </div>
      ) : null}

      {state.kind === 'error' ? (
        <p className="ondo-notice ondo-notice--error" role="alert">
          {state.message}
        </p>
      ) : null}

      {state.kind === 'done' ? <DailyResult cached={state.cached} fortune={state.fortune} /> : null}
    </div>
  );
}
