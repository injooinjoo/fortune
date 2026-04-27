/**
 * LuckCycleTimeline — 대운 타임라인 가로 스크롤.
 *
 * 벤치마크 parity: 각 대운 카드에 아래 세로 구성 표시
 *   - 시작 나이
 *   - 천간 십성
 *   - 천간 한자 스탬프
 *   - 지지 한자 스탬프
 *   - 지지 십성
 *   - 12운성
 *   - 12신살 (년지 기준)
 *   - 12신살 (일지 기준)
 */

import { ScrollView, View } from 'react-native';

import {
  getStemByKr,
  getBranchByKr,
  type LuckCyclesResult,
} from '@fortune/saju-engine';

import { AppText } from '../../../components/app-text';
import { fortuneTheme } from '../../../lib/theme';
import { StemBranchStamp } from './manseryeok-cells';

interface LuckCycleTimelineProps {
  data: LuckCyclesResult;
  /** 현재 나이 — 강조 표시용 */
  currentAge?: number;
  onTermPress?: (term: string) => void;
}

export function LuckCycleTimeline({
  data,
  currentAge,
  onTermPress,
}: LuckCycleTimelineProps) {
  if (!data.cycles || data.cycles.length === 0) {
    return null;
  }

  // 벤치마크처럼 큰 나이부터 역순 표시
  const ordered = [...data.cycles].reverse();

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
          대운
        </AppText>
        <AppText variant="labelSmall" color={fortuneTheme.colors.textSecondary}>
          대운수 {data.startAge}
        </AppText>
        <AppText variant="labelSmall" color={fortuneTheme.colors.textSecondary}>
          · {data.direction}
        </AppText>
        {currentAge !== undefined ? (
          <AppText variant="labelSmall" color={fortuneTheme.colors.textTertiary}>
            · 현재 {currentAge}세
          </AppText>
        ) : null}
      </View>

      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={{ gap: 10, paddingHorizontal: 4, paddingVertical: 4 }}
      >
        {ordered.map((cycle, index) => {
          const stem = getStemByKr(cycle.stem);
          const branch = getBranchByKr(cycle.branch);
          const isCurrent =
            currentAge !== undefined &&
            currentAge >= cycle.startAge &&
            currentAge < cycle.startAge + 10;

          return (
            <View
              key={`${cycle.startAge}-${index}`}
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
                {cycle.startAge}
              </AppText>
              <AppText
                variant="labelSmall"
                color={fortuneTheme.colors.textPrimary}
                onPress={onTermPress ? () => onTermPress(cycle.tenGod) : undefined}
              >
                {cycle.tenGod}
              </AppText>
              <StemBranchStamp
                hanja={stem.hanja}
                element={stem.element}
                size={40}
              />
              <StemBranchStamp
                hanja={branch.hanja}
                element={branch.element}
                size={40}
              />
              {cycle.branchTenGod ? (
                <AppText
                  variant="caption"
                  color={fortuneTheme.colors.textSecondary}
                  onPress={
                    onTermPress ? () => onTermPress(cycle.branchTenGod ?? '') : undefined
                  }
                >
                  {cycle.branchTenGod}
                </AppText>
              ) : null}
              <AppText
                variant="caption"
                color={fortuneTheme.colors.textTertiary}
                onPress={onTermPress ? () => onTermPress(cycle.twelveStage) : undefined}
              >
                {cycle.twelveStage}
              </AppText>
              {cycle.twelveSpirit ? (
                <AppText
                  variant="caption"
                  color={fortuneTheme.colors.ctaBackground}
                  onPress={
                    onTermPress ? () => onTermPress(cycle.twelveSpirit ?? '') : undefined
                  }
                  style={{ fontWeight: '600' }}
                >
                  {cycle.twelveSpirit}
                </AppText>
              ) : null}
              {cycle.twelveSpiritByDay ? (
                <AppText
                  variant="caption"
                  color={fortuneTheme.colors.textSecondary}
                  onPress={
                    onTermPress
                      ? () => onTermPress(cycle.twelveSpiritByDay ?? '')
                      : undefined
                  }
                >
                  {cycle.twelveSpiritByDay}
                </AppText>
              ) : null}
            </View>
          );
        })}
      </ScrollView>
    </View>
  );
}
