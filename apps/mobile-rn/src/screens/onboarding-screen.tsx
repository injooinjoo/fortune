import { router } from 'expo-router';
import { View } from 'react-native';

import { AccountSnapshotCard } from '../components/account-snapshot-card';
import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { Chip } from '../components/chip';
import { PrimaryButton } from '../components/primary-button';
import { Screen } from '../components/screen';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';
import { useMobileAppState } from '../providers/mobile-app-state-provider';

const onboardingSteps = [
  {
    id: 'birth',
    title: '생년월일 확인',
    description: '사주와 기본 운세 라우팅의 기준이 되는 핵심 정보',
  },
  {
    id: 'interest',
    title: '관심사 선택',
    description: 'chat-first 추천칩과 전문가 연결을 위한 취향 정보',
  },
  {
    id: 'handoff',
    title: '첫 진입 안내',
    description: '초기 진입 후 제품 탐색 흐름을 안정적으로 마무리',
  },
] as const;

export function OnboardingScreen() {
  const { gate, onboardingProgress, completeOnboarding, session } =
    useAppBootstrap();
  const { state } = useMobileAppState();
  const profile = state.profile;
  const premium = state.premium;

  async function handleFinishOnboarding() {
    await completeOnboarding();
    router.replace('/chat');
  }

  return (
    <Screen>
      <AppText variant="labelMedium" color={fortuneTheme.colors.accentSecondary}>
        /onboarding
      </AppText>
      <AppText variant="displaySmall">온보딩</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        RN에서는 첫 진입과 재진입이 같은 계약으로 처리됩니다. 현재 화면은 그 흐름을 보여주는 실제 셸입니다.
      </AppText>

      <AccountSnapshotCard
        description="저장된 상태는 한 카드로 합치고, onboarding 진행만 아래에서 따로 보여줍니다."
        emptyCopy="저장된 프로필이 아직 없어서, onboarding 단계에서 채울 기본 정보만 노출합니다."
        gate={gate}
        onboardingProgress={onboardingProgress}
        premium={premium}
        profile={profile}
        sessionActive={Boolean(session)}
      />

      <Card>
        <AppText variant="heading4">진행 상태</AppText>
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          <Chip
            label={`soft:${onboardingProgress.softGateCompleted ? 'done' : 'todo'}`}
          />
          <Chip
            label={`auth:${onboardingProgress.authCompleted ? 'done' : 'todo'}`}
          />
          <Chip
            label={`birth:${onboardingProgress.birthCompleted ? 'done' : 'todo'}`}
          />
          <Chip
            label={`interest:${onboardingProgress.interestCompleted ? 'done' : 'todo'}`}
          />
          <Chip
            label={`handoff:${onboardingProgress.firstRunHandoffSeen ? 'done' : 'todo'}`}
          />
        </View>
      </Card>

      <Card>
        <AppText variant="heading4">온보딩 단계</AppText>
        {onboardingSteps.map((step) => (
          <Card
            key={step.id}
            style={{ backgroundColor: fortuneTheme.colors.surfaceSecondary }}
          >
            <AppText variant="labelLarge">{step.title}</AppText>
            <AppText
              variant="bodySmall"
              color={fortuneTheme.colors.textSecondary}
            >
              {step.description}
            </AppText>
          </Card>
        ))}
      </Card>

      <Card>
        <AppText variant="heading4">다음 동작</AppText>
        <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
          이 화면은 진입 흐름을 안내하고, 실제 완료 동작은 상위 bootstrap contract에서 처리합니다.
        </AppText>
        <PrimaryButton onPress={() => void handleFinishOnboarding()}>
          온보딩 완료하고 Chat으로
        </PrimaryButton>
        <PrimaryButton onPress={() => router.push('/signup')} tone="secondary">
          계정 만들기 / 로그인
        </PrimaryButton>
        <PrimaryButton onPress={() => router.replace('/chat')} tone="secondary">
          Chat으로 돌아가기
        </PrimaryButton>
      </Card>
    </Screen>
  );
}
