import { useState } from 'react';

import { router } from 'expo-router';
import { ActivityIndicator, Pressable, TextInput, View } from 'react-native';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { RouteBackHeader } from '../components/route-back-header';
import { Screen } from '../components/screen';
import { captureError } from '../lib/error-reporting';
import { supabase } from '../lib/supabase';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';

const CONFIRMATION_KEYWORD = '삭제';

const deletionReasons = [
  '서비스가 더 이상 필요하지 않아요',
  '계정을 새로 시작하고 싶어요',
  '개인정보를 정리하고 싶어요',
] as const;

export function AccountDeletionScreen() {
  const { session } = useAppBootstrap();
  const [confirmText, setConfirmText] = useState('');
  const [isDeleting, setIsDeleting] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const isConfirmed = confirmText.trim() === CONFIRMATION_KEYWORD;

  async function handleDeleteAccount() {
    if (!isConfirmed || isDeleting) return;

    setIsDeleting(true);
    setErrorMessage(null);

    try {
      if (!supabase) {
        setErrorMessage('서비스에 연결할 수 없어요. 잠시 후 다시 시도해 주세요.');
        return;
      }

      const { error } = await supabase.functions.invoke('delete-account');

      if (error) {
        setErrorMessage('계정 삭제에 실패했어요. 잠시 후 다시 시도해 주세요.');
        await captureError(error, { surface: 'account-deletion' });
        return;
      }

      await supabase.auth.signOut();
      router.replace('/chat');
    } catch (error) {
      setErrorMessage('알 수 없는 오류가 발생했어요. 잠시 후 다시 시도해 주세요.');
      await captureError(error, { surface: 'account-deletion' });
    } finally {
      setIsDeleting(false);
    }
  }

  return (
    <Screen header={<RouteBackHeader fallbackHref="/profile" />}>
      {/* Title */}
      <AppText variant="displaySmall">계정 삭제</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        계정 삭제는 복구가 어려운 작업이라서, 삭제 전에 꼭 확인해야 할 내용만 먼저 안내해 드려요.
      </AppText>

      {/* Deletion warnings */}
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

      {/* Confirmation input */}
      <Card>
        <AppText variant="heading4">삭제 확인</AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          계속하려면 아래에 "{CONFIRMATION_KEYWORD}"를 입력해 주세요.
        </AppText>
        <TextInput
          autoCapitalize="none"
          autoCorrect={false}
          editable={!isDeleting}
          onChangeText={(text) => {
            setConfirmText(text);
            setErrorMessage(null);
          }}
          placeholder={`"${CONFIRMATION_KEYWORD}" 입력`}
          placeholderTextColor={fortuneTheme.colors.textSecondary}
          style={{
            backgroundColor: fortuneTheme.colors.surfaceSecondary,
            borderColor: isConfirmed ? '#E53E3E' : fortuneTheme.colors.border,
            borderRadius: fortuneTheme.radius.card,
            borderWidth: 1,
            color: fortuneTheme.colors.textPrimary,
            fontSize: 16,
            paddingHorizontal: 16,
            paddingVertical: 14,
            marginTop: fortuneTheme.spacing.xs,
          }}
          value={confirmText}
        />

        {/* Error message */}
        {errorMessage ? (
          <AppText
            variant="bodySmall"
            color="#E53E3E"
            style={{ marginTop: fortuneTheme.spacing.xs }}
          >
            {errorMessage}
          </AppText>
        ) : null}
      </Card>

      {/* Delete CTA */}
      <Pressable
        accessibilityRole="button"
        disabled={!isConfirmed || isDeleting}
        onPress={handleDeleteAccount}
        style={({ pressed }) => ({
          backgroundColor: '#E53E3E',
          opacity: !isConfirmed || isDeleting ? 0.46 : pressed ? 0.82 : 1,
          borderRadius: fortuneTheme.radius.full,
          paddingHorizontal: 18,
          paddingVertical: 14,
          flexDirection: 'row',
          alignItems: 'center',
          justifyContent: 'center',
          gap: 8,
        })}
      >
        {isDeleting ? (
          <ActivityIndicator color="#FFFFFF" size="small" />
        ) : null}
        <AppText
          variant="labelLarge"
          color="#FFFFFF"
          style={{ textAlign: 'center' }}
        >
          {isDeleting ? '삭제 중...' : '계정 영구 삭제'}
        </AppText>
      </Pressable>
    </Screen>
  );
}
