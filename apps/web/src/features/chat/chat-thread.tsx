'use client';

import Link from 'next/link';
import {
  useCallback,
  useEffect,
  useRef,
  useState,
  type FormEvent,
  type KeyboardEvent,
} from 'react';
import type { SupabaseClient } from '@supabase/supabase-js';

import { CharacterAvatar } from './character-avatar';
import type { WebChatCharacter } from './characters';
import {
  ensureChatSession,
  loadConversation,
  saveConversation,
  sendCharacterMessage,
  type ChatFailure,
} from './chat-client';
import type { ChatMessage } from './types';
import styles from './chat.module.css';

/**
 * 캐릭터 대화 스레드.
 *
 * 설계 근거 (전부 서버 동작에서 온 것):
 *
 * 1. **스트리밍이 없다.** character-chat 은 JSON 한 덩어리를 준다. 대신
 *    `segments[]` 를 한 개씩 시차를 두고 붙여 카톡처럼 보이게 한다. 서버가
 *    주는 `delaySec` (4~45초) 은 앱의 푸시 페이싱용이라 웹에서는 쓰지 않는다 —
 *    화면을 보고 있는 사람을 45초 기다리게 할 이유가 없다.
 *
 * 2. **실패 시 자동 재시도 없음.** character-chat 은 body 해시 idempotency 가
 *    없다. 대신 같은 `userMessageId` 로 다시 보내면 서버 차감 키가 같아져
 *    중복 과금이 안 되므로, 재시도 버튼은 실패한 턴의 id 를 그대로 재사용한다.
 *    재시도할지는 사용자가 정한다.
 *
 * 3. **세션이 없으면 로컬 전용.** load/save 는 RLS 로 `auth.uid()` 를 요구하고
 *    (merge RPC 가 anon role 을 명시적으로 거부) 익명 세션이면 통과한다.
 *    익명 로그인마저 실패하면 대화는 이 화면에만 남는다 — 그 사실을 UI 에 적는다.
 */

/** 응답 세그먼트 사이 타이핑 시간. 길이 비례 + 상한. */
function typingDelayMs(segment: string): number {
  return Math.min(1500, 380 + segment.length * 26);
}

function newMessage(type: ChatMessage['type'], content: string, id?: string): ChatMessage {
  return {
    id: id ?? crypto.randomUUID(),
    type,
    content,
    timestamp: new Date().toISOString(),
  };
}

/**
 * 첫 인사는 캐릭터가 먼저 건다.
 *
 * id 를 캐릭터마다 고정한 이유: 저장 RPC 가 id 로 중복을 거르기 때문에
 * (`merge_character_conversation_messages`) 새로고침해도 인사가 두 줄로
 * 쌓이지 않는다.
 */
function openerMessage(character: WebChatCharacter): ChatMessage {
  return newMessage('character', character.opener, `opener:${character.id}`);
}

type Persistence = 'checking' | 'remote' | 'local';

interface PendingTurn {
  text: string;
  messageId: string;
  history: ChatMessage[];
}

export function ChatThread({ character }: { character: WebChatCharacter }) {
  const [messages, setMessages] = useState<ChatMessage[]>(() => [openerMessage(character)]);
  /** 아직 화면에 안 붙은 응답 세그먼트. 앞에서부터 하나씩 뽑는다. */
  const [queue, setQueue] = useState<string[]>([]);
  const [waiting, setWaiting] = useState(false);
  const [input, setInput] = useState('');
  const [failure, setFailure] = useState<ChatFailure | null>(null);
  const [pending, setPending] = useState<PendingTurn | null>(null);
  const [persistence, setPersistence] = useState<Persistence>('checking');
  const [dirty, setDirty] = useState(false);

  const supabaseRef = useRef<SupabaseClient | null>(null);
  const bottomRef = useRef<HTMLDivElement | null>(null);
  const inputRef = useRef<HTMLTextAreaElement | null>(null);
  const scrolledOnceRef = useRef(false);

  const busy = waiting || queue.length > 0;
  const booting = persistence === 'checking';

  // 게스트 부트스트랩 + 저장된 스레드 복원.
  useEffect(() => {
    let cancelled = false;

    void (async () => {
      const session = await ensureChatSession();
      if (cancelled) return;

      if (!session) {
        // Supabase 미설정 빌드. 전송도 실패하지만 화면은 뜬다.
        setPersistence('local');
        return;
      }

      supabaseRef.current = session.supabase;
      if (!session.signedIn) {
        setPersistence('local');
        return;
      }

      const restored = await loadConversation(session.supabase, character.id);
      if (cancelled) return;

      if (restored === null) {
        setPersistence('local');
        return;
      }

      setPersistence('remote');
      if (restored.length > 0) {
        setMessages(restored);
      }
    })();

    return () => {
      cancelled = true;
    };
  }, [character.id]);

  // 세그먼트를 하나씩 말풍선으로 승격. 사이 간격이 곧 타이핑 인디케이터 시간.
  useEffect(() => {
    if (queue.length === 0) return;

    const [next, ...rest] = queue;
    const timer = setTimeout(() => {
      setMessages((prev) => [...prev, newMessage('character', next)]);
      setQueue(rest);
    }, typingDelayMs(next));

    return () => clearTimeout(timer);
  }, [queue]);

  // 한 턴이 완전히 끝난 뒤에만 저장한다. 도중에 저장하면 반쪽짜리 답장이 남는다.
  //
  // 취소 플래그를 두지 않는다: `setDirty(false)` 가 곧바로 이 이펙트를 다시
  // 돌리므로 cleanup 이 즉시 실행돼 오히려 결과 처리를 잡아먹는다. 실패를
  // 화면에 반영해야 해서 (저장 안 됨 → local 안내) 그대로 흘려보낸다.
  useEffect(() => {
    if (!dirty || busy) return;

    // 재진입 차단. 아래 저장이 끝나기 전에 이펙트가 다시 돌아도 dirty 가 이미
    // false 라 같은 스레드를 두 번 올리지 않는다.
    setDirty(false);

    const supabase = supabaseRef.current;
    if (persistence !== 'remote' || !supabase) return;

    void saveConversation(supabase, character.id, messages).then((saved) => {
      if (!saved) setPersistence('local');
    });
  }, [dirty, busy, persistence, messages, character.id]);

  // 입력창 높이를 내용에 맞춘다. rows=1 고정이면 세 줄짜리 메시지를 쓰는 동안
  // 방금 친 줄만 보인다. 상한은 CSS 의 max-height 가 잡고 그 위로는 스크롤.
  useEffect(() => {
    const element = inputRef.current;
    if (!element) return;
    element.style.height = 'auto';
    element.style.height = `${element.scrollHeight}px`;
  }, [input]);

  // 새 말풍선이 붙으면 아래로. 첫 렌더에서는 스크롤하지 않는다 (페이지 상단 유지).
  useEffect(() => {
    if (!scrolledOnceRef.current) {
      scrolledOnceRef.current = true;
      return;
    }
    bottomRef.current?.scrollIntoView({ behavior: 'smooth', block: 'end' });
  }, [messages.length, busy]);

  const runTurn = useCallback(
    async (turn: PendingTurn) => {
      setWaiting(true);
      setFailure(null);

      const result = await sendCharacterMessage({
        supabase: supabaseRef.current,
        character,
        history: turn.history,
        userMessage: turn.text,
        userMessageId: turn.messageId,
      });

      setWaiting(false);

      if (!result.ok) {
        // 자동 재시도 금지 — 중복 과금 가능. 사용자가 버튼으로 결정한다.
        setFailure(result.failure);
        setPending(turn);
        return;
      }

      setPending(null);
      setQueue(result.segments);
      setDirty(true);
    },
    [character],
  );

  function submit() {
    const text = input.trim();
    if (text.length === 0 || busy || booting) return;

    const turn: PendingTurn = {
      text,
      messageId: crypto.randomUUID(),
      history: messages,
    };

    setMessages((prev) => [...prev, newMessage('user', text, turn.messageId)]);
    setInput('');
    void runTurn(turn);
  }

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    submit();
  }

  function handleKeyDown(event: KeyboardEvent<HTMLTextAreaElement>) {
    // 한글 조합 중 Enter 는 글자를 확정하는 키다. 여기서 보내면 문장이 잘린다.
    if (event.key !== 'Enter' || event.shiftKey || event.nativeEvent.isComposing) return;
    event.preventDefault();
    submit();
  }

  return (
    <div className="ondo-stack">
      <div aria-live="polite" className={styles.thread} role="log">
        {messages.map((message, index) => (
          <Bubble
            character={character}
            key={message.id}
            message={message}
            showAvatar={messages[index - 1]?.type !== message.type}
          />
        ))}

        {busy ? <TypingBubble character={character} /> : null}
        <div ref={bottomRef} />
      </div>

      {failure ? (
        <FailureBox character={character} failure={failure} onRetry={pending ? () => void runTurn(pending) : undefined} />
      ) : null}

      <form className={styles.composer} onSubmit={handleSubmit}>
        <label className={styles.srOnly} htmlFor="chat-input">
          {character.name}에게 보낼 메시지
        </label>
        <textarea
          className={`ondo-input ${styles.input}`}
          disabled={booting}
          id="chat-input"
          onChange={(event) => setInput(event.target.value)}
          onKeyDown={handleKeyDown}
          placeholder={booting ? '연결하는 중이에요…' : `${character.name}에게 보낼 말`}
          ref={inputRef}
          rows={1}
          value={input}
        />
        <button
          className={`ondo-button ${styles.sendButton}`}
          disabled={booting || busy || input.trim().length === 0}
          type="submit"
        >
          보내기
        </button>
      </form>

      {persistence === 'local' ? (
        <div className="ondo-notice ondo-stack" style={{ gap: 'var(--ondo-spacing-sm)' }}>
          <p className="ondo-muted">
            지금은 이 대화가 브라우저에만 남아요. 새로고침하면 처음부터 시작합니다.
          </p>
          <div>
            <Link
              className="ondo-button ondo-button--secondary"
              href={`/auth/login?next=${encodeURIComponent(`/대화/${character.id}`)}`}
            >
              로그인하고 이어가기
            </Link>
          </div>
        </div>
      ) : null}

      <p className="ondo-muted">
        온도의 캐릭터 대화는 엔터테인먼트 목적으로 제공되며, 실제 인물이 아닌 AI 캐릭터와의 대화입니다.
      </p>
    </div>
  );
}

function Bubble({
  character,
  message,
  showAvatar,
}: {
  character: WebChatCharacter;
  message: ChatMessage;
  showAvatar: boolean;
}) {
  if (message.type === 'system') {
    return <p className={styles.systemLine}>{message.content}</p>;
  }

  const mine = message.type === 'user';

  return (
    <div className={mine ? `${styles.row} ${styles.rowUser}` : styles.row}>
      {mine ? null : (
        <CharacterAvatar character={character} className={showAvatar ? undefined : styles.avatarSpacer} />
      )}
      <p className={mine ? `${styles.bubble} ${styles.bubbleUser}` : styles.bubble}>{message.content}</p>
    </div>
  );
}

function TypingBubble({ character }: { character: WebChatCharacter }) {
  return (
    <div className={styles.row}>
      <CharacterAvatar character={character} />
      {/* 바깥 컨테이너가 이미 aria-live 라 여기에 role="status" 를 또 두지 않는다.
          중첩 라이브 리전은 스크린리더가 두 번 읽는다. */}
      <span className={`${styles.bubble} ${styles.typingBubble}`}>
        <span className={styles.srOnly}>{character.name} 입력 중</span>
        <span aria-hidden="true" className={styles.dot} />
        <span aria-hidden="true" className={styles.dot} />
        <span aria-hidden="true" className={styles.dot} />
      </span>
    </div>
  );
}

function FailureBox({
  character,
  failure,
  onRetry,
}: {
  character: WebChatCharacter;
  failure: ChatFailure;
  onRetry?: () => void;
}) {
  const loginHref = `/auth/login?next=${encodeURIComponent(`/대화/${character.id}`)}`;

  return (
    <div className="ondo-notice ondo-notice--error ondo-stack" role="alert" style={{ gap: 'var(--ondo-spacing-sm)' }}>
      <p className="ondo-muted">{failure.message}</p>
      <div className="ondo-row">
        {failure.kind === 'auth' ? (
          <Link className="ondo-button" href={loginHref}>
            다시 로그인
          </Link>
        ) : null}
        {/* 자동 재시도를 안 하는 대신 버튼으로 남긴다. 같은 턴 id 로 다시 보낸다. */}
        {onRetry && failure.kind !== 'limit' ? (
          <button className="ondo-button ondo-button--secondary" onClick={onRetry} type="button">
            다시 보내기
          </button>
        ) : null}
      </div>
    </div>
  );
}
