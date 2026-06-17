import type { PropsWithChildren } from 'react';

import { Pressable, View } from 'react-native';
import { router } from 'expo-router';

import { AppText } from '../../components/app-text';
import { Card } from '../../components/card';
import { Chip } from '../../components/chip';
import { Screen } from '../../components/screen';
import { fortuneTheme } from '../../lib/theme';
import type { MetricTileData, ResultMetadata } from './types';

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
        </View>
      </View>

      <View style={{ gap: fortuneTheme.spacing.md }}>{children}</View>
    </Screen>
  );
}

export function SectionCard({
  title,
  description,
  accent,
  children,
}: PropsWithChildren<{
  title: string;
  description?: string;
  /** Accent bar color on the left of the title. Defaults to CTA purple. */
  accent?: string;
}>) {
  const accentColor = accent ?? fortuneTheme.colors.ctaBackground;
  return (
    <Card>
      <View style={{ gap: fortuneTheme.spacing.xs }}>
        <View
          style={{
            flexDirection: 'row',
            alignItems: 'center',
            gap: fortuneTheme.spacing.sm,
          }}
        >
          <View
            style={{
              width: 4,
              height: 14,
              borderRadius: 2,
              backgroundColor: accentColor,
            }}
          />
          <AppText
            variant="kicker"
            color={fortuneTheme.colors.textSecondary}
            style={{ textTransform: 'uppercase' }}
          >
            {title}
          </AppText>
        </View>
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

function MetricTile({ label, value, note }: MetricTileData) {
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
