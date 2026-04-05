import { router } from 'expo-router';
import { View } from 'react-native';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { Chip } from '../components/chip';
import { PrimaryButton } from '../components/primary-button';
import { Screen } from '../components/screen';
import { fortuneTheme } from '../lib/theme';

const deletionReasons = [
  '서비스가 더 이상 필요하지 않아요',
  '계정을 새로 시작하고 싶어요',
  '개인정보를 정리하고 싶어요',
] as const;

export function AccountDeletionScreen() {
  return (
    <Screen>
      <AppText variant="labelMedium" color={fortuneTheme.colors.accentSecondary}>
        /account-deletion
      </AppText>
      <AppText variant="displaySmall">계정 삭제</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        계정 삭제는 복구가 어려운 작업이므로 현재 화면은 핵심 고지와 확인 경로만 제공합니다.
      </AppText>

      <Card>
        <AppText variant="heading4">삭제 전 확인</AppText>
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          <Chip label="profile data" />
          <Chip label="purchase state" />
          <Chip label="chat history" />
        </View>
        {deletionReasons.map((reason) => (
          <Card
            key={reason}
            style={{ backgroundColor: fortuneTheme.colors.surfaceSecondary }}
          >
            <AppText variant="bodyMedium">{reason}</AppText>
          </Card>
        ))}
      </Card>

      <Card>
        <AppText variant="heading4">다음 단계</AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          실제 삭제 요청은 서버 확인과 재인증이 필요하므로, 현재는 프로필 허브로 돌아가 다시 검토하게 합니다.
        </AppText>
        <PrimaryButton onPress={() => router.push('/profile')} tone="secondary">
          프로필로 돌아가기
        </PrimaryButton>
        <PrimaryButton onPress={() => router.replace('/chat')} tone="secondary">
          Chat으로 돌아가기
        </PrimaryButton>
      </Card>
    </Screen>
  );
}
