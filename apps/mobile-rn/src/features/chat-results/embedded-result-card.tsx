import { View } from 'react-native';

import { AppText } from '../../components/app-text';
import { Chip } from '../../components/chip';
import { fortuneTheme } from '../../lib/theme';
import type { ChatShellEmbeddedResultMessage } from '../../lib/chat-shell';
import { resultMetadataByKind } from '../fortune-results/mapping';
import {
  BulletList,
  InsetQuote,
  KeywordPills,
  MetricGrid,
  SectionCard,
} from '../fortune-results/primitives';

/**
 * Embedded result card rendered as a chat bubble.
 * Left-aligned, full-width, with Pencil design sections.
 * Displayed below the character avatar in the chat thread.
 */
export function EmbeddedResultCard({
  message,
}: {
  message: ChatShellEmbeddedResultMessage;
}) {
  const { payload, resultKind } = message;
  const metadata = resultMetadataByKind[resultKind];

  return (
    <View style={{ width: '100%' }}>
      {/* Bubble-style card container */}
      <View
        style={{
          backgroundColor: fortuneTheme.colors.backgroundTertiary,
          borderColor: fortuneTheme.colors.border,
          borderRadius: fortuneTheme.radius.messageBubble,
          borderWidth: 1,
          overflow: 'hidden',
          width: '100%',
        }}
      >
        {/* Header section with score badge */}
        <View
          style={{
            backgroundColor: fortuneTheme.colors.surfaceSecondary,
            borderBottomColor: fortuneTheme.colors.border,
            borderBottomWidth: 1,
            gap: 6,
            paddingHorizontal: 16,
            paddingVertical: 14,
          }}
        >
          <View
            style={{
              alignItems: 'flex-start',
              flexDirection: 'row',
              justifyContent: 'space-between',
              gap: 8,
            }}
          >
            <View style={{ flex: 1, gap: 3 }}>
              {payload.eyebrow ? (
                <View style={{ flexDirection: 'row', gap: 6, alignItems: 'center' }}>
                  <Chip label={payload.eyebrow} tone="accent" />
                </View>
              ) : null}
              <AppText variant="heading4">{payload.title}</AppText>
              {payload.subtitle ? (
                <AppText
                  variant="bodySmall"
                  color={fortuneTheme.colors.textSecondary}
                >
                  {payload.subtitle}
                </AppText>
              ) : null}
            </View>

            {/* Score badge */}
            {typeof payload.score === 'number' ? (
              <View
                style={{
                  alignItems: 'center',
                  backgroundColor: fortuneTheme.colors.ctaBackground,
                  borderRadius: fortuneTheme.radius.full,
                  minWidth: 52,
                  paddingHorizontal: 10,
                  paddingVertical: 6,
                }}
              >
                <AppText
                  variant="heading4"
                  color={fortuneTheme.colors.ctaForeground}
                >
                  {payload.score}
                </AppText>
                <AppText
                  variant="caption"
                  color={fortuneTheme.colors.ctaForeground}
                  style={{ opacity: 0.8 }}
                >
                  점
                </AppText>
              </View>
            ) : null}
          </View>
        </View>

        {/* Body content */}
        <View
          style={{
            gap: fortuneTheme.spacing.md,
            paddingHorizontal: 16,
            paddingVertical: 14,
          }}
        >
          {/* Summary */}
          <AppText variant="bodyMedium" color={fortuneTheme.colors.textPrimary}>
            {payload.summary}
          </AppText>

          {/* Context tags */}
          {payload.contextTags?.length ? (
            <SectionCard title="입력된 맥락">
              <KeywordPills keywords={payload.contextTags} />
            </SectionCard>
          ) : null}

          {/* Metrics grid */}
          {payload.metrics?.length ? (
            <MetricGrid items={payload.metrics} />
          ) : null}

          {/* Highlights */}
          {payload.highlights?.length ? (
            <SectionCard title="핵심 포인트">
              <BulletList items={payload.highlights} accent="핵심" />
            </SectionCard>
          ) : null}

          {/* Recommendations */}
          {payload.recommendations?.length ? (
            <SectionCard title="추천 액션">
              <BulletList items={payload.recommendations} accent="추천" />
            </SectionCard>
          ) : null}

          {/* Warnings */}
          {payload.warnings?.length ? (
            <SectionCard title="주의 포인트">
              <BulletList items={payload.warnings} accent="주의" />
            </SectionCard>
          ) : null}

          {/* Lucky items */}
          {payload.luckyItems?.length ? (
            <SectionCard title="행운 포인트">
              <KeywordPills keywords={payload.luckyItems} />
            </SectionCard>
          ) : null}

          {/* Special tip quote */}
          {payload.specialTip ? <InsetQuote text={payload.specialTip} /> : null}
        </View>

        {/* Footer with design reference */}
        <View
          style={{
            borderTopColor: fortuneTheme.colors.border,
            borderTopWidth: 1,
            paddingHorizontal: 16,
            paddingVertical: 8,
          }}
        >
          <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
            {metadata.fortuneCode} · {metadata.paperNodeId}
          </AppText>
        </View>
      </View>
    </View>
  );
}
