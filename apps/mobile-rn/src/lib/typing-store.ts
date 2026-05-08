/**
 * typing-store — 캐릭터별 "AI 답장 생성 중" 상태의 글로벌 단일 source.
 *
 * 왜 글로벌:
 *   chat-screen.tsx 의 storyTypingByCharacterId 는 컴포넌트 로컬 state 였다.
 *   채팅 리스트 surface (surfaceMode==='list') 에서는 같은 state 를 못 봐서
 *   "어떤 캐릭터의 답장을 기다리는 중인지" 를 행에 표시 불가능했다.
 *
 * Module singleton + subscribe 패턴 (message-store.ts 와 동일):
 *   - setTyping(characterId, true|false) — chat-screen send 흐름 / pending
 *     resumer 가 set
 *   - useIsTyping(characterId) — UI 가 캐릭터 단위 read
 *   - useTypingByCharacterId() — chat-list 가 모든 캐릭터 한 번에 read
 *
 * 메모리만 유지 (재시작 시 초기화). typing 은 ephemeral state 라 영속화 불필요.
 */

import { useEffect, useState } from 'react';

type Listener = () => void;

const typingByCharacter = new Map<string, boolean>();
const globalListeners = new Set<Listener>();

function notifyAll(): void {
  globalListeners.forEach((listener) => {
    try {
      listener();
    } catch {
      // listener 오류는 다른 listener 에 영향 없도록 swallow.
    }
  });
}

export function setTyping(characterId: string, value: boolean): void {
  if (!characterId) return;
  const prev = typingByCharacter.get(characterId) ?? false;
  if (prev === value) return;
  if (value) {
    typingByCharacter.set(characterId, true);
  } else {
    typingByCharacter.delete(characterId);
  }
  notifyAll();
}

export function getTyping(characterId: string): boolean {
  return typingByCharacter.get(characterId) ?? false;
}

function subscribe(listener: Listener): () => void {
  globalListeners.add(listener);
  return () => {
    globalListeners.delete(listener);
  };
}

export function useIsTyping(characterId: string | null | undefined): boolean {
  const [value, setValue] = useState<boolean>(() =>
    characterId ? getTyping(characterId) : false,
  );

  useEffect(() => {
    if (!characterId) {
      setValue(false);
      return undefined;
    }
    setValue(getTyping(characterId));
    return subscribe(() => {
      setValue(getTyping(characterId));
    });
  }, [characterId]);

  return value;
}

/**
 * 모든 캐릭터의 typing 상태 한 번에 read. chat-list 처럼 다수 행을 동시에
 * 보여주는 surface 에서 single subscribe 로 처리. 어떤 캐릭터든 변경되면
 * 단일 re-render 발생 — 캐릭터당 typing on/off 가 빈번하지 않아 비용 무시.
 */
export function useTypingByCharacterId(): Record<string, boolean> {
  const [snapshot, setSnapshot] = useState<Record<string, boolean>>(() =>
    Object.fromEntries(typingByCharacter.entries()),
  );

  useEffect(() => {
    setSnapshot(Object.fromEntries(typingByCharacter.entries()));
    return subscribe(() => {
      setSnapshot(Object.fromEntries(typingByCharacter.entries()));
    });
  }, []);

  return snapshot;
}
