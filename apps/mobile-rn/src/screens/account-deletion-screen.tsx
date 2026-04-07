import { router } from 'expo-router';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
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
      <AppText variant="displaySmall">계정 삭제</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        계정 삭제는 복구가 어려운 작업이라서, 삭제 전에 꼭 확인해야 할 내용만 먼저 안내해 드려요.
      </AppText>

      <Card>
        <AppText variant="heading4">삭제 전 확인</AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          프로필 정보, 구매 내역, 채팅 기록은 삭제 요청이 완료되면 함께 정리될 수 있어요.
        </AppText>
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
          실제 삭제 요청은 본인 확인과 재인증이 필요하므로, 현재는 프로필에서 한 번 더 검토한 뒤 진행하게 됩니다.
        </AppText>
        <PrimaryButton onPress={() => router.push('/profile')} tone="secondary">
          프로필로 돌아가기
        </PrimaryButton>
        <PrimaryButton onPress={() => router.replace('/chat')} tone="secondary">
          채팅으로 돌아가기
        </PrimaryButton>
      </Card>
    </Screen>
  );
}
