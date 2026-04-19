import type { ReactNode } from 'react';

import { Ionicons } from '@expo/vector-icons';
import { Pressable, View } from 'react-native';

import { confirmAction } from '../lib/haptics';
import { fortuneTheme } from '../lib/theme';
import { AppText } from './app-text';
import { PrimaryButton } from './primary-button';
import { Screen } from './screen';

/**
 * Ondo onboarding scaffold — back + progress + skip header, title/caption,
 * content area, and a pinned Pill CTA at the bottom. Leans on the production
 * `Screen` wrapper for SafeArea + scroll behavior; do not duplicate that here.
 */
interface OnboardingShellProps {
  children: ReactNode;
  step: number;
  total: number;
  title: string;
  caption?: string;
  nextLabel?: string;
  nextDisabled?: boolean;
  nextLoading?: boolean;
  onNext?: () => void;
  onBack?: () => void;
  skipLabel?: string;
  onSkip?: () => void;
}

const BACK_HIT_SIZE = 32;
const SKIP_MIN_WIDTH = 48;

export function OnboardingShell({
  children,
  step,
  total,
  title,
  caption,
  nextLabel = '다음',
  nextDisabled,
  nextLoading,
  onNext,
  onBack,
  skipLabel = '건너뛰기',
  onSkip,
}: OnboardingShellProps) {
  const pct = Math.max(
    0,
    Math.min(100, total > 0 ? (step / total) * 100 : 0),
  );

  const handleBack = () => {
    confirmAction();
    onBack?.();
  };
  const handleSkip = () => {
    confirmAction();
    onSkip?.();
  };
  const handleNext = () => {
    confirmAction();
    onNext?.();
  };

  const header = (
    <View
      style={{
        flexDirection: 'row',
        alignItems: 'center',
        gap: fortuneTheme.spacing.md,
      }}
    >
      <Pressable
        accessibilityRole="button"
        accessibilityLabel="뒤로가기"
        disabled={!onBack}
        hitSlop={12}
        onPress={handleBack}
        style={{
          alignItems: 'center',
          height: BACK_HIT_SIZE,
          justifyContent: 'center',
          opacity: onBack ? 1 : 0,
          width: BACK_HIT_SIZE,
        }}
      >
        <Ionicons
          name="chevron-back"
          size={24}
          color={fortuneTheme.colors.textSecondary}
        />
      </Pressable>

      <View
        style={{
          backgroundColor: fortuneTheme.colors.border,
          borderRadius: fortuneTheme.radius.full,
          flex: 1,
          height: 4,
          overflow: 'hidden',
        }}
      >
        <View
          style={{
            backgroundColor: fortuneTheme.colors.accent,
            borderRadius: fortuneTheme.radius.full,
            height: '100%',
            width: `${pct}%`,
          }}
        />
      </View>

      {onSkip ? (
        <Pressable
          accessibilityRole="button"
          accessibilityLabel={skipLabel}
          hitSlop={12}
          onPress={handleSkip}
          style={{
            alignItems: 'flex-end',
            justifyContent: 'center',
            minWidth: SKIP_MIN_WIDTH,
          }}
        >
          <AppText
            variant="labelMedium"
            color={fortuneTheme.colors.textSecondary}
          >
            {skipLabel}
          </AppText>
        </Pressable>
      ) : (
        <View style={{ width: SKIP_MIN_WIDTH }} />
      )}
    </View>
  );

  const footer = (
    <PrimaryButton
      tone="primary"
      fullWidth
      disabled={nextDisabled}
      loading={nextLoading}
      onPress={handleNext}
    >
      {nextLabel}
    </PrimaryButton>
  );

  return (
    <Screen header={header} footer={footer} keyboardAvoiding>
      <View style={{ gap: fortuneTheme.spacing.sm }}>
        <AppText
          accessibilityRole="header"
          variant="displaySmall"
          color={fortuneTheme.colors.textPrimary}
          style={{ letterSpacing: -0.3 }}
        >
          {title}
        </AppText>
        {caption ? (
          <AppText
            variant="bodyMedium"
            color={fortuneTheme.colors.textSecondary}
          >
            {caption}
          </AppText>
        ) : null}
      </View>
      <View style={{ flex: 1, marginTop: fortuneTheme.spacing.lg }}>
        {children}
      </View>
    </Screen>
  );
}
