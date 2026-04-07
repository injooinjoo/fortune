import { useEffect, useState } from 'react';

import {
  router,
  useLocalSearchParams,
  type Href,
} from 'expo-router';
import { Pressable, TextInput, View } from 'react-native';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { PrimaryButton } from '../components/primary-button';
import { RouteBackHeader } from '../components/route-back-header';
import { Screen } from '../components/screen';
import { appEnv } from '../lib/env';
import { captureError } from '../lib/error-reporting';
import { onboardingInterestOptions } from '../lib/onboarding-interest-catalog';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';
import { useMobileAppState } from '../providers/mobile-app-state-provider';

type OnboardingStepId = 'birth' | 'interest' | 'handoff';

const onboardingSteps: readonly {
  id: OnboardingStepId;
  title: string;
  description: string;
}[] = [
  {
    id: 'birth',
    title: '기본 정보',
    description: '이름과 출생 정보를 먼저 확인해요.',
  },
  {
    id: 'interest',
    title: '관심사 선택',
    description: '지금 보고 싶은 대화와 운세 방향을 골라요.',
  },
  {
    id: 'handoff',
    title: '시작 준비',
    description: '확인한 내용을 기준으로 바로 시작해요.',
  },
] as const;

function readSearchParam(
  value: string | string[] | undefined,
): string | undefined {
  return Array.isArray(value) ? value[0] : value;
}

function normalizeReturnTo(value: string | undefined) {
  return value && value.startsWith('/') ? value : '/chat';
}

function normalizeDebugStep(value: string | undefined): OnboardingStepId | null {
  if (value === 'birth' || value === 'interest' || value === 'handoff') {
    return value;
  }

  return null;
}

function normalizeInterestParam(value: string | undefined) {
  if (!value) {
    return [];
  }

  return value
    .split(',')
    .map((item) => item.trim())
    .filter((item) => item.length > 0);
}

export function OnboardingScreen() {
  const params = useLocalSearchParams<{
    returnTo?: string | string[];
    debugStep?: string | string[];
    debugName?: string | string[];
    debugBirthDate?: string | string[];
    debugBirthTime?: string | string[];
    debugInterests?: string | string[];
  }>();
  const {
    onboardingProgress,
    completeOnboarding,
    session,
    updateOnboardingProgress,
  } = useAppBootstrap();
  const { saveProfile, state, status } = useMobileAppState();
  const returnTo = normalizeReturnTo(readSearchParam(params.returnTo));
  const isDevelopment = appEnv.environment === 'development';
  const debugStep = isDevelopment
    ? normalizeDebugStep(readSearchParam(params.debugStep))
    : null;
  const debugName = isDevelopment ? readSearchParam(params.debugName) : undefined;
  const debugBirthDate = isDevelopment
    ? readSearchParam(params.debugBirthDate)
    : undefined;
  const debugBirthTime = isDevelopment
    ? readSearchParam(params.debugBirthTime)
    : undefined;
  const debugInterests = isDevelopment
    ? normalizeInterestParam(readSearchParam(params.debugInterests))
    : [];
  const [displayName, setDisplayName] = useState('');
  const [birthDate, setBirthDate] = useState('');
  const [birthTime, setBirthTime] = useState('');
  const [selectedInterestIds, setSelectedInterestIds] = useState<string[]>([]);
  const [hydrated, setHydrated] = useState(false);
  const [activeStepId, setActiveStepId] = useState<OnboardingStepId>('birth');

  useEffect(() => {
    if (status !== 'ready' || hydrated) {
      return;
    }

    const nextDisplayName = debugName ?? state.profile.displayName.trim();
    const nextBirthDate = debugBirthDate ?? state.profile.birthDate.trim();
    const nextBirthTime = debugBirthTime ?? state.profile.birthTime.trim();
    const nextInterestIds =
      debugInterests.length > 0 ? debugInterests : state.profile.interestIds;

    const derivedStep: OnboardingStepId =
      debugStep ??
      (onboardingProgress.birthCompleted
        ? onboardingProgress.interestCompleted
          ? 'handoff'
          : 'interest'
        : 'birth');

    setDisplayName(nextDisplayName);
    setBirthDate(nextBirthDate);
    setBirthTime(nextBirthTime);
    setSelectedInterestIds(nextInterestIds);
    setActiveStepId(derivedStep);
    setHydrated(true);
  }, [
    debugBirthDate,
    debugBirthTime,
    debugInterests,
    debugName,
    debugStep,
    hydrated,
    onboardingProgress.birthCompleted,
    onboardingProgress.interestCompleted,
    state.profile.birthDate,
    state.profile.birthTime,
    state.profile.displayName,
    state.profile.interestIds,
    status,
  ]);

  const activeStepIndex = onboardingSteps.findIndex(
    (step) => step.id === activeStepId,
  );
  const isBirthStepValid = birthDate.trim().length > 0;
  const isInterestStepValid = selectedInterestIds.length >= 3;

  async function handleContinueFromBirth() {
    try {
      await saveProfile({
        displayName: displayName.trim(),
        birthDate: birthDate.trim(),
        birthTime: birthTime.trim(),
      });
      await updateOnboardingProgress({
        birthCompleted: birthDate.trim().length > 0,
      });
      setActiveStepId('interest');
    } catch (error) {
      await captureError(error, { surface: 'onboarding:save-birth' });
    }
  }

  async function handleContinueFromInterest() {
    try {
      await saveProfile({
        interestIds: selectedInterestIds,
      });
      await updateOnboardingProgress({
        interestCompleted: selectedInterestIds.length > 0,
      });
      setActiveStepId('handoff');
    } catch (error) {
      await captureError(error, { surface: 'onboarding:save-interests' });
    }
  }

  async function handleFinishOnboarding() {
    try {
      await saveProfile({
        displayName: displayName.trim(),
        birthDate: birthDate.trim(),
        birthTime: birthTime.trim(),
        interestIds: selectedInterestIds,
      });
      await updateOnboardingProgress({
        birthCompleted: birthDate.trim().length > 0,
        interestCompleted: selectedInterestIds.length > 0,
      });
      await completeOnboarding();
      router.replace(returnTo as Href);
    } catch (error) {
      await captureError(error, { surface: 'onboarding:finish' });
    }
  }

  function toggleInterest(id: string) {
    setSelectedInterestIds((current) =>
      current.includes(id)
        ? current.filter((item) => item !== id)
        : [...current, id],
    );
  }

  return (
    <Screen
      header={
        <RouteBackHeader
          fallbackHref={returnTo as Href}
          label="처음 설정하기"
        />
      }
    >
      <AppText variant="labelMedium" color={fortuneTheme.colors.accentSecondary}>
        시작 안내
      </AppText>
      <AppText variant="displaySmall">처음 설정하기</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        대화와 운세를 더 자연스럽게 이어가기 위해 필요한 정보만 빠르게 확인해요.
      </AppText>

      <Card>
        <AppText variant="heading4">진행 상태</AppText>
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          {onboardingSteps.map((step, index) => {
            const isActive = step.id === activeStepId;
            const isDone = index < activeStepIndex;
            const backgroundColor = isActive
              ? fortuneTheme.colors.ctaBackground
              : isDone
                ? fortuneTheme.colors.accentSecondary
                : fortuneTheme.colors.surfaceSecondary;
            const color = isActive
              ? fortuneTheme.colors.ctaForeground
              : isDone
                ? fortuneTheme.colors.background
                : fortuneTheme.colors.textSecondary;

            return (
              <View
                key={step.id}
                style={{
                  backgroundColor,
                  borderRadius: fortuneTheme.radius.full,
                  paddingHorizontal: 14,
                  paddingVertical: 9,
                }}
              >
                <AppText variant="labelSmall" color={color}>
                  {index + 1}. {step.title}
                </AppText>
              </View>
            );
          })}
        </View>
      </Card>

      {activeStepId === 'birth' ? (
        <Card>
          <AppText variant="heading4">기본 정보</AppText>
          <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
            이름은 대화에서 불릴 방식이고, 생년월일은 더 잘 맞는 흐름을 찾는 데 사용돼요.
          </AppText>
          <Field
            label="표시 이름"
            placeholder="이름을 입력해 주세요"
            value={displayName}
            onChangeText={setDisplayName}
          />
          <Field
            label="생년월일"
            placeholder="YYYY-MM-DD"
            value={birthDate}
            onChangeText={setBirthDate}
          />
          <Field
            label="태어난 시간"
            placeholder="HH:MM"
            value={birthTime}
            onChangeText={setBirthTime}
          />
          <PrimaryButton
            disabled={!isBirthStepValid}
            onPress={() => void handleContinueFromBirth()}
          >
            관심사 선택으로 이동
          </PrimaryButton>
        </Card>
      ) : null}

      {activeStepId === 'interest' ? (
        <Card>
          <AppText variant="heading4">관심사 선택</AppText>
          <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
            최소 3개를 골라 주면 첫 화면과 추천 흐름을 더 자연스럽게 맞출 수 있어요.
          </AppText>
          <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 10 }}>
            {onboardingInterestOptions.map((option) => {
              const isSelected = selectedInterestIds.includes(option.id);

              return (
                <Pressable
                  key={option.id}
                  accessibilityRole="button"
                  onPress={() => toggleInterest(option.id)}
                  style={{
                    backgroundColor: isSelected
                      ? fortuneTheme.colors.ctaBackground
                      : fortuneTheme.colors.surfaceSecondary,
                    borderColor: isSelected
                      ? fortuneTheme.colors.ctaBackground
                      : fortuneTheme.colors.border,
                    borderRadius: fortuneTheme.radius.card,
                    borderWidth: 1,
                    gap: 6,
                    minWidth: '47%',
                    padding: 14,
                  }}
                >
                  <AppText
                    variant="labelLarge"
                    color={
                      isSelected
                        ? fortuneTheme.colors.ctaForeground
                        : fortuneTheme.colors.textPrimary
                    }
                  >
                    {option.label}
                  </AppText>
                  <AppText
                    variant="bodySmall"
                    color={
                      isSelected
                        ? fortuneTheme.colors.ctaForeground
                        : fortuneTheme.colors.textSecondary
                    }
                  >
                    {option.subtitle}
                  </AppText>
                </Pressable>
              );
            })}
          </View>
          <PrimaryButton
            disabled={!isInterestStepValid}
            onPress={() => void handleContinueFromInterest()}
          >
            시작 준비 보기
          </PrimaryButton>
          <PrimaryButton onPress={() => setActiveStepId('birth')} tone="secondary">
            이전 단계로
          </PrimaryButton>
        </Card>
      ) : null}

      {activeStepId === 'handoff' ? (
        <Card>
          <AppText variant="heading4">시작 준비</AppText>
          <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
            지금까지 확인한 정보를 기준으로 첫 화면과 대화 흐름을 맞춰둘게요.
          </AppText>
          <Card style={{ backgroundColor: fortuneTheme.colors.surfaceSecondary }}>
            <AppText variant="labelLarge">
              {displayName.trim() || '이름 미입력'}
            </AppText>
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              {birthDate.trim() || '생년월일 미입력'} ·{' '}
              {birthTime.trim() || '시간 미입력'}
            </AppText>
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              관심사 {selectedInterestIds.length}개 선택
            </AppText>
            <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
              {selectedInterestIds.map((interestId) => {
                const option = onboardingInterestOptions.find(
                  (item) => item.id === interestId,
                );

                if (!option) {
                  return null;
                }

                return (
                  <View
                    key={interestId}
                    style={{
                      backgroundColor: fortuneTheme.colors.surface,
                      borderColor: fortuneTheme.colors.border,
                      borderRadius: fortuneTheme.radius.full,
                      borderWidth: 1,
                      paddingHorizontal: 12,
                      paddingVertical: 8,
                    }}
                  >
                    <AppText variant="labelSmall">{option.label}</AppText>
                  </View>
                );
              })}
            </View>
          </Card>
          <PrimaryButton onPress={() => void handleFinishOnboarding()}>
            {session ? '설정 완료하고 계속하기' : '설정 저장하고 계속하기'}
          </PrimaryButton>
          {!session ? (
            <PrimaryButton
              onPress={() =>
                router.push({
                  pathname: '/signup',
                  params: { returnTo },
                })
              }
              tone="secondary"
            >
              계정 만들기 / 로그인
            </PrimaryButton>
          ) : null}
          <PrimaryButton
            onPress={() => setActiveStepId('interest')}
            tone="secondary"
          >
            이전 단계로
          </PrimaryButton>
        </Card>
      ) : null}

      <Card>
        <AppText variant="heading4">나가기</AppText>
        <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
          아직 마치지 않아도 언제든 다시 돌아와 이어서 입력할 수 있어요.
        </AppText>
        <PrimaryButton onPress={() => router.replace(returnTo as Href)} tone="secondary">
          {returnTo === '/chat' ? '메시지로 이동' : '원래 화면으로 돌아가기'}
        </PrimaryButton>
        {isDevelopment && debugStep ? (
          <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
            개발용 debug step: {debugStep}
          </AppText>
        ) : null}
      </Card>
    </Screen>
  );
}

function Field({
  label,
  placeholder,
  value,
  onChangeText,
}: {
  label: string;
  placeholder: string;
  value: string;
  onChangeText: (value: string) => void;
}) {
  return (
    <View style={{ gap: fortuneTheme.spacing.xs }}>
      <AppText variant="labelSmall" color={fortuneTheme.colors.textSecondary}>
        {label}
      </AppText>
      <TextInput
        onChangeText={onChangeText}
        placeholder={placeholder}
        placeholderTextColor={fortuneTheme.colors.textTertiary}
        style={{
          backgroundColor: fortuneTheme.colors.surfaceSecondary,
          borderColor: fortuneTheme.colors.border,
          borderRadius: fortuneTheme.radius.lg,
          borderWidth: 1,
          color: fortuneTheme.colors.textPrimary,
          paddingHorizontal: fortuneTheme.spacing.md,
          paddingVertical: 12,
        }}
        value={value}
      />
    </View>
  );
}
