import { View } from "react-native";

import { AppText } from "../../components/app-text";
import { Card } from "../../components/card";
import { fortuneTheme } from "../../lib/theme";
import type { ChatShellEmbeddedResultMessage } from "../../lib/chat-shell";
import {
  BulletList,
  DoDontPair,
  InsetQuote,
  KeywordPills,
  MetricGrid,
  SectionCard,
  StatRail,
  Timeline,
} from "../fortune-results/primitives";

export function EmbeddedResultCard({
  message,
}: {
  message: ChatShellEmbeddedResultMessage;
}) {
  const { payload } = message;
  const isDaily = payload.fortuneType === "daily";
  const [leadHighlight, ...detailHighlights] = payload.highlights ?? [];

  return (
    <View style={{ width: "100%" }}>
      <Card>
        <View style={{ gap: fortuneTheme.spacing.sm }}>
          <View
            style={{
              alignItems: "flex-start",
              flexDirection: "row",
              justifyContent: "space-between",
              gap: fortuneTheme.spacing.sm,
            }}
          >
            <View style={{ flex: 1, gap: 4 }}>
              <AppText
                variant="caption"
                color={fortuneTheme.colors.textTertiary}
              >
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
            {typeof payload.score === "number" ? (
              <View
                style={{
                  alignItems: "center",
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
                  점수
                </AppText>
              </View>
            ) : null}
          </View>

          <AppText
            variant="bodyMedium"
            color={fortuneTheme.colors.textSecondary}
          >
            {payload.summary}
          </AppText>

          {isDaily ? (
            <>
              {leadHighlight ? (
                <SectionCard title="오늘 한 줄">
                  <AppText
                    variant="bodySmall"
                    color={fortuneTheme.colors.textSecondary}
                  >
                    {leadHighlight}
                  </AppText>
                </SectionCard>
              ) : null}

              {payload.metrics?.length ? (
                <MetricGrid items={payload.metrics} />
              ) : null}

              {payload.scoreRails?.length ? (
                <SectionCard title="핵심 지표">
                  <StatRail items={payload.scoreRails} />
                </SectionCard>
              ) : null}

              {payload.timeline?.length ? (
                <SectionCard title="시간대 흐름">
                  <Timeline items={payload.timeline} />
                </SectionCard>
              ) : null}

              {payload.detailSections?.length ? (
                <SectionCard title="분야별 읽기">
                  <View style={{ gap: fortuneTheme.spacing.sm }}>
                    {payload.detailSections.map((section) => (
                      <View
                        key={section.title}
                        style={{
                          backgroundColor: fortuneTheme.colors.surfaceSecondary,
                          borderColor: fortuneTheme.colors.border,
                          borderRadius: fortuneTheme.radius.md,
                          borderWidth: 1,
                          gap: fortuneTheme.spacing.xs,
                          padding: fortuneTheme.spacing.md,
                        }}
                      >
                        <View
                          style={{
                            alignItems: "center",
                            flexDirection: "row",
                            gap: fortuneTheme.spacing.sm,
                            justifyContent: "space-between",
                          }}
                        >
                          <AppText variant="labelLarge">
                            {section.title}
                          </AppText>
                          {typeof section.score === "number" ? (
                            <View
                              style={{
                                backgroundColor:
                                  fortuneTheme.colors.backgroundTertiary,
                                borderRadius: fortuneTheme.radius.full,
                                paddingHorizontal: 10,
                                paddingVertical: 4,
                              }}
                            >
                              <AppText
                                variant="caption"
                                color={fortuneTheme.colors.textSecondary}
                              >
                                {section.score}점
                              </AppText>
                            </View>
                          ) : null}
                        </View>
                        <AppText
                          variant="bodySmall"
                          color={fortuneTheme.colors.textSecondary}
                        >
                          {section.body}
                        </AppText>
                      </View>
                    ))}
                  </View>
                </SectionCard>
              ) : null}

              {detailHighlights.length ? (
                <SectionCard title="핵심 포인트">
                  <BulletList items={detailHighlights} accent="핵심" />
                </SectionCard>
              ) : null}

              {payload.actionPair ? (
                <DoDontPair data={payload.actionPair} />
              ) : payload.recommendations?.length ? (
                <SectionCard title="실천 팁">
                  <BulletList items={payload.recommendations} accent="실천" />
                </SectionCard>
              ) : null}

              {!payload.actionPair && payload.warnings?.length ? (
                <SectionCard title="주의할 점">
                  <BulletList items={payload.warnings} accent="주의" />
                </SectionCard>
              ) : null}

              {payload.luckyItems?.length ? (
                <SectionCard title="행운 포인트">
                  {shouldRenderLuckyItemsAsPills(payload.luckyItems) ? (
                    <KeywordPills keywords={payload.luckyItems} />
                  ) : (
                    <BulletList items={payload.luckyItems} accent="행운" />
                  )}
                </SectionCard>
              ) : null}

              {payload.specialTip ? (
                <InsetQuote text={payload.specialTip} />
              ) : null}
            </>
          ) : (
            <>
              {payload.contextTags?.length ? (
                <SectionCard title="입력된 맥락">
                  <KeywordPills keywords={payload.contextTags} />
                </SectionCard>
              ) : null}

              {payload.metrics?.length ? (
                <MetricGrid items={payload.metrics} />
              ) : null}

              {payload.scoreRails?.length ? (
                <SectionCard title="핵심 지표">
                  <StatRail items={payload.scoreRails} />
                </SectionCard>
              ) : null}

              {payload.detailSections?.length ? (
                <SectionCard title="분야별 읽기">
                  <View style={{ gap: fortuneTheme.spacing.sm }}>
                    {payload.detailSections.map((section) => (
                      <View
                        key={section.title}
                        style={{
                          backgroundColor: fortuneTheme.colors.surfaceSecondary,
                          borderColor: fortuneTheme.colors.border,
                          borderRadius: fortuneTheme.radius.md,
                          borderWidth: 1,
                          gap: fortuneTheme.spacing.xs,
                          padding: fortuneTheme.spacing.md,
                        }}
                      >
                        <View
                          style={{
                            alignItems: "center",
                            flexDirection: "row",
                            gap: fortuneTheme.spacing.sm,
                            justifyContent: "space-between",
                          }}
                        >
                          <AppText variant="labelLarge">
                            {section.title}
                          </AppText>
                          {typeof section.score === "number" ? (
                            <View
                              style={{
                                backgroundColor:
                                  fortuneTheme.colors.backgroundTertiary,
                                borderRadius: fortuneTheme.radius.full,
                                paddingHorizontal: 10,
                                paddingVertical: 4,
                              }}
                            >
                              <AppText
                                variant="caption"
                                color={fortuneTheme.colors.textSecondary}
                              >
                                {section.score}점
                              </AppText>
                            </View>
                          ) : null}
                        </View>
                        <AppText
                          variant="bodySmall"
                          color={fortuneTheme.colors.textSecondary}
                        >
                          {section.body}
                        </AppText>
                      </View>
                    ))}
                  </View>
                </SectionCard>
              ) : null}

              {payload.highlights?.length ? (
                <SectionCard title="핵심 포인트">
                  <BulletList items={payload.highlights} accent="핵심" />
                </SectionCard>
              ) : null}

              {payload.actionPair ? (
                <DoDontPair data={payload.actionPair} />
              ) : payload.recommendations?.length ? (
                <SectionCard title="추천 액션">
                  <BulletList items={payload.recommendations} accent="추천" />
                </SectionCard>
              ) : null}

              {!payload.actionPair && payload.warnings?.length ? (
                <SectionCard title="주의 포인트">
                  <BulletList items={payload.warnings} accent="주의" />
                </SectionCard>
              ) : null}

              {payload.luckyItems?.length ? (
                <SectionCard title="행운 포인트">
                  {shouldRenderLuckyItemsAsPills(payload.luckyItems) ? (
                    <KeywordPills keywords={payload.luckyItems} />
                  ) : (
                    <BulletList items={payload.luckyItems} accent="행운" />
                  )}
                </SectionCard>
              ) : null}

              {payload.specialTip ? (
                <InsetQuote text={payload.specialTip} />
              ) : null}
            </>
          )}
        </View>
      </Card>
    </View>
  );
}

function shouldRenderLuckyItemsAsPills(items: string[]) {
  return items.every(
    (item) => item.trim().length <= 12 && !item.includes("\n"),
  );
}
