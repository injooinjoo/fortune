/**
 * ManseryeokInterpretation — Sprint 3.
 *
 * SajuResult를 받아 `useSajuInterpretation`으로 Edge Function에서 AI 해석을
 * 받아와 섹션 카드 스택으로 표시한다.
 * - 로딩: 스피너 + 안내 텍스트
 * - 에러: 재시도 Pressable
 * - 성공: 오늘의 한 줄 / 종합 / 성격 / 직업 / 재물 / 애정 / 건강 / 대운별 시기
 */

import { ActivityIndicator, View } from 'react-native';

import type { SajuResult } from '@fortune/saju-engine';

import { AppText } from '../../../components/app-text';
import { Card } from '../../../components/card';
import {
  useSajuInterpretation,
  type SajuInterpretationData,
} from '../../../hooks/use-saju-interpretation';
import { fortuneTheme, withAlpha } from '../../../lib/theme';

type TagTone = 'positive' | 'caution' | 'info';

interface TagItem {
  label: string;
  tone: TagTone;
}

interface Props {
  sajuData: SajuResult;
}

export function ManseryeokInterpretation({ sajuData }: Props) {
  const { data, isEnhancing } = useSajuInterpretation(sajuData);

  // fallback이 항상 존재하므로 data가 null인 경우는 sajuData 자체가 null일 때만.
  if (!data) return null;

  return (
    <View>
      {isEnhancing ? <EnhancingBadge /> : null}
      <InterpretationContent data={data} />
    </View>
  );
}

function EnhancingBadge() {
  return (
    <View
      style={{
        marginTop: fortuneTheme.spacing.md,
        paddingHorizontal: 12,
        paddingVertical: 8,
        borderRadius: fortuneTheme.radius.full,
        alignSelf: 'flex-start',
        flexDirection: 'row',
        alignItems: 'center',
        gap: 6,
        backgroundColor: withAlpha(fortuneTheme.colors.ctaBackground, 0.1),
      }}
    >
      <ActivityIndicator size="small" color={fortuneTheme.colors.ctaBackground} />
      <AppText
        variant="labelSmall"
        color={fortuneTheme.colors.ctaBackground}
      >
        AI 심화 해석 준비 중…
      </AppText>
    </View>
  );
}

function InterpretationContent({ data }: { data: SajuInterpretationData }) {
  return (
    <View style={{ gap: fortuneTheme.spacing.sm, marginTop: fortuneTheme.spacing.md }}>
      <DailyCard data={data.daily} />

      <SectionCard title="✨ 종합" body={data.overallSummary} />

      <SectionCard
        title="👤 성격"
        body={data.personality.summary}
        tags={[
          ...data.personality.strengths.map<TagItem>((s) => ({
            label: `+ ${s}`,
            tone: 'positive',
          })),
          ...data.personality.challenges.map<TagItem>((c) => ({
            label: `− ${c}`,
            tone: 'caution',
          })),
        ]}
      />

      <SectionCard
        title="💼 직업"
        body={data.career.summary}
        tags={data.career.suitableFields.map<TagItem>((f) => ({
          label: f,
          tone: 'info',
        }))}
        footer={data.career.advice}
      />

      <SectionCard
        title="💰 재물"
        body={data.wealth.summary}
        tags={data.wealth.bestPeriods.map<TagItem>((p) => ({
          label: p,
          tone: 'info',
        }))}
        footer={`주의 · ${data.wealth.caution}`}
      />

      <SectionCard
        title="💞 애정"
        body={data.love.summary}
        tags={data.love.compatibleTypes.map<TagItem>((t) => ({
          label: t,
          tone: 'info',
        }))}
        footer={data.love.advice}
      />

      <SectionCard
        title="🌱 건강"
        body={data.health.summary}
        tags={data.health.weakPoints.map<TagItem>((w) => ({
          label: w,
          tone: 'caution',
        }))}
        footer={data.health.advice}
      />

      <LuckCyclesCard cycles={data.luckCycles} />
    </View>
  );
}

function DailyCard({
  data,
}: {
  data: SajuInterpretationData['daily'];
}) {
  return (
    <Card
      style={{
        backgroundColor: withAlpha(fortuneTheme.colors.ctaBackground, 0.08),
        borderColor: withAlpha(fortuneTheme.colors.ctaBackground, 0.2),
      }}
    >
      <AppText
        variant="kicker"
        color={fortuneTheme.colors.ctaBackground}
      >
        오늘의 한 줄
      </AppText>
      <AppText
        variant="heading3"
        color={fortuneTheme.colors.textPrimary}
        style={{ marginTop: fortuneTheme.spacing.xs }}
      >
        {data.oneLiner}
      </AppText>
      <View
        style={{
          flexDirection: 'row',
          gap: fortuneTheme.spacing.md,
          marginTop: fortuneTheme.spacing.sm,
        }}
      >
        <AppText
          variant="labelSmall"
          color={fortuneTheme.colors.textSecondary}
        >
          🎨 {data.luckyColor}
        </AppText>
        <AppText
          variant="labelSmall"
          color={fortuneTheme.colors.textSecondary}
        >
          🧭 {data.luckyDirection}
        </AppText>
      </View>
    </Card>
  );
}

interface SectionCardProps {
  title: string;
  body: string;
  tags?: TagItem[];
  footer?: string;
}

function SectionCard({ title, body, tags, footer }: SectionCardProps) {
  return (
    <Card>
      <AppText
        variant="labelLarge"
        color={fortuneTheme.colors.textPrimary}
      >
        {title}
      </AppText>
      <AppText
        variant="bodyMedium"
        color={fortuneTheme.colors.textPrimary}
        style={{ marginTop: fortuneTheme.spacing.xs }}
      >
        {body}
      </AppText>
      {tags && tags.length > 0 ? (
        <View
          style={{
            flexDirection: 'row',
            flexWrap: 'wrap',
            gap: fortuneTheme.spacing.xs,
            marginTop: fortuneTheme.spacing.sm,
          }}
        >
          {tags.map((t, i) => (
            <TagPill key={`${t.label}-${i}`} item={t} />
          ))}
        </View>
      ) : null}
      {footer ? (
        <AppText
          variant="labelMedium"
          color={fortuneTheme.colors.textSecondary}
          style={{ marginTop: fortuneTheme.spacing.sm }}
        >
          💡 {footer}
        </AppText>
      ) : null}
    </Card>
  );
}

function TagPill({ item }: { item: TagItem }) {
  const base = toneColor(item.tone);
  return (
    <View
      style={{
        paddingHorizontal: 10,
        paddingVertical: 4,
        borderRadius: fortuneTheme.radius.full,
        backgroundColor: withAlpha(base, 0.12),
      }}
    >
      <AppText variant="labelSmall" color={base}>
        {item.label}
      </AppText>
    </View>
  );
}

function toneColor(tone: TagTone): string {
  switch (tone) {
    case 'positive':
      return fortuneTheme.colors.success;
    case 'caution':
      return fortuneTheme.colors.warning;
    case 'info':
    default:
      return fortuneTheme.colors.ctaBackground;
  }
}

function LuckCyclesCard({
  cycles,
}: {
  cycles: SajuInterpretationData['luckCycles'];
}) {
  if (cycles.length === 0) return null;
  return (
    <Card>
      <AppText
        variant="labelLarge"
        color={fortuneTheme.colors.textPrimary}
      >
        🗓️ 대운별 시기
      </AppText>
      <View style={{ marginTop: fortuneTheme.spacing.sm }}>
        {cycles.map((c, i) => (
          <View
            key={`${c.ageRange}-${i}`}
            style={{
              paddingVertical: fortuneTheme.spacing.sm,
              borderBottomWidth: i < cycles.length - 1 ? 1 : 0,
              borderBottomColor: fortuneTheme.colors.border,
            }}
          >
            <View
              style={{
                flexDirection: 'row',
                alignItems: 'center',
                gap: fortuneTheme.spacing.xs,
              }}
            >
              <AppText
                variant="labelMedium"
                color={fortuneTheme.colors.ctaBackground}
              >
                {c.ageRange}
              </AppText>
              <AppText
                variant="labelSmall"
                color={fortuneTheme.colors.textSecondary}
              >
                · {c.theme}
              </AppText>
            </View>
            <AppText
              variant="bodySmall"
              color={fortuneTheme.colors.textSecondary}
              style={{ marginTop: 2 }}
            >
              {c.summary}
            </AppText>
          </View>
        ))}
      </View>
    </Card>
  );
}
