import { View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { Card } from '../../../components/card';
import { fortuneTheme } from '../../../lib/theme';
import { resultMetadataByKind } from '../mapping';
import {
  BulletList,
  DoDontPair,
  HeroCard,
  InsetQuote,
  KeywordPills,
  MetricGrid,
  SectionCard,
  StatRail,
  Timeline,
} from '../primitives';
import type { FortuneResultComponentProps } from '../types';
import { useResultData } from '../use-result-data';

/* ------------------------------------------------------------------ */
/*  Safe extraction helpers for rawApiResponse                         */
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
/*  1. WealthResult                                                    */
/* ------------------------------------------------------------------ */

function WealthResult(props: FortuneResultComponentProps) {
  const meta = resultMetadataByKind.wealth;
  const result = useResultData(props.payload);
  const raw = props.payload?.rawApiResponse ?? {};
  const hasRaw = Object.keys(raw).length > 0;

  // --- Extract wealth-specific fields from raw API response ---
  const riskProfile = obj(raw.riskProfile ?? raw.risk_profile);
  const riskLevel = str(riskProfile.level ?? riskProfile.riskLevel ?? riskProfile.risk_level);
  const riskDescription = str(riskProfile.description);
  const riskScore = num(riskProfile.score, 0);

  const investmentRecs = arr(raw.investmentRecommendations ?? raw.investment_recommendations);
  const wealthStrategy = obj(raw.wealthStrategy ?? raw.wealth_strategy ?? raw.personalizedStrategy ?? raw.personalized_strategy);
  const strategyTitle = str(wealthStrategy.title ?? wealthStrategy.name);
  const strategyDescription = str(wealthStrategy.description ?? wealthStrategy.summary);
  const strategySteps = strArr(wealthStrategy.steps ?? wealthStrategy.actions);

  const weeklyFlow = arr(raw.weeklyFlow ?? raw.weekly_flow ?? raw.moneyFlow ?? raw.money_flow);
  const savingsTips = strArr(raw.savingsTips ?? raw.savings_tips);
  const spendingWarnings = strArr(raw.spendingWarnings ?? raw.spending_warnings);

  const summary =
    result.summary ||
    str(raw.content as unknown) ||
    '\uB2E8\uAE30 \uC218\uC785\uBCF4\uB2E4 \uC9C0\uCD9C \uC815\uB9AC\uC640 \uC218\uC775 \uAD6C\uC870 \uC815\uBE44\uAC00 \uBA3C\uC800 \uBCF4\uC785\uB2C8\uB2E4. \uC791\uC740 \uB3C8\uC774 \uC0C8\uC9C0 \uC54A\uAC8C \uC7A1\uC544\uB450\uBA74 \uB2E4\uC74C \uC804\uD658\uC810\uC5D0\uC11C \uCCB4\uAC10\uC774 \uCEE4\uC9D1\uB2C8\uB2E4.';

  const metrics =
    result.metrics.length > 0
      ? result.metrics
      : [
          { label: '\uC7AC\uBB3C \uC810\uC218', value: '82', note: '\uC548\uC815 \uAD6C\uAC04 \uC720\uC9C0' },
          { label: '\uD604\uAE08 \uC720\uB3D9\uC131', value: '74', note: '\uC911\uAC04 \uC774\uC0C1' },
          { label: '\uC9C0\uCD9C \uD1B5\uC81C\uB825', value: '69', note: '\uCDA9\uB3D9\uAD6C\uB9E4 \uC8FC\uC758' },
          { label: '\uAE30\uD68C \uD3EC\uCC29\uB825', value: '88', note: '\uD611\uC5C5\uC5D0 \uAC15\uD568' },
        ];

  const highlights =
    result.highlights.length > 0
      ? result.highlights
      : [
          '\uACE0\uC815\uBE44\uC640 \uBCC0\uB3D9\uBE44\uB97C \uBD84\uB9AC\uD574\uC11C \uC0C8\uB294 \uB3C8\uC744 \uBA3C\uC800 \uCC3E\uAE30',
          '\uC790\uB3D9 \uC801\uB9BD\uC774\uB098 \uC791\uC740 \uC218\uC785\uC6D0\uC744 \uD558\uB098 \uB354 \uBD99\uC774\uAE30',
          '\uC815\uC0B0, \uCCAD\uAD6C, \uD611\uC0C1\uC744 \uBBF8\uB8E8\uC9C0 \uC54A\uAE30',
        ];

  const warnings =
    spendingWarnings.length > 0
      ? spendingWarnings
      : result.warnings.length > 0
        ? result.warnings
        : [
            '\uAC10\uC815\uC774 \uC55E\uC120 \uB2E8\uD0C0\uC131 \uC9C0\uCD9C',
            '\uADFC\uAC70 \uC5C6\uB294 \uB808\uBC84\uB9AC\uC9C0 \uD655\uB300',
            '\uB2F9\uC7A5 \uC4F0\uC9C0 \uC54A\uB294 \uAD6C\uB3C5 \uCD94\uAC00',
          ];

  const recommendations =
    result.recommendations.length > 0
      ? result.recommendations
      : [
          '\uC774\uBC88 \uC8FC\uB294 \uC218\uC775 \uD655\uB300\uBCF4\uB2E4 \uB3C8\uC758 \uBE60\uC9D0\uC744 \uC904\uC774\uB294 \uCABD\uC774 \uC6B0\uC120\uC785\uB2C8\uB2E4.',
          '\uC9C0\uCD9C\uC744 3\uC77C\uB9CC \uC801\uC5B4\uB3C4 \uD750\uB984\uC774 \uBCF4\uC785\uB2C8\uB2E4.',
          '\uD611\uC0C1\uC131 \uC5F0\uB77D\uC740 \uAE08\uC694\uC77C \uC804\uC5D0 \uBA3C\uC800 \uC81C\uC548\uD558\uC138\uC694.',
        ];

  // --- Score for circular gauge ---
  const mainScore = num(metrics[0]?.value, 82);
  const scoreColor =
    mainScore >= 90
      ? '#34C759'
      : mainScore >= 70
        ? '#8B7BE8'
        : mainScore >= 50
          ? '#FFCC00'
          : '#FF3B30';
  const scoreLabel =
    mainScore >= 90
      ? '\uCD5C\uC0C1\uAE09'
      : mainScore >= 70
        ? '\uC548\uC815 \uAD6C\uAC04'
        : mainScore >= 50
          ? '\uAD00\uB9AC \uD544\uC694'
          : '\uC8FC\uC758';

  // --- Risk spectrum position (0-100) ---
  const riskPosition = riskScore > 0 ? riskScore : 45;
  const riskLabel =
    riskPosition >= 80
      ? '\uACF5\uACA9\uC801'
      : riskPosition >= 60
        ? '\uC801\uADF9\uC801'
        : riskPosition >= 40
          ? '\uC911\uB9BD\uC801'
          : riskPosition >= 20
            ? '\uC548\uC815\uC801'
            : '\uBCF4\uC218\uC801';

  // --- Weekly flow bar chart data ---
  const dayLabels = ['\uC6D4', '\uD654', '\uC218', '\uBAA9', '\uAE08', '\uD1A0', '\uC77C'];
  const flowChartData = weeklyFlow.length >= 7
    ? weeklyFlow.map((day, i) => {
        const d = obj(day);
        return {
          day: dayLabels[i] ?? str(d.day ?? d.title, `${i + 1}`),
          income: num(d.income ?? d.\uC218\uC785, 0),
          expense: num(d.expense ?? d.\uC9C0\uCD9C, 0),
        };
      })
    : [
        { day: '\uC6D4', income: 40, expense: 25 },
        { day: '\uD654', income: 10, expense: 35 },
        { day: '\uC218', income: 60, expense: 20 },
        { day: '\uBAA9', income: 20, expense: 45 },
        { day: '\uAE08', income: 35, expense: 55 },
        { day: '\uD1A0', income: 15, expense: 30 },
        { day: '\uC77C', income: 5, expense: 10 },
      ];
  const maxFlowValue = Math.max(
    ...flowChartData.map((d) => Math.max(d.income, d.expense)),
    1,
  );

  // --- Savings tips ---
  const finalSavingsTips =
    savingsTips.length > 0
      ? savingsTips
      : [
          '\uAD6C\uB3C5 \uC11C\uBE44\uC2A4\uB97C \uD55C \uB2EC\uB9CC \uC815\uC9C0\uD574\uBCF4\uC138\uC694',
          '\uCE74\uB4DC \uBA85\uC138\uC11C\uB97C 3\uAC1C\uC6D4\uCE58 \uBE44\uAD50\uD574\uBCF4\uAE30',
          '\uCDA9\uB3D9 \uAD6C\uB9E4 \uC804 24\uC2DC\uAC04 \uB300\uAE30 \uADDC\uCE59',
        ];

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      {/* ====== HERO ====== */}
      <HeroCard emoji={'\uD83D\uDCB0'} title={meta.title} description={summary} />

      {/* ====== 1. CIRCULAR SCORE GAUGE ====== */}
      <Card style={{ gap: fortuneTheme.spacing.md }}>
        <AppText variant="heading4">{'\uD83D\uDCB0 \uC7AC\uBB3C \uC810\uC218'}</AppText>
        <View style={{ alignItems: 'center', gap: fortuneTheme.spacing.sm }}>
          <View
            style={{
              width: 160,
              height: 160,
              borderRadius: 80,
              borderWidth: 10,
              borderColor: scoreColor,
              alignItems: 'center',
              justifyContent: 'center',
              backgroundColor: `${scoreColor}15`,
            }}
          >
            <AppText style={{ fontSize: 40, fontWeight: '700', color: scoreColor, lineHeight: 48, includeFontPadding: false }}>
              {mainScore}
            </AppText>
            <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
              / 100
            </AppText>
          </View>
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
            <View style={{ width: 8, height: 8, borderRadius: 4, backgroundColor: scoreColor }} />
            <AppText variant="labelLarge" style={{ color: scoreColor }}>
              {scoreLabel}
            </AppText>
          </View>
          {/* Sub-metrics row */}
          <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: fortuneTheme.spacing.sm, width: '100%' }}>
            {metrics.slice(1).map((m) => (
              <View
                key={m.label}
                style={{
                  minWidth: '30%',
                  flexGrow: 1,
                  flexBasis: '30%',
                  backgroundColor: fortuneTheme.colors.surfaceSecondary,
                  borderRadius: fortuneTheme.radius.md,
                  padding: fortuneTheme.spacing.sm,
                  alignItems: 'center',
                  gap: 2,
                }}
              >
                <AppText variant="heading4" color={fortuneTheme.colors.accentSecondary}>
                  {m.value}
                </AppText>
                <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
                  {m.label}
                </AppText>
              </View>
            ))}
          </View>
        </View>
      </Card>

      {/* ====== 2. RISK SPECTRUM ====== */}
      <Card style={{ gap: fortuneTheme.spacing.md }}>
        <AppText variant="heading4">{'\uB9AC\uC2A4\uD06C \uC2A4\uD399\uD2B8\uB7FC'}</AppText>
        {riskDescription ? (
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {riskDescription}
          </AppText>
        ) : null}
        <View style={{ gap: fortuneTheme.spacing.sm }}>
          {/* Labels row */}
          <View style={{ flexDirection: 'row', justifyContent: 'space-between' }}>
            <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
              {'\uBCF4\uC218\uC801'}
            </AppText>
            <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
              {'\uC911\uB9BD\uC801'}
            </AppText>
            <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
              {'\uACF5\uACA9\uC801'}
            </AppText>
          </View>
          {/* Gradient bar */}
          <View style={{ position: 'relative', height: 28 }}>
            <View
              style={{
                flexDirection: 'row',
                height: 12,
                borderRadius: fortuneTheme.radius.full,
                overflow: 'hidden',
                marginTop: 8,
              }}
            >
              <View style={{ flex: 1, backgroundColor: '#34C759' }} />
              <View style={{ flex: 1, backgroundColor: '#8BC34A' }} />
              <View style={{ flex: 1, backgroundColor: '#FFCC00' }} />
              <View style={{ flex: 1, backgroundColor: '#FF9500' }} />
              <View style={{ flex: 1, backgroundColor: '#FF3B30' }} />
            </View>
            {/* Position marker */}
            <View
              style={{
                position: 'absolute',
                left: `${Math.min(Math.max(riskPosition, 2), 98)}%`,
                top: 0,
                marginLeft: -10,
                alignItems: 'center',
              }}
            >
              <View
                style={{
                  width: 20,
                  height: 20,
                  borderRadius: 10,
                  backgroundColor: fortuneTheme.colors.textPrimary,
                  borderWidth: 3,
                  borderColor: fortuneTheme.colors.ctaBackground,
                }}
              />
            </View>
          </View>
          {/* Current position label */}
          <View
            style={{
              backgroundColor: fortuneTheme.colors.surfaceSecondary,
              borderRadius: fortuneTheme.radius.md,
              padding: fortuneTheme.spacing.sm,
              flexDirection: 'row',
              alignItems: 'center',
              justifyContent: 'center',
              gap: fortuneTheme.spacing.xs,
            }}
          >
            <AppText variant="labelLarge" color={fortuneTheme.colors.accentSecondary}>
              {riskLabel}
            </AppText>
            {riskLevel ? (
              <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
                {'(' + riskLevel + ')'}
              </AppText>
            ) : null}
          </View>
        </View>
      </Card>

      {/* ====== 3. INVESTMENT RECOMMENDATION CARDS ====== */}
      {(() => {
        const recs =
          investmentRecs.length > 0
            ? investmentRecs
            : [
                { name: '\uC608\uC801\uAE08', risk: '\uB0AE\uC74C', expectedReturn: '3-5%', description: '\uC548\uC815\uC801 \uC6D0\uAE08 \uBCF4\uC804\uD615 \uC0C1\uD488\uC73C\uB85C \uC2DC\uC791\uD558\uAE30' },
                { name: 'ETF \uBD84\uC0B0\uD22C\uC790', risk: '\uC911\uAC04', expectedReturn: '7-12%', description: '\uC778\uB371\uC2A4 \uCD94\uC885\uC73C\uB85C \uB9AC\uC2A4\uD06C \uBD84\uC0B0' },
                { name: '\uD14C\uB9C8\uC8FC', risk: '\uB192\uC74C', expectedReturn: '15%+', description: '\uB2E8\uAE30 \uBAA8\uBA58\uD140 \uD65C\uC6A9, \uC190\uC808 \uB77C\uC778 \uD544\uC218' },
              ];
        const riskColorMap: Record<string, string> = {
          '\uB0AE\uC74C': '#34C759', low: '#34C759', '\uC548\uC804': '#34C759',
          '\uC911\uAC04': '#FFCC00', medium: '#FFCC00', '\uBCF4\uD1B5': '#FFCC00',
          '\uB192\uC74C': '#FF3B30', high: '#FF3B30', '\uC704\uD5D8': '#FF3B30',
        };

        return (
          <Card style={{ gap: fortuneTheme.spacing.md }}>
            <AppText variant="heading4">{'\uD22C\uC790 \uCD94\uCC9C'}</AppText>
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              {'\uC624\uB298\uC758 \uC7AC\uBB3C \uD750\uB984 \uAE30\uBC18 \uD22C\uC790 \uC81C\uC548\uC785\uB2C8\uB2E4.'}
            </AppText>
            <View style={{ gap: fortuneTheme.spacing.sm }}>
              {recs.map((rec, index) => {
                const r = obj(rec);
                const recName = str(r.name ?? r.title ?? r.category, `\uCD94\uCC9C ${index + 1}`);
                const recDesc = str(r.description ?? r.reason);
                const recRisk = str(r.risk ?? r.riskLevel ?? r.risk_level);
                const recReturn = str(r.expectedReturn ?? r.expected_return ?? r.returnRate ?? r.return_rate);
                const badgeColor = riskColorMap[recRisk.toLowerCase()] ?? riskColorMap[recRisk] ?? fortuneTheme.colors.accentSecondary;

                return (
                  <View
                    key={`invest-${index}`}
                    style={{
                      backgroundColor: fortuneTheme.colors.surfaceSecondary,
                      borderRadius: fortuneTheme.radius.md,
                      padding: fortuneTheme.spacing.md,
                      gap: fortuneTheme.spacing.sm,
                      borderLeftWidth: 3,
                      borderLeftColor: badgeColor,
                    }}
                  >
                    <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' }}>
                      <AppText variant="heading4">{recName}</AppText>
                      {recRisk ? (
                        <View
                          style={{
                            backgroundColor: `${badgeColor}20`,
                            paddingHorizontal: fortuneTheme.spacing.sm,
                            paddingVertical: 3,
                            borderRadius: fortuneTheme.radius.full,
                          }}
                        >
                          <AppText variant="caption" style={{ color: badgeColor, fontWeight: '700' }}>
                            {recRisk}
                          </AppText>
                        </View>
                      ) : null}
                    </View>
                    {recDesc ? (
                      <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                        {recDesc}
                      </AppText>
                    ) : null}
                    {recReturn ? (
                      <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
                        <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
                          {'\uAE30\uB300 \uC218\uC775'}
                        </AppText>
                        <AppText variant="labelLarge" color={fortuneTheme.colors.accentSecondary}>
                          {recReturn}
                        </AppText>
                      </View>
                    ) : null}
                  </View>
                );
              })}
            </View>
          </Card>
        );
      })()}

      {/* ====== 4. WEEKLY CASH FLOW MINI CHART ====== */}
      <Card style={{ gap: fortuneTheme.spacing.md }}>
        <AppText variant="heading4">{'\uC8FC\uAC04 \uC790\uAE08 \uD750\uB984'}</AppText>
        <View style={{ flexDirection: 'row', justifyContent: 'space-between', gap: 4 }}>
          {flowChartData.map((d) => {
            const incomeH = Math.round((d.income / maxFlowValue) * 80);
            const expenseH = Math.round((d.expense / maxFlowValue) * 80);
            return (
              <View key={d.day} style={{ flex: 1, alignItems: 'center', gap: 4 }}>
                <View style={{ height: 90, justifyContent: 'flex-end', alignItems: 'center', flexDirection: 'row', gap: 2 }}>
                  <View
                    style={{
                      width: 10,
                      height: Math.max(incomeH, 4),
                      backgroundColor: '#34C759',
                      borderRadius: 3,
                    }}
                  />
                  <View
                    style={{
                      width: 10,
                      height: Math.max(expenseH, 4),
                      backgroundColor: '#FF3B30',
                      borderRadius: 3,
                    }}
                  />
                </View>
                <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
                  {d.day}
                </AppText>
              </View>
            );
          })}
        </View>
        {/* Legend */}
        <View style={{ flexDirection: 'row', justifyContent: 'center', gap: fortuneTheme.spacing.md }}>
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 4 }}>
            <View style={{ width: 8, height: 8, borderRadius: 2, backgroundColor: '#34C759' }} />
            <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>{'\uC218\uC785'}</AppText>
          </View>
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 4 }}>
            <View style={{ width: 8, height: 8, borderRadius: 2, backgroundColor: '#FF3B30' }} />
            <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>{'\uC9C0\uCD9C'}</AppText>
          </View>
        </View>
      </Card>

      {/* ====== 5. SAVINGS TIP CARDS ====== */}
      <Card style={{ gap: fortuneTheme.spacing.md }}>
        <AppText variant="heading4">{'\uD83E\uDE99 \uC808\uC57D \uD301'}</AppText>
        <View style={{ gap: fortuneTheme.spacing.sm }}>
          {finalSavingsTips.map((tip, index) => (
            <View
              key={`tip-${index}`}
              style={{
                backgroundColor: fortuneTheme.colors.surfaceSecondary,
                borderRadius: fortuneTheme.radius.md,
                padding: fortuneTheme.spacing.md,
                flexDirection: 'row',
                alignItems: 'flex-start',
                gap: fortuneTheme.spacing.sm,
              }}
            >
              <AppText style={{ fontSize: 20 }}>{'\uD83E\uDE99'}</AppText>
              <AppText
                variant="bodySmall"
                color={fortuneTheme.colors.textSecondary}
                style={{ flex: 1 }}
              >
                {tip}
              </AppText>
            </View>
          ))}
        </View>
      </Card>

      {/* ====== STRATEGY (from raw API) ====== */}
      {hasRaw && (strategyTitle || strategyDescription || strategySteps.length > 0) && (
        <SectionCard
          title={strategyTitle || '\uB9DE\uCDA4 \uC7AC\uBB3C \uC804\uB7B5'}
          description={strategyDescription || undefined}
        >
          {strategySteps.length > 0 ? (
            <BulletList items={strategySteps} />
          ) : null}
        </SectionCard>
      )}

      {/* ====== DO/DON'T ====== */}
      <DoDontPair
        data={{
          doTitle: '\uC774\uBC88 \uC8FC\uC5D0 \uD560 \uC77C',
          doItems: highlights,
          dontTitle: '\uC774\uBC88 \uC8FC\uC5D0 \uD53C\uD560 \uC77C',
          dontItems: warnings,
        }}
      />

      {/* ====== ACTION TIPS ====== */}
      <SectionCard title="적용 팁">
        <BulletList items={recommendations} />
      </SectionCard>

      {result.hasApiData && result.specialTip && (
        <SectionCard title="특별 조언">
          <InsetQuote text={result.specialTip} />
        </SectionCard>
      )}
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  2. TalentResult                                                    */
/* ------------------------------------------------------------------ */

function TalentResult(props: FortuneResultComponentProps) {
  const meta = resultMetadataByKind.talent;
  const result = useResultData(props.payload);
  const raw = props.payload?.rawApiResponse ?? {};

  // --- Extract talent-specific data from raw API response ---
  const hexagonScores = obj(raw.hexagonScores ?? raw.hexagon_scores);
  const talentInsights = arr(raw.talentInsights ?? raw.talent_insights);
  const weeklyPlan = arr(raw.weeklyPlan ?? raw.weekly_plan);
  const growthRoadmapRaw = raw.growthRoadmap ?? raw.growth_roadmap;
  const growthRoadmap = Array.isArray(growthRoadmapRaw)
    ? growthRoadmapRaw
    : typeof growthRoadmapRaw === 'object' && growthRoadmapRaw != null
      ? Object.entries(growthRoadmapRaw as Record<string, unknown>).map(([key, val]) => ({
          ...(typeof val === 'object' && val != null ? val : {}),
          phase: key === 'month1' ? '1개월' : key === 'month3' ? '3개월' : key === 'month6' ? '6개월' : key === 'year1' ? '1년' : key,
        }))
      : [];
  const mentalModel = obj(raw.mentalModel ?? raw.mental_model);
  const collaboration = obj(raw.collaboration);
  const learningStrategy = obj(raw.learningStrategy ?? raw.learning_strategy);
  const rawWarnings = arr(raw.warnings);
  const rawRecommendations = arr(raw.recommendations);

  const hasHexagon = Object.keys(hexagonScores).length > 0;
  const hasRawData = hasHexagon || talentInsights.length > 0;

  // --- Overall score from hexagon average ---
  const hexLabels: { key: string; label: string }[] = [
    { key: 'creativity', label: '창의력' },
    { key: 'technique', label: '기술력' },
    { key: 'passion', label: '열정' },
    { key: 'discipline', label: '규율' },
    { key: 'uniqueness', label: '독창성' },
    { key: 'marketValue', label: '시장가치' },
  ];

  const hexValues = hexLabels.map((h) => num(hexagonScores[h.key], 0));
  const avgScore =
    hexValues.reduce((a, b) => a + b, 0) > 0
      ? Math.round(hexValues.reduce((a, b) => a + b, 0) / hexValues.filter((v) => v > 0).length)
      : 0;

  const summary =
    result.summary ||
    str(raw.content as unknown) ||
    '번뜩이는 한 방보다 여러 축을 묶어 성과로 바꾸는 능력이 강합니다. 낱개 재능을 설명 가능하게 만들 때 효율이 커집니다.';

  const chips =
    result.contextTags.length > 0
      ? result.contextTags
      : ['재능 분석', '성장 로드맵', '역량 인사이트'];

  // --- 6축 StatRail ---
  const statItems =
    hasHexagon
      ? hexLabels.map((h) => ({
          label: h.label,
          value: num(hexagonScores[h.key], 0),
          highlight: '',
        }))
      : result.metrics.length > 0
        ? result.metrics.map((m, i) => ({
            label: m.label,
            value: Number(m.value) || [85, 74, 88, 70, 79, 82][i] || 75,
            highlight: m.note || '',
          }))
        : [
            { label: '창의력', value: 85, highlight: '아이디어 발산력이 높음' },
            { label: '기술력', value: 74, highlight: '실행으로 옮기는 능력' },
            { label: '열정', value: 88, highlight: '몰입의 깊이' },
            { label: '규율', value: 70, highlight: '루틴 유지 능력' },
            { label: '독창성', value: 79, highlight: '나만의 색깔' },
            { label: '시장가치', value: 82, highlight: '수익화 가능성' },
          ];

  // --- Mental model metrics ---
  const mentalModelItems: { label: string; value: string; note?: string }[] = [];
  const thinkingStyle = str(mentalModel.thinkingStyle ?? mentalModel.thinking_style);
  const decisionPattern = str(mentalModel.decisionPattern ?? mentalModel.decision_pattern);
  const learningStyle = str(mentalModel.learningStyle ?? mentalModel.learning_style);
  if (thinkingStyle) mentalModelItems.push({ label: '사고 스타일', value: thinkingStyle });
  if (decisionPattern) mentalModelItems.push({ label: '결정 패턴', value: decisionPattern });
  if (learningStyle) mentalModelItems.push({ label: '학습 방식', value: learningStyle });

  // --- Collaboration ---
  const goodMatches = strArr(collaboration.goodMatch ?? collaboration.goodMatches ?? collaboration.good_matches ?? collaboration.good_match);
  const collabChallenges = strArr(collaboration.challenges);
  const teamRole = str(collaboration.teamRole ?? collaboration.team_role);

  // --- Learning strategy ---
  const effectiveMethods = strArr(learningStrategy.effectiveMethods ?? learningStrategy.effective_methods);
  const timeManagement = str(learningStrategy.timeManagement ?? learningStrategy.time_management);
  const recommendedBooks = strArr(learningStrategy.recommendedBooks ?? learningStrategy.recommended_books);
  const courses = strArr(learningStrategy.recommendedCourses ?? learningStrategy.recommended_courses ?? learningStrategy.courses);
  const mentorshipAdvice = str(learningStrategy.mentorshipAdvice ?? learningStrategy.mentorship_advice);

  // --- Warnings ---
  const warnings =
    rawWarnings.length > 0
      ? rawWarnings.map((w) => {
          if (typeof w === 'string') return w;
          const wo = obj(w);
          const trap = str(wo.trap ?? wo.title ?? wo.name);
          const solution = str(wo.solution ?? wo.description);
          return trap && solution ? `${trap} - ${solution}` : trap || solution;
        }).filter(Boolean) as string[]
      : result.warnings.length > 0
        ? result.warnings
        : [
            '익숙한 것만 반복하면 성장이 멈출 수 있습니다.',
            '완벽주의는 실행을 늦추는 가장 큰 적입니다.',
            '비교는 동기보다 소모를 더 많이 만듭니다.',
            '혼자만 연습하면 방향이 틀어져도 모릅니다.',
            '수익화를 너무 일찍 생각하면 재미가 사라집니다.',
          ];

  // --- Recommendations ---
  const recommendations =
    rawRecommendations.length > 0
      ? rawRecommendations.map((r) => (typeof r === 'string' ? r : str(obj(r).description ?? obj(r).action ?? r))).filter(Boolean) as string[]
      : result.recommendations.length > 0
        ? result.recommendations
        : [
            '주력 재능 1개를 먼저 고정하세요.',
            '포트폴리오 형태로 남겨야 다음 기회가 빨라집니다.',
            '설명하는 연습이 곧 재능의 선명도를 올립니다.',
          ];

  // --- Description for expanded content ---
  const description = str(raw.description as unknown);

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      {/* 1. Hero */}
      <HeroCard
        emoji="🎯"
        title={meta.title}
        description={summary}
        chips={chips}
        aside={
          avgScore > 0 ? (
            <View style={{ alignItems: 'center', justifyContent: 'center' }}>
              <AppText variant="displaySmall" color={fortuneTheme.colors.accentSecondary}>
                {avgScore}
              </AppText>
              <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                종합 점수
              </AppText>
            </View>
          ) : undefined
        }
      />

      {/* Detailed description if available */}
      {description ? (
        <SectionCard title="상세 분석">
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {description}
          </AppText>
        </SectionCard>
      ) : null}

      {/* 2. 재능 6축 분석 */}
      <SectionCard title="재능 6축 분석" description="창의력, 기술력, 열정, 규율, 독창성, 시장가치를 종합 분석합니다.">
        <StatRail items={statItems} />
      </SectionCard>

      {/* 3. 사고 모델 */}
      {mentalModelItems.length > 0 && (
        <SectionCard title="사고 모델" description="당신의 사고 패턴과 의사결정 스타일입니다.">
          <MetricGrid items={mentalModelItems} />
        </SectionCard>
      )}

      {/* 4. 재능 인사이트 */}
      {talentInsights.length > 0 ? (
        <SectionCard title="재능 인사이트" description="발견된 재능과 개발 경로를 보여드립니다.">
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {talentInsights.map((insight, index) => {
              const ti = obj(insight);
              const talentName = str(ti.talentName ?? ti.talent_name ?? ti.name, `재능 ${index + 1}`);
              const potentialScore = num(ti.potentialScore ?? ti.potential_score, 0);
              const insightDesc = str(ti.description);
              const developmentPath = str(ti.developmentPath ?? ti.development_path);
              const practicalApps = strArr(ti.practicalApplications ?? ti.practical_applications);
              const monetization = str(ti.monetizationStrategy ?? ti.monetization_strategy);
              const portfolioGuide = str(ti.portfolioGuide ?? ti.portfolio_guide);
              const resources = strArr(ti.recommendedResources ?? ti.recommended_resources);

              return (
                <Card
                  key={`talent-insight-${index}`}
                  style={{
                    backgroundColor: fortuneTheme.colors.surfaceSecondary,
                    gap: fortuneTheme.spacing.sm,
                  }}
                >
                  {/* Header: name + score */}
                  <View
                    style={{
                      flexDirection: 'row',
                      justifyContent: 'space-between',
                      alignItems: 'center',
                    }}
                  >
                    <AppText variant="heading4">{talentName}</AppText>
                    {potentialScore > 0 && (
                      <AppText variant="labelLarge" color={fortuneTheme.colors.accentSecondary}>
                        잠재력 {potentialScore}점
                      </AppText>
                    )}
                  </View>

                  {/* Score bar */}
                  {potentialScore > 0 && (
                    <View
                      style={{
                        height: 6,
                        borderRadius: 3,
                        backgroundColor: fortuneTheme.colors.surface,
                        overflow: 'hidden',
                      }}
                    >
                      <View
                        style={{
                          height: '100%',
                          width: `${Math.min(potentialScore, 100)}%`,
                          borderRadius: 3,
                          backgroundColor: fortuneTheme.colors.accentSecondary,
                        }}
                      />
                    </View>
                  )}

                  {/* Description */}
                  {insightDesc ? (
                    <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                      {insightDesc}
                    </AppText>
                  ) : null}

                  {/* Development path */}
                  {developmentPath ? (
                    <View style={{ gap: fortuneTheme.spacing.xs }}>
                      <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                        개발 경로
                      </AppText>
                      <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                        {developmentPath}
                      </AppText>
                    </View>
                  ) : null}

                  {/* Practical applications */}
                  {practicalApps.length > 0 ? (
                    <View style={{ gap: fortuneTheme.spacing.xs }}>
                      <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                        실전 활용
                      </AppText>
                      <KeywordPills keywords={practicalApps} />
                    </View>
                  ) : null}

                  {/* Monetization */}
                  {monetization ? (
                    <View style={{ gap: fortuneTheme.spacing.xs }}>
                      <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                        수익화 전략
                      </AppText>
                      <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                        {monetization}
                      </AppText>
                    </View>
                  ) : null}

                  {/* Portfolio guide */}
                  {portfolioGuide ? (
                    <View style={{ gap: fortuneTheme.spacing.xs }}>
                      <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                        포트폴리오 가이드
                      </AppText>
                      <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                        {portfolioGuide}
                      </AppText>
                    </View>
                  ) : null}

                  {/* Recommended resources */}
                  {resources.length > 0 ? (
                    <View style={{ gap: fortuneTheme.spacing.xs }}>
                      <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                        추천 자료
                      </AppText>
                      <KeywordPills keywords={resources} />
                    </View>
                  ) : null}
                </Card>
              );
            })}
          </View>
        </SectionCard>
      ) : (
        <SectionCard title="재능 인사이트">
          <BulletList
            items={
              result.highlights.length > 0
                ? result.highlights
                : [
                    '패턴을 발견해 흐름을 정리하는 능력이 좋습니다.',
                    '복잡한 상황을 상대가 이해할 말로 바꾸는 힘이 큽니다.',
                    '작업 순서를 설계할 때 재능의 배율이 커집니다.',
                  ]
            }
          />
        </SectionCard>
      )}

      {/* 5. 주간 개발 플랜 */}
      {weeklyPlan.length > 0 ? (
        <SectionCard title="주간 개발 플랜" description="7일간 집중 개발 계획입니다.">
          <Timeline
            items={weeklyPlan.map((day, index) => {
              const d = obj(day);
              const dayLabel = str(d.day, `${index + 1}일차`);
              const focus = str(d.focus);
              const activities = strArr(d.activities);
              const timeNeeded = str(d.timeNeeded ?? d.time_needed);
              const checklist = strArr(d.checklist);
              const expectedOutcome = str(d.expectedOutcome ?? d.expected_outcome);

              const bodyParts: string[] = [];
              if (focus) bodyParts.push(focus);
              if (activities.length > 0) bodyParts.push(activities.join(', '));
              if (timeNeeded) bodyParts.push(`(${timeNeeded})`);
              if (checklist.length > 0) bodyParts.push(`체크: ${checklist.join(', ')}`);
              if (expectedOutcome) bodyParts.push(`기대 결과: ${expectedOutcome}`);

              return {
                title: dayLabel,
                tag: focus || undefined,
                body: bodyParts.length > 0 ? bodyParts.join(' | ') : '',
              };
            })}
          />
        </SectionCard>
      ) : (
        <SectionCard title="주간 개발 계획">
          <Timeline
            items={[
              { title: '1일차', tag: '정리', body: '결과물과 메모를 한 곳에 모읍니다.' },
              { title: '2-3일차', tag: '실험', body: '작은 성과 하나를 반복 구조로 만듭니다.' },
              { title: '4-5일차', tag: '공개', body: '재능을 다른 사람에게 설명해봅니다.' },
              { title: '6일차', tag: '피드백', body: '받은 반응으로 방향을 조정합니다.' },
              { title: '7일차', tag: '회고', body: '한 주를 돌아보고 다음 목표를 세웁니다.' },
            ]}
          />
        </SectionCard>
      )}

      {/* 6. 성장 로드맵 */}
      {growthRoadmap.length > 0 ? (
        <SectionCard title="성장 로드맵" description="단계별 재능 개발 경로입니다.">
          <Timeline
            items={growthRoadmap.map((phase, index) => {
              const p = obj(phase);
              const phaseLabel = str(p.phase ?? p.title ?? p.name, `${index + 1}단계`);
              const goal = str(p.goal);
              const milestones = strArr(p.milestones);
              const skillsToAcquire = strArr(p.skillsToAcquire ?? p.skills_to_acquire);

              const bodyParts: string[] = [];
              if (goal) bodyParts.push(goal);
              if (milestones.length > 0) bodyParts.push(`마일스톤: ${milestones.join(', ')}`);
              if (skillsToAcquire.length > 0) bodyParts.push(`습득 스킬: ${skillsToAcquire.join(', ')}`);

              return {
                title: phaseLabel,
                tag: goal ? undefined : undefined,
                body: bodyParts.length > 0 ? bodyParts.join(' | ') : '',
              };
            })}
          />
        </SectionCard>
      ) : (
        <SectionCard title="성장 로드맵">
          <Timeline
            items={[
              { title: '1개월', tag: '탐색', body: '관심 분야를 좁히고 기초를 다집니다.' },
              { title: '3개월', tag: '실행', body: '첫 결과물을 만들고 피드백을 받습니다.' },
              { title: '6개월', tag: '심화', body: '전문성을 쌓고 포트폴리오를 구성합니다.' },
              { title: '1년', tag: '도약', body: '수익화 또는 커리어 전환을 시도합니다.' },
            ]}
          />
        </SectionCard>
      )}

      {/* 7. 협업 궁합 */}
      {(goodMatches.length > 0 || collabChallenges.length > 0 || teamRole) && (
        <SectionCard title="협업 궁합" description="팀에서 당신의 역할과 궁합입니다.">
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {teamRole ? (
              <View style={{ gap: fortuneTheme.spacing.xs }}>
                <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                  팀 역할
                </AppText>
                <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                  {teamRole}
                </AppText>
              </View>
            ) : null}
            {goodMatches.length > 0 ? (
              <View style={{ gap: fortuneTheme.spacing.xs }}>
                <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                  잘 맞는 유형
                </AppText>
                <KeywordPills keywords={goodMatches} />
              </View>
            ) : null}
            {collabChallenges.length > 0 ? (
              <View style={{ gap: fortuneTheme.spacing.xs }}>
                <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                  주의할 조합
                </AppText>
                <BulletList items={collabChallenges} />
              </View>
            ) : null}
          </View>
        </SectionCard>
      )}

      {/* 8. 학습 전략 */}
      {(effectiveMethods.length > 0 || recommendedBooks.length > 0 || courses.length > 0) && (
        <SectionCard title="학습 전략" description="효과적인 학습 방법과 추천 자료입니다.">
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {effectiveMethods.length > 0 ? (
              <View style={{ gap: fortuneTheme.spacing.xs }}>
                <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                  효과적인 방법
                </AppText>
                <BulletList items={effectiveMethods} />
              </View>
            ) : null}
            {timeManagement ? (
              <View style={{ gap: fortuneTheme.spacing.xs }}>
                <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                  시간 관리
                </AppText>
                <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                  {timeManagement}
                </AppText>
              </View>
            ) : null}
            {recommendedBooks.length > 0 ? (
              <View style={{ gap: fortuneTheme.spacing.xs }}>
                <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                  추천 도서
                </AppText>
                <BulletList items={recommendedBooks} />
              </View>
            ) : null}
            {courses.length > 0 ? (
              <View style={{ gap: fortuneTheme.spacing.xs }}>
                <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                  추천 강의
                </AppText>
                <BulletList items={courses} />
              </View>
            ) : null}
            {mentorshipAdvice ? (
              <View style={{ gap: fortuneTheme.spacing.xs }}>
                <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                  멘토링 조언
                </AppText>
                <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                  {mentorshipAdvice}
                </AppText>
              </View>
            ) : null}
          </View>
        </SectionCard>
      )}

      {/* 9. 주의할 함정 */}
      <SectionCard title="주의할 함정" description="성장을 방해하는 패턴을 미리 알아두세요.">
        <BulletList items={warnings} />
      </SectionCard>

      {/* Recommendations */}
      {recommendations.length > 0 && (
        <SectionCard title="실행 가이드">
          <BulletList items={recommendations} />
        </SectionCard>
      )}

      {result.hasApiData && result.specialTip && (
        <SectionCard title="코칭 메모">
          <InsetQuote text={result.specialTip} />
        </SectionCard>
      )}
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  3. ExerciseResult                                                  */
/* ------------------------------------------------------------------ */

function ExerciseResult(props: FortuneResultComponentProps) {
  const meta = resultMetadataByKind.exercise;
  const result = useResultData(props.payload);
  const raw = props.payload?.rawApiResponse ?? {};
  const hasRaw = Object.keys(raw).length > 0;

  // --- Extract exercise-specific fields from raw API response ---
  const exerciseRoutine = arr(raw.exerciseRoutine ?? raw.exercise_routine ?? raw.routine);
  const nutritionGuide = obj(raw.nutritionGuide ?? raw.nutrition_guide ?? raw.nutrition);
  const nutritionMeals = arr(nutritionGuide.meals ?? nutritionGuide.plan);
  const nutritionTipsRaw = strArr(nutritionGuide.tips ?? nutritionGuide.advice ?? raw.nutritionTips ?? raw.nutrition_tips);
  const hydration = str(nutritionGuide.hydration ?? nutritionGuide.hydrationAdvice ?? nutritionGuide.hydration_advice);
  const timing = obj(raw.timing ?? raw.optimalTiming ?? raw.optimal_timing);
  const bestTime = str(timing.bestTime ?? timing.best_time ?? timing.optimal);
  const avoidTime = str(timing.avoidTime ?? timing.avoid_time ?? timing.worst);
  const timingNote = str(timing.note ?? timing.description);
  const intensity = str(raw.intensity ?? raw.intensityLevel ?? raw.intensity_level);
  const weeklyPlan = arr(raw.weeklyPlan ?? raw.weekly_plan);
  const recoveryTips = strArr(raw.recoveryTips ?? raw.recovery_tips);

  const summary =
    result.summary ||
    str(raw.content as unknown) ||
    '\uC774\uBC88 \uD750\uB984\uC740 \uC9E7\uACE0 \uC790\uC8FC \uC6C0\uC9C1\uC774\uB294 \uBC29\uC2DD\uC774 \uB9DE\uC2B5\uB2C8\uB2E4. \uAC15\uB3C4\uB97C \uC62C\uB9AC\uB294 \uC77C\uBCF4\uB2E4 \uBE48\uB3C4\uB97C \uB9CC\uB4DC\uB294 \uB370 \uB354 \uC798 \uBC18\uC751\uD569\uB2C8\uB2E4.';

  // --- Score for circular gauge ---
  const exerciseScore = num(
    raw.exerciseScore ?? raw.exercise_score ?? raw.overallScore ?? raw.overall_score,
    0,
  ) || (result.metrics.length > 0 ? num(result.metrics[0]?.value, 78) : 78);
  const scoreColor =
    exerciseScore >= 90
      ? '#34C759'
      : exerciseScore >= 70
        ? '#8B7BE8'
        : exerciseScore >= 50
          ? '#FFCC00'
          : '#FF3B30';
  const scoreLabel =
    exerciseScore >= 90
      ? '\uCD5C\uC0C1'
      : exerciseScore >= 70
        ? '\uC88B\uC74C'
        : exerciseScore >= 50
          ? '\uBCF4\uD1B5'
          : '\uBD80\uC871';

  // --- Optimal time display ---
  const displayBestTime = bestTime || '\uC624\uC804 7-9\uC2DC';
  const displayAvoidTime = avoidTime || '\uC624\uD6C4 10\uC2DC \uC774\uD6C4';
  const timeSlots = [
    { label: '\uC0C8\uBCBD', range: '5-7', active: displayBestTime.includes('5') || displayBestTime.includes('6') || displayBestTime.includes('\uC0C8\uBCBD') },
    { label: '\uC624\uC804', range: '7-9', active: displayBestTime.includes('7') || displayBestTime.includes('8') || displayBestTime.includes('\uC624\uC804') },
    { label: '\uC624\uD6C4', range: '12-14', active: displayBestTime.includes('12') || displayBestTime.includes('13') || displayBestTime.includes('\uC810\uC2EC') || displayBestTime.includes('\uC624\uD6C4') },
    { label: '\uC800\uB141', range: '17-19', active: displayBestTime.includes('17') || displayBestTime.includes('18') || displayBestTime.includes('\uC800\uB141') },
    { label: '\uBC24', range: '20-22', active: displayBestTime.includes('20') || displayBestTime.includes('21') || displayBestTime.includes('\uBC24') },
  ];
  // If none matched, highlight the second slot (morning) as default
  const anyActive = timeSlots.some((s) => s.active);
  if (!anyActive && timeSlots.length > 1) timeSlots[1]!.active = true;

  // --- Exercise routine cards with body-part emojis ---
  const bodyPartEmoji: Record<string, string> = {
    '\uD314': '\uD83D\uDCAA', arm: '\uD83D\uDCAA', arms: '\uD83D\uDCAA', bicep: '\uD83D\uDCAA', tricep: '\uD83D\uDCAA',
    '\uB2E4\uB9AC': '\uD83E\uDDB5', leg: '\uD83E\uDDB5', legs: '\uD83E\uDDB5', '\uD558\uCCB4': '\uD83E\uDDB5',
    '\uAC00\uC2B4': '\uD83E\uDEC1', chest: '\uD83E\uDEC1', '\uD765\uBD80': '\uD83E\uDEC1',
    '\uB4F1': '\uD83E\uDEE8', back: '\uD83E\uDEE8',
    '\uC5B4\uAE68': '\uD83E\uDEF7', shoulder: '\uD83E\uDEF7', shoulders: '\uD83E\uDEF7',
    '\uCF54\uC5B4': '\uD83C\uDFAF', core: '\uD83C\uDFAF', abs: '\uD83C\uDFAF', '\uBCF5\uBD80': '\uD83C\uDFAF',
    '\uC804\uC2E0': '\uD83E\uDDD8', full: '\uD83E\uDDD8', '\uC2A4\uD2B8\uB808\uCE6D': '\uD83E\uDDD8', stretch: '\uD83E\uDDD8',
    '\uC720\uC0B0\uC18C': '\uD83C\uDFC3', cardio: '\uD83C\uDFC3', running: '\uD83C\uDFC3',
  };
  function getBodyEmoji(tags: string[]): string {
    for (const tag of tags) {
      const lower = tag.toLowerCase();
      for (const [key, emoji] of Object.entries(bodyPartEmoji)) {
        if (lower.includes(key)) return emoji;
      }
    }
    return '\uD83C\uDFCB\uFE0F';
  }

  const fallbackRoutine = [
    { name: '\uC6CC\uD0B9 \uB7F0\uC9C0', sets: '3', reps: '12', bodyParts: ['\uB2E4\uB9AC'], intensity: '\uC911\uAC04' },
    { name: '\uD478\uC26C\uC5C5', sets: '3', reps: '15', bodyParts: ['\uAC00\uC2B4', '\uD314'], intensity: '\uC911\uAC04' },
    { name: '\uD50C\uB7AD\uD06C', sets: '3', reps: '30\uCD08', bodyParts: ['\uCF54\uC5B4'], intensity: '\uB0AE\uC74C' },
    { name: '\uBC84\uD53C', sets: '4', reps: '8', bodyParts: ['\uB4F1', '\uD314'], intensity: '\uB192\uC74C' },
  ];

  // --- Weekly plan grid ---
  const weekDays = ['\uC6D4', '\uD654', '\uC218', '\uBAA9', '\uAE08', '\uD1A0', '\uC77C'];
  const weekIcons = ['\uD83C\uDFC3', '\uD83E\uDDD8', '\uD83D\uDCAA', '\uD83C\uDFC3', '\uD83E\uDDD8', '\uD83D\uDCAA', '\uD83D\uDE34'];
  const weekPlanData = weeklyPlan.length >= 7
    ? weeklyPlan.map((day, i) => {
        const d = obj(day);
        return {
          day: weekDays[i] ?? str(d.day, `${i + 1}`),
          icon: str(d.icon) || weekIcons[i] || '\uD83C\uDFC3',
          label: str(d.focus ?? d.tag ?? d.body ?? d.description, ''),
          isRest: str(d.focus ?? d.tag ?? d.body, '').includes('\uD734\uC2DD') || str(d.focus ?? d.tag, '').toLowerCase().includes('rest'),
        };
      })
    : weekDays.map((day, i) => ({
        day,
        icon: weekIcons[i] || '\uD83C\uDFC3',
        label: ['\uC720\uC0B0\uC18C', '\uC2A4\uD2B8\uB808\uCE6D', '\uADFC\uB825', '\uC720\uC0B0\uC18C', '\uC2A4\uD2B8\uB808\uCE6D', '\uADFC\uB825', '\uD734\uC2DD'][i] || '',
        isRest: i === 6,
      }));

  // --- Nutrition 3-meal layout ---
  const mealEmojis = ['\uD83C\uDF05', '\u2600\uFE0F', '\uD83C\uDF19'];
  const mealLabels = ['\uC544\uCE68', '\uC810\uC2EC', '\uC800\uB141'];
  const mealData = nutritionMeals.length >= 3
    ? nutritionMeals.map((meal, i) => {
        const m = obj(meal);
        return {
          emoji: mealEmojis[i] || '\uD83C\uDF7D\uFE0F',
          label: mealLabels[i] || str(m.name ?? m.title, `\uC2DD\uC0AC ${i + 1}`),
          desc: str(m.description ?? m.menu, ''),
          foods: strArr(m.foods ?? m.items),
        };
      })
    : [
        { emoji: '\uD83C\uDF05', label: '\uC544\uCE68', desc: '\uB2E8\uBC31\uC9C8 \uC911\uC2EC + \uD0C4\uC218\uD654\uBB3C \uC801\uB7C9', foods: ['\uACC4\uB780', '\uC624\uD2B8\uBC00', '\uBC14\uB098\uB098'] },
        { emoji: '\u2600\uFE0F', label: '\uC810\uC2EC', desc: '\uADE0\uD615 \uC7A1\uD78C \uC2DD\uC0AC + \uC218\uBD84 \uBCF4\uCDA9', foods: ['\uB2ED\uAC00\uC2B4', '\uD604\uBBF8\uBC25', '\uC0D0\uB7EC\uB4DC'] },
        { emoji: '\uD83C\uDF19', label: '\uC800\uB141', desc: '\uAC00\uBCBC\uC6B4 \uB2E8\uBC31\uC9C8 + \uC2DD\uC774\uC12C\uC720', foods: ['\uC5F0\uC5B4', '\uACE0\uAD6C\uB9C8', '\uC57C\uCC44'] },
      ];

  const hydrationText = hydration || '\uD558\uB8E8 2L \uC774\uC0C1 \uC218\uBD84 \uC12D\uCDE8\uB97C \uBAA9\uD45C\uB85C \uD558\uC138\uC694.';

  // --- Recovery tips ---
  const finalRecoveryTips =
    recoveryTips.length > 0
      ? recoveryTips
      : [
          '\uC6B4\uB3D9 \uD6C4 10\uBD84 \uC2A4\uD2B8\uB808\uCE6D\uC73C\uB85C \uADFC\uC721 \uC774\uC644',
          '\uCDA9\uBD84\uD55C \uC218\uBA74(7-8\uC2DC\uAC04)\uC73C\uB85C \uD68C\uBCF5 \uADF9\uB300\uD654',
          '\uD3FC\uB864\uB7EC\uB098 \uAC00\uBCBC\uC6B4 \uB9C8\uC0AC\uC9C0\uB85C \uADFC\uD53C\uB85C \uD574\uC18C',
        ];

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      {/* ====== HERO ====== */}
      <HeroCard emoji={'\uD83C\uDFC3'} title={meta.title} description={summary} />

      {/* ====== 1. CIRCULAR SCORE GAUGE ====== */}
      <Card style={{ gap: fortuneTheme.spacing.md }}>
        <AppText variant="heading4">{'\uD83C\uDFC3 \uC6B4\uB3D9 \uC2A4\uCF54\uC5B4'}</AppText>
        <View style={{ alignItems: 'center', gap: fortuneTheme.spacing.sm }}>
          <View
            style={{
              width: 140,
              height: 140,
              borderRadius: 70,
              borderWidth: 10,
              borderColor: scoreColor,
              alignItems: 'center',
              justifyContent: 'center',
              backgroundColor: `${scoreColor}15`,
            }}
          >
            <AppText style={{ fontSize: 44, fontWeight: '800', color: scoreColor }}>
              {exerciseScore}
            </AppText>
            <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
              / 100
            </AppText>
          </View>
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
            <View style={{ width: 8, height: 8, borderRadius: 4, backgroundColor: scoreColor }} />
            <AppText variant="labelLarge" style={{ color: scoreColor }}>
              {scoreLabel}
            </AppText>
          </View>
          {intensity ? (
            <View
              style={{
                backgroundColor: fortuneTheme.colors.surfaceSecondary,
                borderRadius: fortuneTheme.radius.full,
                paddingHorizontal: fortuneTheme.spacing.md,
                paddingVertical: fortuneTheme.spacing.xs,
              }}
            >
              <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                {'\uAD8C\uC7A5 \uAC15\uB3C4: '}{intensity}
              </AppText>
            </View>
          ) : null}
        </View>
      </Card>

      {/* ====== 2. OPTIMAL TIME DISPLAY ====== */}
      <Card style={{ gap: fortuneTheme.spacing.md }}>
        <AppText variant="heading4">{'\uCD5C\uC801 \uC2DC\uAC04\uB300'}</AppText>
        {timingNote ? (
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {timingNote}
          </AppText>
        ) : null}
        {/* Clock-style time slots */}
        <View style={{ flexDirection: 'row', justifyContent: 'space-between', gap: 4 }}>
          {timeSlots.map((slot) => (
            <View
              key={slot.label}
              style={{
                flex: 1,
                alignItems: 'center',
                gap: 4,
                backgroundColor: slot.active ? `${fortuneTheme.colors.ctaBackground}20` : fortuneTheme.colors.surfaceSecondary,
                borderRadius: fortuneTheme.radius.md,
                paddingVertical: fortuneTheme.spacing.sm,
                borderWidth: slot.active ? 1 : 0,
                borderColor: fortuneTheme.colors.ctaBackground,
              }}
            >
              <AppText style={{ fontSize: 16 }}>{slot.active ? '\u2705' : '\u23F0'}</AppText>
              <AppText
                variant="labelSmall"
                color={slot.active ? fortuneTheme.colors.ctaBackground : fortuneTheme.colors.textTertiary}
                style={{ fontWeight: slot.active ? '700' : '400' }}
              >
                {slot.label}
              </AppText>
              <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
                {slot.range}
              </AppText>
            </View>
          ))}
        </View>
        {/* Best/Avoid row */}
        <View style={{ flexDirection: 'row', gap: fortuneTheme.spacing.sm }}>
          <View
            style={{
              flex: 1,
              backgroundColor: `${'#34C759'}15`,
              borderRadius: fortuneTheme.radius.md,
              padding: fortuneTheme.spacing.sm,
              alignItems: 'center',
              gap: 2,
            }}
          >
            <AppText variant="caption" style={{ color: '#34C759', fontWeight: '700' }}>
              {'\uCD5C\uC801'}
            </AppText>
            <AppText variant="labelMedium" color={fortuneTheme.colors.textSecondary}>
              {displayBestTime}
            </AppText>
          </View>
          <View
            style={{
              flex: 1,
              backgroundColor: `${'#FF3B30'}15`,
              borderRadius: fortuneTheme.radius.md,
              padding: fortuneTheme.spacing.sm,
              alignItems: 'center',
              gap: 2,
            }}
          >
            <AppText variant="caption" style={{ color: '#FF3B30', fontWeight: '700' }}>
              {'\uD53C\uD558\uAE30'}
            </AppText>
            <AppText variant="labelMedium" color={fortuneTheme.colors.textSecondary}>
              {displayAvoidTime}
            </AppText>
          </View>
        </View>
      </Card>

      {/* ====== 3. EXERCISE ROUTINE CARDS ====== */}
      {(() => {
        const routineData = exerciseRoutine.length > 0 ? exerciseRoutine : fallbackRoutine;
        const intensityColorMap: Record<string, string> = {
          '\uB0AE\uC74C': '#34C759', low: '#34C759', '\uAC00\uBCBC\uC6C0': '#34C759',
          '\uC911\uAC04': '#FFCC00', medium: '#FFCC00', '\uBCF4\uD1B5': '#FFCC00',
          '\uB192\uC74C': '#FF3B30', high: '#FF3B30', '\uAC15\uD568': '#FF3B30',
        };

        return (
          <Card style={{ gap: fortuneTheme.spacing.md }}>
            <AppText variant="heading4">{'\uC6B4\uB3D9 \uB8E8\uD2F4'}</AppText>
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              {'\uC624\uB298\uC758 \uC6B4\uB3D9 \uC5D0\uB108\uC9C0 \uAE30\uBC18 \uB9DE\uCDA4 \uB8E8\uD2F4\uC785\uB2C8\uB2E4.'}
            </AppText>
            <View style={{ gap: fortuneTheme.spacing.sm }}>
              {routineData.map((ex, index) => {
                const e = obj(ex);
                const exName = str(e.name ?? e.title ?? e.exercise, `\uC6B4\uB3D9 ${index + 1}`);
                const exDesc = str(e.description ?? e.instruction);
                const sets = str(e.sets);
                const reps = str(e.reps ?? e.repetitions);
                const duration = str(e.duration ?? e.time);
                const exIntensity = str(e.intensity ?? e.level);
                const exTags = strArr(e.tags ?? e.muscles ?? e.bodyParts ?? e.body_parts);
                const emoji = getBodyEmoji(exTags.length > 0 ? exTags : [exName]);
                const intColor = intensityColorMap[exIntensity.toLowerCase()] ?? intensityColorMap[exIntensity] ?? fortuneTheme.colors.accentSecondary;

                const detailParts: string[] = [];
                if (sets) detailParts.push(`${sets}\uC138\uD2B8`);
                if (reps) detailParts.push(`${reps}\uD68C`);
                if (duration) detailParts.push(duration);

                return (
                  <View
                    key={`routine-${index}`}
                    style={{
                      backgroundColor: fortuneTheme.colors.surfaceSecondary,
                      borderRadius: fortuneTheme.radius.md,
                      padding: fortuneTheme.spacing.md,
                      gap: fortuneTheme.spacing.sm,
                    }}
                  >
                    <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.sm }}>
                      <AppText style={{ fontSize: 24 }}>{emoji}</AppText>
                      <View style={{ flex: 1 }}>
                        <AppText variant="heading4">{exName}</AppText>
                        {detailParts.length > 0 ? (
                          <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                            {detailParts.join(' / ')}
                          </AppText>
                        ) : null}
                      </View>
                    </View>
                    {/* Intensity bar */}
                    {exIntensity ? (
                      <View style={{ gap: 4 }}>
                        <View style={{ flexDirection: 'row', justifyContent: 'space-between' }}>
                          <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>{'\uAC15\uB3C4'}</AppText>
                          <AppText variant="caption" style={{ color: intColor, fontWeight: '700' }}>{exIntensity}</AppText>
                        </View>
                        <View
                          style={{
                            height: 6,
                            backgroundColor: fortuneTheme.colors.surfaceSecondary,
                            borderRadius: fortuneTheme.radius.full,
                            overflow: 'hidden',
                            borderWidth: 1,
                            borderColor: fortuneTheme.colors.border,
                          }}
                        >
                          <View
                            style={{
                              width: exIntensity.includes('\uB192') || exIntensity.toLowerCase().includes('high') || exIntensity.includes('\uAC15')
                                ? '90%'
                                : exIntensity.includes('\uC911') || exIntensity.toLowerCase().includes('med')
                                  ? '55%'
                                  : '30%',
                              height: '100%',
                              backgroundColor: intColor,
                              borderRadius: fortuneTheme.radius.full,
                            }}
                          />
                        </View>
                      </View>
                    ) : null}
                    {exDesc ? (
                      <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                        {exDesc}
                      </AppText>
                    ) : null}
                  </View>
                );
              })}
            </View>
          </Card>
        );
      })()}

      {/* ====== 4. WEEKLY PLAN CALENDAR GRID ====== */}
      <Card style={{ gap: fortuneTheme.spacing.md }}>
        <AppText variant="heading4">{'\uC8FC\uAC04 \uD50C\uB79C'}</AppText>
        <View style={{ flexDirection: 'row', justifyContent: 'space-between', gap: 4 }}>
          {weekPlanData.map((d) => (
            <View
              key={d.day}
              style={{
                flex: 1,
                alignItems: 'center',
                gap: 4,
                backgroundColor: d.isRest ? `${'#FF9500'}15` : fortuneTheme.colors.surfaceSecondary,
                borderRadius: fortuneTheme.radius.md,
                paddingVertical: fortuneTheme.spacing.sm,
              }}
            >
              <AppText variant="caption" color={fortuneTheme.colors.textTertiary} style={{ fontWeight: '700' }}>
                {d.day}
              </AppText>
              <AppText style={{ fontSize: 20 }}>{d.icon}</AppText>
              <AppText
                variant="caption"
                color={d.isRest ? '#FF9500' : fortuneTheme.colors.textSecondary}
                style={{ textAlign: 'center' }}
              >
                {d.label}
              </AppText>
            </View>
          ))}
        </View>
      </Card>

      {/* ====== 5. NUTRITION GUIDE - 3 MEAL LAYOUT ====== */}
      <Card style={{ gap: fortuneTheme.spacing.md }}>
        <AppText variant="heading4">{'\uC601\uC591 \uAC00\uC774\uB4DC'}</AppText>
        <View style={{ gap: fortuneTheme.spacing.sm }}>
          {mealData.map((meal, index) => (
            <View
              key={`meal-${index}`}
              style={{
                backgroundColor: fortuneTheme.colors.surfaceSecondary,
                borderRadius: fortuneTheme.radius.md,
                padding: fortuneTheme.spacing.md,
                gap: fortuneTheme.spacing.sm,
              }}
            >
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.sm }}>
                <AppText style={{ fontSize: 24 }}>{meal.emoji}</AppText>
                <View style={{ flex: 1 }}>
                  <AppText variant="heading4">{meal.label}</AppText>
                  {meal.desc ? (
                    <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                      {meal.desc}
                    </AppText>
                  ) : null}
                </View>
              </View>
              {meal.foods.length > 0 ? <KeywordPills keywords={meal.foods} /> : null}
            </View>
          ))}
        </View>
        {/* Hydration tracker */}
        <View
          style={{
            backgroundColor: `${'#2196F3'}15`,
            borderRadius: fortuneTheme.radius.md,
            padding: fortuneTheme.spacing.md,
            flexDirection: 'row',
            alignItems: 'center',
            gap: fortuneTheme.spacing.sm,
          }}
        >
          <AppText style={{ fontSize: 24 }}>{'\uD83D\uDCA7'}</AppText>
          <View style={{ flex: 1 }}>
            <AppText variant="labelMedium" style={{ color: '#2196F3', fontWeight: '700' }}>
              {'\uC218\uBD84 \uBCF4\uCDA9'}
            </AppText>
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              {hydrationText}
            </AppText>
          </View>
        </View>
      </Card>

      {/* ====== 6. RECOVERY TIP CARDS ====== */}
      <Card style={{ gap: fortuneTheme.spacing.md }}>
        <AppText variant="heading4">{'\uD83D\uDECC \uD68C\uBCF5 \uD301'}</AppText>
        <View style={{ gap: fortuneTheme.spacing.sm }}>
          {finalRecoveryTips.map((tip, index) => (
            <View
              key={`rec-${index}`}
              style={{
                backgroundColor: fortuneTheme.colors.surfaceSecondary,
                borderRadius: fortuneTheme.radius.md,
                padding: fortuneTheme.spacing.md,
                flexDirection: 'row',
                alignItems: 'flex-start',
                gap: fortuneTheme.spacing.sm,
              }}
            >
              <AppText style={{ fontSize: 18 }}>{['\uD83E\uDDD8', '\uD83D\uDE34', '\uD83D\uDC86'][index] ?? '\u2728'}</AppText>
              <AppText
                variant="bodySmall"
                color={fortuneTheme.colors.textSecondary}
                style={{ flex: 1 }}
              >
                {tip}
              </AppText>
            </View>
          ))}
        </View>
      </Card>

      {result.hasApiData && result.specialTip && (
        <SectionCard title="오늘의 팁">
          <InsetQuote text={result.specialTip} />
        </SectionCard>
      )}
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  4. TarotResult                                                     */
/* ------------------------------------------------------------------ */

function TarotResult(props: FortuneResultComponentProps) {
  const meta = resultMetadataByKind.tarot;
  const result = useResultData(props.payload);
  const raw = props.payload?.rawApiResponse ?? {};

  // --- Extract tarot-specific data from raw API response ---
  const positions = arr(raw.positions ?? raw.spread ?? raw.cards);
  const spreadType = str(raw.spreadType ?? raw.spread_type, '');
  const overallInterpretation = str(raw.overallInterpretation ?? raw.overall_interpretation);

  // Dream-specific fields (fortune-dream maps to tarot result kind)
  const symbols = arr(raw.symbols);
  const scenes = arr(raw.scenes);
  const psychologicalMeaning = str(raw.psychologicalMeaning ?? raw.psychological_meaning);
  const traditionalMeaning = str(raw.traditionalMeaning ?? raw.traditional_meaning);
  const isDream = symbols.length > 0 || scenes.length > 0;

  const hasRawTarot = positions.length > 0;
  const hasRawDream = isDream;

  const summary =
    result.summary ||
    '질문을 구체화할수록 카드의 메시지가 선명해집니다. 감정 해석보다 상황 해석이 먼저 필요한 날입니다.';

  const specialTip =
    result.specialTip ||
    '지금의 카드는 멈춤이 아니라 정렬을 말합니다. 바깥보다 안쪽 질문을 먼저 정리하세요.';

  const recommendations =
    result.recommendations.length > 0
      ? result.recommendations
      : [
          '비교할 선택지가 있으면 먼저 버릴 기준을 세우세요.',
          '카드가 비슷해 보여도 역할은 다릅니다.',
          '24시간 뒤 다시 읽으면 해석이 더 좋아집니다.',
        ];

  // --- Position color mapping for tarot spread visual ---
  const positionColors: Record<string, string> = {
    past: '#4FC3F7',
    present: '#FFD54F',
    future: '#B388FF',
    '과거': '#4FC3F7',
    '현재': '#FFD54F',
    '미래': '#B388FF',
  };
  const defaultPositionColorOrder = ['#4FC3F7', '#FFD54F', '#B388FF'];

  function getPositionColor(posName: string, index: number): string {
    const lower = posName.toLowerCase();
    for (const [key, color] of Object.entries(positionColors)) {
      if (lower.includes(key)) return color;
    }
    return defaultPositionColorOrder[index % defaultPositionColorOrder.length];
  }

  // --- Build card data for tarot spread visual ---
  const spreadCards = hasRawTarot
    ? positions.map((pos, index) => {
        const p = obj(pos);
        const positionName = str(p.position ?? p.positionName ?? p.position_name, `위치 ${index + 1}`);
        const cardName = str(p.cardName ?? p.card_name ?? p.card ?? p.name, '카드');
        const reversed = p.reversed === true || p.isReversed === true || p.is_reversed === true;
        const interpretation = str(p.interpretation ?? p.meaning ?? p.description);
        const keywords = strArr(p.keywords ?? p.themes);
        const color = getPositionColor(positionName, index);
        return { positionName, cardName, reversed, interpretation, keywords, color };
      })
    : [
        { positionName: '과거', cardName: '완드 4', reversed: false, interpretation: '안정된 기반 위에 세운 구조가 지금의 힘이 됩니다.', keywords: ['안정', '기반'], color: '#4FC3F7' },
        { positionName: '현재', cardName: '펜타클 7', reversed: false, interpretation: '기다림과 점검의 시간. 조급함을 내려놓으세요.', keywords: ['기다림', '점검'], color: '#FFD54F' },
        { positionName: '미래', cardName: '소드 2', reversed: false, interpretation: '선택 전 균형이 필요합니다. 직감을 믿으세요.', keywords: ['선택', '균형'], color: '#B388FF' },
      ];

  // Card rotation for visual spread effect
  const cardRotations = [-6, 0, 6];

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard
        emoji={isDream ? '🌙' : '🃏'}
        title={meta.title}
        description={summary}
      />

      {/* ============================================================ */}
      {/*  Tarot Spread Visual — Cards as colored rectangles             */}
      {/* ============================================================ */}
      {!hasRawDream && (
        <SectionCard
          title={spreadType ? `${spreadType} 스프레드` : '타로 스프레드'}
        >
          <View
            style={{
              flexDirection: 'row',
              justifyContent: 'center',
              alignItems: 'center',
              paddingVertical: fortuneTheme.spacing.lg,
              gap: -8,
            }}
          >
            {spreadCards.map((card, index) => (
              <View
                key={`spread-card-${index}`}
                style={{
                  width: 80,
                  height: 120,
                  borderRadius: fortuneTheme.radius.md,
                  backgroundColor: fortuneTheme.colors.surfaceSecondary,
                  borderWidth: 2,
                  borderColor: card.color,
                  justifyContent: 'center',
                  alignItems: 'center',
                  transform: [{ rotate: `${cardRotations[index % cardRotations.length]}deg` }],
                  marginHorizontal: -4,
                  shadowColor: card.color,
                  shadowOpacity: 0.3,
                  shadowRadius: 8,
                  shadowOffset: { width: 0, height: 4 },
                  elevation: 4,
                  zIndex: index === 1 ? 2 : 1,
                }}
              >
                <View
                  style={{
                    position: 'absolute',
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 4,
                    backgroundColor: card.color,
                    borderTopLeftRadius: fortuneTheme.radius.md - 2,
                    borderTopRightRadius: fortuneTheme.radius.md - 2,
                  }}
                />
                {card.reversed && (
                  <AppText
                    variant="caption"
                    color={card.color}
                    style={{ position: 'absolute', top: 8 }}
                  >
                    {'↓'}
                  </AppText>
                )}
                <AppText
                  variant="labelSmall"
                  color={fortuneTheme.colors.textPrimary}
                  style={{ textAlign: 'center', paddingHorizontal: 4 }}
                >
                  {card.cardName}
                </AppText>
                <AppText
                  variant="caption"
                  color={card.color}
                  style={{ marginTop: 4 }}
                >
                  {card.positionName}
                </AppText>
              </View>
            ))}
          </View>
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Per-Card Interpretation — Colored left border sections        */}
      {/* ============================================================ */}
      {!hasRawDream &&
        spreadCards.map((card, index) => (
          <Card
            key={`interp-${index}`}
            style={{
              borderLeftWidth: 4,
              borderLeftColor: card.color,
              gap: fortuneTheme.spacing.sm,
            }}
          >
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.sm }}>
              <View
                style={{
                  backgroundColor: card.color,
                  borderRadius: fortuneTheme.radius.xs,
                  paddingHorizontal: fortuneTheme.spacing.sm,
                  paddingVertical: fortuneTheme.spacing.xxs,
                }}
              >
                <AppText variant="labelSmall" color="#000000">
                  {card.positionName}
                </AppText>
              </View>
              <AppText variant="heading4">{card.cardName}</AppText>
              {card.reversed && (
                <AppText variant="labelMedium" color={card.color}>
                  {'↓ 역방향'}
                </AppText>
              )}
            </View>
            {card.interpretation ? (
              <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                {card.interpretation}
              </AppText>
            ) : null}
            {card.keywords.length > 0 && (
              <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 6 }}>
                {card.keywords.map((kw) => (
                  <View
                    key={kw}
                    style={{
                      backgroundColor: `${card.color}20`,
                      borderRadius: fortuneTheme.radius.full,
                      paddingHorizontal: fortuneTheme.spacing.sm,
                      paddingVertical: fortuneTheme.spacing.xxs,
                    }}
                  >
                    <AppText variant="caption" color={card.color}>
                      {kw}
                    </AppText>
                  </View>
                ))}
              </View>
            )}
          </Card>
        ))}

      {/* ============================================================ */}
      {/*  Dream: Symbol cards with emoji + impact bar                   */}
      {/* ============================================================ */}
      {hasRawDream && symbols.length > 0 && (
        <SectionCard title="심볼 카드" description="꿈에 등장한 상징과 감정 임팩트입니다.">
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {symbols.map((sym, index) => {
              const s = obj(sym);
              const symbolName = str(s.name ?? s.symbol, `상징 ${index + 1}`);
              const emoji = str(s.emoji ?? s.icon, '🔮');
              const meaning = str(s.meaning);
              const emotionalImpact = num(s.emotionalImpact ?? s.emotional_impact, 0);
              const impactClamped = Math.max(-5, Math.min(5, emotionalImpact));
              const impactNormalized = (impactClamped + 5) / 10; // 0..1

              return (
                <Card
                  key={`sym-${index}`}
                  style={{
                    backgroundColor: fortuneTheme.colors.surfaceSecondary,
                    gap: fortuneTheme.spacing.sm,
                  }}
                >
                  <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.sm }}>
                    <View
                      style={{
                        width: 40,
                        height: 40,
                        borderRadius: fortuneTheme.radius.md,
                        backgroundColor: fortuneTheme.colors.backgroundTertiary,
                        justifyContent: 'center',
                        alignItems: 'center',
                      }}
                    >
                      <AppText variant="heading3">{emoji}</AppText>
                    </View>
                    <View style={{ flex: 1 }}>
                      <AppText variant="heading4">{symbolName}</AppText>
                      {meaning ? (
                        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                          {meaning}
                        </AppText>
                      ) : null}
                    </View>
                  </View>
                  {/* Emotional impact bar -5 to +5 */}
                  <View style={{ gap: fortuneTheme.spacing.xs }}>
                    <View style={{ flexDirection: 'row', justifyContent: 'space-between' }}>
                      <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
                        감정 임팩트
                      </AppText>
                      <AppText
                        variant="labelSmall"
                        color={
                          impactClamped > 0
                            ? '#4FC3F7'
                            : impactClamped < 0
                              ? '#FF8A80'
                              : fortuneTheme.colors.textTertiary
                        }
                      >
                        {impactClamped > 0 ? `+${impactClamped}` : String(impactClamped)}
                      </AppText>
                    </View>
                    <View
                      style={{
                        height: 6,
                        borderRadius: 3,
                        backgroundColor: fortuneTheme.colors.backgroundTertiary,
                        overflow: 'hidden',
                      }}
                    >
                      <View
                        style={{
                          position: 'absolute',
                          left: 0,
                          top: 0,
                          bottom: 0,
                          width: `${Math.round(impactNormalized * 100)}%`,
                          borderRadius: 3,
                          backgroundColor:
                            impactClamped > 0
                              ? '#4FC3F7'
                              : impactClamped < 0
                                ? '#FF8A80'
                                : fortuneTheme.colors.textTertiary,
                        }}
                      />
                      {/* Center marker for zero */}
                      <View
                        style={{
                          position: 'absolute',
                          left: '50%',
                          top: -1,
                          width: 2,
                          height: 8,
                          backgroundColor: fortuneTheme.colors.textTertiary,
                          marginLeft: -1,
                        }}
                      />
                    </View>
                  </View>
                </Card>
              );
            })}
          </View>
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Dream: Scene timeline                                         */}
      {/* ============================================================ */}
      {hasRawDream && scenes.length > 0 && (
        <SectionCard title="장면 타임라인" description="꿈에서 펼쳐진 장면의 순서입니다.">
          <Timeline
            items={scenes.map((sc, index) => {
              const s = obj(sc);
              return {
                title: str(s.title ?? s.name, `장면 ${index + 1}`),
                tag: str(s.tag ?? s.emotion),
                body: str(s.description ?? s.content, '장면 설명 없음'),
              };
            })}
          />
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Dream: Psychological vs Traditional comparison                */}
      {/* ============================================================ */}
      {hasRawDream && (psychologicalMeaning || traditionalMeaning) && (
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: fortuneTheme.spacing.sm }}>
          {psychologicalMeaning ? (
            <View style={{ minWidth: '47%', flexGrow: 1, flexBasis: '47%' }}>
              <Card
                style={{
                  borderLeftWidth: 4,
                  borderLeftColor: '#B388FF',
                  gap: fortuneTheme.spacing.sm,
                }}
              >
                <AppText variant="labelLarge" color="#B388FF">
                  심리학적 해석
                </AppText>
                <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                  {psychologicalMeaning}
                </AppText>
              </Card>
            </View>
          ) : null}
          {traditionalMeaning ? (
            <View style={{ minWidth: '47%', flexGrow: 1, flexBasis: '47%' }}>
              <Card
                style={{
                  borderLeftWidth: 4,
                  borderLeftColor: '#FFD54F',
                  gap: fortuneTheme.spacing.sm,
                }}
              >
                <AppText variant="labelLarge" color="#FFD54F">
                  전통 해몽
                </AppText>
                <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                  {traditionalMeaning}
                </AppText>
              </Card>
            </View>
          ) : null}
        </View>
      )}

      {/* ============================================================ */}
      {/*  Overall interpretation                                        */}
      {/* ============================================================ */}
      {overallInterpretation ? (
        <SectionCard title="종합 해석">
          <InsetQuote text={overallInterpretation} />
        </SectionCard>
      ) : (
        <SectionCard title="종합 해석">
          <InsetQuote text={specialTip} />
        </SectionCard>
      )}

      <SectionCard title="가이드">
        <BulletList items={recommendations} />
      </SectionCard>

      {result.hasApiData && result.highlights.length > 0 && (
        <SectionCard title="추가 인사이트">
          <BulletList items={result.highlights} />
        </SectionCard>
      )}
    </View>
  );
}

/* ---------- RPG stat helpers ---------- */

function rpgBar(value: number, maxSegments = 10): string {
  const clamped = Math.max(0, Math.min(100, value));
  const filled = Math.round((clamped / 100) * maxSegments);
  return '\u2588'.repeat(filled) + '\u2591'.repeat(maxSegments - filled);
}

function rpgStatColor(value: number): string {
  if (value >= 85) return '#34C759';
  if (value >= 70) return '#8FB8FF';
  if (value >= 50) return '#FFCC00';
  return '#FF6B6B';
}

const GAME_ROLE_BADGES: Record<string, { emoji: string; color: string }> = {
  '\uD0F1\uCEE4': { emoji: '\uD83D\uDEE1\uFE0F', color: '#8FB8FF' },
  '\uB51C\uB7EC': { emoji: '\u2694\uFE0F', color: '#FF6B6B' },
  '\uD798\uB7EC': { emoji: '\uD83D\uDC9A', color: '#34C759' },
  '\uC11C\uD3EC\uD130': { emoji: '\uD83C\uDF1F', color: '#FFCC00' },
  '\uC5B4\uC384\uC2E0': { emoji: '\uD83D\uDDE1\uFE0F', color: '#E0A76B' },
  '\uAD81\uC218': { emoji: '\uD83C\uDFF9', color: '#8FB8FF' },
  '\uB9C8\uBC95\uC0AC': { emoji: '\uD83D\uDD2E', color: '#E8E0FF' },
};

function gameRoleBadge(role: string): { emoji: string; color: string } {
  for (const [key, val] of Object.entries(GAME_ROLE_BADGES)) {
    if (role.includes(key)) return val;
  }
  return { emoji: '\uD83C\uDFAD', color: '#8FB8FF' };
}

/* ------------------------------------------------------------------ */
/*  5. GameEnhanceResult                                               */
/* ------------------------------------------------------------------ */

function GameEnhanceResult(props: FortuneResultComponentProps) {
  const meta = resultMetadataByKind['game-enhance'];
  const result = useResultData(props.payload);
  const raw = props.payload?.rawApiResponse ?? {};
  const hasRaw = Object.keys(raw).length > 0;

  // --- Extract game-enhance-specific fields from raw API response ---
  const gameStats = obj(raw.gameStats ?? raw.game_stats ?? raw.stats);
  const attackPower = num(gameStats.attack ?? gameStats.attackPower ?? gameStats.attack_power, 0);
  const defensePower = num(gameStats.defense ?? gameStats.defensePower ?? gameStats.defense_power, 0);
  const luck = num(gameStats.luck ?? gameStats.luckScore ?? gameStats.luck_score, 0);
  const dropRate = num(gameStats.dropRate ?? gameStats.drop_rate ?? gameStats.drop, 0);
  const criticalRate = num(gameStats.criticalRate ?? gameStats.critical_rate ?? gameStats.critical, 0);
  const optimalTiming = obj(raw.optimalTiming ?? raw.optimal_timing ?? raw.timing);
  const goldenTime = str(optimalTiming.goldenTime ?? optimalTiming.golden_time ?? optimalTiming.best);
  const dangerTime = str(optimalTiming.dangerTime ?? optimalTiming.danger_time ?? optimalTiming.worst ?? optimalTiming.avoid);
  const timingDescription = str(optimalTiming.description ?? optimalTiming.note);
  const timeSlots = arr(optimalTiming.slots ?? optimalTiming.timeSlots ?? optimalTiming.time_slots);

  const teamStrategy = obj(raw.teamStrategy ?? raw.team_strategy ?? raw.team);
  const teamRole = str(teamStrategy.role ?? teamStrategy.teamRole ?? teamStrategy.team_role);
  const teamTips = strArr(teamStrategy.tips ?? teamStrategy.advice);
  const teamComposition = strArr(teamStrategy.composition ?? teamStrategy.members ?? teamStrategy.recommended);
  const synergyNote = str(teamStrategy.synergy ?? teamStrategy.synergyNote ?? teamStrategy.synergy_note);

  const enhanceSteps = arr(raw.enhanceSteps ?? raw.enhance_steps ?? raw.roadmap ?? raw.steps);

  const summary =
    result.summary ||
    str(raw.content as unknown) ||
    '무작정 누르기보다 타이밍을 보는 쪽이 맞습니다. 강화 의식은 짧게, 판단은 냉정하게 가져가야 손실이 줄어듭니다.';

  // --- Stat values with fallbacks ---
  const displayAttack = attackPower > 0 ? attackPower : 84;
  const displayDefense = defensePower > 0 ? defensePower : 71;
  const displayLuck = luck > 0 ? luck : 88;
  const displayDrop = dropRate > 0 ? dropRate : 77;
  const displayCritical = criticalRate > 0 ? criticalRate : 82;

  const displayGoldenTime = goldenTime || '21:00 ~ 23:00';
  const displayDangerTime = dangerTime || '00:30 ~ 02:00';
  const displayTimingDesc = timingDescription || '골든타임에 집중하고, 위험 시간대는 피하세요.';

  const displayTeamRole = teamRole || '딜러';
  const displayComposition =
    teamComposition.length > 0
      ? teamComposition
      : ['탱커', '딜러', '힐러', '서포터'];
  const displaySynergy =
    synergyNote || '오늘은 안정적인 파티 구성에서 시너지가 극대화됩니다. 무리한 솔로 플레이보다 팀워크에 집중하세요.';
  const displayTeamTips =
    teamTips.length > 0
      ? teamTips
      : [
          '탱커가 어그로를 잡은 뒤 딜 타이밍을 노리세요.',
          '힐러와 가까운 포지션을 유지하세요.',
        ];

  const rpgStats = [
    { icon: '⚔️', label: '공격력', value: displayAttack },
    { icon: '🛡️', label: '방어력', value: displayDefense },
    { icon: '🍀', label: '행운', value: displayLuck },
    { icon: '💎', label: '드롭률', value: displayDrop },
    { icon: '⚡', label: '크리티컬', value: displayCritical },
  ];

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      {/* ============================================================ */}
      {/*  Hero: RPG character sheet header                             */}
      {/* ============================================================ */}
      <Card
        style={{
          backgroundColor: fortuneTheme.colors.backgroundTertiary,
          gap: fortuneTheme.spacing.md,
        }}
      >
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.sm }}>
          <AppText style={{ fontSize: 28, lineHeight: 36 }}>🎮</AppText>
          <View style={{ flex: 1 }}>
            <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
              오늘의 캐릭터 시트
            </AppText>
            <AppText variant="heading2">{meta.title}</AppText>
          </View>
        </View>
        <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
          {summary}
        </AppText>
      </Card>

      {/* ============================================================ */}
      {/*  1. RPG Stat Sheet                                            */}
      {/* ============================================================ */}
      <Card
        style={{
          backgroundColor: fortuneTheme.colors.backgroundTertiary,
          gap: fortuneTheme.spacing.sm,
        }}
      >
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
          <AppText style={{ fontSize: 20, lineHeight: 26 }}>📊</AppText>
          <AppText variant="heading4">게임 스탯 시트</AppText>
        </View>
        <View style={{ gap: fortuneTheme.spacing.md }}>
          {rpgStats.map((stat) => {
            const clamped = Math.max(0, Math.min(100, stat.value));
            return (
              <View key={stat.label} style={{ gap: fortuneTheme.spacing.xs }}>
                <View
                  style={{
                    flexDirection: 'row',
                    alignItems: 'center',
                    gap: fortuneTheme.spacing.xs,
                  }}
                >
                  <AppText style={{ fontSize: 16, lineHeight: 22 }}>{stat.icon}</AppText>
                  <AppText variant="labelLarge" style={{ width: 60 }}>
                    {stat.label}
                  </AppText>
                  <AppText
                    variant="labelLarge"
                    style={{ color: rpgStatColor(clamped), width: 32, textAlign: 'right' }}
                  >
                    {clamped}
                  </AppText>
                  <View style={{ flex: 1, marginLeft: fortuneTheme.spacing.xs }}>
                    <View
                      style={{
                        backgroundColor: fortuneTheme.colors.surfaceSecondary,
                        borderRadius: fortuneTheme.radius.full,
                        height: 14,
                        overflow: 'hidden',
                      }}
                    >
                      <View
                        style={{
                          backgroundColor: rpgStatColor(clamped),
                          borderRadius: fortuneTheme.radius.full,
                          height: '100%',
                          width: `${clamped}%`,
                        }}
                      />
                    </View>
                  </View>
                </View>
              </View>
            );
          })}
        </View>
        {/* Text-based stat summary for RPG feel */}
        <View
          style={{
            backgroundColor: fortuneTheme.colors.surfaceSecondary,
            borderRadius: fortuneTheme.radius.md,
            padding: fortuneTheme.spacing.sm,
            marginTop: fortuneTheme.spacing.xs,
          }}
        >
          <AppText
            variant="caption"
            style={{
              fontFamily: 'monospace',
              color: fortuneTheme.colors.textTertiary,
              lineHeight: 18,
            }}
          >
            {rpgStats
              .map(
                (s) =>
                  `${s.icon} ${s.label.padEnd(5, '\u3000')} ${String(s.value).padStart(3)} ${rpgBar(s.value)}`,
              )
              .join('\n')}
          </AppText>
        </View>
      </Card>

      {/* ============================================================ */}
      {/*  2. Golden Time - highlighted time slots with glow            */}
      {/* ============================================================ */}
      <SectionCard title="골든 타임" description={displayTimingDesc}>
        <View style={{ flexDirection: 'row', gap: fortuneTheme.spacing.sm }}>
          {/* Golden time card */}
          <View style={{ flex: 1 }}>
            <Card
              style={{
                backgroundColor: 'rgba(52, 199, 89, 0.12)',
                borderWidth: 1,
                borderColor: 'rgba(52, 199, 89, 0.3)',
                alignItems: 'center',
                gap: fortuneTheme.spacing.xs,
                paddingVertical: fortuneTheme.spacing.md,
              }}
            >
              <AppText style={{ fontSize: 24, lineHeight: 30 }}>✨</AppText>
              <AppText variant="labelMedium" color="#34C759">
                골든타임
              </AppText>
              <AppText variant="heading4" style={{ color: '#34C759' }}>
                {displayGoldenTime}
              </AppText>
            </Card>
          </View>

          {/* Danger time card */}
          <View style={{ flex: 1 }}>
            <Card
              style={{
                backgroundColor: 'rgba(255, 59, 48, 0.12)',
                borderWidth: 1,
                borderColor: 'rgba(255, 59, 48, 0.3)',
                alignItems: 'center',
                gap: fortuneTheme.spacing.xs,
                paddingVertical: fortuneTheme.spacing.md,
              }}
            >
              <AppText style={{ fontSize: 24, lineHeight: 30 }}>💀</AppText>
              <AppText variant="labelMedium" color="#FF3B30">
                위험시간
              </AppText>
              <AppText variant="heading4" style={{ color: '#FF3B30' }}>
                {displayDangerTime}
              </AppText>
            </Card>
          </View>
        </View>

        {/* Detailed time slots from raw API */}
        {hasRaw && timeSlots.length > 0 && (
          <View style={{ marginTop: fortuneTheme.spacing.sm }}>
            <Timeline
              items={timeSlots.map((slot, index) => {
                const s = obj(slot);
                return {
                  title: str(s.time ?? s.title ?? s.period, `${index + 1}구간`),
                  tag: str(s.tag ?? s.rating) || undefined,
                  body: str(s.body ?? s.description ?? s.advice, ''),
                };
              })}
            />
          </View>
        )}
      </SectionCard>

      {/* ============================================================ */}
      {/*  3. Team Strategy - party composition with role badges        */}
      {/* ============================================================ */}
      <SectionCard title="팀 전략" description="오늘의 추천 파티 구성과 역할입니다.">
        <View style={{ gap: fortuneTheme.spacing.md }}>
          {/* Recommended role */}
          <View
            style={{
              flexDirection: 'row',
              alignItems: 'center',
              gap: fortuneTheme.spacing.sm,
            }}
          >
            <View
              style={{
                width: 48,
                height: 48,
                borderRadius: fortuneTheme.radius.full,
                backgroundColor: 'rgba(139, 123, 232, 0.2)',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <AppText style={{ fontSize: 24, lineHeight: 30 }}>
                {gameRoleBadge(displayTeamRole).emoji}
              </AppText>
            </View>
            <View style={{ flex: 1 }}>
              <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                추천 역할
              </AppText>
              <AppText variant="heading3" style={{ color: gameRoleBadge(displayTeamRole).color }}>
                {displayTeamRole}
              </AppText>
            </View>
          </View>

          {/* Party composition badges */}
          <View style={{ gap: fortuneTheme.spacing.xs }}>
            <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
              추천 파티 구성
            </AppText>
            <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: fortuneTheme.spacing.sm }}>
              {displayComposition.map((member) => {
                const badge = gameRoleBadge(member);
                return (
                  <View
                    key={member}
                    style={{
                      flexDirection: 'row',
                      alignItems: 'center',
                      gap: fortuneTheme.spacing.xs,
                      backgroundColor: fortuneTheme.colors.surfaceSecondary,
                      borderRadius: fortuneTheme.radius.full,
                      paddingHorizontal: fortuneTheme.spacing.md,
                      paddingVertical: fortuneTheme.spacing.xs,
                    }}
                  >
                    <AppText style={{ fontSize: 14, lineHeight: 18 }}>{badge.emoji}</AppText>
                    <AppText variant="labelMedium" style={{ color: badge.color }}>
                      {member}
                    </AppText>
                  </View>
                );
              })}
            </View>
          </View>

          {/* Synergy note */}
          <View
            style={{
              backgroundColor: fortuneTheme.colors.surfaceSecondary,
              borderLeftWidth: 3,
              borderLeftColor: fortuneTheme.colors.ctaBackground,
              borderRadius: fortuneTheme.radius.md,
              padding: fortuneTheme.spacing.md,
            }}
          >
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              {displaySynergy}
            </AppText>
          </View>

          {/* Team tips */}
          {displayTeamTips.length > 0 && <BulletList items={displayTeamTips} />}
        </View>
      </SectionCard>

      {/* ============================================================ */}
      {/*  4. Enhancement Roadmap - step-by-step path                   */}
      {/* ============================================================ */}
      <SectionCard title="강화 로드맵" description="단계별 강화 전략입니다.">
        {hasRaw && enhanceSteps.length > 0 ? (
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {enhanceSteps.map((step, index) => {
              const s = obj(step);
              const stepTitle = str(s.title ?? s.phase ?? s.step, `${index + 1}단계`);
              const stepTag = str(s.tag ?? s.action);
              const stepBody = str(s.body ?? s.description ?? s.detail, '');
              const stepNum = index + 1;
              return (
                <View
                  key={`step-${index}`}
                  style={{
                    flexDirection: 'row',
                    gap: fortuneTheme.spacing.sm,
                    alignItems: 'flex-start',
                  }}
                >
                  <View
                    style={{
                      width: 32,
                      height: 32,
                      borderRadius: fortuneTheme.radius.full,
                      backgroundColor: fortuneTheme.colors.ctaBackground,
                      alignItems: 'center',
                      justifyContent: 'center',
                    }}
                  >
                    <AppText
                      variant="labelLarge"
                      style={{ color: fortuneTheme.colors.ctaForeground }}
                    >
                      {stepNum}
                    </AppText>
                  </View>
                  <View style={{ flex: 1, gap: fortuneTheme.spacing.xs }}>
                    <View
                      style={{
                        flexDirection: 'row',
                        alignItems: 'center',
                        gap: fortuneTheme.spacing.xs,
                      }}
                    >
                      <AppText variant="labelLarge">{stepTitle}</AppText>
                      {stepTag ? (
                        <View
                          style={{
                            backgroundColor: fortuneTheme.colors.surfaceSecondary,
                            borderRadius: fortuneTheme.radius.full,
                            paddingHorizontal: fortuneTheme.spacing.sm,
                            paddingVertical: 2,
                          }}
                        >
                          <AppText variant="caption" color={fortuneTheme.colors.accentSecondary}>
                            {stepTag}
                          </AppText>
                        </View>
                      ) : null}
                    </View>
                    {stepBody ? (
                      <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                        {stepBody}
                      </AppText>
                    ) : null}
                  </View>
                </View>
              );
            })}
          </View>
        ) : (
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {[
              { num: 1, title: '준비', tag: '자원 확인', body: '강화 재료와 손실 한도를 먼저 확인하세요.' },
              { num: 2, title: '진입', tag: '타이밍', body: '골든타임에 맞춰 짧게 집중 시도합니다.' },
              { num: 3, title: '실행', tag: '집중', body: '연속 실패 시 즉시 멈추고 쿨다운합니다.' },
              { num: 4, title: '정산', tag: '기록', body: '결과를 기록하고 다음 전략을 수립합니다.' },
            ].map((step) => (
              <View
                key={`step-${step.num}`}
                style={{
                  flexDirection: 'row',
                  gap: fortuneTheme.spacing.sm,
                  alignItems: 'flex-start',
                }}
              >
                <View
                  style={{
                    width: 32,
                    height: 32,
                    borderRadius: fortuneTheme.radius.full,
                    backgroundColor: fortuneTheme.colors.ctaBackground,
                    alignItems: 'center',
                    justifyContent: 'center',
                  }}
                >
                  <AppText
                    variant="labelLarge"
                    style={{ color: fortuneTheme.colors.ctaForeground }}
                  >
                    {step.num}
                  </AppText>
                </View>
                <View style={{ flex: 1, gap: fortuneTheme.spacing.xs }}>
                  <View
                    style={{
                      flexDirection: 'row',
                      alignItems: 'center',
                      gap: fortuneTheme.spacing.xs,
                    }}
                  >
                    <AppText variant="labelLarge">{step.title}</AppText>
                    <View
                      style={{
                        backgroundColor: fortuneTheme.colors.surfaceSecondary,
                        borderRadius: fortuneTheme.radius.full,
                        paddingHorizontal: fortuneTheme.spacing.sm,
                        paddingVertical: 2,
                      }}
                    >
                      <AppText variant="caption" color={fortuneTheme.colors.accentSecondary}>
                        {step.tag}
                      </AppText>
                    </View>
                  </View>
                  <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                    {step.body}
                  </AppText>
                </View>
              </View>
            ))}
          </View>
        )}
      </SectionCard>

      {result.hasApiData && result.specialTip && (
        <SectionCard title="한 줄 조언">
          <InsetQuote text={result.specialTip} />
        </SectionCard>
      )}

      {result.hasApiData && result.highlights.length > 0 && (
        <SectionCard title="추가 전략">
          <BulletList items={result.highlights} />
        </SectionCard>
      )}
    </View>
  );
}

/* ------------------------------------------------------------------ */
/*  6. OotdEvaluationResult                                            */
/* ------------------------------------------------------------------ */

function OotdEvaluationResult(props: FortuneResultComponentProps) {
  const meta = resultMetadataByKind['ootd-evaluation'];
  const result = useResultData(props.payload);
  const raw = props.payload?.rawApiResponse ?? {};
  const hasRaw = Object.keys(raw).length > 0;

  // --- Extract ootd-specific fields from raw API response ---
  const outfitEval = obj(raw.outfitEvaluation ?? raw.outfit_evaluation ?? raw.evaluation);
  const overallScore = num(outfitEval.overallScore ?? outfitEval.overall_score ?? raw.overallScore ?? raw.overall_score, 0);
  const colorScore = num(outfitEval.colorScore ?? outfitEval.color_score, 0);
  const fitScore = num(outfitEval.fitScore ?? outfitEval.fit_score, 0);
  const completionScore = num(outfitEval.completionScore ?? outfitEval.completion_score, 0);
  const tpoScore = num(outfitEval.tpoScore ?? outfitEval.tpo_score, 0);
  const hasScores = overallScore > 0 || colorScore > 0 || fitScore > 0;

  const colorAnalysis = obj(raw.colorAnalysis ?? raw.color_analysis ?? raw.colors);
  const mainColors = strArr(colorAnalysis.mainColors ?? colorAnalysis.main_colors ?? colorAnalysis.primary);
  const accentColors = strArr(colorAnalysis.accentColors ?? colorAnalysis.accent_colors ?? colorAnalysis.accent);
  const colorHarmony = str(colorAnalysis.harmony ?? colorAnalysis.colorHarmony ?? colorAnalysis.color_harmony);
  const colorAdvice = str(colorAnalysis.advice ?? colorAnalysis.recommendation ?? colorAnalysis.description);
  const seasonalType = str(colorAnalysis.seasonalType ?? colorAnalysis.seasonal_type ?? colorAnalysis.personalColor ?? colorAnalysis.personal_color);
  const hasColorAnalysis = mainColors.length > 0 || colorHarmony !== '' || seasonalType !== '';

  const styleRecs = arr(raw.styleRecommendations ?? raw.style_recommendations ?? raw.itemRecommendations ?? raw.item_recommendations);
  const outfitItems = arr(raw.outfitItems ?? raw.outfit_items ?? raw.items);
  const tpoFeedback = strArr(raw.tpoFeedback ?? raw.tpo_feedback);
  const celebMatch = obj(raw.celebMatch ?? raw.celeb_match ?? raw.celebrity);
  const celebName = str(celebMatch.name ?? celebMatch.celebrity);
  const celebImage = str(celebMatch.image ?? celebMatch.matchPoint ?? celebMatch.match_point);
  const celebDescription = str(celebMatch.description ?? celebMatch.reason);
  const rawStyleKeywords = strArr(raw.styleKeywords ?? raw.style_keywords ?? raw.keywords);

  const summary =
    result.summary ||
    str(raw.content as unknown) ||
    '전체 실루엣은 안정적이고, 포인트 하나만 더 살리면 인상이 훨씬 선명해집니다. 이번 결과는 TPO와 컬러 밸런스를 기준으로 보면 좋습니다.';

  const chips =
    result.contextTags.length > 0
      ? result.contextTags
      : ['TPO', '컬러 밸런스', '스타일 포인트'];

  const scoreMetrics =
    hasScores
      ? [
          ...(overallScore > 0 ? [{ label: '전체 점수', value: String(overallScore), note: '' }] : []),
          ...(colorScore > 0 ? [{ label: '컬러', value: String(colorScore), note: '' }] : []),
          ...(fitScore > 0 ? [{ label: '핏', value: String(fitScore), note: '' }] : []),
          ...(completionScore > 0 ? [{ label: '완성도', value: String(completionScore), note: '' }] : []),
          ...(tpoScore > 0 ? [{ label: 'TPO', value: String(tpoScore), note: '' }] : []),
        ]
      : result.metrics.length >= 4
        ? result.metrics.slice(0, 4)
        : [
            { label: '전체 점수', value: '86', note: '무난하게 강함' },
            { label: '컬러', value: '79', note: '톤은 안정적' },
            { label: '핏', value: '88', note: '실루엣이 살아남' },
            { label: '완성도', value: '81', note: '포인트만 더하면 상승' },
          ];

  const categoryItems =
    result.metrics.length >= 8
      ? result.metrics.slice(4, 8).map((m, i) => ({
          label: m.label,
          value: Number(m.value) || [84, 77, 90, 68][i] || 75,
          highlight: m.note || '',
        }))
      : [
          { label: '상의', value: 84, highlight: '기본 아이템이 안정적으로 받쳐줌' },
          { label: '하의', value: 77, highlight: '비율은 좋지만 변주 여지 있음' },
          { label: '아우터', value: 90, highlight: '전체 분위기를 강하게 만듦' },
          { label: '액세서리', value: 68, highlight: '포인트를 더 줄 수 있음' },
        ];

  const highlights =
    tpoFeedback.length > 0
      ? tpoFeedback
      : result.highlights.length > 0
        ? result.highlights
        : [
            '출근용으로는 충분히 단정하고, 데이트용으로는 한 끗이 부족합니다.',
            '낮보다 밤에 더 잘 보이는 조합입니다.',
            '사진보다 실물에서 더 강한 스타일입니다.',
          ];

  const recommendations =
    result.recommendations.length > 0
      ? result.recommendations
      : [
          '포인트 목걸이 하나로 목선 비율을 더 정리하기',
          '톤온톤 가방으로 전체 룩의 고급감 올리기',
          '신발은 광택보다 실루엣 정리에 집중하기',
        ];

  const celebMetrics =
    celebName
      ? [
          { label: '매치 셀럽', value: celebName, note: celebImage || '' },
          ...(celebDescription ? [{ label: '매치 포인트', value: celebDescription, note: '' }] : []),
        ]
      : result.metrics.length >= 10
        ? result.metrics.slice(8, 10)
        : [
            { label: '매치 이미지', value: '세련된 미니멀', note: '깔끔한 선이 강점' },
            { label: '매치 포인트', value: '차분한 자신감', note: '과하지 않은 존재감' },
          ];

  const luckyItems =
    rawStyleKeywords.length > 0
      ? rawStyleKeywords
      : result.luckyItems.length > 0
        ? result.luckyItems
        : ['미니멀', '정돈', '선명한 비율', 'TPO 적합'];

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <HeroCard emoji="👗" title={meta.title} description={summary} chips={chips} />

      <SectionCard title="스타일 점수">
        <MetricGrid items={scoreMetrics} />
      </SectionCard>

      {/* ============================================================ */}
      {/*  Outfit Items evaluation from raw API                         */}
      {/* ============================================================ */}
      {hasRaw && outfitItems.length > 0 ? (
        <SectionCard title="아이템 분석" description="착장 아이템별 평가입니다.">
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {outfitItems.map((item, index) => {
              const it = obj(item);
              const itemName = str(it.name ?? it.title ?? it.item, `아이템 ${index + 1}`);
              const itemCategory = str(it.category ?? it.type);
              const itemScore = num(it.score ?? it.rating, 0);
              const itemFeedback = str(it.feedback ?? it.description ?? it.comment);
              const itemTags = strArr(it.tags ?? it.keywords);

              return (
                <Card
                  key={`outfit-item-${index}`}
                  style={{
                    backgroundColor: fortuneTheme.colors.surfaceSecondary,
                    gap: fortuneTheme.spacing.sm,
                  }}
                >
                  <View
                    style={{
                      flexDirection: 'row',
                      justifyContent: 'space-between',
                      alignItems: 'center',
                    }}
                  >
                    <AppText variant="heading4">{itemName}</AppText>
                    {itemScore > 0 ? (
                      <AppText variant="labelLarge" color={fortuneTheme.colors.accentSecondary}>
                        {itemScore}점
                      </AppText>
                    ) : null}
                  </View>
                  {itemCategory ? (
                    <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                      {itemCategory}
                    </AppText>
                  ) : null}
                  {itemFeedback ? (
                    <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                      {itemFeedback}
                    </AppText>
                  ) : null}
                  {itemTags.length > 0 ? <KeywordPills keywords={itemTags} /> : null}
                </Card>
              );
            })}
          </View>
        </SectionCard>
      ) : (
        <SectionCard title="카테고리 레일">
          <StatRail items={categoryItems} />
        </SectionCard>
      )}

      {/* ============================================================ */}
      {/*  Color Analysis from raw API                                  */}
      {/* ============================================================ */}
      {hasRaw && hasColorAnalysis && (
        <SectionCard title="컬러 분석" description="착장 컬러 하모니 분석입니다.">
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {seasonalType ? (
              <Card
                style={{
                  backgroundColor: fortuneTheme.colors.backgroundTertiary,
                  alignItems: 'center',
                  gap: fortuneTheme.spacing.xs,
                  paddingVertical: fortuneTheme.spacing.lg,
                }}
              >
                <AppText variant="heading4" color={fortuneTheme.colors.accentSecondary}>
                  {seasonalType}
                </AppText>
                <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                  퍼스널 컬러
                </AppText>
              </Card>
            ) : null}
            {colorHarmony ? (
              <View style={{ gap: fortuneTheme.spacing.xs }}>
                <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                  컬러 하모니
                </AppText>
                <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                  {colorHarmony}
                </AppText>
              </View>
            ) : null}
            {mainColors.length > 0 ? (
              <View style={{ gap: fortuneTheme.spacing.xs }}>
                <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                  메인 컬러
                </AppText>
                <KeywordPills keywords={mainColors} />
              </View>
            ) : null}
            {accentColors.length > 0 ? (
              <View style={{ gap: fortuneTheme.spacing.xs }}>
                <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
                  액센트 컬러
                </AppText>
                <KeywordPills keywords={accentColors} />
              </View>
            ) : null}
            {colorAdvice ? (
              <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                {colorAdvice}
              </AppText>
            ) : null}
          </View>
        </SectionCard>
      )}

      {/* Category rail fallback when outfit items and color analysis are both missing */}
      {hasRaw && outfitItems.length > 0 && !hasColorAnalysis && (
        <SectionCard title="카테고리 레일">
          <StatRail items={categoryItems} />
        </SectionCard>
      )}

      <SectionCard title="TPO 피드백">
        <BulletList items={highlights} />
      </SectionCard>

      {/* ============================================================ */}
      {/*  Style Recommendations from raw API                           */}
      {/* ============================================================ */}
      {hasRaw && styleRecs.length > 0 ? (
        <SectionCard title="추천 아이템" description="스타일 완성도를 올려줄 제안입니다.">
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {styleRecs.map((rec, index) => {
              const r = obj(rec);
              const recName = str(r.name ?? r.title ?? r.item, `추천 ${index + 1}`);
              const recCategory = str(r.category ?? r.type);
              const recReason = str(r.reason ?? r.description ?? r.why);
              const recTags = strArr(r.tags ?? r.keywords ?? r.styles);

              return (
                <Card
                  key={`style-rec-${index}`}
                  style={{
                    backgroundColor: fortuneTheme.colors.surfaceSecondary,
                    gap: fortuneTheme.spacing.sm,
                  }}
                >
                  <View
                    style={{
                      flexDirection: 'row',
                      justifyContent: 'space-between',
                      alignItems: 'center',
                    }}
                  >
                    <AppText variant="heading4">{recName}</AppText>
                    {recCategory ? (
                      <AppText variant="labelMedium" color={fortuneTheme.colors.accentSecondary}>
                        {recCategory}
                      </AppText>
                    ) : null}
                  </View>
                  {recReason ? (
                    <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                      {recReason}
                    </AppText>
                  ) : null}
                  {recTags.length > 0 ? <KeywordPills keywords={recTags} /> : null}
                </Card>
              );
            })}
          </View>
        </SectionCard>
      ) : (
        <SectionCard title="추천 아이템">
          <BulletList items={recommendations} />
        </SectionCard>
      )}

      <SectionCard title="셀럽 매치">
        <MetricGrid items={celebMetrics} />
      </SectionCard>

      <SectionCard title="스타일 키워드">
        <KeywordPills keywords={luckyItems} />
      </SectionCard>

      {result.hasApiData && result.specialTip && (
        <SectionCard title="스타일 조언">
          <InsetQuote text={result.specialTip} />
        </SectionCard>
      )}
    </View>
  );
}

export const ResultBatchD = {
  WealthResult,
  TalentResult,
  ExerciseResult,
  TarotResult,
  GameEnhanceResult,
  OotdEvaluationResult,
};
