/**
 * ProfileSajuSummaryScreen — "내 만세력" 대시보드.
 *
 * 벤치마크 parity 구성:
 *  1. MySajuActions
 *  2. HeroManseryeok (4주 + 각 기둥 내 15행)
 *  3. YearSwitcher (세운/월운 기준 년도 변경)
 *  4. LuckCycleTimeline (대운)
 *  5. AnnualCycleTimeline (세운 7년)
 *  6. MonthlyCycleTimeline (월운 12개월)
 *  7. ManseryeokInterpretation
 */

import { useMemo, useState } from 'react';
import { useRouter } from 'expo-router';
import { Pressable, View } from 'react-native';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { RouteBackHeader } from '../components/route-back-header';
import { Screen } from '../components/screen';
import { HeroManseryeok } from '../features/fortune-results/heroes/hero-manseryeok';
import { LuckCycleTimeline } from '../features/fortune-results/primitives/luck-cycle-timeline';
import { AnnualCycleTimeline } from '../features/fortune-results/primitives/annual-cycle-timeline';
import { MonthlyCycleTimeline } from '../features/fortune-results/primitives/monthly-cycle-timeline';
import { YearSwitcher } from '../features/fortune-results/primitives/year-switcher';
import { ManseryeokInterpretation } from '../features/fortune-results/primitives/manseryeok-interpretation';
import { MySajuActions } from '../features/fortune-results/primitives/my-saju-actions';
import { useTermInfo } from '../features/fortune-results/primitives/term-info-sheet';
import { useMySaju } from '../hooks/use-saju';
import { fortuneTheme } from '../lib/theme';
import { useMobileAppState } from '../providers/mobile-app-state-provider';

function computeAge(birthDate: string): number {
  const now = new Date();
  const parts = birthDate.split('-');
  if (parts.length !== 3) return 0;
  const [yStr, mStr, dStr] = parts;
  const y = Number.parseInt(yStr ?? '', 10);
  const m = Number.parseInt(mStr ?? '', 10);
  const d = Number.parseInt(dStr ?? '', 10);
  if (!Number.isFinite(y) || !Number.isFinite(m) || !Number.isFinite(d)) {
    return 0;
  }
  let age = now.getFullYear() - y;
  const beforeBirthday =
    now.getMonth() + 1 < m ||
    (now.getMonth() + 1 === m && now.getDate() < d);
  if (beforeBirthday) age -= 1;
  return Math.max(0, age);
}

function formatBirthLabel(birthDate: string, birthTime: string): string {
  const parts = birthDate.split('-');
  const time = birthTime && birthTime.length > 0 ? birthTime : '00:00';
  if (parts.length !== 3) return `${birthDate} ${time}`;
  const [y, m, d] = parts;
  return `(양력) ${y}년 ${m}월 ${d}일 ${time}`;
}

export function ProfileSajuSummaryScreen() {
  const router = useRouter();
  const { state } = useMobileAppState();
  const term = useTermInfo();

  const profile = state.profile;
  const birthDate = (profile.birthDate ?? '').trim();
  const birthTime = (profile.birthTime ?? '').trim();
  const birthReady =
    birthDate.length > 0 && /^\d{4}-\d{2}-\d{2}$/.test(birthDate);

  const [refYear, setRefYear] = useState<number>(() => new Date().getFullYear());
  const saju = useMySaju(useMemo(() => ({ referenceYear: refYear }), [refYear]));

  if (!birthReady) {
    return (
      <Screen
        header={<RouteBackHeader fallbackHref="/profile" label="내 만세력" />}
      >
        <Card>
          <View style={{ gap: 8, paddingVertical: 6 }}>
            <AppText
              variant="heading3"
              color={fortuneTheme.colors.textPrimary}
            >
              생년월일이 필요해요
            </AppText>
            <AppText
              variant="bodyMedium"
              color={fortuneTheme.colors.textSecondary}
            >
              프로필 편집에서 생년월일과 태어난 시간을 입력하면 만세력을 볼 수
              있어요.
            </AppText>
            <Pressable
              onPress={() => router.push('/profile/edit')}
              style={({ pressed }) => ({
                marginTop: 8,
                paddingVertical: 12,
                borderRadius: fortuneTheme.radius.md,
                backgroundColor: fortuneTheme.colors.ctaBackground,
                alignItems: 'center',
                opacity: pressed ? 0.7 : 1,
              })}
            >
              <AppText
                variant="labelLarge"
                color={fortuneTheme.colors.ctaForeground}
              >
                프로필 편집하기
              </AppText>
            </Pressable>
          </View>
        </Card>
      </Screen>
    );
  }

  if (!saju) {
    return (
      <Screen
        header={<RouteBackHeader fallbackHref="/profile" label="내 만세력" />}
      >
        <Card>
          <View style={{ gap: 8, paddingVertical: 6 }}>
            <AppText variant="heading3" color={fortuneTheme.colors.textPrimary}>
              만세력 계산 중 문제가 발생했어요
            </AppText>
            <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
              입력된 생년월일시: {birthDate} {birthTime || '시간 미입력'}
            </AppText>
            <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
              프로필 편집에서 시간을 다시 저장해 보시거나, 앱을 재시작해 주세요.
            </AppText>
            <Pressable
              onPress={() => router.push('/profile/edit')}
              style={({ pressed }) => ({
                marginTop: 8,
                paddingVertical: 12,
                borderRadius: fortuneTheme.radius.md,
                backgroundColor: fortuneTheme.colors.ctaBackground,
                alignItems: 'center',
                opacity: pressed ? 0.7 : 1,
              })}
            >
              <AppText variant="labelLarge" color={fortuneTheme.colors.ctaForeground}>
                프로필 편집하기
              </AppText>
            </Pressable>
          </View>
        </Card>
      </Screen>
    );
  }

  const age = computeAge(birthDate);
  const birthLabel = formatBirthLabel(birthDate, birthTime);
  const name = profile.displayName.trim() || '나';
  const currentMonth = new Date().getMonth() + 1;

  return (
    <Screen
      header={<RouteBackHeader fallbackHref="/profile" label="내 만세력" />}
    >
      <MySajuActions saju={saju} />
      <HeroManseryeok
        data={saju}
        profile={{ name, age, birthLabel }}
        onTermPress={term.open}
      />
      <LuckCycleTimeline
        data={saju.luckCycles}
        currentAge={age}
        onTermPress={term.open}
      />
      <YearSwitcher year={refYear} onChange={setRefYear} label="세운·월운 기준" />
      <AnnualCycleTimeline
        cycles={saju.luckCycles.yearlyLucks}
        currentYear={refYear}
        window={7}
        onTermPress={term.open}
      />
      <MonthlyCycleTimeline
        cycles={saju.luckCycles.monthlyLucks}
        year={refYear}
        currentMonth={refYear === new Date().getFullYear() ? currentMonth : undefined}
        onTermPress={term.open}
      />
      <ManseryeokInterpretation sajuData={saju} />
      {term.sheet}
    </Screen>
  );
}
