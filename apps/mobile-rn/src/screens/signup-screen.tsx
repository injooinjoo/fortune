import { router } from 'expo-router';
import { View } from 'react-native';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { Chip } from '../components/chip';
import { PrimaryButton } from '../components/primary-button';
import { Screen } from '../components/screen';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';
import { useMobileAppState } from '../providers/mobile-app-state-provider';

const authOptions = [
  {
    id: 'apple',
    label: 'Apple로 계속하기',
    note: 'iOS 환경에서 연결될 소셜 로그인 진입점',
  },
  {
    id: 'google',
    label: 'Google로 계속하기',
    note: 'Android / web 계정 연결 진입점',
  },
  {
    id: 'kakao',
    label: 'Kakao로 계속하기',
    note: '국내 계정 복귀 플로우 진입점',
  },
] as const;

export function SignupScreen() {
  const { gate, onboardingProgress, session } = useAppBootstrap();
  const { state } = useMobileAppState();
  const profile = state.profile;
  const premium = state.premium;
  const hasProfileHint = Boolean(
    profile.displayName ||
      profile.birthDate ||
      profile.birthTime ||
      profile.mbti ||
      profile.bloodType,
  );

  return (
    <Screen>
      <AppText variant="labelMedium" color={fortuneTheme.colors.accentSecondary}>
        /signup
      </AppText>
      <AppText variant="displaySmall">가입 및 로그인</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        실제 공급자 연결은 다음 단계에서 붙고, 현재는 RN에서 올바른 진입 구조와 복귀 경로를 유지합니다.
      </AppText>

      <Card>
        <AppText variant="heading4">계정 시작</AppText>
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          <Chip label="guest browse" tone="accent" />
          <Chip label="oauth callback" />
          <Chip label="profile unlock" />
        </View>
      </Card>

      <Card>
        <AppText variant="heading4">저장된 상태</AppText>
        <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
          앱 재실행 후에도 남아 있는 프로필과 premium 상태를 먼저 보여줍니다.
        </AppText>
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          <Chip
            label={session ? 'session:active' : 'session:guest'}
            tone={session ? 'success' : 'neutral'}
          />
          <Chip label={`gate:${gate}`} />
          <Chip label={`soft:${onboardingProgress.softGateCompleted ? 'done' : 'todo'}`} />
          <Chip
            label={`profile:${hasProfileHint ? 'saved' : 'empty'}`}
            tone={hasProfileHint ? 'success' : 'neutral'}
          />
          <Chip
            label={`plan:${premium.status}`}
            tone={premium.status === 'inactive' ? 'neutral' : 'accent'}
          />
          <Chip label={`tokens:${premium.tokenBalance.toLocaleString('ko-KR')}`} />
        </View>
        {hasProfileHint ? (
          <View style={{ gap: 8 }}>
            <AppText variant="labelLarge">{profile.displayName || '저장된 이름 없음'}</AppText>
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              {[
                profile.birthDate ? `생년월일 ${profile.birthDate}` : null,
                profile.birthTime ? `시간 ${profile.birthTime}` : null,
                profile.mbti ? `MBTI ${profile.mbti}` : null,
                profile.bloodType ? `혈액형 ${profile.bloodType}` : null,
              ]
                .filter(Boolean)
                .join(' · ')}
            </AppText>
          </View>
        ) : (
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            아직 저장된 프로필이 없어서, 가입 후 온보딩에서 채워질 정보를 보여줄 수 있습니다.
          </AppText>
        )}
      </Card>

      <Card>
        <AppText variant="heading4">소셜 로그인</AppText>
        {authOptions.map((option) => (
          <PrimaryButton
            key={option.id}
            onPress={() =>
              router.push({
                pathname: '/auth/callback',
                params: {
                  authCallbackUrl: `com.beyond.fortune://auth-callback?provider=${option.id}`,
                },
              })
            }
          >
            {option.label}
          </PrimaryButton>
        ))}
      </Card>

      <Card>
        <AppText variant="heading4">왜 필요한가요?</AppText>
        <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
          로그인 후에는 프로필 수정, 관계 관리, 구매 복원, 알림 설정 등 계정 기반 표면이 활성화됩니다.
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
          게스트로 먼저 둘러본 뒤 언제든 로그인으로 전환할 수 있습니다.
        </AppText>
        <PrimaryButton onPress={() => router.push('/onboarding')} tone="secondary">
          온보딩 계속하기
        </PrimaryButton>
        <PrimaryButton onPress={() => router.replace('/chat')} tone="secondary">
          Chat으로 돌아가기
        </PrimaryButton>
      </Card>
    </Screen>
  );
}
