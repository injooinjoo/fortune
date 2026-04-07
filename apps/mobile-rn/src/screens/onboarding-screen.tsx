import { router, useLocalSearchParams, type Href } from 'expo-router';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { PrimaryButton } from '../components/primary-button';
import { Screen } from '../components/screen';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';

const onboardingSteps = [
  {
    id: 'birth',
    title: '생년월일 확인',
    description: '맞춤 결과를 보여주기 위해 먼저 확인하는 정보예요.',
  },
  {
    id: 'interest',
    title: '관심사 선택',
    description: '더 잘 맞는 콘텐츠를 보여주기 위한 선택 항목이에요.',
  },
  {
    id: 'handoff',
    title: '첫 진입 안내',
    description: '처음 이용할 때 어디로 이어지는지 알려드려요.',
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

export function OnboardingScreen() {
  const params = useLocalSearchParams<{ returnTo?: string | string[] }>();
  const { onboardingProgress, completeOnboarding, session } = useAppBootstrap();
  const returnTo = normalizeReturnTo(readSearchParam(params.returnTo));

  async function handleFinishOnboarding() {
    await completeOnboarding();
    router.replace(returnTo as Href);
  }

  return (
    <Screen>
      <AppText variant="labelMedium" color={fortuneTheme.colors.accentSecondary}>
        시작 안내
      </AppText>
      <AppText variant="displaySmall">처음 설정하기</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        처음 들어오면 몇 가지 정보만 확인하고 바로 이용을 시작할 수 있어요.
      </AppText>

      <Card>
        <AppText variant="heading4">진행 상태</AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          생년월일: {onboardingProgress.birthCompleted ? '확인 완료' : '아직 필요해요'}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          관심사: {onboardingProgress.interestCompleted ? '선택 완료' : '선택해 주세요'}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          첫 안내: {onboardingProgress.firstRunHandoffSeen ? '확인 완료' : '아직 안 봤어요'}
        </AppText>
      </Card>

      <Card>
        <AppText variant="heading4">확인할 항목</AppText>
        {onboardingSteps.map((step) => (
          <Card
            key={step.id}
            style={{ backgroundColor: fortuneTheme.colors.surfaceSecondary }}
          >
            <AppText variant="labelLarge">{step.title}</AppText>
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              {step.description}
            </AppText>
          </Card>
        ))}
      </Card>

      <Card>
        <AppText variant="heading4">다음 동작</AppText>
        <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
          이 단계를 마치면 바로 채팅으로 이어지거나, 계정 연결을 계속할 수 있어요.
        </AppText>
        <PrimaryButton onPress={() => void handleFinishOnboarding()}>
          {session ? '설정 완료하고 계속하기' : '설정 저장하고 계속하기'}
        </PrimaryButton>
        {!session ? (
          <PrimaryButton
            onPress={() =>
              router.push({
                pathname: '/signup',
                params: { returnTo: '/onboarding' },
              })
            }
            tone="secondary"
          >
            계정 만들기 / 로그인
          </PrimaryButton>
        ) : null}
        <PrimaryButton
          onPress={() => router.replace(returnTo as Href)}
          tone="secondary"
        >
          {returnTo === '/chat' ? '채팅으로 돌아가기' : '이전 화면으로 돌아가기'}
        </PrimaryButton>
      </Card>
    </Screen>
  );
}
