import { router } from 'expo-router';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { PrimaryButton } from '../components/primary-button';
import { Screen } from '../components/screen';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';

export function SplashScreen() {
  const { gate, onboardingProgress, session, status } = useAppBootstrap();

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
          앱 상태: {status}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          다음 화면: {gate === 'auth-entry' ? '로그인 안내' : gate === 'profile-flow' ? '처음 설정' : '채팅'}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          로그인 상태: {session ? '연결됨' : '게스트'}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          설정 진행: {onboardingProgress.birthCompleted ? '일부 완료' : '아직 시작 전'}
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
