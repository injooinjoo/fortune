import { router } from 'expo-router';
import { View } from 'react-native';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { Chip } from '../components/chip';
import { PrimaryButton } from '../components/primary-button';
import { Screen } from '../components/screen';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';

export function ProfileSajuSummaryScreen() {
  const { onboardingProgress, session } = useAppBootstrap();

  return (
    <Screen>
      <AppText
        variant="labelMedium"
        color={fortuneTheme.colors.accentSecondary}
      >
        /profile/saju-summary
      </AppText>
      <AppText variant="displaySmall">사주 요약</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        실제 사주 계산 전 단계에서 RN shell이 현재 프로필 준비 상태를 보여줍니다.
      </AppText>

      <Card>
        <AppText variant="heading4">준비 상태</AppText>
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          <Chip label={`session:${session ? 'active' : 'guest'}`} />
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
        <AppText variant="heading4">현재 해석 카드</AppText>
        <AppText variant="labelLarge">기본 흐름</AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          프로필 편집에서 생년월일과 선호 정보를 채우면 이후 실제 사주 결과와 연결될 자리입니다.
        </AppText>
        <AppText variant="labelLarge">관계 흐름</AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          채팅 사용량이 늘어날수록 관계도와 궁합이 함께 보강되는 구성이 들어갈 수 있습니다.
        </AppText>
        <AppText variant="labelLarge">추천 다음 동작</AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          프로필 편집과 채팅 진입을 함께 이어서 보세요.
        </AppText>
      </Card>

      <Card>
        <AppText variant="heading4">동작</AppText>
        <PrimaryButton onPress={() => router.push('/profile/edit')}>
          프로필 수정으로 이동
        </PrimaryButton>
        <PrimaryButton onPress={() => router.push('/chat')} tone="secondary">
          Chat 허브로 이동
        </PrimaryButton>
      </Card>
    </Screen>
  );
}
