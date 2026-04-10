import { View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { Card } from '../../../components/card';
import { fortuneTheme } from '../../../lib/theme';
import { resultMetadataByKind } from '../mapping';
import {
  BulletList,
  HeroCard,
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
  木: { label: '木', labelKo: '목', color: '#4CAF50' },
  火: { label: '火', labelKo: '화', color: '#FF5722' },
  土: { label: '土', labelKo: '토', color: '#FFC107' },
  金: { label: '金', labelKo: '금', color: '#9E9E9E' },
  水: { label: '水', labelKo: '수', color: '#2196F3' },
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
/*  RankBadge — #1, #2, #3 with medal colors                          */
/* ------------------------------------------------------------------ */

function RankBadge({ rank }: { rank: number }) {
  const bg =
    rank === 1
      ? '#FFD700'
      : rank === 2
        ? '#C0C0C0'
        : rank === 3
          ? '#CD7F32'
          : fortuneTheme.colors.surfaceSecondary;
  const fg = rank <= 3 ? '#0B0B10' : fortuneTheme.colors.textPrimary;

  return (
    <View
      style={{
        width: 32,
        height: 32,
        borderRadius: fortuneTheme.radius.full,
        backgroundColor: bg,
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      <AppText variant="labelLarge" style={{ color: fg, fontSize: 13 }}>
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

  return (
    <Card
      style={{
        backgroundColor: rank <= 3
          ? fortuneTheme.colors.backgroundTertiary
          : fortuneTheme.colors.surfaceSecondary,
        gap: fortuneTheme.spacing.md,
      }}
    >
      {/* Header: rank badge + names */}
      <View
        style={{
          flexDirection: 'row',
          alignItems: 'center',
          gap: fortuneTheme.spacing.sm,
        }}
      >
        <RankBadge rank={rank} />
        <View style={{ flex: 1, gap: 2 }}>
          <AppText variant="heading2">{koreanName}</AppText>
          {hanjaName ? (
            <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
              {hanjaName}
            </AppText>
          ) : null}
        </View>
        <View
          style={{
            alignItems: 'center',
            justifyContent: 'center',
            backgroundColor: fortuneTheme.colors.surfaceSecondary,
            borderRadius: fortuneTheme.radius.lg,
            paddingVertical: fortuneTheme.spacing.xs,
            paddingHorizontal: fortuneTheme.spacing.sm,
            minWidth: 56,
          }}
        >
          <AppText variant="heading3" color={fortuneTheme.colors.accentSecondary}>
            {totalScore}
          </AppText>
          <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary} style={{ fontSize: 10 }}>
            총점
          </AppText>
        </View>
      </View>

      {/* Hanja meaning breakdown */}
      {hanjaMeaning.length > 0 ? (
        <View style={{ gap: fortuneTheme.spacing.xs }}>
          <AppText variant="labelMedium" color={fortuneTheme.colors.textSecondary}>
            한자 의미
          </AppText>
          {hanjaMeaning.map((meaning, idx) => (
            <View
              key={`meaning-${idx}`}
              style={{
                flexDirection: 'row',
                alignItems: 'flex-start',
                gap: fortuneTheme.spacing.xs,
              }}
            >
              <View
                style={{
                  backgroundColor: fortuneTheme.colors.ctaBackground,
                  borderRadius: fortuneTheme.radius.full,
                  width: 6,
                  height: 6,
                  marginTop: 7,
                  opacity: 0.6,
                }}
              />
              <AppText
                variant="bodySmall"
                color={fortuneTheme.colors.textSecondary}
                style={{ flex: 1 }}
              >
                {meaning}
              </AppText>
            </View>
          ))}
        </View>
      ) : null}

      {/* Ohaeng tags */}
      {(pronunciationOhaeng || strokeOhaeng) ? (
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: fortuneTheme.spacing.sm }}>
          {pronunciationOhaeng ? (
            <View
              style={{
                flexDirection: 'row',
                alignItems: 'center',
                gap: fortuneTheme.spacing.xs,
                backgroundColor: fortuneTheme.colors.surfaceSecondary,
                borderRadius: fortuneTheme.radius.md,
                paddingVertical: fortuneTheme.spacing.xs,
                paddingHorizontal: fortuneTheme.spacing.sm,
              }}
            >
              <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                발음오행
              </AppText>
              <AppText variant="labelMedium" color={fortuneTheme.colors.accentSecondary}>
                {pronunciationOhaeng}
              </AppText>
            </View>
          ) : null}
          {strokeOhaeng ? (
            <View
              style={{
                flexDirection: 'row',
                alignItems: 'center',
                gap: fortuneTheme.spacing.xs,
                backgroundColor: fortuneTheme.colors.surfaceSecondary,
                borderRadius: fortuneTheme.radius.md,
                paddingVertical: fortuneTheme.spacing.xs,
                paddingHorizontal: fortuneTheme.spacing.sm,
              }}
            >
              <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                수리오행
              </AppText>
              <AppText variant="labelMedium" color={fortuneTheme.colors.accentSecondary}>
                {strokeOhaeng}
              </AppText>
            </View>
          ) : null}
        </View>
      ) : null}

      {/* Score bar */}
      <ScoreBar score={totalScore} label="종합 점수" />

      {/* Analysis */}
      {analysis ? (
        <View style={{ gap: fortuneTheme.spacing.xs }}>
          <AppText variant="labelMedium" color={fortuneTheme.colors.textSecondary}>
            분석
          </AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {analysis}
          </AppText>
        </View>
      ) : null}

      {/* Compatibility */}
      {compatibility ? (
        <InsetQuote text={compatibility} />
      ) : null}
    </Card>
  );
}

/* ------------------------------------------------------------------ */
/*  Main NamingResult component                                        */
/* ------------------------------------------------------------------ */

export function NamingResult(props: FortuneResultComponentProps) {
  const meta = resultMetadataByKind.naming;
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

  const hasRaw = Object.keys(raw).length > 0 && recommendedNames.length > 0;

  // Compute max value for distribution bar scaling
  const distValues = OHAENG_ELEMENTS.map((el) => num(distribution[el], 0));
  const maxDist = Math.max(...distValues, 1);

  // Hero summary
  const heroDescription = recommendation
    || result.summary
    || '사주 오행을 분석하여 아기에게 가장 어울리는 이름을 추천합니다.';

  const topScore = hasRaw
    ? num(obj(recommendedNames[0]).totalScore, result.score ?? 85)
    : result.score ?? 85;

  const heroChips = result.contextTags.length > 0
    ? result.contextTags
    : [
        yongsin ? `용신: ${yongsin}` : null,
        missing.length > 0 ? `부족: ${missing.join(', ')}` : null,
        '작명',
      ].filter(Boolean) as string[];

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      {/* ============================================================ */}
      {/*  Hero                                                         */}
      {/* ============================================================ */}
      <HeroCard
        emoji="🏒"
        title={meta.title}
        description={heroDescription}
        chips={heroChips}
        aside={
          <View
            style={{
              alignItems: 'center',
              justifyContent: 'center',
              backgroundColor: fortuneTheme.colors.surfaceSecondary,
              borderRadius: fortuneTheme.radius.lg,
              paddingVertical: fortuneTheme.spacing.sm,
              paddingHorizontal: fortuneTheme.spacing.md,
              minWidth: 80,
            }}
          >
            <AppText variant="displaySmall" color={fortuneTheme.colors.accentSecondary}>
              {topScore}
            </AppText>
            <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
              최고점
            </AppText>
          </View>
        }
      />

      {/* ============================================================ */}
      {/*  Ohaeng Distribution                                          */}
      {/* ============================================================ */}
      {hasRaw && (
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
      {hasRaw && (
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
      {/*  Fallback when no raw API data                                */}
      {/* ============================================================ */}
      {!hasRaw && result.highlights.length > 0 && (
        <SectionCard title="작명 포인트">
          <BulletList items={result.highlights} />
        </SectionCard>
      )}

      {!hasRaw && result.recommendations.length > 0 && (
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
