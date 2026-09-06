'use client';

import { useRef, useState } from 'react';

import { FortuneLinkCard } from '@/components/fortune-link-card';
import type { WebFortune } from './catalog';

export function FortuneExplorer({ sections }: {
  sections: Array<{ group: string; fortunes: WebFortune[] }>;
}) {
  const [query, setQuery] = useState('');
  const [group, setGroup] = useState('');
  const searchRef = useRef<HTMLInputElement>(null);
  const search = query.trim().toLocaleLowerCase('ko-KR').replace(/\s+/g, '');
  const filtered = sections
    .filter((section) => !group || section.group === group)
    .map((section) => ({
      ...section,
      fortunes: section.fortunes.filter((fortune) =>
        `${fortune.title} ${fortune.blurb}`.toLocaleLowerCase('ko-KR').replace(/\s+/g, '').includes(search)),
    }))
    .filter((section) => section.fortunes.length > 0);
  const count = filtered.reduce((total, section) => total + section.fortunes.length, 0);

  function reset() {
    setQuery('');
    setGroup('');
    searchRef.current?.focus();
  }

  return (
    <div className="ondo-stack">
      <section aria-label="운세 찾기" className="ondo-explorer-controls ondo-stack">
        <div>
          <label className="ondo-label" htmlFor="fortune-search">운세 검색</label>
          <input
            autoComplete="off"
            className="ondo-input"
            id="fortune-search"
            onChange={(event) => setQuery(event.target.value)}
            placeholder="타로, 연애, 꿈처럼 궁금한 주제를 찾아보세요"
            ref={searchRef}
            type="search"
            value={query}
          />
        </div>
        <div aria-label="운세 분야" className="ondo-row" role="group">
          {['', ...sections.map((section) => section.group)].map((option) => (
            <button
              aria-pressed={group === option}
              className="ondo-chip"
              key={option}
              onClick={() => setGroup(option)}
              type="button"
            >
              {option || '전체'}
            </button>
          ))}
        </div>
        <p className="ondo-field-hint" role="status">{count}개의 운세 · 시작 전에 온도 사용량을 확인해 주세요.</p>
      </section>

      {filtered.length === 0 ? (
        <div className="ondo-card ondo-stack">
          <h2 className="ondo-h3">조건에 맞는 운세가 없어요.</h2>
          <p className="ondo-muted">검색어를 짧게 바꾸거나 다른 분야를 선택해 보세요.</p>
          <button className="ondo-button ondo-button--secondary" onClick={reset} type="button">전체 운세 보기</button>
        </div>
      ) : filtered.map((section) => {
        const headingId = `fortune-group-${sections.findIndex((item) => item.group === section.group)}`;
        return (
          <section aria-labelledby={headingId} className="ondo-stack ondo-fortune-group" key={section.group}>
            <h2 className="ondo-h3" id={headingId}>{section.group}</h2>
            <div className="ondo-fortune-list">
              {section.fortunes.map((fortune) => <FortuneLinkCard fortune={fortune} key={fortune.slug} />)}
            </div>
          </section>
        );
      })}
    </div>
  );
}
