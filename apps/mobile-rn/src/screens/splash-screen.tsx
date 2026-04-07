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

export function SplashScreen() {
  const { gate, onboardingProgress, session, status } = useAppBootstrap();
  const { state } = useMobileAppState();

  return (
    <Screen>
      <AppText variant="labelMedium" color={fortuneTheme.colors.accentSecondary}>
        /splash
      </AppText>
      <AppText variant="displaySmall">스플래시</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        문서 기준 active start route입니다. RN 부트스트랩 상태를 보여주고 다음
        진입 표면으로 이동합니다.
      </AppText>

      <Card>
        <AppText variant="heading4">부트스트랩 상태</AppText>
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          <Chip label={`status:${status}`} tone="accent" />
          <Chip label={`gate:${gate}`} />
          <Chip label={`session:${session ? 'active' : 'guest'}`} />
        </View>
      </Card>

      <AccountSnapshotCard
        description="저장된 프로필과 premium 상태를 읽은 뒤 문서상 진입 경로를 확인합니다."
        gate={gate}
        onboardingProgress={onboardingProgress}
        premium={state.premium}
        profile={state.profile}
        sessionActive={Boolean(session)}
      />

      <Card>
        <AppText variant="heading4">다음 진입</AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {gate === 'auth-entry'
            ? '현재는 signup soft gate로 이어지는 상태입니다.'
            : gate === 'profile-flow'
              ? '현재는 onboarding completion flow로 이어지는 상태입니다.'
              : '현재는 ready 상태로 chat surface에 바로 진입할 수 있습니다.'}
        </AppText>
        {gate === 'auth-entry' ? (
          <PrimaryButton onPress={() => router.replace('/signup')}>
            가입 시작하기
          </PrimaryButton>
        ) : null}
        {gate === 'profile-flow' ? (
          <PrimaryButton onPress={() => router.replace('/onboarding')}>
            온보딩 이어가기
          </PrimaryButton>
        ) : null}
        <PrimaryButton onPress={() => router.replace('/chat')} tone="secondary">
          Chat으로 이동
        </PrimaryButton>
      </Card>
    </Screen>
  );
}
