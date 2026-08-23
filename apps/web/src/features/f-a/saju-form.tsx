'use client';

/**
 * 전통 사주 입력 폼.
 *
 * 요청 계약 (`supabase/functions/fortune-traditional-saju/index.ts`):
 * 함수는 생년월일을 받지 않는다. `question` 과 **이미 계산된** `sajuData` 만 읽고
 * (`const { question, sajuData, isPremium } = requestData`) 프롬프트를 만든다.
 * `sajuData` 를 안 보내면 서버 기본값(갑자·을축·병인·정묘, 목/수)으로 아무 관계
 * 없는 명식을 풀어버리므로, 4주 계산은 클라이언트가 해서 보내야 한다.
 *
 * 서버가 읽는 정확한 경로:
 *   sajuData.pillar.{year|month|day|time}.{heavenlyStem, earthlyBranch}
 *   sajuData.elements['목'|'화'|'토'|'금'|'수']
 *   sajuData.dominantElement / sajuData.lackingElement
 * (cohort 키도 `pillar.day.heavenlyStem` + `dominantElement` + `question` 이다.
 *  `hour` 가 아니라 `time` 인 것에 주의.)
 *
 * 계산은 앱과 같은 `@fortune/saju-engine` 을 쓴다 — 웹이 따로 만세력을 다시
 * 구현하면 같은 생일에 앱과 다른 명식이 나온다.
 */

import { calculateElements, calculatePillars } from '@fortune/saju-engine';
import { useState, type FormEvent } from 'react';

import { BirthDateField, BirthTimeChips, TextArea } from '@/features/fortune/fields';
import { FailureNotice } from '@/features/fortune/result';
import { runFortune, type FortuneFailureKind } from '@/features/fortune/runner';

import { SajuResult, type SajuChart, type SajuEnvelope, type SajuReading } from './saju-result';

const LOGIN_HREF = `/auth/login?next=${encodeURIComponent('/운세/사주')}`;

/** 질문이 비면 프롬프트에 "질문: undefined" 가 박힌다. 기본 질문으로 채운다. */
const DEFAULT_QUESTION = '제 사주의 전체적인 흐름과 올해 운을 알고 싶어요.';

/** '08:00~10:00' 같은 슬롯 라벨 → 엔진이 받는 'HH:mm'. 모름이면 undefined. */
function slotToTime(slot: string): string | undefined {
  const start = slot.split('~')[0]?.trim();
  return start && /^\d{2}:\d{2}$/.test(start) ? start : undefined;
}

interface SajuPayload {
  pillar: Record<string, { heavenlyStem: string; earthlyBranch: string }>;
  elements: Record<string, number>;
  dominantElement: string;
  lackingElement: string;
}

/** 화면용 4주/오행(=chart)과 서버로 보낼 sajuData 를 한 번에 만든다. */
function buildSaju(
  birthDate: string,
  birthTime: string | undefined,
): { chart: SajuChart; payload: SajuPayload } {
  const pillars = calculatePillars({
    birthDate,
    birthTime: birthTime ?? '00:00',
    // 4주/오행 계산은 성별을 쓰지 않는다 (대운 방향에만 쓰이는데 여기선 안 뽑는다).
    // 물어보지 않는 값을 폼에 세우지 않으려고 타입 충족용으로만 고정한다.
    gender: 'male',
  });
  const elements = calculateElements(pillars);
  // 서버 프롬프트가 읽는 키는 한글 오행이다 (`elements['목']` …).
  const elementCounts: Record<string, number> = {
    목: elements.wood,
    화: elements.fire,
    토: elements.earth,
    금: elements.metal,
    수: elements.water,
  };

  return {
    chart: {
      pillars: [
        { label: '년주', korean: pillars.year.korean, hanja: pillars.year.hanja },
        { label: '월주', korean: pillars.month.korean, hanja: pillars.month.hanja },
        { label: '일주', korean: pillars.day.korean, hanja: pillars.day.hanja },
        { label: '시주', korean: pillars.hour.korean, hanja: pillars.hour.hanja },
      ],
      elements: elementCounts,
      dominantElement: elements.strongest,
      lackingElement: elements.weakest,
      hasBirthTime: birthTime !== undefined,
    },
    payload: {
      pillar: {
        year: {
          heavenlyStem: pillars.year.stem.korean,
          earthlyBranch: pillars.year.branch.korean,
        },
        month: {
          heavenlyStem: pillars.month.stem.korean,
          earthlyBranch: pillars.month.branch.korean,
        },
        day: {
          heavenlyStem: pillars.day.stem.korean,
          earthlyBranch: pillars.day.branch.korean,
        },
        // 서버 키는 `time` 이다 (`pillar?.time`). `hour` 로 보내면 기본값으로 샌다.
        time: {
          heavenlyStem: pillars.hour.stem.korean,
          earthlyBranch: pillars.hour.branch.korean,
        },
      },
      elements: elementCounts,
      dominantElement: elements.strongest,
      lackingElement: elements.weakest,
    },
  };
}

type State =
  | { kind: 'idle' }
  | { kind: 'loading' }
  | { kind: 'done'; chart: SajuChart; reading: SajuReading }
  | { kind: 'failed'; failure: FortuneFailureKind; message: string };

export function SajuForm() {
  const [birthDate, setBirthDate] = useState('');
  const [birthTime, setBirthTime] = useState('');
  const [question, setQuestion] = useState('');
  const [state, setState] = useState<State>({ kind: 'idle' });

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!birthDate) return;
    setState({ kind: 'loading' });

    const { chart, payload } = buildSaju(birthDate, birthTime ? slotToTime(birthTime) : undefined);

    const result = await runFortune<SajuEnvelope>('traditional-saju', {
      question: question.trim() || DEFAULT_QUESTION,
      sajuData: payload,
    });

    if (!result.ok) {
      setState({ kind: 'failed', failure: result.kind, message: result.message });
      return;
    }

    const reading = result.data.data;
    if (!reading) {
      setState({
        kind: 'failed',
        failure: 'error',
        message: '사주 풀이가 비어 있어요. 잠시 후 다시 시도해 주세요.',
      });
      return;
    }

    setState({ kind: 'done', chart, reading });
  }

  return (
    <div className="ondo-stack">
      <form className="ondo-stack" onSubmit={handleSubmit}>
        <BirthDateField onChange={setBirthDate} value={birthDate} />
        <BirthTimeChips onChange={setBirthTime} value={birthTime} />

        <TextArea
          id="saju-question"
          label="궁금한 것 (선택)"
          maxLength={200}
          onChange={setQuestion}
          placeholder="예: 올해 이직을 해도 괜찮을까요?"
          rows={3}
          value={question}
        />

        <button
          className="ondo-button"
          disabled={state.kind === 'loading' || !birthDate}
          type="submit"
        >
          {state.kind === 'loading' ? '명식을 세우는 중…' : '사주 풀이 보기'}
        </button>
      </form>

      {state.kind === 'failed' ? (
        <FailureNotice kind={state.failure} loginHref={LOGIN_HREF} message={state.message} />
      ) : null}

      {state.kind === 'done' ? <SajuResult chart={state.chart} reading={state.reading} /> : null}
    </div>
  );
}
