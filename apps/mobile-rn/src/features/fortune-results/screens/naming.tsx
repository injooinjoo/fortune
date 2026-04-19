import { View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { Card } from '../../../components/card';
import { fortuneTheme, withAlpha } from '../../../lib/theme';
import { HeroNaming } from '../heroes';
import {
  BulletList,
  InsetQuote,
  SectionCard,
} from '../primitives';
import type { FortuneResultComponentProps } from '../types';
import { useResultData } from '../use-result-data';

/* ------------------------------------------------------------------ */
/*  Type helpers (same pattern as face-reading)                        */
/* ------------------------------------------------------------------ */

type R = Record<string, unknown>;

function obj(val: unknown): R {
  return val != null && typeof val === 'object' && !Array.isArray(val)
    ? (val as R)
    : {};
}

function str(val: unknown, fallback = ''): string {
  return typeof val === 'string' && val.trim() ? val.trim() : fallback;
}

function num(val: unknown, fallback = 0): number {
  if (typeof val === 'number' && !Number.isNaN(val)) return val;
  if (typeof val === 'string') {
    const n = Number(val);
    if (!Number.isNaN(n)) return n;
  }
  return fallback;
}

function arr(val: unknown): unknown[] {
  return Array.isArray(val) ? val : [];
}

function strArr(val: unknown): string[] {
  return arr(val)
    .map((v) => str(v))
    .filter(Boolean);
}

/* ------------------------------------------------------------------ */
/*  Ohaeng (Five-Element) constants                                    */
/* ------------------------------------------------------------------ */

const OHAENG_ELEMENTS = ['木', '火', '土', '金', '水'] as const;

const OHAENG_META: Record<
  string,
  { label: string; labelKo: string; color: string }
> = {
  木: { label: '木', labelKo: '목', color: fortuneTheme.colors.elemental.wood },
  火: { label: '火', labelKo: '화', color: fortuneTheme.colors.elemental.fire },
  土: { label: '土', labelKo: '토', color: fortuneTheme.colors.elemental.earth },
  金: { label: '金', labelKo: '금', color: fortuneTheme.colors.elemental.metal },
  水: { label: '水', labelKo: '수', color: fortuneTheme.colors.elemental.water },
};

/* ------------------------------------------------------------------ */
/*  OhaengBar — single element distribution bar                        */
/* ------------------------------------------------------------------ */

function OhaengBar({
  element,
  value,
  maxValue,
}: {
  element: string;
  value: number;
  maxValue: number;
}) {
  const meta = OHAENG_META[element] ?? { label: element, labelKo: '', color: fortuneTheme.colors.ctaBackground };
  const pct = maxValue > 0 ? Math.min(100, Math.round((value / maxValue) * 100)) : 0;

  return (
    <View style={{ gap: fortuneTheme.spacing.xs }}>
      <View
        style={{
          flexDirection: 'row',
          justifyContent: 'space-between',
          alignItems: 'center',
        }}
      >
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
          <View
            style={{
              width: 24,
              height: 24,
              borderRadius: fortuneTheme.radius.full,
              backgroundColor: meta.color,
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <AppText
              variant="labelMedium"
              style={{ fontSize: 12, color: '#FFFFFF' }}
            >
              {meta.label}
            </AppText>
          </View>
          <AppText variant="labelLarge">{meta.labelKo}</AppText>
        </View>
        <AppText variant="labelLarge" color={meta.color}>
          {value}
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
            backgroundColor: meta.color,
            borderRadius: fortuneTheme.radius.full,
            height: '100%',
            width: `${pct}%`,
            opacity: 0.85,
          }}
        />
      </View>
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  RankBadge — #1, #2, #3 with medal colors + glow for top 3         */
/* ------------------------------------------------------------------ */

const RANK_STYLES: Record<number, { bg: string; fg: string; emoji: string; glow: string }> = {
  1: { bg: '#FFD700', fg: '#1A1200', emoji: '👑', glow: withAlpha('#FFD700', 0.25) },
  2: { bg: '#C0C0C0', fg: '#1A1A1A', emoji: '🥈', glow: withAlpha('#C0C0C0', 0.2) },
  3: { bg: '#CD7F32', fg: '#1A1200', emoji: '🥉', glow: withAlpha('#CD7F32', 0.2) },
};

function RankBadge({ rank }: { rank: number }) {
  const style = RANK_STYLES[rank];

  if (style) {
    return (
      <View
        style={{
          width: 40,
          height: 40,
          borderRadius: fortuneTheme.radius.full,
          backgroundColor: style.bg,
          alignItems: 'center',
          justifyContent: 'center',
          shadowColor: style.bg,
          shadowOffset: { width: 0, height: 2 },
          shadowOpacity: 0.5,
          shadowRadius: 6,
          elevation: 4,
        }}
      >
        <AppText variant="emojiInline">{style.emoji}</AppText>
      </View>
    );
  }

  return (
    <View
      style={{
        width: 36,
        height: 36,
        borderRadius: fortuneTheme.radius.full,
        backgroundColor: fortuneTheme.colors.surfaceSecondary,
        borderWidth: 1,
        borderColor: fortuneTheme.colors.border,
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      <AppText variant="labelLarge" style={{ color: fortuneTheme.colors.textSecondary, fontSize: 13 }}>
        #{rank}
      </AppText>
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  ScoreBar — horizontal score visualisation                          */
/* ------------------------------------------------------------------ */

function ScoreBar({ score, label }: { score: number; label?: string }) {
  const clamped = Math.max(0, Math.min(100, score));
  return (
    <View style={{ gap: fortuneTheme.spacing.xs }}>
      {label ? (
        <View style={{ flexDirection: 'row', justifyContent: 'space-between' }}>
          <AppText variant="labelMedium" color={fortuneTheme.colors.textSecondary}>
            {label}
          </AppText>
          <AppText variant="labelLarge" color={fortuneTheme.colors.accentSecondary}>
            {clamped}점
          </AppText>
        </View>
      ) : null}
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
            width: `${clamped}%`,
          }}
        />
      </View>
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  RecommendedNameCard                                                */
/* ------------------------------------------------------------------ */

/* ------------------------------------------------------------------ */
/*  CircleScore — circular score badge with ring indicator              */
/* ------------------------------------------------------------------ */

function CircleScore({ score }: { score: number }) {
  const clamped = Math.max(0, Math.min(100, score));
  const color =
    clamped >= 90
      ? fortuneTheme.colors.success
      : clamped >= 75
        ? fortuneTheme.colors.accentSecondary
        : clamped >= 60
          ? fortuneTheme.colors.warning
          : fortuneTheme.colors.error;

  return (
    <View
      style={{
        width: 64,
        height: 64,
        borderRadius: 32,
        borderWidth: 3,
        borderColor: color,
        backgroundColor: fortuneTheme.colors.surfaceSecondary,
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      <AppText variant="heading2" style={{ color, fontSize: 20 }}>
        {clamped}
      </AppText>
      <AppText variant="caption" color={fortuneTheme.colors.textTertiary} style={{ fontSize: 9, marginTop: -2 }}>
        점
      </AppText>
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  OhaengTag — compact ohaeng label chip                              */
/* ------------------------------------------------------------------ */

function OhaengTag({ label, value }: { label: string; value: string }) {
  return (
    <View
      style={{
        flexDirection: 'row',
        alignItems: 'center',
        gap: fortuneTheme.spacing.xs,
        backgroundColor: fortuneTheme.colors.surfaceSecondary,
        borderRadius: fortuneTheme.radius.full,
        paddingVertical: 6,
        paddingHorizontal: fortuneTheme.spacing.sm + 2,
      }}
    >
      <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
        {label}
      </AppText>
      <AppText variant="labelMedium" color={fortuneTheme.colors.accentSecondary}>
        {value}
      </AppText>
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  RecommendedNameCard — polished per-name card                       */
/* ------------------------------------------------------------------ */

function RecommendedNameCard({ data }: { data: R }) {
  const rank = num(data.rank, 0);
  const koreanName = str(data.koreanName, '이름');
  const hanjaName = str(data.hanjaName);
  const hanjaMeaning = strArr(data.hanjaMeaning);
  const pronunciationOhaeng = str(data.pronunciationOhaeng);
  const strokeOhaeng = str(data.strokeOhaeng);
  const totalScore = num(data.totalScore, 80);
  const analysis = str(data.analysis);
  const compatibility = str(data.compatibility);

  const isTop3 = rank <= 3;
  const rankStyle = RANK_STYLES[rank];
  const accentBorderColor = rankStyle?.bg ?? 'transparent';

  return (
    <Card
      style={{
        backgroundColor: fortuneTheme.colors.surfaceSecondary,
        gap: fortuneTheme.spacing.md,
        borderLeftWidth: isTop3 ? 3 : 0,
        borderLeftColor: accentBorderColor,
        ...(isTop3 && {
          shadowColor: accentBorderColor,
          shadowOffset: { width: 0, height: 2 },
          shadowOpacity: 0.15,
          shadowRadius: 8,
          elevation: 3,
        }),
      }}
    >
      {/* Header: rank badge + name + circle score */}
      <View
        style={{
          flexDirection: 'row',
          alignItems: 'center',
          gap: fortuneTheme.spacing.sm,
        }}
      >
        <RankBadge rank={rank} />
        <View style={{ flex: 1, gap: 2 }}>
          <AppText variant="heading2" style={{ fontSize: isTop3 ? 24 : 20 }}>
            {koreanName}
          </AppText>
          {hanjaName ? (
            <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
              {hanjaName}
            </AppText>
          ) : null}
        </View>
        <CircleScore score={totalScore} />
      </View>

      {/* Hanja meaning — pill style */}
      {hanjaMeaning.length > 0 ? (
        <View style={{ gap: fortuneTheme.spacing.xs }}>
          <AppText variant="labelMedium" color={fortuneTheme.colors.textSecondary}>
            한자 풀이
          </AppText>
          <View style={{ gap: 6 }}>
            {hanjaMeaning.map((meaning, idx) => (
              <View
                key={`meaning-${idx}`}
                style={{
                  backgroundColor: fortuneTheme.colors.backgroundTertiary,
                  borderRadius: fortuneTheme.radius.md,
                  paddingVertical: 8,
                  paddingHorizontal: fortuneTheme.spacing.sm,
                }}
              >
                <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                  {meaning}
                </AppText>
              </View>
            ))}
          </View>
        </View>
      ) : null}

      {/* Ohaeng tags — inline chips */}
      {(pronunciationOhaeng || strokeOhaeng) ? (
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: fortuneTheme.spacing.sm }}>
          {pronunciationOhaeng ? <OhaengTag label="발음" value={pronunciationOhaeng} /> : null}
          {strokeOhaeng ? <OhaengTag label="수리" value={strokeOhaeng} /> : null}
        </View>
      ) : null}

      {/* Score bar */}
      <ScoreBar score={totalScore} label="종합 점수" />

      {/* Analysis */}
      {analysis ? (
        <View
          style={{
            backgroundColor: fortuneTheme.colors.backgroundTertiary,
            borderRadius: fortuneTheme.radius.md,
            padding: fortuneTheme.spacing.md,
            gap: fortuneTheme.spacing.xs,
          }}
        >
          <AppText variant="labelMedium" color={fortuneTheme.colors.textSecondary}>
            이름 분석
          </AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textPrimary}>
            {analysis}
          </AppText>
        </View>
      ) : null}

      {/* Compatibility */}
      {compatibility ? (
        <View style={{ gap: fortuneTheme.spacing.xs }}>
          <AppText variant="labelMedium" color={fortuneTheme.colors.textSecondary}>
            사주 궁합
          </AppText>
          <InsetQuote text={compatibility} />
        </View>
      ) : null}
    </Card>
  );
}

/* ------------------------------------------------------------------ */
/*  Main NamingResult component                                        */
/* ------------------------------------------------------------------ */

export function NamingResult(props: FortuneResultComponentProps) {
  const result = useResultData(props.payload);
  const raw = props.payload?.rawApiResponse ?? {};

  // --- Extract structured data from raw API response ---
  const ohaengAnalysis = obj(raw.ohaengAnalysis);
  const distribution = obj(ohaengAnalysis.distribution);
  const missing = strArr(ohaengAnalysis.missing);
  const yongsin = str(ohaengAnalysis.yongsin);
  const recommendation = str(ohaengAnalysis.recommendation);
  const recommendedNames = arr(raw.recommendedNames);
  const namingTips = strArr(raw.namingTips);
  const warnings = strArr(raw.warnings);
  const content = str(raw.content);
  const advice = str(raw.advice);

  const hasOhaeng =
    !!yongsin ||
    missing.length > 0 ||
    OHAENG_ELEMENTS.some((el) => num(distribution[el], 0) > 0);
  const hasRecommendedNames = recommendedNames.length > 0;

  // Compute max value for distribution bar scaling
  const distValues = OHAENG_ELEMENTS.map((el) => num(distribution[el], 0));
  const maxDist = Math.max(...distValues, 1);

  // Hero summary
  const heroDescription = recommendation
    || result.summary
    || '사주 오행을 분석하여 아기에게 가장 어울리는 이름을 추천합니다.';

  const topScore = hasRecommendedNames
    ? num(obj(recommendedNames[0]).totalScore, result.score ?? 85)
    : result.score ?? 85;

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      {/* ============================================================ */}
      {/*  Hero                                                         */}
      {/* ============================================================ */}
      <HeroNaming
        topScore={topScore}
        recommendedCount={recommendedNames.length}
        distribution={{
          木: num(distribution['木'], 0),
          火: num(distribution['火'], 0),
          土: num(distribution['土'], 0),
          金: num(distribution['金'], 0),
          水: num(distribution['水'], 0),
        }}
        missing={missing}
        description={heroDescription}
      />

      {/* ============================================================ */}
      {/*  Content — main narrative from API                            */}
      {/* ============================================================ */}
      {content ? (
        <SectionCard title="작명 리딩" description="사주 흐름을 기반으로 이름의 기운을 읽었습니다.">
          <AppText variant="oracleBody" color={fortuneTheme.colors.textSecondary}>
            {content}
          </AppText>
        </SectionCard>
      ) : null}

      {/* ============================================================ */}
      {/*  Ohaeng Distribution                                          */}
      {/* ============================================================ */}
      {hasOhaeng && (
        <SectionCard
          title="오행 분석"
          description="사주에서 읽힌 오행의 분포입니다."
        >
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {OHAENG_ELEMENTS.map((el) => (
              <OhaengBar
                key={el}
                element={el}
                value={num(distribution[el], 0)}
                maxValue={maxDist}
              />
            ))}
          </View>

          {/* Missing elements */}
          {missing.length > 0 ? (
            <View style={{ gap: fortuneTheme.spacing.xs, marginTop: fortuneTheme.spacing.sm }}>
              <AppText variant="labelMedium" color={fortuneTheme.colors.textSecondary}>
                부족한 오행
              </AppText>
              <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: fortuneTheme.spacing.sm }}>
                {missing.map((el) => {
                  const elMeta = OHAENG_META[el];
                  return (
                    <View
                      key={el}
                      style={{
                        flexDirection: 'row',
                        alignItems: 'center',
                        gap: fortuneTheme.spacing.xs,
                        backgroundColor: fortuneTheme.colors.surfaceSecondary,
                        borderRadius: fortuneTheme.radius.md,
                        borderWidth: 1,
                        borderColor: elMeta?.color ?? fortuneTheme.colors.border,
                        paddingVertical: fortuneTheme.spacing.xs,
                        paddingHorizontal: fortuneTheme.spacing.sm,
                      }}
                    >
                      <View
                        style={{
                          width: 8,
                          height: 8,
                          borderRadius: fortuneTheme.radius.full,
                          backgroundColor: elMeta?.color ?? fortuneTheme.colors.accentSecondary,
                        }}
                      />
                      <AppText variant="labelMedium" color={elMeta?.color ?? fortuneTheme.colors.textPrimary}>
                        {el} ({elMeta?.labelKo ?? el})
                      </AppText>
                    </View>
                  );
                })}
              </View>
            </View>
          ) : null}

          {/* Yongsin + Recommendation */}
          {yongsin ? (
            <View style={{ marginTop: fortuneTheme.spacing.sm }}>
              <View
                style={{
                  flexDirection: 'row',
                  alignItems: 'center',
                  gap: fortuneTheme.spacing.xs,
                  marginBottom: fortuneTheme.spacing.xs,
                }}
              >
                <AppText variant="labelMedium" color={fortuneTheme.colors.textSecondary}>
                  용신
                </AppText>
                <AppText variant="labelLarge" color={fortuneTheme.colors.accentSecondary}>
                  {yongsin}
                </AppText>
              </View>
              {recommendation ? <InsetQuote text={recommendation} /> : null}
            </View>
          ) : null}
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Recommended Names                                            */}
      {/* ============================================================ */}
      {hasRecommendedNames ? (
        <SectionCard
          title="추천 이름"
          description={`총 ${recommendedNames.length}개의 이름을 오행 균형에 맞춰 추천합니다.`}
        >
          <View style={{ gap: fortuneTheme.spacing.md }}>
            {recommendedNames.map((nameRaw, idx) => (
              <RecommendedNameCard
                key={`name-${idx}`}
                data={obj(nameRaw)}
              />
            ))}
          </View>
        </SectionCard>
      ) : (
        <SectionCard
          title="추천 이름"
          description="아기 이름 후보는 사주 분석을 마친 뒤 제공됩니다."
        >
          <View
            style={{
              backgroundColor: fortuneTheme.colors.surfaceSecondary,
              borderRadius: fortuneTheme.radius.md,
              paddingVertical: fortuneTheme.spacing.md,
              paddingHorizontal: fortuneTheme.spacing.md,
              gap: fortuneTheme.spacing.xs,
            }}
          >
            <AppText variant="labelLarge" color={fortuneTheme.colors.textPrimary}>
              추천 이름을 불러오지 못했어요.
            </AppText>
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              잠시 후 다시 시도하거나, 엄마 사주·출산 예정일 입력을 재확인해주세요.
            </AppText>
          </View>
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Naming Tips                                                  */}
      {/* ============================================================ */}
      {namingTips.length > 0 ? (
        <SectionCard title="작명 팁" description="이름을 최종 결정하기 전에 참고하세요.">
          <BulletList items={namingTips} accent="팁" />
        </SectionCard>
      ) : null}

      {/* ============================================================ */}
      {/*  Advice — actionable tip from API                             */}
      {/* ============================================================ */}
      {advice ? (
        <SectionCard title="작명 조언">
          <View
            style={{
              backgroundColor: fortuneTheme.colors.backgroundTertiary,
              borderRadius: fortuneTheme.radius.md,
              borderLeftWidth: 3,
              borderLeftColor: fortuneTheme.colors.ctaBackground,
              padding: fortuneTheme.spacing.md,
            }}
          >
            <AppText variant="oracleBody" color={fortuneTheme.colors.textPrimary}>
              {advice}
            </AppText>
          </View>
        </SectionCard>
      ) : null}

      {/* ============================================================ */}
      {/*  Warnings                                                     */}
      {/* ============================================================ */}
      {warnings.length > 0 ? (
        <SectionCard title="주의 사항">
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {warnings.map((warning, idx) => (
              <View
                key={`warning-${idx}`}
                style={{
                  flexDirection: 'row',
                  alignItems: 'flex-start',
                  gap: fortuneTheme.spacing.sm,
                  backgroundColor: fortuneTheme.colors.surfaceSecondary,
                  borderRadius: fortuneTheme.radius.md,
                  borderLeftWidth: 3,
                  borderLeftColor: fortuneTheme.colors.warning,
                  padding: fortuneTheme.spacing.md,
                }}
              >
                <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                  {warning}
                </AppText>
              </View>
            ))}
          </View>
        </SectionCard>
      ) : null}

      {/* ============================================================ */}
      {/*  Fallback — 실응답(오행/추천 이름) 이 모두 없을 때만 노출      */}
      {/* ============================================================ */}
      {!hasOhaeng && !hasRecommendedNames && result.highlights.length > 0 && (
        <SectionCard title="작명 포인트">
          <BulletList items={result.highlights} />
        </SectionCard>
      )}

      {!hasOhaeng && !hasRecommendedNames && result.recommendations.length > 0 && (
        <SectionCard title="추천 행동">
          <BulletList items={result.recommendations} />
        </SectionCard>
      )}

      {result.specialTip && (
        <SectionCard title="작명 메모">
          <InsetQuote text={result.specialTip} />
        </SectionCard>
      )}
    </View>
  );
}
