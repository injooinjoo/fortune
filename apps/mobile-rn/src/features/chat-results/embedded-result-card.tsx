import { View } from 'react-native';

import { AppText } from '../../components/app-text';
import { Card } from '../../components/card';
import { fortuneTheme } from '../../lib/theme';
import type { ChatShellEmbeddedResultMessage } from '../../lib/chat-shell';
import {
  BulletList,
  InsetQuote,
  KeywordPills,
  MetricGrid,
  SectionCard,
} from '../fortune-results/primitives';
import { RenderFortuneResult } from '../fortune-results/registry';
import { resolveResultKindFromFortuneType } from '../fortune-results/mapping';

export function EmbeddedResultCard({
  message,
}: {
  message: ChatShellEmbeddedResultMessage;
}) {
  const { payload } = message;

  // Try to use the dedicated result component if available
  const resultKind = resolveResultKindFromFortuneType(message.fortuneType);
  if (resultKind) {
    return (
      <View style={{ width: '100%' }}>
        <Card>
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            <RenderFortuneResult resultKind={resultKind} payload={payload} />
            <AppText variant="caption" color={fortuneTheme.colors.textTertiary} style={{ textAlign: 'center', marginTop: 8 }}>
              오락 목적의 AI 생성 콘텐츠입니다
            </AppText>
          </View>
        </Card>
      </View>
    );
  }

  // Fallback: generic normalized rendering
  return (
    <View style={{ width: '100%' }}>
      <Card>
        <View style={{ gap: fortuneTheme.spacing.sm }}>
          <View
            style={{
              alignItems: 'flex-start',
              flexDirection: 'row',
              justifyContent: 'space-between',
              gap: fortuneTheme.spacing.sm,
            }}
          >
            <View style={{ flex: 1, gap: 4 }}>
              <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
                {payload.eyebrow}
              </AppText>
              <AppText variant="heading4">{payload.title}</AppText>
              <AppText
                variant="bodySmall"
                color={fortuneTheme.colors.textSecondary}
              >
                {payload.subtitle}
              </AppText>
            </View>
            {typeof payload.score === 'number' ? (
              <View
                style={{
                  alignItems: 'center',
                  backgroundColor: fortuneTheme.colors.backgroundTertiary,
                  borderRadius: fortuneTheme.radius.full,
                  minWidth: 56,
                  paddingHorizontal: 12,
                  paddingVertical: 8,
                }}
              >
                <AppText variant="labelLarge">{payload.score}</AppText>
                <AppText
                  variant="caption"
                  color={fortuneTheme.colors.textTertiary}
                >
                  score
                </AppText>
              </View>
            ) : null}
          </View>

          <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
            {payload.summary}
          </AppText>

          {message.fortuneType !== 'celebrity' && payload.contextTags?.length ? (
            <SectionCard title="입력된 맥락">
              <KeywordPills keywords={payload.contextTags} />
            </SectionCard>
          ) : null}

          {payload.metrics?.length ? <MetricGrid items={payload.metrics} /> : null}

          {payload.highlights?.length ? (
            <SectionCard title="핵심 포인트">
              <BulletList items={payload.highlights} accent="핵심" />
            </SectionCard>
          ) : null}

          {payload.recommendations?.length ? (
            <SectionCard title="추천 액션">
              <BulletList items={payload.recommendations} accent="추천" />
            </SectionCard>
          ) : null}

          {payload.warnings?.length ? (
            <SectionCard title="주의 포인트">
              <BulletList items={payload.warnings} accent="주의" />
            </SectionCard>
          ) : null}

          {payload.luckyItems?.length ? (
            <SectionCard title="행운 포인트">
              <KeywordPills keywords={payload.luckyItems} />
            </SectionCard>
          ) : null}

          {payload.specialTip ? <InsetQuote text={payload.specialTip} /> : null}

          <AppText variant="caption" color={fortuneTheme.colors.textTertiary} style={{ textAlign: 'center', marginTop: 8 }}>
            오락 목적의 AI 생성 콘텐츠입니다
          </AppText>
        </View>
      </Card>
    </View>
  );
}
