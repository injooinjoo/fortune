/**
 * AnnualCycleTimeline — 세운 7년 가로 스크롤.
 *
 * 각 세운 카드: 년도 / 천간 십성 / 간지 스탬프×2 / 지지 십성 / 12운성 / 12신살×2
 */

import { ScrollView, View } from 'react-native';

import {
  getStemByKr,
  getBranchByKr,
  type Element,
  type YearlyLuck,
} from '@fortune/saju-engine';

import { AppText } from '../../../components/app-text';
import { fortuneTheme } from '../../../lib/theme';
import { StemBranchStamp } from './manseryeok-cells';

interface AnnualCycleTimelineProps {
  cycles: YearlyLuck[];
  /** 현재 강조 년도 */
  currentYear?: number;
  /** 표시 창 크기 (기본 7 — 현재 년도 기준 ±3) */
  window?: number;
  onTermPress?: (term: string) => void;
}

export function AnnualCycleTimeline({
  cycles,
  currentYear,
  window = 7,
  onTermPress,
}: AnnualCycleTimelineProps) {
  if (!cycles || cycles.length === 0) {
    return null;
  }

  // 현재 년도를 중심으로 window 길이만큼 슬라이스
  let shown: YearlyLuck[] = cycles;
  if (currentYear !== undefined) {
    const centerIdx = cycles.findIndex((c) => c.year === currentYear);
    if (centerIdx >= 0) {
      const half = Math.floor(window / 2);
      const start = Math.max(0, centerIdx - half);
      const end = Math.min(cycles.length, start + window);
      shown = cycles.slice(start, end);
    } else {
      shown = cycles.slice(0, window);
    }
  }

  return (
    <View style={{ marginTop: 20 }}>
      <View
        style={{
          paddingHorizontal: 4,
          marginBottom: 10,
          flexDirection: 'row',
          alignItems: 'baseline',
          flexWrap: 'wrap',
          gap: 8,
        }}
      >
        <AppText variant="heading4" color={fortuneTheme.colors.textPrimary}>
          세운
        </AppText>
        {currentYear !== undefined ? (
          <AppText variant="labelSmall" color={fortuneTheme.colors.textSecondary}>
            {currentYear}년 기준
          </AppText>
        ) : null}
      </View>

      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={{ gap: 10, paddingHorizontal: 4, paddingVertical: 4 }}
      >
        {shown.map((y) => {
          const stem = getStemByKr(y.stem);
          const branch = getBranchByKr(y.branch);
          const isCurrent = currentYear !== undefined && y.year === currentYear;
          return (
            <CycleCard
              key={y.year}
              label={`${y.year}`}
              tenGod={y.tenGod}
              branchTenGod={y.branchTenGod}
              stemHanja={stem.hanja}
              stemElement={stem.element}
              branchHanja={branch.hanja}
              branchElement={branch.element}
              twelveStage={y.twelveStage}
              twelveSpirit={y.twelveSpirit}
              twelveSpiritByDay={y.twelveSpiritByDay}
              isCurrent={isCurrent}
              onTermPress={onTermPress}
            />
          );
        })}
      </ScrollView>
    </View>
  );
}

interface CycleCardProps {
  label: string;
  tenGod: string;
  branchTenGod?: string;
  stemHanja: string;
  stemElement: Element;
  branchHanja: string;
  branchElement: Element;
  twelveStage?: string;
  twelveSpirit?: string;
  twelveSpiritByDay?: string;
  isCurrent?: boolean;
  onTermPress?: (term: string) => void;
}

// 공용 카드 — 월운에서도 재사용
export function CycleCard({
  label,
  tenGod,
  branchTenGod,
  stemHanja,
  stemElement,
  branchHanja,
  branchElement,
  twelveStage,
  twelveSpirit,
  twelveSpiritByDay,
  isCurrent,
  onTermPress,
}: CycleCardProps) {
  return (
    <View
      style={{
        alignItems: 'center',
        gap: 4,
        minWidth: 60,
        paddingHorizontal: 6,
        paddingVertical: 8,
        borderRadius: fortuneTheme.radius.sm,
        backgroundColor: isCurrent
          ? fortuneTheme.colors.surfaceSecondary
          : 'transparent',
        borderWidth: isCurrent ? 1 : 0,
        borderColor: isCurrent
          ? fortuneTheme.colors.ctaBackground
          : 'transparent',
      }}
    >
      <AppText
        variant="labelSmall"
        color={
          isCurrent
            ? fortuneTheme.colors.ctaBackground
            : fortuneTheme.colors.textSecondary
        }
        style={{ fontWeight: '700' }}
      >
        {label}
      </AppText>
      <AppText
        variant="labelSmall"
        color={fortuneTheme.colors.textPrimary}
        onPress={onTermPress ? () => onTermPress(tenGod) : undefined}
      >
        {tenGod}
      </AppText>
      <StemBranchStamp hanja={stemHanja} element={stemElement} size={40} />
      <StemBranchStamp hanja={branchHanja} element={branchElement} size={40} />
      {branchTenGod ? (
        <AppText
          variant="caption"
          color={fortuneTheme.colors.textSecondary}
          onPress={onTermPress ? () => onTermPress(branchTenGod) : undefined}
        >
          {branchTenGod}
        </AppText>
      ) : null}
      {twelveStage ? (
        <AppText
          variant="caption"
          color={fortuneTheme.colors.textTertiary}
          onPress={onTermPress ? () => onTermPress(twelveStage) : undefined}
        >
          {twelveStage}
        </AppText>
      ) : null}
      {twelveSpirit ? (
        <AppText
          variant="caption"
          color={fortuneTheme.colors.ctaBackground}
          onPress={onTermPress ? () => onTermPress(twelveSpirit) : undefined}
          style={{ fontWeight: '600' }}
        >
          {twelveSpirit}
        </AppText>
      ) : null}
      {twelveSpiritByDay ? (
        <AppText
          variant="caption"
          color={fortuneTheme.colors.textSecondary}
          onPress={
            onTermPress ? () => onTermPress(twelveSpiritByDay) : undefined
          }
        >
          {twelveSpiritByDay}
        </AppText>
      ) : null}
    </View>
  );
}
