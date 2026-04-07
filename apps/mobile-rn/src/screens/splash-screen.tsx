import { router } from 'expo-router';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { PrimaryButton } from '../components/primary-button';
import { Screen } from '../components/screen';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';

export function SplashScreen() {
  const { gate, onboardingProgress, session, status } = useAppBootstrap();
  const nextStepLabel =
    gate === 'auth-entry'
      ? '로그인 안내'
      : gate === 'profile-flow'
        ? '처음 설정'
        : '채팅';
  const readinessMessage =
    status === 'ready'
      ? '준비가 거의 끝나서 곧 다음 화면으로 넘어가요.'
      : '저장된 정보와 연결 상태를 확인하고 있어요.';

  return (
    <Screen>
      <AppText variant="labelMedium" color={fortuneTheme.colors.accentSecondary}>
        앱 시작
      </AppText>
      <AppText variant="displaySmall">불러오는 중</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        저장된 정보와 현재 상태를 확인한 뒤 가장 알맞은 화면으로 이어집니다.
      </AppText>

      <Card>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {readinessMessage}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          다음으로는 {nextStepLabel} 화면이 열릴 예정이에요.
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {session
            ? '로그인 정보가 확인되면 바로 이어서 사용할 수 있어요.'
            : '게스트 상태여도 먼저 둘러볼 수 있어요.'}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {onboardingProgress.birthCompleted
            ? '기본 정보가 일부 준비되어 있어서 다음 단계가 더 빨라집니다.'
            : '처음 설정이 필요한지 함께 확인하고 있어요.'}
        </AppText>
        {gate === 'auth-entry' ? (
          <PrimaryButton onPress={() => router.replace('/signup')}>
            로그인 시작하기
          </PrimaryButton>
        ) : null}
        {gate === 'profile-flow' ? (
          <PrimaryButton onPress={() => router.replace('/onboarding')}>
            설정 이어가기
          </PrimaryButton>
        ) : null}
        <PrimaryButton onPress={() => router.replace('/chat')} tone="secondary">
          채팅으로 이동
        </PrimaryButton>
      </Card>
    </Screen>
  );
}
