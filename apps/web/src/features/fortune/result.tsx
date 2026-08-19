/**
 * 운세 결과 표시 프리미티브.
 *
 * 전제: 응답은 LLM 이 만든 JSON 이라 스키마가 있어도 필드가 통째로 빈다.
 * 그래서 모든 컴포넌트는 값이 없으면 **터지지 않고 아무것도 그리지 않는다**.
 * 호출부에서 `x ? <A/> : null` 로 감싸지 않아도 되게 하는 게 목적이다.
 *
 * 마크업은 `/운세/오늘` 결과 화면에서 그대로 뽑았다. 클래스는 globals.css 의
 * .ondo-* 만 쓰고 색은 tokens.css 의 var(--ondo-*) 로만 들어간다.
 *
 * 서버 컴포넌트로 그대로 쓸 수 있게 순수하게 유지한다 ('use client' 없음).
 */

import Link from 'next/link';
import type { ReactNode } from 'react';

import type { FortuneFailureKind } from './runner';

type MaybeText = string | null | undefined;

function cleanText(value: MaybeText): string | undefined {
  if (typeof value !== 'string') return undefined;
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : undefined;
}

function cleanList(values: ReadonlyArray<MaybeText> | null | undefined): string[] {
  if (!Array.isArray(values)) return [];
  return values.map(cleanText).filter((entry): entry is string => entry !== undefined);
}

function isScore(value: unknown): value is number {
  return typeof value === 'number' && Number.isFinite(value);
}

function toParagraphs(text: MaybeText | ReadonlyArray<MaybeText>): string[] {
  if (typeof text === 'string') return cleanList([text]);
  if (Array.isArray(text)) return cleanList(text);
  return [];
}

function Card({ children, gap }: { children: ReactNode; gap: string }) {
  return (
    <div className="ondo-card ondo-stack" style={{ gap }}>
      {children}
    </div>
  );
}

/** 큰 점수 + 한 줄 요약. 결과 화면 맨 위 블록. */
export function ScoreHeadline({
  kicker,
  score,
  summary,
  note,
  unit = '점',
}: {
  kicker?: MaybeText;
  score?: number | null;
  summary?: MaybeText;
  note?: MaybeText;
  unit?: string;
}) {
  const kickerText = cleanText(kicker);
  const summaryText = cleanText(summary);
  const noteText = cleanText(note);
  if (!kickerText && !isScore(score) && !summaryText && !noteText) return null;

  return (
    <Card gap="var(--ondo-spacing-xs)">
      {kickerText ? <p className="ondo-kicker">{kickerText}</p> : null}
      {isScore(score) ? (
        <p className="ondo-h1">
          {score}
          {unit}
        </p>
      ) : null}
      {summaryText ? <p>{summaryText}</p> : null}
      {noteText ? <p className="ondo-muted">{noteText}</p> : null}
    </Card>
  );
}

/** 라벨 + 점수 + 짧은 본문. 카테고리 카드(애정/재물/…)용. */
export function ScoreSection({
  label,
  score,
  text,
  unit = '점',
}: {
  label: string;
  score?: number | null;
  text?: MaybeText;
  unit?: string;
}) {
  const bodyText = cleanText(text);
  if (!isScore(score) && !bodyText) return null;

  return (
    <Card gap="var(--ondo-spacing-xxs)">
      <p className="ondo-kicker">{label}</p>
      {isScore(score) ? (
        <p className="ondo-h3">
          {score}
          {unit}
        </p>
      ) : null}
      {bodyText ? <p className="ondo-muted">{bodyText}</p> : null}
    </Card>
  );
}

/** 라벨 + 문단. 문자열 하나든 배열이든 받는다. */
export function TextSection({
  label,
  text,
}: {
  label: string;
  text?: MaybeText | ReadonlyArray<MaybeText>;
}) {
  const paragraphs = toParagraphs(text);
  if (paragraphs.length === 0) return null;

  return (
    <Card gap="var(--ondo-spacing-xs)">
      <p className="ondo-kicker">{label}</p>
      {paragraphs.map((paragraph, index) => (
        <p key={`${index}-${paragraph.slice(0, 12)}`}>{paragraph}</p>
      ))}
    </Card>
  );
}

/** 라벨 + 불릿. 빈 문자열/누락 항목은 걸러진다. */
export function BulletList({
  label,
  items,
}: {
  label: string;
  items?: ReadonlyArray<MaybeText> | null;
}) {
  const entries = cleanList(items);
  if (entries.length === 0) return null;

  return (
    <Card gap="var(--ondo-spacing-xs)">
      <p className="ondo-kicker">{label}</p>
      <ul
        className="ondo-stack"
        style={{ gap: 'var(--ondo-spacing-xs)', margin: 0, paddingLeft: '1.2em' }}
      >
        {entries.map((entry, index) => (
          <li key={`${index}-${entry.slice(0, 12)}`}>{entry}</li>
        ))}
      </ul>
    </Card>
  );
}

export interface KeyValuePair {
  label: string;
  value?: string | number | null;
}

function cleanPairValue(value: KeyValuePair['value']): string | undefined {
  if (isScore(value)) return String(value);
  return cleanText(typeof value === 'string' ? value : undefined);
}

/** 라벨 + 2열 정의 목록. 행운 요소(색/숫자/방향…) 같은 짧은 쌍 데이터용. */
export function KeyValueGrid({
  label,
  pairs,
}: {
  label: string;
  pairs?: ReadonlyArray<KeyValuePair> | null;
}) {
  const entries = (pairs ?? [])
    .map((pair) => ({ label: pair.label, value: cleanPairValue(pair.value) }))
    .filter((pair): pair is { label: string; value: string } => pair.value !== undefined);
  if (entries.length === 0) return null;

  return (
    <Card gap="var(--ondo-spacing-xs)">
      <p className="ondo-kicker">{label}</p>
      <dl className="ondo-grid-2" style={{ margin: 0 }}>
        {entries.map((pair, index) => (
          <div key={`${index}-${pair.label}`}>
            <dt className="ondo-muted">{pair.label}</dt>
            <dd style={{ margin: 0 }}>{pair.value}</dd>
          </div>
        ))}
      </dl>
    </Card>
  );
}

export interface CardListItem {
  title?: MaybeText;
  description?: MaybeText;
}

/** 라벨 + 제목/설명 항목 목록. '오늘 해볼 것' 같은 순서 있는 액션용. */
export function CardList({
  label,
  items,
}: {
  label: string;
  items?: ReadonlyArray<CardListItem> | null;
}) {
  const entries = (items ?? [])
    .map((item) => ({ title: cleanText(item.title), description: cleanText(item.description) }))
    .filter((item) => item.title !== undefined || item.description !== undefined);
  if (entries.length === 0) return null;

  return (
    <Card gap="var(--ondo-spacing-xs)">
      <p className="ondo-kicker">{label}</p>
      <ol
        className="ondo-stack"
        style={{ gap: 'var(--ondo-spacing-sm)', margin: 0, paddingLeft: '1.2em' }}
      >
        {entries.map((item, index) => (
          <li key={item.title ?? index}>
            {item.title ? <p className="ondo-h3">{item.title}</p> : null}
            {item.description ? <p className="ondo-muted">{item.description}</p> : null}
          </li>
        ))}
      </ol>
    </Card>
  );
}

/** 모든 결과 화면 하단에 붙는 엔터테인먼트 고지. 문구는 앱/랜딩과 동일하게 유지. */
export function Disclaimer() {
  return (
    <p className="ondo-muted">
      온도의 운세는 엔터테인먼트 목적으로 제공되며, 어떠한 전문적 조언도 대체하지 않습니다.
    </p>
  );
}

/**
 * `runFortune` 실패 3종을 그대로 그리는 안내.
 *
 * 12개 페이지가 각자 이 마크업을 복붙하면 문구가 갈라지므로 여기서 한 번만 쓴다.
 * `loginHref` 는 로그인 후 돌아올 경로를 담은 링크 (`/auth/login?next=...`).
 */
export function FailureNotice({
  kind,
  message,
  loginHref,
}: {
  kind: FortuneFailureKind;
  message: string;
  loginHref?: string;
}) {
  if (kind === 'auth') {
    return (
      <div className="ondo-notice ondo-stack" role="alert" style={{ gap: 'var(--ondo-spacing-sm)' }}>
        <p className="ondo-h3">로그인이 필요해요</p>
        <p className="ondo-muted">{message}</p>
        {loginHref ? (
          <Link className="ondo-button" href={loginHref}>
            다시 로그인
          </Link>
        ) : null}
      </div>
    );
  }

  if (kind === 'tokens') {
    return (
      <div className="ondo-notice ondo-stack" role="alert" style={{ gap: 'var(--ondo-spacing-sm)' }}>
        <p className="ondo-h3">온도가 부족해요</p>
        <p className="ondo-muted">{message}</p>
      </div>
    );
  }

  return (
    <p className="ondo-notice ondo-notice--error" role="alert">
      {message}
    </p>
  );
}
