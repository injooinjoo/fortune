import { useEffect, useState } from 'react';

import {
  router,
  useLocalSearchParams,
  type Href,
} from 'expo-router';
import { Modal, Pressable, TextInput, View } from 'react-native';

import * as SecureStore from 'expo-secure-store';

import { AppText } from '../components/app-text';
import { BloodPicker, type BloodType } from '../components/blood-picker';
import { Card } from '../components/card';
import {
  DateInput,
  type DateInputValue,
} from '../components/date-input';
import { MBTIPicker, type MbtiType } from '../components/mbti-picker';
import { PrimaryButton } from '../components/primary-button';
import {
  resolveBackDestinationLabel,
  RouteBackHeader,
} from '../components/route-back-header';
import { Screen } from '../components/screen';
import { TimeInput, TIME_INPUT_UNKNOWN } from '../components/time-input';
import { appEnv } from '../lib/env';
import { captureError } from '../lib/error-reporting';
import { pageSnap } from '../lib/haptics';
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
    description: '지금 보고 싶은 대화와 인사이트 방향을 골라요.',
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

const DISCLAIMER_STORAGE_KEY = 'fortune.disclaimer-accepted.v1';

// DateInput uses a `{y, m, d}` struct, but the profile stores birthDate as a
// "YYYY-MM-DD" string. These adapters keep the profile contract stable while
// giving the onboarding UI a real segmented date picker.
function parseBirthDate(value: string): DateInputValue {
  const match = value.match(/^(\d{4})-(\d{1,2})-(\d{1,2})$/);
  if (!match) return { y: '', m: '', d: '' };
  return { y: match[1], m: match[2].padStart(2, '0'), d: match[3].padStart(2, '0') };
}

function serializeBirthDate(value: DateInputValue): string {
  const year = value.y.trim();
  const month = value.m.trim();
  const day = value.d.trim();
  if (!year || !month || !day) return '';
  return `${year}-${month.padStart(2, '0')}-${day.padStart(2, '0')}`;
}

// Ondo TimeInput returns a 12-branch token like "자(23~1시)". The saju Edge
// Function expects an HH:MM hour string, so we map each branch to the start
// hour of its 2-hour window. "시간 모름" maps to an empty string so saju
// treats it as unspecified rather than midnight.
const BRANCH_TO_HOUR: Record<string, string> = {
  '자(23~1시)': '23:00',
  '축(1~3시)': '01:00',
  '인(3~5시)': '03:00',
  '묘(5~7시)': '05:00',
  '진(7~9시)': '07:00',
  '사(9~11시)': '09:00',
  '오(11~13시)': '11:00',
  '미(13~15시)': '13:00',
  '신(15~17시)': '15:00',
  '유(17~19시)': '19:00',
  '술(19~21시)': '19:00',
  '해(21~23시)': '21:00',
  [TIME_INPUT_UNKNOWN]: '',
};

const HOUR_TO_BRANCH: Record<string, string> = Object.fromEntries(
  Object.entries(BRANCH_TO_HOUR)
    .filter(([, hour]) => hour !== '')
    .map(([branch, hour]) => [hour, branch]),
);

function parseBirthTime(value: string): string | undefined {
  if (!value) return undefined;
  if (value === TIME_INPUT_UNKNOWN) return TIME_INPUT_UNKNOWN;
  const trimmed = value.trim();
  const match = HOUR_TO_BRANCH[trimmed];
  if (match) return match;
  const hourPart = trimmed.slice(0, 2);
  return HOUR_TO_BRANCH[`${hourPart}:00`];
}

function serializeBirthTime(value: string | undefined): string {
  if (!value) return '';
  if (value === TIME_INPUT_UNKNOWN) return '';
  return BRANCH_TO_HOUR[value] ?? '';
}

export function OnboardingScreen() {
  const [disclaimerVisible, setDisclaimerVisible] = useState(false);

  useEffect(() => {
    void (async () => {
      const accepted = await SecureStore.getItemAsync(DISCLAIMER_STORAGE_KEY);
      if (!accepted) {
        setDisclaimerVisible(true);
      }
    })();
  }, []);

  async function handleAcceptDisclaimer() {
    await SecureStore.setItemAsync(DISCLAIMER_STORAGE_KEY, 'true');
    setDisclaimerVisible(false);
  }

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
  const backDestinationLabel = resolveBackDestinationLabel(returnTo as Href);
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
  const [mbti, setMbti] = useState('');
  const [bloodType, setBloodType] = useState('');
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

    const hasBirthProfile = nextBirthDate.trim().length > 0;
    const hasInterestProfile = nextInterestIds.length >= 3;
    const derivedStep: OnboardingStepId =
      debugStep ??
      (hasBirthProfile
        ? hasInterestProfile
          ? 'handoff'
          : 'interest'
        : 'birth');

    setDisplayName(nextDisplayName);
    setBirthDate(nextBirthDate);
    setBirthTime(nextBirthTime);
    setMbti(state.profile.mbti?.trim() ?? '');
    setBloodType(state.profile.bloodType?.trim() ?? '');
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
    state.profile.bloodType,
    state.profile.displayName,
    state.profile.interestIds,
    state.profile.mbti,
    status,
  ]);

  const activeStepIndex = onboardingSteps.findIndex(
    (step) => step.id === activeStepId,
  );
  const isBirthStepValid = birthDate.trim().length > 0;
  const isInterestStepValid = selectedInterestIds.length >= 3;
  const isHandoffReady = isBirthStepValid && isInterestStepValid;

  async function handleContinueFromBirth() {
    try {
      await saveProfile({
        displayName: displayName.trim(),
        birthDate: birthDate.trim(),
        birthTime: birthTime.trim(),
        mbti: mbti.trim(),
        bloodType: bloodType.trim(),
      });
      await updateOnboardingProgress({
        birthCompleted: birthDate.trim().length > 0,
      });
      pageSnap();
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
        interestCompleted: selectedInterestIds.length >= 3,
      });
      pageSnap();
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
        mbti: mbti.trim(),
        bloodType: bloodType.trim(),
        interestIds: selectedInterestIds,
      });
      await updateOnboardingProgress({
        birthCompleted: birthDate.trim().length > 0,
        interestCompleted: selectedInterestIds.length >= 3,
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
          label={backDestinationLabel}
        />
      }
    >
      <Modal
        animationType="fade"
        transparent
        visible={disclaimerVisible}
        onRequestClose={() => void handleAcceptDisclaimer()}
      >
        <View
          style={{
            flex: 1,
            backgroundColor: 'rgba(0,0,0,0.6)',
            justifyContent: 'center',
            alignItems: 'center',
            paddingHorizontal: 24,
          }}
        >
          <View
            style={{
              backgroundColor: fortuneTheme.colors.surface,
              borderRadius: fortuneTheme.radius.card,
              padding: 24,
              width: '100%',
              maxWidth: 360,
              gap: 16,
            }}
          >
            <AppText variant="heading4">오락 목적 안내</AppText>
            <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
              이 앱은 오락 목적으로 제공됩니다. AI가 생성한 인사이트는 실제 예측이
              아니며, 전문적인 조언을 대체하지 않습니다.
            </AppText>
            <PrimaryButton onPress={() => void handleAcceptDisclaimer()}>
              확인
            </PrimaryButton>
          </View>
        </View>
      </Modal>

      <AppText variant="labelMedium" color={fortuneTheme.colors.accentSecondary}>
        시작 안내
      </AppText>
      <AppText variant="displaySmall">처음 설정하기</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        대화와 인사이트를 더 자연스럽게 이어가기 위해 필요한 정보만 빠르게 확인해요.
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
            이름, 생년월일, 태어난 시간 그리고 MBTI / 혈액형까지 한 번에 확인해요.
            대화와 운세 흐름을 맞추는 데 쓰입니다.
          </AppText>

          <Field
            label="표시 이름"
            placeholder="이름을 입력해 주세요"
            value={displayName}
            onChangeText={setDisplayName}
          />

          <View style={{ gap: fortuneTheme.spacing.xs }}>
            <AppText
              variant="labelSmall"
              color={fortuneTheme.colors.textSecondary}
            >
              생년월일
            </AppText>
            <DateInput
              value={parseBirthDate(birthDate)}
              onChange={(next) => setBirthDate(serializeBirthDate(next))}
            />
          </View>

          <View style={{ gap: fortuneTheme.spacing.xs }}>
            <AppText
              variant="labelSmall"
              color={fortuneTheme.colors.textSecondary}
            >
              태어난 시간 (모르면 &quot;시간 모름&quot;)
            </AppText>
            <TimeInput
              value={parseBirthTime(birthTime)}
              onChange={(next) => setBirthTime(serializeBirthTime(next))}
            />
          </View>

          <View style={{ gap: fortuneTheme.spacing.xs }}>
            <AppText
              variant="labelSmall"
              color={fortuneTheme.colors.textSecondary}
            >
              MBTI (선택)
            </AppText>
            <MBTIPicker
              value={mbti || undefined}
              onChange={(next: MbtiType) => setMbti(next)}
            />
          </View>

          <View style={{ gap: fortuneTheme.spacing.xs }}>
            <AppText
              variant="labelSmall"
              color={fortuneTheme.colors.textSecondary}
            >
              혈액형 (선택)
            </AppText>
            <BloodPicker
              value={bloodType || undefined}
              onChange={(next: BloodType) => setBloodType(next)}
            />
          </View>

          <PrimaryButton
            disabled={!isBirthStepValid}
            onPress={() => void handleContinueFromBirth()}
            fullWidth
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
          <PrimaryButton
            disabled={!isHandoffReady}
            onPress={() => void handleFinishOnboarding()}
          >
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
        {__DEV__ && debugStep ? (
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
