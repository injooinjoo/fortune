'use client';

/**
 * `/설정/ai` 의 인터랙티브 부분 — 연결 목록 + 연결 폼 + 해제 버튼.
 *
 * 키 취급 원칙 (전부 의도적이다, 편의로 바꾸지 말 것):
 *
 * 1. API 키 입력칸은 **uncontrolled** 다. `useState` 로 묶으면 사용자가 타이핑하는
 *    동안 평문 키가 React state 에 들어가고, 그 state 는 컴포넌트가 살아 있는 한
 *    남는다. ref 로 제출 순간에만 읽어서 지역 변수로 쓰고 흘려보낸다.
 * 2. 저장에 성공하면 즉시 DOM 입력값까지 비운다. 화면에는 서버가 준 메타데이터
 *    (제공자 / 마지막 네 자리 / 연결 날짜) 만 남는다.
 * 3. localStorage / sessionStorage / URL 에 키를 쓰지 않는다. 이 파일에 그 API 가
 *    한 번도 등장하지 않는 게 정상이다.
 * 4. 키도, 키가 섞일 수 있는 서버 원문 에러도 console 로 찍지 않는다.
 *
 * 색은 전부 var(--ondo-*), 클래스는 globals.css 의 .ondo-* 만 쓴다.
 */

import Link from 'next/link';
import { useCallback, useEffect, useRef, useState, type FormEvent } from 'react';

import { ChipSelect, TextField } from '@/features/fortune/fields';

import {
  isUserLlmProviderId,
  providerLabel,
  SETTINGS_AI_LOGIN_HREF,
  USER_LLM_PROVIDER_OPTIONS,
  type UserLlmProviderId,
} from './providers';
import {
  connectUserLlmKey,
  disconnectUserLlmKey,
  listUserLlmKeys,
  readSettingsSession,
  type UserLlmKeyMeta,
} from './user-llm-key-client';

type Gate = 'checking' | 'signed-out' | 'unavailable' | 'ready';

type Notice = { tone: 'ok' | 'error'; message: string };

const EMPTY_KEY_MESSAGE = '키를 붙여 넣어 주세요.';

/**
 * `toLocaleDateString` 을 쓰지 않는 이유: 이 컴포넌트는 클라이언트에서만 그리지만,
 * 로케일에 따라 표기가 갈리는 것보다 앱과 같은 `YYYY.MM.DD` 로 고정하는 편이 낫다.
 */
function formatConnectedDate(iso: string | undefined): string | undefined {
  if (!iso) return undefined;
  const date = new Date(iso);
  if (Number.isNaN(date.getTime())) return undefined;

  const month = `${date.getMonth() + 1}`.padStart(2, '0');
  const day = `${date.getDate()}`.padStart(2, '0');
  return `${date.getFullYear()}.${month}.${day}`;
}

/** 제공자 · 마지막 네 자리 · 모델 · 연결 날짜를 한 줄로. 없는 건 조용히 빠진다. */
function keySummary(key: UserLlmKeyMeta): string {
  const parts = [`•••• ${key.last4}`];
  if (key.model) parts.push(key.model);

  const connectedOn = formatConnectedDate(key.createdAt);
  if (connectedOn) parts.push(`${connectedOn} 연결`);

  return parts.join(' · ');
}

function SignInPrompt() {
  return (
    <div className="ondo-card ondo-stack" style={{ gap: 'var(--ondo-spacing-sm)' }}>
      <p>키는 계정에 묶여 저장돼요. 로그인한 뒤에 연결할 수 있어요.</p>
      <p className="ondo-muted">
        운세를 볼 때 쓰는 임시(익명) 세션으로는 연결할 수 없어요. 기기를 바꾸거나 쿠키가
        지워지면 그 키를 다시 찾을 수 없기 때문이에요.
      </p>
      <Link className="ondo-button" href={SETTINGS_AI_LOGIN_HREF}>
        로그인하고 연결하기
      </Link>
    </div>
  );
}

export function AiKeySettings() {
  const [gate, setGate] = useState<Gate>('checking');
  const [keys, setKeys] = useState<UserLlmKeyMeta[]>([]);
  const [provider, setProvider] = useState<UserLlmProviderId>('openai');
  const [model, setModel] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [removing, setRemoving] = useState<string | null>(null);
  const [notice, setNotice] = useState<Notice | null>(null);

  // 평문 키는 여기(DOM)에만 잠깐 있는다. state 로 올리지 않는다.
  const keyInputRef = useRef<HTMLInputElement>(null);

  const refresh = useCallback(async () => {
    const result = await listUserLlmKeys();
    if (!result.ok) {
      if (result.kind === 'auth') {
        setGate('signed-out');
        return;
      }
      setNotice({ tone: 'error', message: result.message });
      return;
    }
    setKeys(result.data);
  }, []);

  useEffect(() => {
    let cancelled = false;

    void (async () => {
      const session = await readSettingsSession();
      if (cancelled) return;

      if (session.kind !== 'ready') {
        setGate(session.kind === 'unavailable' ? 'unavailable' : 'signed-out');
        return;
      }

      setGate('ready');
      await refresh();
    })();

    return () => {
      cancelled = true;
    };
  }, [refresh]);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    const input = keyInputRef.current;
    const apiKey = input?.value.trim() ?? '';
    if (apiKey.length === 0) {
      setNotice({ tone: 'error', message: EMPTY_KEY_MESSAGE });
      return;
    }

    setNotice(null);
    setSubmitting(true);
    // apiKey 는 이 핸들러의 지역 변수다 — 아래 await 가 끝나면 참조가 사라진다.
    const result = await connectUserLlmKey(provider, apiKey, model.trim() || undefined);
    setSubmitting(false);

    if (!result.ok) {
      if (result.kind === 'auth') {
        setGate('signed-out');
        return;
      }
      // 서버가 "이 키로는 인증 안 된다" 고 확정한 경우엔 DOM 에서도 지운다.
      // 어차피 못 쓰는 값이고, 남겨 두면 탭이 열려 있는 내내 평문으로 떠 있는다.
      // (네트워크 실패 같은 미확정 실패는 재시도할 수 있게 그대로 둔다.)
      if (result.kind === 'invalid_key' && input) input.value = '';
      setNotice({ tone: 'error', message: result.message });
      return;
    }

    // 성공 즉시 입력칸을 비운다. 이 시점 이후 평문 키는 어디에도 남지 않는다.
    if (input) input.value = '';
    setModel('');
    setNotice({ tone: 'ok', message: `${providerLabel(provider)} 키를 연결했어요.` });
    await refresh();
  }

  async function handleDisconnect(target: string) {
    setNotice(null);
    setRemoving(target);
    const result = await disconnectUserLlmKey(target);
    setRemoving(null);

    if (!result.ok) {
      if (result.kind === 'auth') {
        setGate('signed-out');
        return;
      }
      setNotice({ tone: 'error', message: result.message });
      return;
    }

    setNotice({ tone: 'ok', message: `${providerLabel(target)} 키 연결을 해제했어요.` });
    await refresh();
  }

  if (gate === 'checking') {
    return <p className="ondo-muted">불러오는 중…</p>;
  }

  if (gate === 'unavailable') {
    return (
      <p className="ondo-notice" role="alert">
        서비스 설정이 아직 준비되지 않았어요.
      </p>
    );
  }

  if (gate === 'signed-out') {
    return <SignInPrompt />;
  }

  return (
    <div className="ondo-stack">
      <section className="ondo-stack" style={{ gap: 'var(--ondo-spacing-sm)' }}>
        <h2 className="ondo-h3">연결된 키</h2>

        {keys.length === 0 ? (
          <p className="ondo-muted">아직 연결한 키가 없어요.</p>
        ) : (
          keys.map((entry) => (
            <div
              className="ondo-card ondo-row"
              key={entry.provider}
              style={{ alignItems: 'center', justifyContent: 'space-between' }}
            >
              <div className="ondo-stack" style={{ gap: 'var(--ondo-spacing-xxs)' }}>
                <p>{providerLabel(entry.provider)}</p>
                <p className="ondo-muted">{keySummary(entry)}</p>
                {entry.isActive ? null : (
                  <p className="ondo-muted">지금은 사용하지 않는 상태예요.</p>
                )}
              </div>

              <button
                className="ondo-button ondo-button--secondary"
                disabled={removing !== null}
                onClick={() => handleDisconnect(entry.provider)}
                type="button"
              >
                {removing === entry.provider ? '해제 중…' : '연결 해제'}
              </button>
            </div>
          ))
        )}
      </section>

      <section className="ondo-stack" style={{ gap: 'var(--ondo-spacing-sm)' }}>
        <h2 className="ondo-h3">새 키 연결</h2>

        <form className="ondo-stack" onSubmit={handleSubmit}>
          <ChipSelect
            label="제공자"
            onChange={(value) => {
              if (isUserLlmProviderId(value)) setProvider(value);
            }}
            options={USER_LLM_PROVIDER_OPTIONS}
            value={provider}
          />

          <div>
            <label className="ondo-label" htmlFor="user-llm-api-key">
              API 키
            </label>
            {/*
              uncontrolled + autoComplete="off" + name 없음.
              name 을 붙이면 브라우저/비밀번호 관리자가 저장 대상으로 잡는다.
            */}
            <input
              autoComplete="off"
              className="ondo-input"
              disabled={submitting}
              id="user-llm-api-key"
              placeholder="발급받은 키를 붙여 넣어 주세요"
              ref={keyInputRef}
              spellCheck={false}
              type="password"
            />
          </div>

          <TextField
            id="user-llm-model"
            label="모델 (선택)"
            onChange={setModel}
            placeholder="비워 두면 기본 모델을 씁니다"
            value={model}
          />

          <button className="ondo-button" disabled={submitting} type="submit">
            {submitting ? '확인 중…' : '키 연결하기'}
          </button>
        </form>
      </section>

      {notice ? (
        <p
          className={notice.tone === 'error' ? 'ondo-notice ondo-notice--error' : 'ondo-notice'}
          role={notice.tone === 'error' ? 'alert' : 'status'}
        >
          {notice.message}
        </p>
      ) : null}
    </div>
  );
}
