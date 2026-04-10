import { View } from 'react-native';

import { AppText } from '../../components/app-text';
import { Card } from '../../components/card';
import { fortuneTheme } from '../../lib/theme';
import type { Element, ManseryeokLocalData } from '../../lib/manseryeok-local';

// ---------------------------------------------------------------------------
// Element color mapping
// ---------------------------------------------------------------------------

const ELEMENT_COLORS: Record<Element, string> = {
  목: '#4CAF50',
  화: '#F44336',
  토: '#FF9800',
  금: '#C0C0C0',
  수: '#2196F3',
};

const ELEMENT_BG: Record<Element, string> = {
  목: 'rgba(76,175,80,0.12)',
  화: 'rgba(244,67,54,0.12)',
  토: 'rgba(255,152,0,0.12)',
  금: 'rgba(192,192,192,0.12)',
  수: 'rgba(33,150,243,0.12)',
};

const ELEMENT_HANJA: Record<Element, string> = {
  목: '木',
  화: '火',
  토: '土',
  금: '金',
  수: '水',
};

function elementColor(el: Element): string {
  return ELEMENT_COLORS[el];
}

function elementBg(el: Element): string {
  return ELEMENT_BG[el];
}

// ---------------------------------------------------------------------------
// Hero section — Day Pillar is THE star
// ---------------------------------------------------------------------------

function HeroSection({ data }: { data: ManseryeokLocalData }) {
  const { dayPillar, solarDate, lunarDate } = data;
  const stemColor = elementColor(dayPillar.stem.element);
  const branchColor = elementColor(dayPillar.branch.element);

  return (
    <Card
      style={{
        backgroundColor: fortuneTheme.colors.backgroundTertiary,
        gap: fortuneTheme.spacing.lg,
        padding: fortuneTheme.spacing.lg,
        borderWidth: 0,
      }}
    >
      {/* Header row: title + date */}
      <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start' }}>
        <View style={{ gap: 2 }}>
          <AppText variant="labelSmall" color={fortuneTheme.colors.accentSecondary}>
            만세력 萬歲曆
          </AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textPrimary}>
            {solarDate}
          </AppText>
        </View>
        <View
          style={{
            backgroundColor: fortuneTheme.colors.surfaceSecondary,
            borderRadius: fortuneTheme.radius.chip,
            paddingHorizontal: 12,
            paddingVertical: 6,
          }}
        >
          <AppText variant="labelSmall" color={fortuneTheme.colors.accentTertiary}>
            {lunarDate}
          </AppText>
        </View>
      </View>

      {/* Day Pillar HERO — two large hanja boxes side by side */}
      <View style={{ alignItems: 'center', gap: fortuneTheme.spacing.md, paddingVertical: fortuneTheme.spacing.sm }}>
        <View style={{ flexDirection: 'row', gap: fortuneTheme.spacing.md, alignItems: 'center' }}>
          {/* Stem (천간) box */}
          <View style={{ alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
            <View
              style={{
                width: 88,
                height: 88,
                borderRadius: fortuneTheme.radius.xl,
                backgroundColor: stemColor,
                alignItems: 'center',
                justifyContent: 'center',
                shadowColor: stemColor,
                shadowOpacity: 0.4,
                shadowRadius: 16,
                shadowOffset: { width: 0, height: 4 },
                elevation: 8,
              }}
            >
              <AppText
                style={{ fontSize: 44, lineHeight: 52, fontWeight: '800', color: '#FFFFFF' }}
              >
                {dayPillar.stem.hanja}
              </AppText>
            </View>
            <AppText variant="labelSmall" color={stemColor}>
              {dayPillar.stem.korean} · {dayPillar.stem.element}
            </AppText>
            <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
              천간
            </AppText>
          </View>

          {/* Branch (지지) box */}
          <View style={{ alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
            <View
              style={{
                width: 88,
                height: 88,
                borderRadius: fortuneTheme.radius.xl,
                backgroundColor: branchColor,
                alignItems: 'center',
                justifyContent: 'center',
                shadowColor: branchColor,
                shadowOpacity: 0.4,
                shadowRadius: 16,
                shadowOffset: { width: 0, height: 4 },
                elevation: 8,
              }}
            >
              <AppText
                style={{ fontSize: 44, lineHeight: 52, fontWeight: '800', color: '#FFFFFF' }}
              >
                {dayPillar.branch.hanja}
              </AppText>
            </View>
            <AppText variant="labelSmall" color={branchColor}>
              {dayPillar.branch.korean} · {dayPillar.branch.element}
            </AppText>
            <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
              지지
            </AppText>
          </View>
        </View>

        {/* Korean reading + animal */}
        <View style={{ alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
          <AppText variant="heading2" color={fortuneTheme.colors.textPrimary}>
            {dayPillar.stem.korean}{dayPillar.branch.korean}일
          </AppText>
          <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
            {dayPillar.stem.hanja}{dayPillar.branch.hanja}日 · {dayPillar.branch.animal}띠
          </AppText>
        </View>
      </View>
    </Card>
  );
}

// ---------------------------------------------------------------------------
// Solar Term progress bar — enhanced contrast
// ---------------------------------------------------------------------------

function SolarTermSection({ data }: { data: ManseryeokLocalData }) {
  const { solarTerm } = data;
  const clampedProgress = Math.max(0, Math.min(100, solarTerm.progress));

  return (
    <Card
      style={{
        backgroundColor: fortuneTheme.colors.backgroundTertiary,
        borderWidth: 0,
        gap: fortuneTheme.spacing.md,
      }}
    >
      {/* Header row */}
      <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' }}>
        <AppText variant="labelLarge" color={fortuneTheme.colors.textPrimary}>절기 진행</AppText>
        <View
          style={{
            backgroundColor: fortuneTheme.colors.surfaceSecondary,
            borderRadius: fortuneTheme.radius.chip,
            paddingHorizontal: 10,
            paddingVertical: 4,
          }}
        >
          <AppText variant="caption" color={fortuneTheme.colors.accentSecondary}>
            {solarTerm.season}
          </AppText>
        </View>
      </View>

      {/* Term labels */}
      <View
        style={{
          flexDirection: 'row',
          justifyContent: 'space-between',
          alignItems: 'center',
        }}
      >
        <View style={{ alignItems: 'flex-start', gap: 2 }}>
          <AppText variant="heading3" color={fortuneTheme.colors.textPrimary}>{solarTerm.current}</AppText>
          <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>현재 절기</AppText>
        </View>
        <View
          style={{
            backgroundColor: 'rgba(139,123,232,0.15)',
            borderRadius: fortuneTheme.radius.chip,
            paddingHorizontal: 10,
            paddingVertical: 4,
          }}
        >
          <AppText variant="labelSmall" color={fortuneTheme.colors.ctaBackground}>
            {solarTerm.daysRemaining}일 남음
          </AppText>
        </View>
        <View style={{ alignItems: 'flex-end', gap: 2 }}>
          <AppText variant="heading3" color={fortuneTheme.colors.textTertiary}>{solarTerm.next}</AppText>
          <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>다음 절기</AppText>
        </View>
      </View>

      {/* Progress bar — thicker, with glow */}
      <View
        style={{
          backgroundColor: fortuneTheme.colors.surfaceSecondary,
          borderRadius: fortuneTheme.radius.full,
          height: 12,
          overflow: 'hidden',
        }}
      >
        <View
          style={{
            backgroundColor: fortuneTheme.colors.ctaBackground,
            borderRadius: fortuneTheme.radius.full,
            height: '100%',
            width: `${clampedProgress}%`,
            shadowColor: fortuneTheme.colors.ctaBackground,
            shadowOpacity: 0.6,
            shadowRadius: 8,
            shadowOffset: { width: 0, height: 0 },
          }}
        />
      </View>
    </Card>
  );
}

// ---------------------------------------------------------------------------
// Daily Five-Element Energy — prominent element colors
// ---------------------------------------------------------------------------

function DailyEnergySection({ data }: { data: ManseryeokLocalData }) {
  const { dailyEnergy } = data;

  return (
    <Card
      style={{
        backgroundColor: fortuneTheme.colors.backgroundTertiary,
        borderWidth: 0,
        gap: fortuneTheme.spacing.md,
      }}
    >
      <AppText variant="labelLarge" color={fortuneTheme.colors.textPrimary}>오행 에너지</AppText>

      <View style={{ flexDirection: 'row', gap: fortuneTheme.spacing.sm }}>
        {/* Dominant */}
        <View
          style={{
            flex: 1,
            backgroundColor: elementBg(dailyEnergy.dominant),
            borderRadius: fortuneTheme.radius.lg,
            padding: fortuneTheme.spacing.md,
            gap: fortuneTheme.spacing.sm,
            borderWidth: 1,
            borderColor: `${elementColor(dailyEnergy.dominant)}33`,
          }}
        >
          <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
            주도 원소
          </AppText>
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
            <View
              style={{
                width: 36,
                height: 36,
                borderRadius: fortuneTheme.radius.md,
                backgroundColor: elementColor(dailyEnergy.dominant),
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <AppText style={{ fontSize: 18, fontWeight: '800', color: '#FFFFFF' }}>
                {ELEMENT_HANJA[dailyEnergy.dominant]}
              </AppText>
            </View>
            <AppText variant="heading2" color={elementColor(dailyEnergy.dominant)}>
              {dailyEnergy.dominant}
            </AppText>
          </View>
        </View>

        {/* Supporting */}
        <View
          style={{
            flex: 1,
            backgroundColor: elementBg(dailyEnergy.supporting),
            borderRadius: fortuneTheme.radius.lg,
            padding: fortuneTheme.spacing.md,
            gap: fortuneTheme.spacing.sm,
            borderWidth: 1,
            borderColor: `${elementColor(dailyEnergy.supporting)}33`,
          }}
        >
          <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
            보조 원소
          </AppText>
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
            <View
              style={{
                width: 36,
                height: 36,
                borderRadius: fortuneTheme.radius.md,
                backgroundColor: elementColor(dailyEnergy.supporting),
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <AppText style={{ fontSize: 18, fontWeight: '800', color: '#FFFFFF' }}>
                {ELEMENT_HANJA[dailyEnergy.supporting]}
              </AppText>
            </View>
            <AppText variant="heading2" color={elementColor(dailyEnergy.supporting)}>
              {dailyEnergy.supporting}
            </AppText>
          </View>
        </View>
      </View>

      {/* Description */}
      <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
        {dailyEnergy.description}
      </AppText>
    </Card>
  );
}

// ---------------------------------------------------------------------------
// Week strip — today strongly highlighted
// ---------------------------------------------------------------------------

function WeekStripSection({ data }: { data: ManseryeokLocalData }) {
  const { weekStrip } = data;

  return (
    <Card
      style={{
        backgroundColor: fortuneTheme.colors.backgroundTertiary,
        borderWidth: 0,
        gap: fortuneTheme.spacing.md,
      }}
    >
      <AppText variant="labelLarge" color={fortuneTheme.colors.textPrimary}>주간 일진</AppText>

      <View
        style={{
          flexDirection: 'row',
          justifyContent: 'space-between',
          gap: 4,
        }}
      >
        {weekStrip.map((day) => {
          const isToday = day.isToday;

          return (
            <View
              key={`${day.dayLabel}-${day.dateNumber}`}
              style={{
                flex: 1,
                alignItems: 'center',
                gap: 6,
                paddingVertical: fortuneTheme.spacing.sm,
                paddingHorizontal: 2,
                borderRadius: fortuneTheme.radius.md,
                backgroundColor: isToday
                  ? fortuneTheme.colors.ctaBackground
                  : 'transparent',
                ...(isToday
                  ? {
                      shadowColor: fortuneTheme.colors.ctaBackground,
                      shadowOpacity: 0.5,
                      shadowRadius: 12,
                      shadowOffset: { width: 0, height: 2 },
                      elevation: 6,
                    }
                  : {}),
              }}
            >
              <AppText
                variant="caption"
                color={
                  isToday
                    ? '#FFFFFF'
                    : fortuneTheme.colors.textTertiary
                }
              >
                {day.dayLabel}
              </AppText>

              <AppText
                style={{
                  fontSize: 16,
                  fontWeight: isToday ? '800' : '500',
                  color: isToday ? '#FFFFFF' : fortuneTheme.colors.textSecondary,
                }}
              >
                {day.dateNumber}
              </AppText>

              <AppText
                variant="caption"
                color={
                  isToday
                    ? 'rgba(255,255,255,0.85)'
                    : fortuneTheme.colors.textTertiary
                }
              >
                {day.iljin}
              </AppText>
            </View>
          );
        })}
      </View>
    </Card>
  );
}

// ---------------------------------------------------------------------------
// Main exported component
// ---------------------------------------------------------------------------

export function ManseryeokCard({ data }: { data: ManseryeokLocalData }) {
  return (
    <View style={{ gap: fortuneTheme.spacing.sm }}>
      <HeroSection data={data} />
      <SolarTermSection data={data} />
      <DailyEnergySection data={data} />
      <WeekStripSection data={data} />
    </View>
  );
}
