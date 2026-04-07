import type { PropsWithChildren, ReactNode } from 'react';

import { Pressable, View } from 'react-native';
import { router } from 'expo-router';

import { AppText } from '../../components/app-text';
import { Card } from '../../components/card';
import { Chip } from '../../components/chip';
import { PrimaryButton } from '../../components/primary-button';
import { Screen } from '../../components/screen';
import { fortuneTheme } from '../../lib/theme';
import type {
  DoDontData,
  MetricTileData,
  ResultMetadata,
  StatRailData,
  TimelineEntry,
} from './types';

export function FortuneResultLayout({
  metadata,
  children,
}: PropsWithChildren<{ metadata: ResultMetadata }>) {
  return (
    <Screen>
      <View style={{ gap: fortuneTheme.spacing.sm }}>
        <Pressable
          accessibilityRole="button"
          onPress={() => router.back()}
          style={({ pressed }) => ({ opacity: pressed ? 0.8 : 1 })}
        >
          <View
            style={{
              alignSelf: 'flex-start',
              paddingVertical: fortuneTheme.spacing.xs,
            }}
          >
            <AppText variant="labelLarge" color={fortuneTheme.colors.accentSecondary}>
              이전으로
            </AppText>
          </View>
        </Pressable>

        <View style={{ gap: fortuneTheme.spacing.xs }}>
          <AppText variant="labelMedium" color={fortuneTheme.colors.accentSecondary}>
            {metadata.eyebrow}
          </AppText>
          <AppText variant="displaySmall">{metadata.title}</AppText>
          <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
            {metadata.subtitle}
          </AppText>
          <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
            <Chip label={metadata.fortuneCode} tone="accent" />
            <Chip label={metadata.paperNodeId} />
            <Chip label={metadata.resultKind} />
          </View>
        </View>
      </View>

      <View style={{ gap: fortuneTheme.spacing.md }}>{children}</View>

      <CTAFooter />
    </Screen>
  );
}

export function HeroCard({
  emoji,
  title,
  description,
  chips = [],
  aside,
}: {
  emoji: string;
  title: string;
  description: string;
  chips?: string[];
  aside?: ReactNode;
}) {
  return (
    <Card
      style={{
        backgroundColor: fortuneTheme.colors.backgroundTertiary,
        gap: fortuneTheme.spacing.md,
      }}
    >
      <View
        style={{
          flexDirection: 'row',
          gap: fortuneTheme.spacing.md,
          justifyContent: 'space-between',
        }}
      >
        <View style={{ flex: 1, gap: fortuneTheme.spacing.sm }}>
          <AppText variant="displaySmall">{emoji}</AppText>
          <AppText variant="heading2">{title}</AppText>
          <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
            {description}
          </AppText>
        </View>
        {aside ? <View style={{ flexShrink: 1 }}>{aside}</View> : null}
      </View>
      {chips.length > 0 ? <KeywordPills keywords={chips} /> : null}
    </Card>
  );
}

export function SectionCard({
  title,
  description,
  children,
}: PropsWithChildren<{
  title: string;
  description?: string;
}>) {
  return (
    <Card>
      <View style={{ gap: fortuneTheme.spacing.xs }}>
        <AppText variant="heading4">{title}</AppText>
        {description ? (
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {description}
          </AppText>
        ) : null}
      </View>
      <View style={{ gap: fortuneTheme.spacing.sm }}>{children}</View>
    </Card>
  );
}

export function MetricGrid({ items }: { items: MetricTileData[] }) {
  return (
    <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: fortuneTheme.spacing.sm }}>
      {items.map((item) => (
        <View key={item.label} style={{ minWidth: '47%', flexGrow: 1, flexBasis: '47%' }}>
          <MetricTile {...item} />
        </View>
      ))}
    </View>
  );
}

export function MetricTile({ label, value, note }: MetricTileData) {
  return (
    <View
      style={{
        backgroundColor: fortuneTheme.colors.surfaceSecondary,
        borderRadius: fortuneTheme.radius.md,
        borderWidth: 1,
        borderColor: fortuneTheme.colors.border,
        gap: fortuneTheme.spacing.xs,
        padding: fortuneTheme.spacing.md,
      }}
    >
      <AppText variant="labelMedium" color={fortuneTheme.colors.textSecondary}>
        {label}
      </AppText>
      <AppText variant="heading3">{value}</AppText>
      {note ? (
        <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
          {note}
        </AppText>
      ) : null}
    </View>
  );
}

export function StatRail({ items }: { items: StatRailData[] }) {
  return (
    <View style={{ gap: fortuneTheme.spacing.sm }}>
      {items.map((item) => {
        const clampedValue = Math.max(0, Math.min(100, item.value));

        return (
          <View key={item.label} style={{ gap: fortuneTheme.spacing.xs }}>
            <View
              style={{
                flexDirection: 'row',
                justifyContent: 'space-between',
                gap: fortuneTheme.spacing.sm,
              }}
            >
              <AppText variant="labelLarge">{item.label}</AppText>
              <AppText variant="labelLarge" color={fortuneTheme.colors.accentSecondary}>
                {clampedValue}
              </AppText>
            </View>
            <View
              style={{
                backgroundColor: fortuneTheme.colors.surfaceSecondary,
                borderRadius: fortuneTheme.radius.full,
                height: 10,
                overflow: 'hidden',
              }}
            >
              <View
                style={{
                  backgroundColor: fortuneTheme.colors.ctaBackground,
                  borderRadius: fortuneTheme.radius.full,
                  height: '100%',
                  width: `${clampedValue}%`,
                }}
              />
            </View>
            {item.highlight ? (
              <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                {item.highlight}
              </AppText>
            ) : null}
          </View>
        );
      })}
    </View>
  );
}

export function Timeline({ items }: { items: TimelineEntry[] }) {
  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      {items.map((item, index) => (
        <View
          key={`${item.title}-${index}`}
          style={{ flexDirection: 'row', gap: fortuneTheme.spacing.sm }}
        >
          <View style={{ alignItems: 'center', paddingTop: 4 }}>
            <View
              style={{
                backgroundColor: fortuneTheme.colors.accentSecondary,
                borderRadius: fortuneTheme.radius.full,
                height: 10,
                width: 10,
              }}
            />
            {index < items.length - 1 ? (
              <View
                style={{
                  backgroundColor: fortuneTheme.colors.borderOpaque,
                  marginTop: 4,
                  minHeight: 32,
                  width: 2,
                }}
              />
            ) : null}
          </View>
          <View style={{ flex: 1, gap: fortuneTheme.spacing.xs }}>
            <View
              style={{
                alignItems: 'center',
                flexDirection: 'row',
                flexWrap: 'wrap',
                gap: fortuneTheme.spacing.xs,
              }}
            >
              <AppText variant="labelLarge">{item.title}</AppText>
              {item.tag ? <Chip label={item.tag} /> : null}
            </View>
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              {item.body}
            </AppText>
          </View>
        </View>
      ))}
    </View>
  );
}

export function DoDontPair({ data }: { data: DoDontData }) {
  return (
    <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: fortuneTheme.spacing.sm }}>
      <View style={{ minWidth: '47%', flexGrow: 1, flexBasis: '47%' }}>
        <SectionCard title={data.doTitle ?? '추천'}>
          <BulletList items={data.doItems} accent="추천" />
        </SectionCard>
      </View>
      <View style={{ minWidth: '47%', flexGrow: 1, flexBasis: '47%' }}>
        <SectionCard title={data.dontTitle ?? '주의'}>
          <BulletList items={data.dontItems} accent="주의" />
        </SectionCard>
      </View>
    </View>
  );
}

export function BulletList({
  items,
  accent = '포인트',
}: {
  items: string[];
  accent?: string;
}) {
  return (
    <View style={{ gap: fortuneTheme.spacing.sm }}>
      {items.map((item, index) => (
        <View key={`${accent}-${index}`} style={{ flexDirection: 'row', gap: fortuneTheme.spacing.sm }}>
          <View
            style={{
              alignItems: 'center',
              justifyContent: 'center',
              paddingTop: 2,
            }}
          >
            <View
              style={{
                backgroundColor: fortuneTheme.colors.accentSecondary,
                borderRadius: fortuneTheme.radius.full,
                height: 6,
                width: 6,
              }}
            />
          </View>
          <AppText
            style={{ flex: 1 }}
            variant="bodySmall"
            color={fortuneTheme.colors.textSecondary}
          >
            {item}
          </AppText>
        </View>
      ))}
    </View>
  );
}

export function KeywordPills({ keywords }: { keywords: string[] }) {
  return (
    <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
      {keywords.map((keyword) => (
        <Chip key={keyword} label={keyword} />
      ))}
    </View>
  );
}

export function InsetQuote({ text }: { text: string }) {
  return (
    <View
      style={{
        backgroundColor: fortuneTheme.colors.surfaceSecondary,
        borderLeftColor: fortuneTheme.colors.accentSecondary,
        borderLeftWidth: 3,
        borderRadius: fortuneTheme.radius.md,
        padding: fortuneTheme.spacing.md,
      }}
    >
      <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
        {text}
      </AppText>
    </View>
  );
}

export function CTAFooter() {
  return (
    <Card>
      <AppText variant="heading4">다음 동선</AppText>
      <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
        이 wave에서는 결과 화면을 canonical surface로 두고, 채팅은 결과 재진입 허브로 유지합니다.
      </AppText>
      <PrimaryButton onPress={() => router.replace('/chat')}>
        채팅으로 돌아가기
      </PrimaryButton>
      <PrimaryButton onPress={() => router.replace('/profile')} tone="secondary">
        프로필 표면 보기
      </PrimaryButton>
    </Card>
  );
}
