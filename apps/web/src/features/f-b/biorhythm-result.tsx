/**
 * 바이오리듬 결과 — `supabase/functions/fortune-biorhythm/index.ts` 응답.
 *
 * 봉투는 `{ success, data, error }` 이고 `data` 안에 표준 필드(score/content/…)와
 * LLM 이 만든 원본 스키마가 함께 펼쳐져 들어온다.
 *
 * 서버는 생년월일로 23/28/33일 주기의 sin 값을 계산해 프롬프트에 넣고, LLM 이
 * 그 수치를 `physical.value` 등으로 되돌려준다. 그래서 세 수치는 -100~100 의
 * 연속값이고, 여기서는 차트 라이브러리 없이 CSS 폭으로 그린다.
 */

import {
  BulletList,
  CardList,
  Disclaimer,
  ScoreHeadline,
  type CardListItem,
} from '@/features/fortune/result';

export interface BiorhythmRhythm {
  score?: number;
  /** -100 ~ 100. 프롬프트가 요구한 범위. */
  value?: number;
  /** 'High' | 'Rising' | 'Transition' | 'Declining' | 'Recharge'. */
  phase?: string;
  status?: string;
  advice?: string;
}

export interface BiorhythmFortune {
  score?: number;
  content?: string;
  overall_score?: number;
  status_message?: string;
  physical?: BiorhythmRhythm;
  emotional?: BiorhythmRhythm;
  intellectual?: BiorhythmRhythm;
  today_recommendation?: {
    best_activity?: string;
    avoid_activity?: string;
    best_time?: string;
    energy_management?: string;
  };
  weekly_forecast?: {
    best_day?: string;
    worst_day?: string;
    overview?: string;
    weekly_advice?: string;
  };
  important_dates?: Array<{ date?: string; type?: string; description?: string }>;
  weekly_activities?: {
    physical_activities?: string[];
    mental_activities?: string[];
    rest_days?: string[];
  };
  personal_analysis?: {
    personality_insight?: string;
    life_phase?: string;
    current_challenge?: string;
    growth_opportunity?: string;
  };
  lifestyle_advice?: {
    sleep_pattern?: string;
    exercise_timing?: string;
    nutrition_tip?: string;
    stress_management?: string;
  };
  health_tips?: {
    physical_health?: string;
    mental_health?: string;
    energy_boost?: string;
    warning_signs?: string;
  };
  percentile?: number | null;
}

export interface BiorhythmEnvelope {
  success?: boolean;
  data?: BiorhythmFortune;
  error?: string;
}

/** 프롬프트가 영어 enum 을 요구해서 한국어로 바꿔 그린다. */
const PHASE_LABELS: Record<string, string> = {
  high: '최고조',
  rising: '상승',
  transition: '전환',
  declining: '하강',
  recharge: '재충전',
};

const IMPORTANT_DATE_LABELS: Record<string, string> = {
  high: '좋은 날',
  low: '낮은 날',
  critical: '주의할 날',
};

function clampValue(value: unknown): number | undefined {
  if (typeof value !== 'number' || !Number.isFinite(value)) return undefined;
  return Math.max(-100, Math.min(100, value));
}

function phaseLabel(phase: string | undefined): string | undefined {
  if (typeof phase !== 'string') return undefined;
  return PHASE_LABELS[phase.trim().toLowerCase()];
}

/**
 * 가운데(0)를 기준으로 좌우로 자라는 막대.
 *
 * 폭은 `|value| / 2` % — 값 100 이 트랙의 절반을 채운다. 수치는 막대 위에
 * 글자로도 적으므로 막대 자체는 `aria-hidden` 으로 둔다.
 */
function RhythmBar({
  label,
  cycle,
  rhythm,
}: {
  label: string;
  cycle: string;
  rhythm: BiorhythmRhythm | undefined;
}) {
  const value = clampValue(rhythm?.value);
  const status = rhythm?.status?.trim();
  const advice = rhythm?.advice?.trim();
  const phase = phaseLabel(rhythm?.phase);

  if (value === undefined && !status && !advice) return null;

  const positive = value !== undefined && value >= 0;
  // 부호는 반올림한 값 기준으로 붙인다 (0.4 를 '+0' 으로 적지 않게).
  const rounded = value === undefined ? undefined : Math.round(value);

  return (
    <div className="ondo-card ondo-stack" style={{ gap: 'var(--ondo-spacing-xxs)' }}>
      <p className="ondo-kicker">{`${label} · ${cycle}`}</p>

      {rounded !== undefined ? (
        <p className="ondo-h3">
          {`${rounded > 0 ? '+' : ''}${rounded}${phase ? ` · ${phase}` : ''}`}
        </p>
      ) : null}

      {value !== undefined ? (
        <div
          aria-hidden="true"
          style={{
            position: 'relative',
            height: '10px',
            borderRadius: 'var(--ondo-radius-full)',
            background: 'var(--ondo-color-surface-secondary)',
            border: '1px solid var(--ondo-color-border)',
            overflow: 'hidden',
          }}
        >
          <span
            style={{
              position: 'absolute',
              top: 0,
              bottom: 0,
              left: positive ? '50%' : `${50 + value / 2}%`,
              width: `${Math.abs(value) / 2}%`,
              background: positive ? 'var(--ondo-color-accent)' : 'var(--ondo-color-warning)',
            }}
          />
          <span
            style={{
              position: 'absolute',
              top: 0,
              bottom: 0,
              left: '50%',
              width: '1px',
              background: 'var(--ondo-color-divider)',
            }}
          />
        </div>
      ) : null}

      {status ? <p className="ondo-muted">{status}</p> : null}
      {advice ? <p className="ondo-muted">{advice}</p> : null}
    </div>
  );
}

/**
 * 라벨 고정 + 값 optional 인 섹션을 CardList 항목으로 만든다.
 *
 * 값이 없는 항목은 버린다 — 라벨이 항상 문자열이라 그냥 넘기면 CardList 의
 * 빈 항목 필터를 통과해서, 응답이 비었을 때 제목만 늘어선 껍데기 카드가 남는다.
 */
function pairs(entries: Array<[string, string | undefined]>): CardListItem[] {
  return entries
    .filter(([, description]) => typeof description === 'string' && description.trim().length > 0)
    .map(([title, description]) => ({ title, description }));
}

export function BiorhythmResult({ fortune }: { fortune: BiorhythmFortune }) {
  return (
    <section aria-label="바이오리듬 결과" className="ondo-stack">
      <ScoreHeadline
        kicker="바이오리듬"
        note={
          typeof fortune.percentile === 'number'
            ? `오늘 본 사람들 중 상위 ${fortune.percentile}%`
            : undefined
        }
        score={fortune.overall_score ?? fortune.score}
        summary={fortune.status_message ?? fortune.content}
      />

      <RhythmBar cycle="23일 주기" label="신체" rhythm={fortune.physical} />
      <RhythmBar cycle="28일 주기" label="감정" rhythm={fortune.emotional} />
      <RhythmBar cycle="33일 주기" label="지성" rhythm={fortune.intellectual} />

      <CardList
        items={pairs([
          ['추천 활동', fortune.today_recommendation?.best_activity],
          ['피할 활동', fortune.today_recommendation?.avoid_activity],
          ['최고 컨디션 시간', fortune.today_recommendation?.best_time],
          ['에너지 관리', fortune.today_recommendation?.energy_management],
        ])}
        label="오늘의 추천"
      />

      <CardList
        items={pairs([
          ['좋은 날', fortune.weekly_forecast?.best_day],
          ['주의할 날', fortune.weekly_forecast?.worst_day],
          ['흐름', fortune.weekly_forecast?.overview],
          ['전략', fortune.weekly_forecast?.weekly_advice],
        ])}
        label="이번 주"
      />

      <CardList
        items={(fortune.important_dates ?? []).map((entry) => {
          const type = entry?.type ? IMPORTANT_DATE_LABELS[entry.type.toLowerCase()] : undefined;
          const date = entry?.date;
          return {
            title: date && type ? `${date} · ${type}` : (date ?? type),
            description: entry?.description,
          };
        })}
        label="주요 날짜"
      />

      <BulletList items={fortune.weekly_activities?.physical_activities} label="몸을 위한 활동" />

      <BulletList items={fortune.weekly_activities?.mental_activities} label="머리를 위한 활동" />

      <BulletList items={fortune.weekly_activities?.rest_days} label="쉬어가는 날" />

      <CardList
        items={pairs([
          ['성격 인사이트', fortune.personal_analysis?.personality_insight],
          ['지금의 단계', fortune.personal_analysis?.life_phase],
          ['지금의 과제', fortune.personal_analysis?.current_challenge],
          ['성장 기회', fortune.personal_analysis?.growth_opportunity],
        ])}
        label="지금의 나"
      />

      <CardList
        items={pairs([
          ['수면', fortune.lifestyle_advice?.sleep_pattern],
          ['운동 타이밍', fortune.lifestyle_advice?.exercise_timing],
          ['영양', fortune.lifestyle_advice?.nutrition_tip],
          ['스트레스', fortune.lifestyle_advice?.stress_management],
        ])}
        label="생활 조언"
      />

      <CardList
        items={pairs([
          ['신체 건강', fortune.health_tips?.physical_health],
          ['마음 건강', fortune.health_tips?.mental_health],
          ['에너지 충전', fortune.health_tips?.energy_boost],
          ['주의 신호', fortune.health_tips?.warning_signs],
        ])}
        label="건강 관리"
      />

      <Disclaimer />
    </section>
  );
}
