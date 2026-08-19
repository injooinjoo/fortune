/**
 * 캐릭터 아바타.
 *
 * 이미지가 없다 — 앱의 캐릭터 사진은 `apps/mobile-rn` 번들 안 require 에셋이라
 * 웹에서 참조할 수 없다. 대신 이름 첫 글자 + 캐릭터별 chip 토큰 배경으로
 * 구분한다. 색은 tokens.css 의 --ondo-color-chip-* 만 쓴다.
 *
 * 'use client' 없이 순수하게 유지한다 — 목록 페이지(서버 컴포넌트)와
 * 스레드(클라이언트 컴포넌트)가 같이 쓴다.
 */

import type { WebChatCharacter } from './characters';
import styles from './chat.module.css';

export function CharacterAvatar({
  character,
  className,
  large,
}: {
  character: WebChatCharacter;
  className?: string;
  large?: boolean;
}) {
  const base = large ? styles.cardAvatar : styles.avatar;

  return (
    <span
      aria-hidden="true"
      className={className ? `${base} ${className}` : base}
      style={{ background: `var(${character.accentToken})` }}
    >
      {character.name.slice(0, 1)}
    </span>
  );
}
