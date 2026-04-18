import { useMemo } from 'react';
import { View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { Card } from '../../../components/card';
import { calculateManseryeok } from '../../../lib/manseryeok-local';
import { fortuneTheme } from '../../../lib/theme';
import { useMobileAppState } from '../../../providers/mobile-app-state-provider';
import { ManseryeokCard } from '../manseryeok-card';
import { resultMetadataByKind } from '../mapping';
import {
  BulletList,
  HeroCard,
  InsetQuote,
  KeywordPills,
  MetricGrid,
  SectionCard,
  StatRail,
} from '../primitives';
import type { FortuneResultComponentProps } from '../types';
import { useResultData } from '../use-result-data';

/* ------------------------------------------------------------------ */
/*  12지신 (Zodiac Animals) lookup                                     */
/* ------------------------------------------------------------------ */

const ZODIAC_ANIMALS = [
  { emoji: '🐭', name: '쥐', branch: '자', element: '수(水)' },
  { emoji: '🐄', name: '소', branch: '축', element: '토(土)' },
  { emoji: '🐯', name: '호랑이', branch: '인', element: '목(木)' },
  { emoji: '🐰', name: '토끼', branch: '묘', element: '목(木)' },
  { emoji: '🐉', name: '용', branch: '진', element: '토(土)' },
  { emoji: '🐍', name: '뱀', branch: '사', element: '화(火)' },
  { emoji: '🐴', name: '말', branch: '오', element: '화(火)' },
  { emoji: '🐑', name: '양', branch: '미', element: '토(土)' },
  { emoji: '🐵', name: '원숭이', branch: '신', element: '금(金)' },
  { emoji: '🐓', name: '닭', branch: '유', element: '금(金)' },
  { emoji: '🐶', name: '개', branch: '술', element: '토(土)' },
  { emoji: '🐷', name: '돼지', branch: '해', element: '수(水)' },
] as const;

/** Lookup an animal emoji by Korean name (e.g. '원숭이' -> '🐵') */
function zodiacEmojiByName(name: string): string {
  return ZODIAC_ANIMALS.find((a) => a.name === name)?.emoji ?? '';
}

function deriveZodiacAnimal(birthYear: number) {
  const index = ((birthYear - 4) % 12 + 12) % 12;
  return ZODIAC_ANIMALS[index]!;
}

/* ------------------------------------------------------------------ */
/*  12별자리 (Constellations / Western Zodiac) lookup                   */
/* ------------------------------------------------------------------ */

const CONSTELLATIONS = [
  { emoji: '♈', name: '양자리', en: 'Aries', startMonth: 3, startDay: 21, endMonth: 4, endDay: 19, element: '불(Fire)', planet: '화성' },
  { emoji: '♉', name: '황소자리', en: 'Taurus', startMonth: 4, startDay: 20, endMonth: 5, endDay: 20, element: '흙(Earth)', planet: '금성' },
  { emoji: '♊', name: '쌍둥이자리', en: 'Gemini', startMonth: 5, startDay: 21, endMonth: 6, endDay: 21, element: '공기(Air)', planet: '수성' },
  { emoji: '♋', name: '게자리', en: 'Cancer', startMonth: 6, startDay: 22, endMonth: 7, endDay: 22, element: '물(Water)', planet: '달' },
  { emoji: '♌', name: '사자자리', en: 'Leo', startMonth: 7, startDay: 23, endMonth: 8, endDay: 22, element: '불(Fire)', planet: '태양' },
  { emoji: '♍', name: '처녀자리', en: 'Virgo', startMonth: 8, startDay: 23, endMonth: 9, endDay: 22, element: '흙(Earth)', planet: '수성' },
  { emoji: '♎', name: '천칭자리', en: 'Libra', startMonth: 9, startDay: 23, endMonth: 10, endDay: 23, element: '공기(Air)', planet: '금성' },
  { emoji: '♏', name: '전갈자리', en: 'Scorpio', startMonth: 10, startDay: 24, endMonth: 11, endDay: 22, element: '물(Water)', planet: '명왕성' },
  { emoji: '♐', name: '사수자리', en: 'Sagittarius', startMonth: 11, startDay: 23, endMonth: 12, endDay: 21, element: '불(Fire)', planet: '목성' },
  { emoji: '♑', name: '염소자리', en: 'Capricorn', startMonth: 12, startDay: 22, endMonth: 1, endDay: 19, element: '흙(Earth)', planet: '토성' },
  { emoji: '♒', name: '물병자리', en: 'Aquarius', startMonth: 1, startDay: 20, endMonth: 2, endDay: 18, element: '공기(Air)', planet: '천왕성' },
  { emoji: '♓', name: '물고기자리', en: 'Pisces', startMonth: 2, startDay: 19, endMonth: 3, endDay: 20, element: '물(Water)', planet: '해왕성' },
] as const;

/** Derive constellation from a birth date string (e.g. "1992-04-15" or Date). */
function deriveConstellation(birthDate: string | Date) {
  const d = typeof birthDate === 'string' ? new Date(birthDate) : birthDate;
  const month = d.getMonth() + 1; // 1-12
  const day = d.getDate();

  for (const c of CONSTELLATIONS) {
    // Capricorn spans Dec-Jan so handle wrap-around
    if (c.startMonth > c.endMonth) {
      // e.g. startMonth=12, endMonth=1
      if ((month === c.startMonth && day >= c.startDay) || (month === c.endMonth && day <= c.endDay)) {
        return c;
      }
    } else {
      if (
        (month === c.startMonth && day >= c.startDay) ||
        (month === c.endMonth && day <= c.endDay) ||
        (month > c.startMonth && month < c.endMonth)
      ) {
        return c;
      }
    }
  }
  // Fallback: Aries
  return CONSTELLATIONS[0]!;
}

/** Format constellation date range for display (e.g. "3.21 ~ 4.19") */
function constellationDateRange(c: (typeof CONSTELLATIONS)[number]): string {
  return `${c.startMonth}.${c.startDay} ~ ${c.endMonth}.${c.endDay}`;
}

/* ------------------------------------------------------------------ */
/*  1. TraditionalSajuResult                                          */
/* ------------------------------------------------------------------ */

function TraditionalSajuResult(props: FortuneResultComponentProps) {
  const meta = resultMetadataByKind['traditional-saju'];
  const result = useResultData(props.payload);
  const raw = _obj(props.payload?.rawApiResponse);
  const data = _obj(raw.data ?? raw.fortune ?? raw);

  // Direct API fields
  const sections = _obj(data.sections);
  const analysis = _str(sections.analysis);
  const answer = _str(sections.answer);
  const adviceText = _str(sections.advice) || _str(data.advice);
  const supplement = _str(sections.supplement);
  const sajuSummary = _str(data.saju_summary);
  const question = _str(data.question);

  const pillarMetrics = result.hasApiData && result.metrics.length >= 4
    ? result.metrics.slice(0, 4)
    : [
        { label: '년주', value: '갑인', note: '기본 기질과 시작점' },
        { label: '월주', value: '정사', note: '현재 흐름과 환경' },
        { label: '일주', value: '병오', note: '핵심 에너지' },
        { label: '시주', value: '계해', note: '저녁 이후 집중력' },
      ];

  const elementStats = result.hasApiData && result.metrics.length >= 9
    ? result.metrics.slice(4, 9).map((m) => ({
        label: m.label,
        value: parseInt(m.value, 10) || 70,
        highlight: m.note,
      }))
    : [
        { label: '목', value: 82, highlight: '확장성과 시작 에너지가 좋습니다.' },
        { label: '화', value: 91, highlight: '표현력과 추진력이 강하게 나옵니다.' },
        { label: '토', value: 64, highlight: '중간 정리 역할을 의식해야 합니다.' },
        { label: '금', value: 58, highlight: '판단을 단단하게 묶는 힘은 보강 필요.' },
        { label: '수', value: 70, highlight: '휴식과 회복은 의외로 괜찮은 편입니다.' },
      ];

  const highlights = result.hasApiData && result.highlights.length > 0
    ? result.highlights
    : [
        '오늘은 강한 화 기운이 보이므로, 새로운 일을 벌이기보다 이미 시작한 일을 밀어붙이는 편이 좋습니다.',
        '토와 금이 약한 편이라 감정이 올라오면 판단이 급해질 수 있습니다.',
      ];

  const fortuneMetrics = result.hasApiData && result.metrics.length >= 13
    ? result.metrics.slice(9, 13)
    : [
        { label: '일 흐름', value: '상', note: '오전부터 속도가 붙습니다.' },
        { label: '대인운', value: '중상', note: '짧고 분명한 대화가 좋음' },
        { label: '재물운', value: '중', note: '수익보다 정리가 우선' },
        { label: '회복운', value: '중상', note: '잠깐 쉬어야 운이 유지됩니다.' },
      ];

  const summary = sajuSummary || (result.hasApiData && result.summary
    ? result.summary
    : '오행의 균형은 크게 흔들리지 않지만, 오늘은 강한 기운을 어디에 쓰는지가 더 중요합니다.');

  const chips = result.hasApiData && result.contextTags.length > 0
    ? result.contextTags
    : ['오행 균형', '사주 포인트', '핵심 흐름'];

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard
        emoji="☯️"
        title={meta.title}
        description={summary}
        chips={chips}
      />

      <SectionCard title="사주 기둥" description="네 개의 기둥을 나눠서 오늘의 흐름을 쉽게 읽을 수 있게 정리했어요.">
        <MetricGrid items={pillarMetrics} />
      </SectionCard>

      <SectionCard title="오행 분포" description="강한 기운과 보완이 필요한 기운을 한눈에 읽는 구간입니다.">
        <StatRail items={elementStats} />
      </SectionCard>

      {/* Raw sections from API */}
      {analysis ? (
        <SectionCard title="사주 분석">
          <AppText variant="oracleBody" color={fortuneTheme.colors.textPrimary}>{analysis}</AppText>
        </SectionCard>
      ) : null}

      {answer ? (
        <SectionCard title="질문 답변">
          <AppText variant="oracleBody" color={fortuneTheme.colors.textPrimary}>{answer}</AppText>
        </SectionCard>
      ) : null}

      <SectionCard title="핵심 포인트">
        <BulletList items={highlights} />
      </SectionCard>

      <SectionCard title="인사이트 포인트">
        <MetricGrid items={fortuneMetrics} />
      </SectionCard>

      {adviceText ? (
        <SectionCard title="조언">
          <AppText variant="oracleBody" color={fortuneTheme.colors.textPrimary}>{adviceText}</AppText>
        </SectionCard>
      ) : null}

      {supplement ? (
        <SectionCard title="보완 방법">
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>{supplement}</AppText>
        </SectionCard>
      ) : null}
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  2. DailyCalendarResult                                            */
/* ------------------------------------------------------------------ */

/* Raw API response type helpers (same pattern as face-reading) */
type R = Record<string, unknown>;

function _obj(val: unknown): R {
  return val != null && typeof val === 'object' && !Array.isArray(val)
    ? (val as R)
    : {};
}

function _str(val: unknown, fallback = ''): string {
  return typeof val === 'string' && val.trim() ? val.trim() : fallback;
}

function _num(val: unknown, fallback = 0): number {
  if (typeof val === 'number' && !Number.isNaN(val)) return val;
  if (typeof val === 'string') {
    const n = Number(val);
    if (!Number.isNaN(n)) return n;
  }
  return fallback;
}

function _arr(val: unknown): unknown[] {
  return Array.isArray(val) ? val : [];
}

function _strArr(val: unknown): string[] {
  return _arr(val)
    .map((v) => _str(v))
    .filter(Boolean);
}

/* Category display config */
const CATEGORY_META: Record<string, { label: string; emoji: string; color: string }> = {
  love:   { label: '연애', emoji: '💕', color: '#F06292' },
  money:  { label: '재물', emoji: '💰', color: '#FFD54F' },
  work:   { label: '직업', emoji: '💼', color: '#8FB8FF' },
  study:  { label: '학업', emoji: '📚', color: '#81C784' },
  health: { label: '건강', emoji: '🏃', color: '#4DD0E1' },
};

/* Lucky item display config */
const LUCKY_ITEM_META: Record<string, { label: string; emoji: string; color: string }> = {
  color:     { label: '색상', emoji: '🎨', color: '#F06292' },
  number:    { label: '숫자', emoji: '🔢', color: '#FFD54F' },
  direction: { label: '방위', emoji: '🧭', color: '#81C784' },
  time:      { label: '시간', emoji: '⏰', color: '#8FB8FF' },
  food:      { label: '음식', emoji: '🍽️', color: '#FF8A65' },
  item:      { label: '아이템', emoji: '✨', color: '#CE93D8' },
};

function DailyCalendarResult(props: FortuneResultComponentProps) {
  const manseryeokData = useMemo(() => calculateManseryeok(), []);
  const result = useResultData(props.payload);
  const raw = _obj(props.payload?.rawApiResponse);
  const hasRaw = Object.keys(raw).length > 0;

  /* --- Categories (love, money, work, study, health) --- */
  const categories = _obj(raw.categories);
  const totalCat = _obj(categories.total);

  const categoryStatItems = (['love', 'money', 'work', 'study', 'health'] as const)
    .map((key) => {
      const cat = _obj(categories[key]);
      const advice = _obj(cat.advice);
      const m = CATEGORY_META[key]!;
      return {
        key,
        label: m.label,
        emoji: m.emoji,
        color: m.color,
        value: _num(cat.score, 70),
        highlight: _str(advice.description) || _str(advice.detail),
        detail: _str(advice.detail),
      };
    });

  const hasCategoryData = hasRaw && categoryStatItems.some((c) => c.value > 0);

  /* --- Lucky Items --- */
  const luckyItems = _obj(raw.lucky_items);
  const luckyEntries = (['color', 'number', 'direction', 'time', 'food', 'item'] as const)
    .map((key) => {
      const val = _str(luckyItems[key]);
      const m = LUCKY_ITEM_META[key]!;
      return { key, value: val, ...m };
    })
    .filter((e) => e.value);

  const hasLuckyItems = hasRaw && luckyEntries.length > 0;

  /* --- Special Tip & AI Insight --- */
  const specialTip = _str(raw.special_tip) || (result.hasApiData ? result.specialTip : undefined);
  const aiInsight = _str(raw.ai_insight);
  const aiTips = _arr(raw.ai_tips).map((t) => _str(t)).filter(Boolean);

  /* --- Celebrities same day --- */
  const celebsSameDay = _arr(raw.celebrities_same_day)
    .map((c) => {
      const cel = _obj(c);
      return {
        name: _str(cel.name),
        year: _str(cel.year),
        description: _str(cel.description),
      };
    })
    .filter((c) => c.name);

  /* --- Age Fortune --- */
  const ageFortune = _obj(raw.age_fortune);
  const ageGroup = _str(ageFortune.ageGroup);
  const ageTitle = _str(ageFortune.title);
  const ageDescription = _str(ageFortune.description);
  const hasAgeFortune = !!(ageGroup || ageTitle);

  /* --- Missing fields: personalActions, caution, lucky_outfit, daily_predictions, lucky_numbers --- */
  const personalActions = _arr(raw.personalActions)
    .map((a) => {
      const act = _obj(a);
      const title = _str(act.title);
      const why = _str(act.why);
      return title ? (why ? `${title}: ${why}` : title) : '';
    })
    .filter(Boolean);

  const caution = _str(raw.caution);

  const luckyOutfit = _obj(raw.lucky_outfit);
  const outfitTitle = _str(luckyOutfit.title);
  const outfitItems = _arr(luckyOutfit.items).map((i) => _str(i)).filter(Boolean);

  const dailyPredictions = _obj(raw.daily_predictions);
  const hasDailyPredictions = _num(dailyPredictions.tomorrow) > 0 || _num(dailyPredictions.yesterday) > 0;

  const luckyNumbers = _arr(raw.lucky_numbers).map((n) => String(n)).filter(Boolean);

  const celebsSimilarSaju = _arr(raw.celebrities_similar_saju)
    .map((c) => {
      const cel = _obj(c);
      return { name: _str(cel.name), year: _str(cel.year), description: _str(cel.description) };
    })
    .filter((c) => c.name);

  const godlife = _str(raw.godlife);
  const greeting = _str(raw.greeting);

  /* --- Fortune Summary (by MBTI, zodiac sign, zodiac animal) --- */
  const fortuneSummaryObj = _obj(raw.fortuneSummary);
  const byMBTI = _obj(fortuneSummaryObj.byMBTI);
  const byZodiacSign = _obj(fortuneSummaryObj.byZodiacSign);
  const byZodiacAnimal = _obj(fortuneSummaryObj.byZodiacAnimal);
  const hasFortuneSummary = _str(byMBTI.title) || _str(byZodiacSign.title) || _str(byZodiacAnimal.title);

  /* --- Saju Insight --- */
  const sajuInsight = _obj(raw.sajuInsight);
  const sajuKeyword = _str(sajuInsight.keyword);

  /* --- Summary (no chips / no context tags — they looked like debug) --- */
  const summary = result.hasApiData && result.summary
    ? result.summary
    : '날짜의 흐름은 차분하지만, 계절 에너지와 개인 리듬이 겹치는 순간에 운이 선명하게 보입니다.';

  /* --- Total score --- */
  const totalIdiom = _str(_obj(totalCat.advice).idiom);
  const totalDescription = _str(_obj(totalCat.advice).description);
  const totalScore = _num(totalCat.score, result.score ?? 75);

  /* --- Fallback: season highlights (when no raw data) --- */
  const seasonHighlights = result.hasApiData && result.highlights.length > 0
    ? result.highlights
    : [
        '봄의 기운이 강해 새로운 시도에 유리하지만, 과속하면 마무리가 흐려질 수 있습니다.',
        '지금은 큰 결론보다 "첫 버튼"을 누르는 선택이 더 잘 맞습니다.',
        '외부 자극이 많아도 내 루틴을 잃지 않으면 하루 전체가 안정됩니다.',
      ];

  /* Score ring color */
  const scoreColor =
    totalScore >= 80
      ? '#4CAF50'
      : totalScore >= 60
        ? '#FFD54F'
        : '#FF8A65';

  return (
    <View style={{ gap: fortuneTheme.spacing.sm }}>
      {/* ===== MANSERYEOK CARD — THE HERO ===== */}
      <ManseryeokCard data={manseryeokData} />

      {/* ===== Summary + Score ===== */}
      <Card
        style={{
          backgroundColor: fortuneTheme.colors.backgroundTertiary,
          borderWidth: 0,
          gap: fortuneTheme.spacing.md,
          padding: fortuneTheme.spacing.lg,
        }}
      >
        <View
          style={{
            flexDirection: 'row',
            gap: fortuneTheme.spacing.md,
            alignItems: 'center',
          }}
        >
          {/* Score circle */}
          {hasRaw && totalScore > 0 ? (
            <View
              style={{
                width: 80,
                height: 80,
                borderRadius: 40,
                borderWidth: 4,
                borderColor: scoreColor,
                alignItems: 'center',
                justifyContent: 'center',
                backgroundColor: `${scoreColor}15`,
                shadowColor: scoreColor,
                shadowOpacity: 0.3,
                shadowRadius: 12,
                shadowOffset: { width: 0, height: 2 },
                flexShrink: 0,
              }}
            >
              <AppText style={{ fontSize: 28, fontWeight: '800', color: scoreColor }}>
                {totalScore}
              </AppText>
              <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
                종합
              </AppText>
            </View>
          ) : null}

          {/* Summary text */}
          <View style={{ flex: 1, gap: fortuneTheme.spacing.xs }}>
            {totalIdiom ? (
              <AppText variant="labelMedium" color={fortuneTheme.colors.accentTertiary}>
                {totalIdiom}
              </AppText>
            ) : null}
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              {totalDescription || summary}
            </AppText>
          </View>
        </View>
      </Card>

      {/* ===== Category Score Cards (colored) ===== */}
      {hasCategoryData ? (
        <View style={{ gap: fortuneTheme.spacing.sm }}>
          <View style={{ paddingHorizontal: 4 }}>
            <AppText variant="labelLarge" color={fortuneTheme.colors.textPrimary}>
              카테고리별 인사이트
            </AppText>
          </View>

          {/* Score cards — 2 per row, colored accent */}
          <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: fortuneTheme.spacing.sm }}>
            {categoryStatItems.map((cat) => {
              const scoreVal = cat.value;
              return (
                <View
                  key={cat.key}
                  style={{ minWidth: '47%', flexGrow: 1, flexBasis: '47%' }}
                >
                  <Card
                    style={{
                      backgroundColor: fortuneTheme.colors.backgroundTertiary,
                      borderWidth: 1,
                      borderColor: `${cat.color}30`,
                      gap: fortuneTheme.spacing.sm,
                    }}
                  >
                    {/* Header: emoji + label + score */}
                    <View
                      style={{
                        flexDirection: 'row',
                        justifyContent: 'space-between',
                        alignItems: 'center',
                      }}
                    >
                      <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
                        <AppText style={{ fontSize: 18 }}>{cat.emoji}</AppText>
                        <AppText variant="labelLarge" color={fortuneTheme.colors.textPrimary}>
                          {cat.label}
                        </AppText>
                      </View>
                      <AppText
                        style={{ fontSize: 22, fontWeight: '800', color: cat.color }}
                      >
                        {scoreVal}
                      </AppText>
                    </View>

                    {/* Score bar */}
                    <View
                      style={{
                        backgroundColor: fortuneTheme.colors.surfaceSecondary,
                        borderRadius: fortuneTheme.radius.full,
                        height: 6,
                        overflow: 'hidden',
                      }}
                    >
                      <View
                        style={{
                          backgroundColor: cat.color,
                          borderRadius: fortuneTheme.radius.full,
                          height: '100%',
                          width: `${Math.max(0, Math.min(100, scoreVal))}%`,
                        }}
                      />
                    </View>

                    {/* Advice snippet */}
                    {cat.highlight ? (
                      <AppText
                        variant="caption"
                        color={fortuneTheme.colors.textTertiary}
                        numberOfLines={2}
                      >
                        {cat.highlight}
                      </AppText>
                    ) : null}
                  </Card>
                </View>
              );
            })}
          </View>
        </View>
      ) : (
        /* Fallback: season highlights */
        <Card
          style={{
            backgroundColor: fortuneTheme.colors.backgroundTertiary,
            borderWidth: 0,
            gap: fortuneTheme.spacing.md,
          }}
        >
          <AppText variant="labelLarge" color={fortuneTheme.colors.textPrimary}>계절 해석</AppText>
          <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
            계절과 날짜 흐름을 함께 읽어 오늘의 타이밍을 정리했어요.
          </AppText>
          <BulletList items={seasonHighlights} />
        </Card>
      )}

      {/* ===== Lucky Items — colored pills ===== */}
      {hasLuckyItems ? (
        <Card
          style={{
            backgroundColor: fortuneTheme.colors.backgroundTertiary,
            borderWidth: 0,
            gap: fortuneTheme.spacing.md,
          }}
        >
          <AppText variant="labelLarge" color={fortuneTheme.colors.textPrimary}>행운 아이템</AppText>

          <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: fortuneTheme.spacing.sm }}>
            {luckyEntries.map((entry) => (
              <View
                key={entry.key}
                style={{
                  flexDirection: 'row',
                  alignItems: 'center',
                  gap: 8,
                  backgroundColor: `${entry.color}18`,
                  borderRadius: fortuneTheme.radius.chip,
                  borderWidth: 1,
                  borderColor: `${entry.color}30`,
                  paddingHorizontal: 14,
                  paddingVertical: 8,
                }}
              >
                <AppText style={{ fontSize: 16 }}>{entry.emoji}</AppText>
                <View style={{ gap: 1 }}>
                  <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
                    {entry.label}
                  </AppText>
                  <AppText variant="labelLarge" color={entry.color}>
                    {entry.value}
                  </AppText>
                </View>
              </View>
            ))}
          </View>
        </Card>
      ) : null}

      {/* ===== Special Tip / AI Insight — combined quote block ===== */}
      {specialTip || aiInsight ? (
        <Card
          style={{
            backgroundColor: fortuneTheme.colors.backgroundTertiary,
            borderWidth: 0,
            gap: fortuneTheme.spacing.md,
          }}
        >
          <AppText variant="labelLarge" color={fortuneTheme.colors.textPrimary}>
            {specialTip && aiInsight ? '팁 & 인사이트' : specialTip ? '스페셜 팁' : 'AI 인사이트'}
          </AppText>
          {specialTip ? <InsetQuote text={specialTip} /> : null}
          {aiInsight ? <InsetQuote text={aiInsight} /> : null}
        </Card>
      ) : null}

      {/* ===== AI Tips ===== */}
      {aiTips.length > 0 ? (
        <Card
          style={{
            backgroundColor: fortuneTheme.colors.backgroundTertiary,
            borderWidth: 0,
            gap: fortuneTheme.spacing.md,
          }}
        >
          <AppText variant="labelLarge" color={fortuneTheme.colors.textPrimary}>AI 추천 팁</AppText>
          <BulletList items={aiTips} />
        </Card>
      ) : null}

      {/* ===== Same-Day Celebrities — fun cards ===== */}
      {celebsSameDay.length > 0 ? (
        <Card
          style={{
            backgroundColor: fortuneTheme.colors.backgroundTertiary,
            borderWidth: 0,
            gap: fortuneTheme.spacing.md,
          }}
        >
          <View style={{ gap: 2 }}>
            <AppText variant="labelLarge" color={fortuneTheme.colors.textPrimary}>
              같은 날 태어난 유명인
            </AppText>
            <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
              오늘과 같은 날 태어난 특별한 인물들
            </AppText>
          </View>

          <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: fortuneTheme.spacing.sm }}>
            {celebsSameDay.map((cel, idx) => {
              const accentColors = ['#8FB8FF', '#CE93D8', '#FFD54F', '#81C784', '#F06292'];
              const accent = accentColors[idx % accentColors.length]!;

              return (
                <View
                  key={cel.name}
                  style={{
                    minWidth: celebsSameDay.length === 1 ? '100%' : '47%',
                    flexGrow: 1,
                    flexBasis: celebsSameDay.length === 1 ? '100%' : '47%',
                  }}
                >
                  <View
                    style={{
                      backgroundColor: `${accent}12`,
                      borderRadius: fortuneTheme.radius.lg,
                      borderWidth: 1,
                      borderColor: `${accent}25`,
                      padding: fortuneTheme.spacing.md,
                      gap: fortuneTheme.spacing.xs,
                    }}
                  >
                    {/* Name + year row */}
                    <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' }}>
                      <AppText variant="labelLarge" color={accent}>
                        {cel.name}
                      </AppText>
                      {cel.year ? (
                        <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
                          {cel.year}
                        </AppText>
                      ) : null}
                    </View>
                    {cel.description ? (
                      <AppText variant="caption" color={fortuneTheme.colors.textSecondary} numberOfLines={3}>
                        {cel.description}
                      </AppText>
                    ) : null}
                  </View>
                </View>
              );
            })}
          </View>
        </Card>
      ) : null}

      {/* ===== Age Fortune ===== */}
      {hasAgeFortune ? (
        <Card
          style={{
            backgroundColor: fortuneTheme.colors.backgroundTertiary,
            borderWidth: 0,
            gap: fortuneTheme.spacing.sm,
          }}
        >
          <AppText variant="labelLarge" color={fortuneTheme.colors.textPrimary}>
            {ageGroup ? `${ageGroup} 나이대 분석` : '나이 분석'}
          </AppText>
          {ageTitle ? (
            <AppText variant="heading4" color={fortuneTheme.colors.accentTertiary}>
              {ageTitle}
            </AppText>
          ) : null}
          {ageDescription ? (
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              {ageDescription}
            </AppText>
          ) : null}
        </Card>
      ) : null}

      {/* ===== Personal Actions (추천 행동) ===== */}
      {personalActions.length > 0 ? (
        <SectionCard title="추천 행동">
          <BulletList items={personalActions} />
        </SectionCard>
      ) : null}

      {/* ===== Caution (주의 사항) ===== */}
      {caution ? (
        <SectionCard title="주의 사항">
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>{caution}</AppText>
        </SectionCard>
      ) : null}

      {/* ===== Lucky Outfit (오늘의 코디) ===== */}
      {outfitTitle || outfitItems.length > 0 ? (
        <SectionCard title={outfitTitle || '오늘의 코디'}>
          {outfitItems.length > 0 ? <KeywordPills keywords={outfitItems} /> : null}
        </SectionCard>
      ) : null}

      {/* ===== Daily Predictions (전후일 점수) ===== */}
      {hasDailyPredictions ? (
        <SectionCard title="주변 날짜 흐름">
          <MetricGrid items={[
            ..._num(dailyPredictions.before_yesterday) > 0 ? [{ label: '그저께', value: `${_num(dailyPredictions.before_yesterday)}`, note: '' }] : [],
            ..._num(dailyPredictions.yesterday) > 0 ? [{ label: '어제', value: `${_num(dailyPredictions.yesterday)}`, note: '' }] : [],
            ..._num(dailyPredictions.tomorrow) > 0 ? [{ label: '내일', value: `${_num(dailyPredictions.tomorrow)}`, note: '' }] : [],
            ..._num(dailyPredictions.after_tomorrow) > 0 ? [{ label: '모레', value: `${_num(dailyPredictions.after_tomorrow)}`, note: '' }] : [],
          ]} />
        </SectionCard>
      ) : null}

      {/* ===== Lucky Numbers (행운 번호) ===== */}
      {luckyNumbers.length > 0 ? (
        <SectionCard title="행운 번호">
          <KeywordPills keywords={luckyNumbers} />
        </SectionCard>
      ) : null}

      {/* ===== Celebrities Similar Saju (비슷한 사주 유명인) ===== */}
      {celebsSimilarSaju.length > 0 ? (
        <SectionCard title="비슷한 사주 유명인">
          {celebsSimilarSaju.map((cel, i) => (
            <AppText key={i} variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              {cel.name} ({cel.year}) — {cel.description}
            </AppText>
          ))}
        </SectionCard>
      ) : null}

      {/* ===== Godlife (갓생 팁) ===== */}
      {godlife ? (
        <InsetQuote text={godlife} />
      ) : null}

      {/* ===== Fortune Summary by type (MBTI/별자리/띠) ===== */}
      {hasFortuneSummary ? (
        <SectionCard title="유형별 인사이트 요약">
          {_str(byMBTI.title) ? (
            <View style={{ marginBottom: fortuneTheme.spacing.sm }}>
              <AppText variant="labelLarge" color={fortuneTheme.colors.ctaBackground}>🧠 MBTI ({_num(byMBTI.score)}점)</AppText>
              <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                {_str(byMBTI.title)}: {_str(byMBTI.content)}
              </AppText>
            </View>
          ) : null}
          {_str(byZodiacSign.title) ? (
            <View style={{ marginBottom: fortuneTheme.spacing.sm }}>
              <AppText variant="labelLarge" color={fortuneTheme.colors.ctaBackground}>⭐ 별자리 ({_num(byZodiacSign.score)}점)</AppText>
              <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                {_str(byZodiacSign.title)}: {_str(byZodiacSign.content)}
              </AppText>
            </View>
          ) : null}
          {_str(byZodiacAnimal.title) ? (
            <View>
              <AppText variant="labelLarge" color={fortuneTheme.colors.ctaBackground}>🐉 띠 ({_num(byZodiacAnimal.score)}점)</AppText>
              <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                {_str(byZodiacAnimal.title)}: {_str(byZodiacAnimal.content)}
              </AppText>
            </View>
          ) : null}
        </SectionCard>
      ) : null}

      {/* ===== Saju Insight (사주 키워드) ===== */}
      {sajuKeyword ? (
        <SectionCard title="사주 키워드">
          <KeywordPills keywords={[sajuKeyword]} />
        </SectionCard>
      ) : null}

      {/* ===== Fallback memo when no specialTip or aiInsight ===== */}
      {!specialTip && !aiInsight ? (
        <Card
          style={{
            backgroundColor: fortuneTheme.colors.backgroundTertiary,
            borderWidth: 0,
            gap: fortuneTheme.spacing.sm,
          }}
        >
          <AppText variant="labelLarge" color={fortuneTheme.colors.textPrimary}>만세력 메모</AppText>
          <InsetQuote
            text={
              result.hasApiData && result.specialTip
                ? result.specialTip
                : '오늘은 하루를 완벽히 해석하려 하기보다, 잘 맞는 시간대를 먼저 찾는 쪽이 훨씬 실용적입니다.'
            }
          />
        </Card>
      ) : null}
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  3. MbtiResult                                                     */
/* ------------------------------------------------------------------ */

function MbtiResult(props: FortuneResultComponentProps) {
  const meta = resultMetadataByKind.mbti;
  const result = useResultData(props.payload);
  const raw = _obj(props.payload?.rawApiResponse);
  const data = _obj(raw.data ?? raw.fortune ?? raw);

  // Direct API fields
  const mbtiType = _str(data.mbti) || _str(data.mbtiType) || (result.hasApiData && result.metrics.length > 0 ? result.metrics[0]!.value : 'INFJ');
  const mbtiDesc = _str(data.mbtiDescription) || '유형 자체보다 오늘 어떤 축이 먼저 드러나는지가 중요합니다.';
  const score = _num(data.score) || _num(data.overallScore) || result.score;
  const heroDescription = _str(data.summary) || result.summary || '유형 자체보다 오늘 어떤 축이 먼저 드러나는지가 중요합니다.';
  const todayFortune = _str(data.todayFortune);
  const todayTrap = _str(data.todayTrap);
  const luckyColor = _str(data.luckyColor);
  const luckyNumber = _str(data.luckyNumber);
  const energyLevel = _num(data.energyLevel);

  // Dimensions (E/N/T/J axis data)
  const rawDimensions = Array.isArray(data.dimensions) ? data.dimensions as Record<string, unknown>[] : [];
  const dimensionStats = rawDimensions.length > 0
    ? rawDimensions.map((d) => ({
        label: _str(d.dimension),
        value: _num(d.score, 70),
        highlight: _str(d.tip) || _str(d.fortune).slice(0, 40),
      }))
    : result.hasApiData && result.metrics.length >= 6
      ? result.metrics.slice(2, 6).map((m) => ({
          label: m.label,
          value: parseInt(m.value, 10) || 70,
          highlight: m.note,
        }))
      : [
          { label: 'E ↔ I', value: 68, highlight: '혼자 정리한 뒤 말할 때 더 정확합니다.' },
          { label: 'S ↔ N', value: 86, highlight: '맥락과 미래 흐름을 먼저 읽습니다.' },
          { label: 'T ↔ F', value: 61, highlight: '감정 공감이 크지만 오늘은 기준이 필요합니다.' },
          { label: 'J ↔ P', value: 80, highlight: '정리된 계획이 있을수록 힘이 납니다.' },
        ];

  // Category fortunes
  const loveFortune = _str(data.loveFortune);
  const careerFortune = _str(data.careerFortune);
  const moneyFortune = _str(data.moneyFortune);
  const healthFortune = _str(data.healthFortune);
  const hasCategoryFortunes = loveFortune || careerFortune || moneyFortune || healthFortune;

  // Compatibility
  // compatibility can be string[] (MBTI types) or object[] (detailed)
  const rawCompatRaw = Array.isArray(data.compatibility) ? data.compatibility : [];
  const rawCompat = rawCompatRaw.length > 0 && typeof rawCompatRaw[0] === 'string'
    ? (rawCompatRaw as string[]).map((mbtiType, i) => ({ label: `궁합 ${i + 1}`, value: mbtiType, note: '' }))
    : (rawCompatRaw as Record<string, unknown>[]).map((c) => ({
        label: _str(c.type) || _str(c.mbti) || `궁합`,
        value: _str(c.score) || _str(c.compatibility) || '?',
        note: _str(c.description) || _str(c.reason) || '',
      }));

  // Cognitive strengths & challenges
  const cognitiveStrengths = _strArr(data.cognitiveStrengths);
  const challenges = _strArr(data.challenges);

  // Category insight
  const catInsight = _obj(data.categoryInsight);
  const catInsightTips = _strArr(catInsight.tips);

  const advice = _str(data.advice) || _str(data.mbti_advice);

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard
        emoji="🧠"
        title={meta.title}
        description={heroDescription}
      />

      {/* MBTI 타입 카드 */}
      <SectionCard title="오늘의 MBTI 요약">
        <Card style={{ backgroundColor: fortuneTheme.colors.backgroundTertiary, gap: fortuneTheme.spacing.sm, alignItems: 'center', paddingVertical: 20 }}>
          <AppText variant="displayMedium">{mbtiType}</AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>{mbtiDesc}</AppText>
          {energyLevel > 0 ? (
            <AppText variant="labelLarge" color={fortuneTheme.colors.ctaBackground}>에너지 레벨: {energyLevel}%</AppText>
          ) : null}
          {luckyColor || luckyNumber ? (
            <KeywordPills keywords={[
              ...(luckyColor ? [`행운 색상: ${luckyColor}`] : []),
              ...(luckyNumber ? [`행운 숫자: ${luckyNumber}`] : []),
            ]} />
          ) : null}
        </Card>
      </SectionCard>

      {/* 오늘의 흐름 */}
      {todayFortune ? (
        <SectionCard title="오늘의 흐름">
          <AppText variant="oracleBody" color={fortuneTheme.colors.textPrimary}>{todayFortune}</AppText>
        </SectionCard>
      ) : null}

      {/* 성향 축 */}
      <SectionCard title="성향 축">
        <StatRail items={dimensionStats} />
        {rawDimensions.length > 0 ? (
          <View style={{ gap: fortuneTheme.spacing.xs, marginTop: fortuneTheme.spacing.sm }}>
            {rawDimensions.map((d, i) => {
              const warning = _str(d.warning);
              return warning ? (
                <AppText key={i} variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                  ⚠️ {_str(d.dimension)}: {warning}
                </AppText>
              ) : null;
            })}
          </View>
        ) : null}
      </SectionCard>

      {/* 카테고리 인사이트 */}
      {_str(catInsight.title) ? (
        <SectionCard title={_str(catInsight.title)}>
          {_str(catInsight.content) ? (
            <AppText variant="oracleBody" color={fortuneTheme.colors.textPrimary}>{_str(catInsight.content)}</AppText>
          ) : null}
          {catInsightTips.length > 0 ? (
            <BulletList items={catInsightTips} />
          ) : null}
        </SectionCard>
      ) : null}

      {/* 카테고리별 인사이트 */}
      {hasCategoryFortunes ? (
        <SectionCard title="분야별 인사이트">
          {loveFortune ? (
            <View style={{ marginBottom: fortuneTheme.spacing.sm }}>
              <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary}>💕 연애</AppText>
              <AppText variant="bodySmall" color={fortuneTheme.colors.textPrimary}>{loveFortune}</AppText>
            </View>
          ) : null}
          {careerFortune ? (
            <View style={{ marginBottom: fortuneTheme.spacing.sm }}>
              <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary}>💼 직장</AppText>
              <AppText variant="bodySmall" color={fortuneTheme.colors.textPrimary}>{careerFortune}</AppText>
            </View>
          ) : null}
          {moneyFortune ? (
            <View style={{ marginBottom: fortuneTheme.spacing.sm }}>
              <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary}>💰 금전</AppText>
              <AppText variant="bodySmall" color={fortuneTheme.colors.textPrimary}>{moneyFortune}</AppText>
            </View>
          ) : null}
          {healthFortune ? (
            <View>
              <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary}>🏃 건강</AppText>
              <AppText variant="bodySmall" color={fortuneTheme.colors.textPrimary}>{healthFortune}</AppText>
            </View>
          ) : null}
        </SectionCard>
      ) : null}

      {/* 인지 강점 */}
      {cognitiveStrengths.length > 0 ? (
        <SectionCard title="인지 강점">
          <BulletList items={cognitiveStrengths} />
        </SectionCard>
      ) : null}

      {/* 도전 과제 */}
      {challenges.length > 0 ? (
        <SectionCard title="오늘의 도전 과제">
          <BulletList items={challenges} />
        </SectionCard>
      ) : null}

      {/* 궁합 */}
      {rawCompat.length > 0 ? (
        <SectionCard title="MBTI 궁합">
          <KeywordPills keywords={rawCompat.map((c) => c.value).filter(Boolean)} />
        </SectionCard>
      ) : null}

      {/* 주의 (오늘의 함정) */}
      {todayTrap ? (
        <SectionCard title="오늘의 함정 ⚠️">
          <InsetQuote text={todayTrap} />
        </SectionCard>
      ) : null}

      {/* 조언 */}
      {advice ? (
        <SectionCard title="조언">
          <AppText variant="oracleBody" color={fortuneTheme.colors.textPrimary}>{advice}</AppText>
        </SectionCard>
      ) : null}
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  4. BloodTypeResult                                                */
/* ------------------------------------------------------------------ */

function BloodTypeResult(props: FortuneResultComponentProps) {
  const meta = resultMetadataByKind['blood-type'];
  const result = useResultData(props.payload);
  const raw = _obj(props.payload?.rawApiResponse);
  const data = _obj(raw.data ?? raw.fortune ?? raw);

  // Direct API fields
  const bloodTypeLabel = _str(data.bloodTypeLabel) || _str(data.bloodType) || 'A형';
  const bloodTypeKeyword = _str(data.bloodTypeKeyword);
  const bloodTypeElement = _str(data.bloodTypeElement);
  const personality = _obj(data.personalityAnalysis);
  const coreTrait = _str(personality.coreTrait);
  const strengths = _strArr(personality.strengths);
  const watchOut = _str(personality.watchOut);
  const moodKeyword = _str(personality.moodKeyword);
  const categories = _obj(data.categories);
  const compat = _obj(data.compatibility);
  const lucky = _obj(data.luckyItems);
  const specialNote = _str(data.specialNote);
  const highlights = _strArr(data.highlights);

  const heroDescription = _str(data.summary) || result.summary
    || '혈액형 성향은 오늘의 분위기와 만나면 더 현실적인 조언으로 바뀝니다.';

  const score = _num(data.score) || result.score;

  // Category scores
  const catLove = _obj(categories.love);
  const catWork = _obj(categories.work);
  const catMoney = _obj(categories.money);
  const catHealth = _obj(categories.health);

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      {/* Big Blood Type Identity Card */}
      <Card style={{ alignItems: 'center', paddingVertical: 24, backgroundColor: fortuneTheme.colors.backgroundTertiary }}>
        <AppText style={{ fontSize: 64, lineHeight: 76 }}>🩸</AppText>
        <AppText variant="displaySmall" style={{ marginTop: 8 }}>{bloodTypeLabel}</AppText>
        {bloodTypeKeyword ? (
          <AppText variant="bodyMedium" color={fortuneTheme.colors.ctaBackground} style={{ marginTop: 4 }}>
            {bloodTypeKeyword}
          </AppText>
        ) : null}
        {bloodTypeElement ? (
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary} style={{ marginTop: 2 }}>
            오행: {bloodTypeElement}
          </AppText>
        ) : null}
        {moodKeyword ? (
          <KeywordPills keywords={[`오늘의 무드: ${moodKeyword}`]} />
        ) : null}
      </Card>

      <HeroCard
        emoji="🩸"
        title={meta.title}
        description={heroDescription}
      />

      {/* 성격 분석 */}
      {coreTrait ? (
        <SectionCard title="성격 분석">
          <AppText variant="oracleBody" color={fortuneTheme.colors.textPrimary}>
            {coreTrait}
          </AppText>
          {strengths.length > 0 ? (
            <View style={{ marginTop: fortuneTheme.spacing.sm }}>
              <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary} style={{ marginBottom: 4 }}>
                강점
              </AppText>
              <BulletList items={strengths} />
            </View>
          ) : null}
          {watchOut ? (
            <View style={{ marginTop: fortuneTheme.spacing.sm }}>
              <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary} style={{ marginBottom: 4 }}>
                주의할 점
              </AppText>
              <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                {watchOut}
              </AppText>
            </View>
          ) : null}
        </SectionCard>
      ) : null}

      {/* 카테고리별 점수 */}
      {_num(catLove.score) > 0 || _num(catWork.score) > 0 ? (
        <SectionCard title="오늘의 흐름">
          <MetricGrid
            items={[
              ..._num(catLove.score) > 0 ? [{ label: '연애', value: `${_num(catLove.score)}%`, note: _str(catLove.description).slice(0, 30) }] : [],
              ..._num(catWork.score) > 0 ? [{ label: '직장', value: `${_num(catWork.score)}%`, note: _str(catWork.description).slice(0, 30) }] : [],
              ..._num(catMoney.score) > 0 ? [{ label: '금전', value: `${_num(catMoney.score)}%`, note: _str(catMoney.description).slice(0, 30) }] : [],
              ..._num(catHealth.score) > 0 ? [{ label: '건강', value: `${_num(catHealth.score)}%`, note: _str(catHealth.description).slice(0, 30) }] : [],
            ]}
          />
        </SectionCard>
      ) : null}

      {/* 궁합 */}
      {_str(compat.bestMatch) ? (
        <SectionCard title="궁합 포인트">
          <MetricGrid items={[
            { label: '잘 맞는 타입', value: _str(compat.bestMatch), note: _str(compat.bestReason) },
            { label: '조심할 타입', value: _str(compat.cautionMatch), note: _str(compat.cautionReason) },
          ]} />
        </SectionCard>
      ) : (
        <SectionCard title="궁합 포인트">
          <MetricGrid items={result.metrics.length >= 3
            ? result.metrics.slice(1, 3)
            : [
                { label: '잘 맞는 타입', value: 'O형', note: '속도와 안정의 균형' },
                { label: '조심할 타입', value: 'B형', note: '리듬 차이가 큼' },
              ]} />
        </SectionCard>
      )}

      {/* 하이라이트 */}
      {highlights.length > 0 ? (
        <SectionCard title="핵심 포인트">
          <BulletList items={highlights} />
        </SectionCard>
      ) : null}

      {/* 조언 */}
      {_str(data.advice) ? (
        <SectionCard title="추천 행동">
          <BulletList items={[_str(data.advice)]} />
        </SectionCard>
      ) : result.recommendations.length > 0 ? (
        <SectionCard title="추천 행동">
          <BulletList items={result.recommendations} />
        </SectionCard>
      ) : null}

      {/* 특별 메모 */}
      {specialNote ? (
        <InsetQuote text={specialNote} />
      ) : null}

      {/* 행운 아이템 */}
      {_str(lucky.color) || _str(lucky.number) ? (
        <SectionCard title="행운 포인트">
          <KeywordPills keywords={[
            ..._str(lucky.color) ? [_str(lucky.color)] : [],
            ..._str(lucky.number) ? [_str(lucky.number)] : [],
            ..._str(lucky.time) ? [_str(lucky.time)] : [],
            ..._str(lucky.item) ? [_str(lucky.item)] : [],
          ]} />
        </SectionCard>
      ) : result.highlights.length > 0 ? (
        <SectionCard title="행운 포인트">
          <KeywordPills keywords={result.highlights} />
        </SectionCard>
      ) : null}
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  5. ZodiacAnimalResult                                             */
/* ------------------------------------------------------------------ */

/** Element display color helper */
const ELEMENT_COLORS: Record<string, string> = {
  '목': '#4CAF50',
  '화': '#F44336',
  '토': '#FF9800',
  '금': '#FFD700',
  '수': '#2196F3',
};

function elementColor(element: string): string {
  const key = element.charAt(0);
  return ELEMENT_COLORS[key] ?? fortuneTheme.colors.accentSecondary;
}

function ZodiacAnimalResult(props: FortuneResultComponentProps) {
  const meta = resultMetadataByKind['zodiac-animal'];
  const result = useResultData(props.payload);
  const raw = _obj(props.payload?.rawApiResponse);
  const hasRaw = Object.keys(raw).length > 0;
  const { state } = useMobileAppState();
  const profileBirthDate = state.profile.birthDate;

  // --- Detect whether this is a constellation (별자리) or animal (띠) request ---
  const fortuneType = props.payload?.fortuneType;
  const isConstellation = fortuneType === 'zodiac' || fortuneType === 'constellation';

  // --- Derive zodiac animal + birth year ---
  const { animal, birthYear } = useMemo(() => {
    // 1) Try rawApiResponse birthYear
    const rawBY = _num(raw.birthYear, 0);
    if (rawBY >= 1900 && rawBY <= 2100) return { animal: deriveZodiacAnimal(rawBY), birthYear: rawBY };

    // 2) Try payload contextTags for a birth-year hint (e.g. "1988")
    const tagYear = result.contextTags
      .map((t) => parseInt(t, 10))
      .find((n) => n >= 1900 && n <= 2100);
    if (tagYear) return { animal: deriveZodiacAnimal(tagYear), birthYear: tagYear };

    // 3) Try result metrics for a zodiacAnimal / birthYear value
    const yearMetric = result.metrics.find(
      (m) => m.label === 'birthYear' || m.label === '출생년도',
    );
    if (yearMetric) {
      const y = parseInt(yearMetric.value, 10);
      if (y >= 1900 && y <= 2100) return { animal: deriveZodiacAnimal(y), birthYear: y };
    }

    // 4) Fall back to profile birthDate
    if (profileBirthDate) {
      const y = new Date(profileBirthDate).getFullYear();
      if (y >= 1900 && y <= 2100) return { animal: deriveZodiacAnimal(y), birthYear: y };
    }

    // 5) Default: dragon
    return { animal: ZODIAC_ANIMALS[4]!, birthYear: 0 };
  }, [raw.birthYear, result.contextTags, result.metrics, profileBirthDate]);

  // --- Derive constellation from birth date ---
  const constellation = useMemo(() => {
    // 1) Try rawApiResponse constellation name
    const rawName = _str(raw.constellation) || _str(raw.zodiacSign);
    if (rawName) {
      const match = CONSTELLATIONS.find(
        (c) => c.name === rawName || c.en.toLowerCase() === rawName.toLowerCase(),
      );
      if (match) return match;
    }

    // 2) Try profile birthDate
    if (profileBirthDate) return deriveConstellation(profileBirthDate);

    // 3) Try rawApiResponse birthDate
    const rawBD = _str(raw.birthDate);
    if (rawBD) return deriveConstellation(rawBD);

    // 4) Fallback: Aries
    return CONSTELLATIONS[0]!;
  }, [raw.constellation, raw.zodiacSign, raw.birthDate, profileBirthDate]);

  // --- Element (from raw or derived) ---
  const animalElement = _str(raw.zodiacElement) || animal.element;

  // --- Overall score ---
  const overallScore = hasRaw
    ? _num(raw.score ?? raw.overall_score, 0)
    : (_num(result.score, 0));

  // --- Summary & Advice ---
  const summary = _str(raw.summary) || (result.hasApiData ? result.summary : '');
  const advice = _str(raw.advice);

  const heroDescription = summary
    || (isConstellation
      ? '별자리의 에너지와 오늘의 흐름이 만나, 관계와 기회를 더 선명하게 읽어드립니다.'
      : '띠의 기본 기질과 오늘의 흐름이 겹치며, 사람 관계와 타이밍 해석이 더 도드라지는 화면입니다.');

  const heroChips = result.hasApiData && result.contextTags.length > 0
    ? result.contextTags
    : isConstellation
      ? ['별자리 흐름', '원소 에너지', '오늘의 흐름']
      : ['띠별 흐름', '궁합', '타이밍 읽기'];

  // --- Category scores (대인운/실행운/감정운/타이밍운) ---
  const categories = _obj(raw.categories);
  const interpersonal = _obj(categories.interpersonal);
  const action = _obj(categories.action);
  const emotion = _obj(categories.emotion);
  const timing = _obj(categories.timing);

  const flowStats = hasRaw && (interpersonal.score || action.score || emotion.score || timing.score)
    ? [
        { label: '대인운', value: _num(interpersonal.score, 75), highlight: _str(interpersonal.description) },
        { label: '실행운', value: _num(action.score, 70), highlight: _str(action.description) },
        { label: '감정운', value: _num(emotion.score, 72), highlight: _str(emotion.description) },
        { label: '타이밍운', value: _num(timing.score, 78), highlight: _str(timing.description) },
      ]
    : result.hasApiData && result.metrics.length >= 4
      ? result.metrics.slice(0, 4).map((m) => ({
          label: m.label,
          value: parseInt(m.value, 10) || 75,
          highlight: m.note,
        }))
      : [
          { label: '대인운', value: 88, highlight: '사람 사이에서 존재감이 커집니다.' },
          { label: '실행운', value: 79, highlight: '시작은 좋지만 마무리를 의식해야 합니다.' },
          { label: '감정운', value: 67, highlight: '과한 해석은 피하는 게 좋습니다.' },
          { label: '타이밍운', value: 84, highlight: '한 번 더 기다리면 더 좋습니다.' },
        ];

  // --- Compatibility ---
  const compatibility = _obj(raw.compatibility);
  const bestAnimals = _strArr(compatibility.best);
  const cautionAnimals = _strArr(compatibility.caution);
  const hasCompatibility = bestAnimals.length > 0 || cautionAnimals.length > 0;

  // --- Lucky items ---
  const luckyItems = _obj(raw.luckyItems);
  const luckyTime = _str(luckyItems.time);
  const luckyColor = _str(luckyItems.color);
  const luckyDirection = _str(luckyItems.direction);
  const luckyNumber = _str(luckyItems.number);
  const hasLuckyItems = !!(luckyTime || luckyColor || luckyDirection || luckyNumber);

  const luckyMetrics = [
    { label: '행운 시간', value: luckyTime || '-', note: '' },
    { label: '행운 색상', value: luckyColor || '-', note: '' },
    { label: '행운 방위', value: luckyDirection || '-', note: '' },
    { label: '행운 숫자', value: luckyNumber || '-', note: '' },
  ];

  // --- Highlights ---
  const highlights = _strArr(raw.highlights).length > 0
    ? _strArr(raw.highlights)
    : result.hasApiData && result.highlights.length > 0
      ? result.highlights
      : [
          '오늘은 비슷한 속도의 사람보다, 나를 한 번 더 잡아주는 사람이 잘 맞습니다.',
          '대화가 빠르게 이어지는 상대와 궁합이 좋습니다.',
          '감정이 크게 출렁이는 상대와는 잠시 템포를 늦추세요.',
        ];

  // --- Timing tip ---
  const timingTip = _str(raw.timingTip) || _str(raw.timing_tip)
    || (result.hasApiData ? result.specialTip : undefined)
    || '승부를 보려면 오전보다 오후가 더 낫습니다. 말을 꺼내기 전 10초만 더 정리하면 결과가 좋아집니다.';

  // --- Special note ---
  const specialNote = _str(raw.specialNote) || _str(raw.special_note);

  // --- Identity display values (constellation vs animal) ---
  const identityEmoji = isConstellation ? constellation.emoji : animal.emoji;
  const identityName = isConstellation ? constellation.name : `${animal.name}띠`;
  const identitySubtitle = isConstellation
    ? `${constellationDateRange(constellation)} · ${constellation.element} · ${constellation.planet}`
    : `${birthYear > 0 ? `${birthYear}년 · ` : ''}${animal.branch}(${animal.name}) · ${animal.element}`;
  const identityPrefix = isConstellation
    ? ''
    : birthYear > 0 ? `${String(birthYear).slice(2)}년생 ` : '';

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      {/* Big Identity Hero */}
      <Card style={{ alignItems: 'center', paddingVertical: 28, backgroundColor: fortuneTheme.colors.backgroundTertiary }}>
        <AppText style={{ fontSize: 72, lineHeight: 84 }}>{identityEmoji}</AppText>
        <AppText variant="displaySmall" style={{ marginTop: 8, fontWeight: '800' }}>
          {identityPrefix}{identityName}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary} style={{ marginTop: 4 }}>
          {identitySubtitle}
        </AppText>
        {overallScore > 0 ? (
          <View style={{
            backgroundColor: fortuneTheme.colors.ctaBackground + '20',
            borderRadius: fortuneTheme.radius.full,
            paddingHorizontal: 16,
            paddingVertical: 6,
            marginTop: 12,
          }}>
            <AppText variant="labelLarge" color={fortuneTheme.colors.ctaBackground} style={{ fontWeight: '700' }}>
              오늘의 점수 {overallScore}점
            </AppText>
          </View>
        ) : null}
      </Card>

      <HeroCard
        emoji={identityEmoji}
        title={isConstellation ? '별자리 인사이트' : meta.title}
        description={heroDescription}
        chips={heroChips}
      />

      {/* ============================================================ */}
      {/*  Identity detail card (constellation or animal)               */}
      {/* ============================================================ */}
      <SectionCard title={isConstellation ? '나의 별자리' : '나의 띠'}>
        <Card
          style={{
            backgroundColor: fortuneTheme.colors.backgroundTertiary,
            alignItems: 'center',
            paddingVertical: fortuneTheme.spacing.lg,
            gap: fortuneTheme.spacing.sm,
          }}
        >
          <AppText style={{ fontSize: 60, lineHeight: 72 }}>{identityEmoji}</AppText>
          <AppText variant="displaySmall">
            {identityPrefix}{identityName}
          </AppText>
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              {isConstellation
                ? `${constellationDateRange(constellation)} · ${constellation.planet}`
                : `${birthYear > 0 ? `${birthYear}년 · ` : ''}${animal.branch}(${animal.name})`}
            </AppText>
            <View
              style={{
                backgroundColor: isConstellation
                  ? fortuneTheme.colors.accentSecondary
                  : elementColor(animalElement),
                borderRadius: fortuneTheme.radius.full,
                paddingHorizontal: fortuneTheme.spacing.sm,
                paddingVertical: 2,
              }}
            >
              <AppText variant="labelSmall" color="#FFFFFF">
                {isConstellation ? constellation.element : animalElement}
              </AppText>
            </View>
          </View>
        </Card>
      </SectionCard>

      {/* ============================================================ */}
      {/*  Overall score badge                                         */}
      {/* ============================================================ */}
      {overallScore > 0 && (
        <SectionCard title="오늘의 종합 인사이트">
          <View style={{ alignItems: 'center', gap: fortuneTheme.spacing.sm }}>
            <Card
              style={{
                backgroundColor: fortuneTheme.colors.backgroundTertiary,
                alignItems: 'center',
                gap: fortuneTheme.spacing.xs,
                paddingVertical: fortuneTheme.spacing.lg,
                minWidth: 140,
              }}
            >
              <AppText variant="displaySmall" color={fortuneTheme.colors.accentSecondary}>
                {overallScore}점
              </AppText>
              <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                종합 점수
              </AppText>
            </Card>
            {advice ? (
              <AppText
                variant="bodySmall"
                color={fortuneTheme.colors.textSecondary}
                style={{ textAlign: 'center' }}
              >
                {advice}
              </AppText>
            ) : null}
          </View>
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Category scores (StatRail)                                   */}
      {/* ============================================================ */}
      <SectionCard title="오늘의 흐름">
        <StatRail items={flowStats} />
      </SectionCard>

      {/* ============================================================ */}
      {/*  Compatibility (best + caution animals with emojis)           */}
      {/* ============================================================ */}
      {hasCompatibility ? (
        <SectionCard title={isConstellation ? '별자리 궁합' : '띠 궁합'}>
          {bestAnimals.length > 0 && (
            <View style={{ gap: fortuneTheme.spacing.xs }}>
              <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary}>
                {isConstellation ? '잘 맞는 별자리' : '잘 맞는 띠'}
              </AppText>
              <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: fortuneTheme.spacing.sm }}>
                {bestAnimals.map((name) => (
                  <Card
                    key={name}
                    style={{
                      backgroundColor: fortuneTheme.colors.backgroundTertiary,
                      flexDirection: 'row',
                      alignItems: 'center',
                      gap: fortuneTheme.spacing.xs,
                      paddingHorizontal: fortuneTheme.spacing.md,
                      paddingVertical: fortuneTheme.spacing.sm,
                    }}
                  >
                    <AppText style={{ fontSize: 24 }}>
                      {isConstellation
                        ? (CONSTELLATIONS.find((c) => c.name === name)?.emoji ?? '')
                        : zodiacEmojiByName(name)}
                    </AppText>
                    <AppText variant="labelLarge">
                      {isConstellation ? name : `${name}띠`}
                    </AppText>
                  </Card>
                ))}
              </View>
            </View>
          )}
          {cautionAnimals.length > 0 && (
            <View style={{ gap: fortuneTheme.spacing.xs }}>
              <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary}>
                {isConstellation ? '주의할 별자리' : '주의할 띠'}
              </AppText>
              <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: fortuneTheme.spacing.sm }}>
                {cautionAnimals.map((name) => (
                  <Card
                    key={name}
                    style={{
                      backgroundColor: fortuneTheme.colors.surfaceSecondary,
                      flexDirection: 'row',
                      alignItems: 'center',
                      gap: fortuneTheme.spacing.xs,
                      paddingHorizontal: fortuneTheme.spacing.md,
                      paddingVertical: fortuneTheme.spacing.sm,
                    }}
                  >
                    <AppText style={{ fontSize: 24 }}>
                      {isConstellation
                        ? (CONSTELLATIONS.find((c) => c.name === name)?.emoji ?? '')
                        : zodiacEmojiByName(name)}
                    </AppText>
                    <AppText variant="labelLarge" color={fortuneTheme.colors.textTertiary}>
                      {isConstellation ? name : `${name}띠`}
                    </AppText>
                  </Card>
                ))}
              </View>
            </View>
          )}
        </SectionCard>
      ) : (
        <SectionCard title="궁합 메모">
          <BulletList items={highlights} />
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Lucky items                                                  */}
      {/* ============================================================ */}
      {hasLuckyItems && (
        <SectionCard title="행운 아이템">
          <MetricGrid items={luckyMetrics} />
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Highlights / key insights                                    */}
      {/* ============================================================ */}
      <SectionCard title="핵심 인사이트">
        <BulletList items={highlights} />
      </SectionCard>

      {/* ============================================================ */}
      {/*  Timing tip                                                   */}
      {/* ============================================================ */}
      <SectionCard title="타이밍 팁">
        <InsetQuote text={timingTip} />
      </SectionCard>

      {/* ============================================================ */}
      {/*  Special note (animal-specific)                               */}
      {/* ============================================================ */}
      {specialNote ? (
        <SectionCard title={`${identityEmoji} ${identityName} 특별 메시지`}>
          <InsetQuote text={specialNote} />
        </SectionCard>
      ) : null}
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  6. NewYearResult                                                  */
/* ------------------------------------------------------------------ */

/** Ohaeng element emoji helper */
const ELEMENT_EMOJI: Record<string, string> = {
  '목': '🌳',
  '화': '🔥',
  '토': '🏔️',
  '금': '⚙️',
  '수': '💧',
  wood: '🌳',
  fire: '🔥',
  earth: '🏔️',
  metal: '⚙️',
  water: '💧',
};

function elementEmoji(element: string): string {
  const lower = element.toLowerCase();
  return ELEMENT_EMOJI[lower] ?? ELEMENT_EMOJI[element.charAt(0)] ?? '✨';
}

/** Score-to-color for monthly timeline */
function monthScoreColor(score: number): string {
  if (score >= 85) return '#4CAF50';
  if (score >= 70) return '#8FB8FF';
  if (score >= 55) return '#FFD54F';
  return '#FF8A65';
}

const QUARTER_LABELS = ['1분기 (1~3월)', '2분기 (4~6월)', '3분기 (7~9월)', '4분기 (10~12월)'];

function NewYearResult(props: FortuneResultComponentProps) {
  const result = useResultData(props.payload);
  const raw = _obj(props.payload?.rawApiResponse);
  const data = _obj(raw.data ?? raw.fortune ?? raw);

  /* --- Top-level fields --- */
  const score = _num(data.overallScore) || _num(data.score) || _num(raw.overallScore) || _num(raw.score) || _num(result.score);
  const summary = _str(data.summary) || _str(raw.summary) || result.summary || '';
  const greeting = _str(data.greeting) || _str(raw.greeting);
  const specialMessage = _str(data.specialMessage) || _str(raw.specialMessage);
  const recommendations = _strArr(data.recommendations).length > 0
    ? _strArr(data.recommendations)
    : _strArr(raw.recommendations).length > 0
      ? _strArr(raw.recommendations)
      : result.recommendations;

  /* --- Goal Fortune --- */
  const goalFortune = _obj(data.goalFortune ?? raw.goalFortune);
  const goalEmoji = _str(goalFortune.emoji) || '🎯';
  const goalLabel = _str(goalFortune.goalLabel);
  const goalTitle = _str(goalFortune.title);
  const goalPrediction = _str(goalFortune.prediction);
  const goalDeepAnalysis = _str(goalFortune.deepAnalysis);
  const goalBestMonths = _strArr(goalFortune.bestMonths);
  const goalCautionMonths = _strArr(goalFortune.cautionMonths);
  const goalQuarterlyMilestones = _arr(goalFortune.quarterlyMilestones).map((m) => {
    const item = _obj(m);
    return { quarter: _str(item.quarter), milestone: _str(item.milestone) || _str(item.description) || _str(item.goal) };
  }).filter((m) => m.milestone);
  const goalRiskAnalysis = _arr(goalFortune.riskAnalysis).map((r) => {
    const item = _obj(r);
    return _str(item.risk) || _str(item.description) || String(r);
  }).filter(Boolean);
  const goalSuccessFactors = _strArr(goalFortune.successFactors);
  const goalActionItems = _arr(goalFortune.actionItems).map((a) => {
    const item = _obj(a);
    return _str(item.action) || _str(item.description) || _str(a as unknown as string);
  }).filter(Boolean);
  const hasGoalFortune = !!(goalTitle || goalPrediction || goalLabel);

  /* --- Saju Analysis --- */
  const sajuAnalysis = _obj(data.sajuAnalysis ?? raw.sajuAnalysis);
  const dominantElement = _str(sajuAnalysis.dominantElement);
  const yearElement = _str(sajuAnalysis.yearElement);
  const sajuCompatibility = _str(sajuAnalysis.compatibility);
  const compatibilityReason = _str(sajuAnalysis.compatibilityReason);
  const elementalAdvice = _str(sajuAnalysis.elementalAdvice);
  const balanceElements = _strArr(sajuAnalysis.balanceElements);
  const strengthenTips = _strArr(sajuAnalysis.strengthenTips);
  const hasSajuAnalysis = !!(dominantElement || yearElement || sajuCompatibility);

  /* --- Monthly Highlights --- */
  const monthlyHighlights = _arr(data.monthlyHighlights ?? raw.monthlyHighlights).map((m) => {
    const item = _obj(m);
    return {
      month: _num(item.month),
      theme: _str(item.theme),
      score: _num(item.score),
      advice: _str(item.advice),
      energyLevel: _str(item.energyLevel),
      bestDays: _strArr(item.bestDays),
      recommendedAction: _str(item.recommendedAction),
      avoidAction: _str(item.avoidAction),
    };
  }).filter((m) => m.month > 0);
  const hasMonthlyHighlights = monthlyHighlights.length > 0;

  /* --- Action Plan --- */
  const actionPlan = _obj(data.actionPlan ?? raw.actionPlan);
  const immediateActions = _arr(actionPlan.immediate).map((a) => {
    const item = _obj(a);
    const action = _str(item.action) || _str(a as unknown as string);
    const timeframe = _str(item.timeframe);
    return action ? (timeframe ? `${action} (${timeframe})` : action) : '';
  }).filter(Boolean);
  const shortTermActions = _arr(actionPlan.shortTerm).map((a) => {
    const item = _obj(a);
    const action = _str(item.action) || _str(a as unknown as string);
    const timeframe = _str(item.timeframe);
    return action ? (timeframe ? `${action} (${timeframe})` : action) : '';
  }).filter(Boolean);
  const longTermActions = _arr(actionPlan.longTerm).map((a) => {
    const item = _obj(a);
    const action = _str(item.action) || _str(a as unknown as string);
    const timeframe = _str(item.timeframe);
    return action ? (timeframe ? `${action} (${timeframe})` : action) : '';
  }).filter(Boolean);
  const hasActionPlan = immediateActions.length > 0 || shortTermActions.length > 0 || longTermActions.length > 0;

  /* --- Lucky Items --- */
  const luckyItems = _obj(data.luckyItems ?? raw.luckyItems);
  const luckyColor = _str(luckyItems.color);
  const luckyNumber = _str(luckyItems.number);
  const luckyDirection = _str(luckyItems.direction);
  const luckyItem = _str(luckyItems.item);
  const luckyFood = _str(luckyItems.food);
  const hasLuckyItems = !!(luckyColor || luckyNumber || luckyDirection || luckyItem || luckyFood);

  /* --- Hero description --- */
  const heroDescription = greeting || summary || '새해 목표와 사주를 결합해 한 해의 흐름을 종합적으로 분석한 결과입니다.';

  /* --- Score color --- */
  const scoreColor = score >= 80 ? '#4CAF50' : score >= 60 ? '#FFD54F' : '#FF8A65';

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      {/* ===== 1. Hero — Year + Score + Goal Badge ===== */}
      <HeroCard
        emoji="🎍"
        title="새해 인사이트"
        description={heroDescription}
        chips={goalLabel ? [goalLabel] : undefined}
        aside={
          score > 0 ? (
            <View
              style={{
                width: 72,
                height: 72,
                borderRadius: 36,
                borderWidth: 3,
                borderColor: scoreColor,
                alignItems: 'center',
                justifyContent: 'center',
                backgroundColor: `${scoreColor}15`,
              }}
            >
              <AppText style={{ fontSize: 24, fontWeight: '800', color: scoreColor }}>
                {score}
              </AppText>
              <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
                종합
              </AppText>
            </View>
          ) : undefined
        }
      />

      {/* Goal badge row */}
      {goalLabel ? (
        <Card style={{ backgroundColor: fortuneTheme.colors.backgroundTertiary, flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.sm, paddingVertical: fortuneTheme.spacing.md }}>
          <AppText style={{ fontSize: 36 }}>{goalEmoji}</AppText>
          <View style={{ flex: 1 }}>
            <AppText variant="labelLarge" color={fortuneTheme.colors.textPrimary}>
              올해의 목표
            </AppText>
            <AppText variant="bodySmall" color={fortuneTheme.colors.accentTertiary}>
              {goalLabel}
            </AppText>
          </View>
        </Card>
      ) : null}

      {/* ===== 2. Goal Fortune ===== */}
      {hasGoalFortune ? (
        <SectionCard title="목표 인사이트" description={goalTitle || undefined}>
          {goalPrediction ? (
            <AppText variant="oracleBody" color={fortuneTheme.colors.textPrimary}>
              {goalPrediction}
            </AppText>
          ) : null}

          {goalDeepAnalysis ? (
            <View style={{ marginTop: fortuneTheme.spacing.sm }}>
              <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary} style={{ marginBottom: 4 }}>
                심층 분석
              </AppText>
              <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                {goalDeepAnalysis}
              </AppText>
            </View>
          ) : null}

          {goalBestMonths.length > 0 ? (
            <View style={{ marginTop: fortuneTheme.spacing.sm }}>
              <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary} style={{ marginBottom: 4 }}>
                최적의 달
              </AppText>
              <KeywordPills keywords={goalBestMonths} />
            </View>
          ) : null}

          {goalCautionMonths.length > 0 ? (
            <View style={{ marginTop: fortuneTheme.spacing.sm }}>
              <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary} style={{ marginBottom: 4 }}>
                주의할 달
              </AppText>
              <KeywordPills keywords={goalCautionMonths} />
            </View>
          ) : null}

          {goalSuccessFactors.length > 0 ? (
            <View style={{ marginTop: fortuneTheme.spacing.sm }}>
              <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary} style={{ marginBottom: 4 }}>
                성공 요인
              </AppText>
              <BulletList items={goalSuccessFactors} />
            </View>
          ) : null}

          {goalRiskAnalysis.length > 0 ? (
            <View style={{ marginTop: fortuneTheme.spacing.sm }}>
              <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary} style={{ marginBottom: 4 }}>
                리스크 분석
              </AppText>
              <BulletList items={goalRiskAnalysis} />
            </View>
          ) : null}

          {goalActionItems.length > 0 ? (
            <View style={{ marginTop: fortuneTheme.spacing.sm }}>
              <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary} style={{ marginBottom: 4 }}>
                실행 항목
              </AppText>
              <BulletList items={goalActionItems} />
            </View>
          ) : null}
        </SectionCard>
      ) : null}

      {/* ===== 3. Saju/Ohaeng Analysis ===== */}
      {hasSajuAnalysis ? (
        <SectionCard title="사주 오행 분석">
          <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: fortuneTheme.spacing.sm }}>
            {dominantElement ? (
              <Card style={{ backgroundColor: fortuneTheme.colors.backgroundTertiary, alignItems: 'center', gap: 4, paddingVertical: fortuneTheme.spacing.md, minWidth: '45%', flexGrow: 1 }}>
                <AppText style={{ fontSize: 28 }}>{elementEmoji(dominantElement)}</AppText>
                <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>주도 원소</AppText>
                <AppText variant="labelLarge" color={fortuneTheme.colors.textPrimary}>{dominantElement}</AppText>
              </Card>
            ) : null}
            {yearElement ? (
              <Card style={{ backgroundColor: fortuneTheme.colors.backgroundTertiary, alignItems: 'center', gap: 4, paddingVertical: fortuneTheme.spacing.md, minWidth: '45%', flexGrow: 1 }}>
                <AppText style={{ fontSize: 28 }}>{elementEmoji(yearElement)}</AppText>
                <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>올해의 원소</AppText>
                <AppText variant="labelLarge" color={fortuneTheme.colors.textPrimary}>{yearElement}</AppText>
              </Card>
            ) : null}
          </View>

          {sajuCompatibility ? (
            <View style={{ marginTop: fortuneTheme.spacing.sm }}>
              <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary} style={{ marginBottom: 4 }}>
                궁합도
              </AppText>
              <AppText variant="bodyMedium" color={fortuneTheme.colors.ctaBackground}>
                {sajuCompatibility}
              </AppText>
              {compatibilityReason ? (
                <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary} style={{ marginTop: 2 }}>
                  {compatibilityReason}
                </AppText>
              ) : null}
            </View>
          ) : null}

          {elementalAdvice ? (
            <View style={{ marginTop: fortuneTheme.spacing.sm }}>
              <InsetQuote text={elementalAdvice} />
            </View>
          ) : null}

          {balanceElements.length > 0 ? (
            <View style={{ marginTop: fortuneTheme.spacing.sm }}>
              <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary} style={{ marginBottom: 4 }}>
                균형 원소
              </AppText>
              <KeywordPills keywords={balanceElements} />
            </View>
          ) : null}

          {strengthenTips.length > 0 ? (
            <View style={{ marginTop: fortuneTheme.spacing.sm }}>
              <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary} style={{ marginBottom: 4 }}>
                보강 팁
              </AppText>
              <BulletList items={strengthenTips} />
            </View>
          ) : null}
        </SectionCard>
      ) : null}

      {/* ===== 4. Monthly Timeline (compact 12-month grid) ===== */}
      {hasMonthlyHighlights ? (
        <SectionCard title="월별 하이라이트" description="12개월의 테마와 에너지 흐름을 한눈에 볼 수 있습니다.">
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {monthlyHighlights.map((m) => {
              const color = monthScoreColor(m.score);
              return (
                <Card
                  key={m.month}
                  style={{
                    backgroundColor: fortuneTheme.colors.backgroundTertiary,
                    borderLeftWidth: 3,
                    borderLeftColor: color,
                    gap: fortuneTheme.spacing.xs,
                  }}
                >
                  {/* Header: month + score */}
                  <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' }}>
                    <AppText variant="labelLarge" color={fortuneTheme.colors.textPrimary}>
                      {m.month}월
                    </AppText>
                    {m.score > 0 ? (
                      <AppText style={{ fontSize: 16, fontWeight: '700', color }}>
                        {m.score}점
                      </AppText>
                    ) : null}
                  </View>

                  {/* Theme */}
                  {m.theme ? (
                    <AppText variant="bodySmall" color={fortuneTheme.colors.accentTertiary}>
                      {m.theme}
                    </AppText>
                  ) : null}

                  {/* Advice */}
                  {m.advice ? (
                    <AppText variant="caption" color={fortuneTheme.colors.textSecondary}>
                      {m.advice}
                    </AppText>
                  ) : null}

                  {/* Energy + recommended/avoid */}
                  <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 6, marginTop: 2 }}>
                    {m.energyLevel ? (
                      <View style={{ backgroundColor: `${color}20`, borderRadius: fortuneTheme.radius.chip, paddingHorizontal: 8, paddingVertical: 2 }}>
                        <AppText variant="caption" color={color}>{m.energyLevel}</AppText>
                      </View>
                    ) : null}
                    {m.recommendedAction ? (
                      <View style={{ backgroundColor: '#4CAF5020', borderRadius: fortuneTheme.radius.chip, paddingHorizontal: 8, paddingVertical: 2 }}>
                        <AppText variant="caption" color="#4CAF50">{m.recommendedAction}</AppText>
                      </View>
                    ) : null}
                    {m.avoidAction ? (
                      <View style={{ backgroundColor: '#FF8A6520', borderRadius: fortuneTheme.radius.chip, paddingHorizontal: 8, paddingVertical: 2 }}>
                        <AppText variant="caption" color="#FF8A65">{m.avoidAction}</AppText>
                      </View>
                    ) : null}
                  </View>

                  {/* Best days */}
                  {m.bestDays.length > 0 ? (
                    <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
                      좋은 날: {m.bestDays.join(', ')}
                    </AppText>
                  ) : null}
                </Card>
              );
            })}
          </View>
        </SectionCard>
      ) : null}

      {/* ===== 5. Quarterly Milestones ===== */}
      {goalQuarterlyMilestones.length > 0 ? (
        <SectionCard title="분기별 마일스톤">
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {goalQuarterlyMilestones.map((m, idx) => (
              <Card
                key={idx}
                style={{
                  backgroundColor: fortuneTheme.colors.backgroundTertiary,
                  flexDirection: 'row',
                  alignItems: 'center',
                  gap: fortuneTheme.spacing.sm,
                }}
              >
                <View
                  style={{
                    width: 36,
                    height: 36,
                    borderRadius: 18,
                    backgroundColor: fortuneTheme.colors.ctaBackground + '25',
                    alignItems: 'center',
                    justifyContent: 'center',
                    flexShrink: 0,
                  }}
                >
                  <AppText variant="labelLarge" color={fortuneTheme.colors.ctaBackground}>
                    Q{idx + 1}
                  </AppText>
                </View>
                <View style={{ flex: 1, gap: 2 }}>
                  <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                    {m.quarter || QUARTER_LABELS[idx] || `${idx + 1}분기`}
                  </AppText>
                  <AppText variant="bodySmall" color={fortuneTheme.colors.textPrimary}>
                    {m.milestone}
                  </AppText>
                </View>
              </Card>
            ))}
          </View>
        </SectionCard>
      ) : null}

      {/* ===== 6. Action Plan ===== */}
      {hasActionPlan ? (
        <SectionCard title="실행 계획">
          {immediateActions.length > 0 ? (
            <View style={{ marginBottom: fortuneTheme.spacing.sm }}>
              <AppText variant="labelLarge" color="#F06292" style={{ marginBottom: 4 }}>
                즉시 실행
              </AppText>
              <BulletList items={immediateActions} />
            </View>
          ) : null}
          {shortTermActions.length > 0 ? (
            <View style={{ marginBottom: fortuneTheme.spacing.sm }}>
              <AppText variant="labelLarge" color="#8FB8FF" style={{ marginBottom: 4 }}>
                단기 계획
              </AppText>
              <BulletList items={shortTermActions} />
            </View>
          ) : null}
          {longTermActions.length > 0 ? (
            <View>
              <AppText variant="labelLarge" color="#CE93D8" style={{ marginBottom: 4 }}>
                장기 계획
              </AppText>
              <BulletList items={longTermActions} />
            </View>
          ) : null}
        </SectionCard>
      ) : null}

      {/* ===== 7. Lucky Items ===== */}
      {hasLuckyItems ? (
        <SectionCard title="올해의 행운 아이템">
          <MetricGrid items={[
            ...(luckyColor ? [{ label: '색상', value: luckyColor, note: '' }] : []),
            ...(luckyNumber ? [{ label: '숫자', value: luckyNumber, note: '' }] : []),
            ...(luckyDirection ? [{ label: '방위', value: luckyDirection, note: '' }] : []),
            ...(luckyItem ? [{ label: '아이템', value: luckyItem, note: '' }] : []),
            ...(luckyFood ? [{ label: '음식', value: luckyFood, note: '' }] : []),
          ]} />
        </SectionCard>
      ) : null}

      {/* ===== 8. Special Message ===== */}
      {specialMessage ? (
        <SectionCard title="특별 메시지">
          <InsetQuote text={specialMessage} />
        </SectionCard>
      ) : null}

      {/* ===== 9. Recommendations & Warnings ===== */}
      {recommendations.length > 0 ? (
        <SectionCard title="추천 사항">
          <BulletList items={recommendations} />
        </SectionCard>
      ) : null}
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  Export                                                            */
/* ------------------------------------------------------------------ */

export const ResultBatchA = {
  TraditionalSajuResult,
  DailyCalendarResult,
  MbtiResult,
  BloodTypeResult,
  ZodiacAnimalResult,
  NewYearResult,
};
