/**
 * MonthlyCycleTimeline — 월운 12개월 가로 스크롤.
 *
 * 각 월 카드: 월 / 천간 십성 / 간지 스탬프×2 / 지지 십성 / 12운성 / 12신살×2
 */

import { ScrollView, View } from 'react-native';

import {
  getStemByKr,
  getBranchByKr,
  type MonthlyLuck,
} from '@fortune/saju-engine';

import { AppText } from '../../../components/app-text';
import { fortuneTheme } from '../../../lib/theme';
import { CycleCard } from './annual-cycle-timeline';

interface MonthlyCycleTimelineProps {
  cycles: MonthlyLuck[];
  /** 기준 년도 (헤더 표시용) */
  year?: number;
  /** 현재 월 (1-12) 강조 */
  currentMonth?: number;
  onTermPress?: (term: string) => void;
}

export function MonthlyCycleTimeline({
  cycles,
  year,
  currentMonth,
  onTermPress,
}: MonthlyCycleTimelineProps) {
  if (!cycles || cycles.length === 0) {
    return null;
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
          월운
        </AppText>
        {year !== undefined ? (
          <AppText variant="labelSmall" color={fortuneTheme.colors.textSecondary}>
            {year}년
          </AppText>
        ) : null}
      </View>

      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={{ gap: 10, paddingHorizontal: 4, paddingVertical: 4 }}
      >
        {cycles.map((m) => {
          const stem = getStemByKr(m.stem);
          const branch = getBranchByKr(m.branch);
          const isCurrent = currentMonth !== undefined && m.month === currentMonth;
          return (
            <CycleCard
              key={m.month}
              label={`${m.month}월`}
              tenGod={m.tenGod}
              branchTenGod={m.branchTenGod}
              stemHanja={stem.hanja}
              stemElement={stem.element}
              branchHanja={branch.hanja}
              branchElement={branch.element}
              twelveStage={m.twelveStage}
              twelveSpirit={m.twelveSpirit}
              twelveSpiritByDay={m.twelveSpiritByDay}
              isCurrent={isCurrent}
              onTermPress={onTermPress}
            />
          );
        })}
      </ScrollView>
    </View>
  );
}
