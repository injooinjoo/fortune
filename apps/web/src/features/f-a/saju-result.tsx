/**
 * 전통 사주 결과.
 *
 * 응답 계약 (`supabase/functions/fortune-traditional-saju/index.ts`):
 * 봉투는 `{ success, data }`, 본문은
 * `{ fortuneType, score, content, summary, advice, question, sections, saju_summary }`.
 * `sections` 는 LLM 이 만든 `{ analysis, answer, advice, supplement }` 네 덩어리다.
 * cohort pool 히트 경로는 저장된 payload 를 그대로 돌려주므로 sections 가
 * 통째로 없을 수 있고, 그때는 `content`/`summary` 만 남는다.
 *
 * 사주 명식(4주)은 **응답에 없다** — 서버는 클라가 보낸 `sajuData` 를 프롬프트에만
 * 쓰고 되돌려주지 않는다. 그래서 4주는 폼에서 계산한 값을 그대로 받아 그린다.
 */

import { Disclaimer, KeyValueGrid, ScoreHeadline, TextSection } from '@/features/fortune/result';

import { splitParagraphs } from './text';

/** 폼이 `@fortune/saju-engine` 으로 계산해서 서버로 보낸 것과 같은 값. */
/** 오행 표시 순서. saju-engine 의 elements 키와 동일. */
const ELEMENT_LABELS = ['목', '화', '토', '금', '수'] as const;

export interface SajuPillarView {
  /** '년주' / '월주' / '일주' / '시주' */
  label: string;
  /** 간지 한글, 예: '갑자' */
  korean: string;
  /** 간지 한자, 예: '甲子' */
  hanja: string;
}

export interface SajuChart {
  pillars: SajuPillarView[];
  /** 오행 개수. 키는 목/화/토/금/수. */
  elements: Record<string, number>;
  dominantElement: string;
  lackingElement: string;
  /** 태어난 시간을 안 받았으면 시주는 추정값이라 화면에서 구분해야 한다. */
  hasBirthTime: boolean;
}

export interface SajuSections {
  analysis?: string;
  answer?: string;
  advice?: string;
  supplement?: string;
}

export interface SajuReading {
  score?: number;
  content?: string;
  summary?: string;
  advice?: string;
  question?: string;
  sections?: SajuSections;
  saju_summary?: string;
  percentile?: number | null;
  isPercentileValid?: boolean;
}

export interface SajuEnvelope {
  success?: boolean;
  data?: SajuReading;
}

export function SajuResult({ chart, reading }: { chart: SajuChart; reading: SajuReading }) {
  const sections = reading.sections ?? {};

  // 시간 미입력이면 시주는 자정 기준 추정이라 명식에서 뺀다 (없는 사실 만들지 않기).
  // pillars 는 로컬 saju-engine 산출물이라 정상 흐름에선 항상 배열이지만,
  // 엔진이 실패해 빈 객체가 넘어와도 화면 전체가 죽지 않게 배열 여부를 확인한다.
  const pillars = Array.isArray(chart.pillars) ? chart.pillars : [];
  const shownPillars = chart.hasBirthTime
    ? pillars
    : pillars.filter((pillar) => pillar.label !== '시주');

  // 같은 이유로 오행 카운트도 없을 수 있다. KeyValueGrid 가 undefined 행을 걸러준다.
  const elements: Record<string, number | undefined> =
    chart.elements !== null && typeof chart.elements === 'object' ? chart.elements : {};

  return (
    <section aria-label="사주 풀이 결과" className="ondo-stack">
      <ScoreHeadline
        kicker="사주 풀이"
        note={
          reading.isPercentileValid === true && typeof reading.percentile === 'number'
            ? `오늘 사주를 본 사람들 중 상위 ${reading.percentile}%`
            : undefined
        }
        summary={reading.summary ?? reading.saju_summary}
      />

      <KeyValueGrid
        label="사주 명식"
        pairs={shownPillars.map((pillar) => ({
          label: pillar.label,
          value: `${pillar.korean} (${pillar.hanja})`,
        }))}
      />

      {chart.hasBirthTime ? null : (
        <p className="ondo-muted">
          태어난 시간을 알려주면 시주(時柱)까지 세워 더 정확하게 풀어드려요.
        </p>
      )}

      <KeyValueGrid
        label="오행 분포"
        pairs={[
          ...ELEMENT_LABELS.map((element) => ({ label: element, value: elements[element] })),
          { label: '가장 강한 기운', value: chart.dominantElement },
          { label: '보완할 기운', value: chart.lackingElement },
        ]}
      />

      <TextSection label="사주 분석" text={splitParagraphs(sections.analysis ?? reading.content)} />

      <TextSection label="질문에 대한 답" text={splitParagraphs(sections.answer)} />

      <TextSection label="조언" text={splitParagraphs(sections.advice ?? reading.advice)} />

      <TextSection label="오행 보완법" text={splitParagraphs(sections.supplement)} />

      <Disclaimer />
    </section>
  );
}
