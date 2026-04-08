import { Platform } from 'react-native';

import { fortuneTheme } from '../theme';

export type FortuneWidgetTone = 'positive' | 'balanced' | 'careful';

export type FortuneHomeWidgetProps = {
  headline: string;
  summary: string;
  scoreLabel: string;
  badgeLabel: string;
  updatedAtLabel: string;
  tone: FortuneWidgetTone;
  accentColor: string;
  surfaceColor: string;
  textColor: string;
  secondaryTextColor: string;
};

export type FortuneWidgetSnapshotInput = {
  headline?: string | null;
  summary?: string | null;
  score?: number | string | null;
  badgeLabel?: string | null;
  fortuneType?: string | null;
  updatedAt?: Date | string | number | null;
  tone?: FortuneWidgetTone | null;
  accentColor?: string | null;
  surfaceColor?: string | null;
  textColor?: string | null;
  secondaryTextColor?: string | null;
};

export type FortuneWidgetSnapshot = FortuneHomeWidgetProps;

type WidgetTimelineEntryLike<Props> = {
  date: Date;
  props: Props;
};

type FortuneHomeWidgetModule = {
  getFortuneHomeWidget: () => {
    updateSnapshot: (snapshot: FortuneWidgetSnapshot) => void;
    updateTimeline: (
      entries: Array<{ date: Date; props: FortuneWidgetSnapshot }>,
    ) => void;
    getTimeline: () => Promise<Array<WidgetTimelineEntryLike<FortuneWidgetSnapshot>>>;
    reload: () => void;
  } | null;
};

function loadFortuneHomeWidgetModule(): FortuneHomeWidgetModule | null {
  try {
    return require('../../widgets/fortune-home-widget') as FortuneHomeWidgetModule;
  } catch {
    return null;
  }
}

function isSupportedWidgetPlatform() {
  return Platform.OS === 'ios';
}

function toDate(value: FortuneWidgetSnapshotInput['updatedAt']) {
  if (value instanceof Date) {
    return value;
  }

  if (typeof value === 'string' || typeof value === 'number') {
    const parsed = new Date(value);
    if (!Number.isNaN(parsed.getTime())) {
      return parsed;
    }
  }

  return new Date();
}

function formatUpdatedAtLabel(date: Date) {
  const pad = (value: number) => String(value).padStart(2, '0');

  return `${pad(date.getMonth() + 1)}/${pad(date.getDate())} ${pad(
    date.getHours(),
  )}:${pad(date.getMinutes())}`;
}

function normalizeHeadline(value: FortuneWidgetSnapshotInput) {
  const headline =
    value.headline?.trim() ||
    value.fortuneType?.trim() ||
    value.badgeLabel?.trim() ||
    '오늘의 운세';

  return headline.length > 28 ? `${headline.slice(0, 28)}…` : headline;
}

function normalizeSummary(value: FortuneWidgetSnapshotInput) {
  const summary = value.summary?.trim() || '한눈에 흐름을 확인할 수 있도록 업데이트됐어요.';

  return summary.length > 90 ? `${summary.slice(0, 90)}…` : summary;
}

function normalizeScoreLabel(score: FortuneWidgetSnapshotInput['score']) {
  if (score === null || score === undefined || score === '') {
    return 'Score -';
  }

  if (typeof score === 'number' && Number.isFinite(score)) {
    return `Score ${Math.round(score)}`;
  }

  const trimmed = String(score).trim();
  if (!trimmed) {
    return 'Score -';
  }

  return trimmed.startsWith('Score') ? trimmed : `Score ${trimmed}`;
}

function normalizeTone(scoreLabel: string, fallback?: FortuneWidgetTone | null) {
  if (fallback) {
    return fallback;
  }

  const match = scoreLabel.match(/(\d{1,3})/);
  const numeric = match ? Number(match[1]) : Number.NaN;

  if (Number.isFinite(numeric) && numeric >= 80) {
    return 'positive';
  }

  if (Number.isFinite(numeric) && numeric < 60) {
    return 'careful';
  }

  return 'balanced';
}

function normalizeBadgeLabel(value: FortuneWidgetSnapshotInput) {
  const raw = value.badgeLabel?.trim() || value.fortuneType?.trim() || 'Fortune';
  return raw.length > 18 ? `${raw.slice(0, 18)}…` : raw;
}

export function createFortuneWidgetSnapshot(
  input: FortuneWidgetSnapshotInput = {},
): FortuneWidgetSnapshot {
  const scoreLabel = normalizeScoreLabel(input.score);
  const tone = normalizeTone(scoreLabel, input.tone);
  const updatedAt = toDate(input.updatedAt);

  return {
    headline: normalizeHeadline(input),
    summary: normalizeSummary(input),
    scoreLabel,
    badgeLabel: normalizeBadgeLabel(input),
    updatedAtLabel: formatUpdatedAtLabel(updatedAt),
    tone,
    accentColor: input.accentColor?.trim() || fortuneHomeWidgetTheme.accentColor,
    surfaceColor: input.surfaceColor?.trim() || fortuneHomeWidgetTheme.surfaceColor,
    textColor: input.textColor?.trim() || fortuneHomeWidgetTheme.textColor,
    secondaryTextColor:
      input.secondaryTextColor?.trim() || fortuneHomeWidgetTheme.secondaryTextColor,
  };
}

export function getDefaultFortuneWidgetSnapshot(): FortuneWidgetSnapshot {
  return createFortuneWidgetSnapshot({
    headline: '오늘의 흐름을 확인해 보세요',
    summary: '최근 결과를 기반으로 핵심 메시지를 빠르게 보여드려요.',
    score: 'Score -',
    badgeLabel: 'Today',
  });
}

export function updateFortuneWidgetSnapshot(input: FortuneWidgetSnapshotInput = {}) {
  const widgetModule = loadFortuneHomeWidgetModule();
  const widget = widgetModule?.getFortuneHomeWidget();
  if (!widget || !isSupportedWidgetPlatform()) {
    return false;
  }

  widget.updateSnapshot(createFortuneWidgetSnapshot(input));
  return true;
}

export function scheduleFortuneWidgetTimeline(
  entries: Array<WidgetTimelineEntryLike<FortuneWidgetSnapshotInput>>,
) {
  const widgetModule = loadFortuneHomeWidgetModule();
  const widget = widgetModule?.getFortuneHomeWidget();
  if (!widget || !isSupportedWidgetPlatform()) {
    return false;
  }

  widget.updateTimeline(
    entries.map((entry) => ({
      date: entry.date,
      props: createFortuneWidgetSnapshot(entry.props),
    })),
  );

  return true;
}

export async function readFortuneWidgetTimeline() {
  const widgetModule = loadFortuneHomeWidgetModule();
  const widget = widgetModule?.getFortuneHomeWidget();
  if (!widget || !isSupportedWidgetPlatform()) {
    return [];
  }

  return widget.getTimeline();
}

export function reloadFortuneWidget() {
  const widgetModule = loadFortuneHomeWidgetModule();
  const widget = widgetModule?.getFortuneHomeWidget();
  if (!widget || !isSupportedWidgetPlatform()) {
    return false;
  }

  widget.reload();
  return true;
}

export const fortuneHomeWidgetTheme = {
  surfaceColor: fortuneTheme.colors.surface,
  accentColor: fortuneTheme.colors.ctaBackground,
  textColor: fortuneTheme.colors.textPrimary,
  secondaryTextColor: fortuneTheme.colors.textSecondary,
};
