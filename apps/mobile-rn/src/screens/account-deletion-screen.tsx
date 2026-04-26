import { useState } from 'react';

import { router } from 'expo-router';
import { ActivityIndicator, Pressable, TextInput, View } from 'react-native';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { RouteBackHeader } from '../components/route-back-header';
import { Screen } from '../components/screen';
import { captureError } from '../lib/error-reporting';
import { deactivateCurrentPushToken } from '../lib/push-notifications';
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
  const [selectedReason, setSelectedReason] = useState<string | null>(null);

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

      // QA-E: edge function hang 방지 60s hard timeout. delete-account 은
      // 25+ 테이블 + storage purge + auth.admin.deleteUser 까지 수행하므로
      // 일반 edge function 보다 오래 걸릴 수 있음 — 넉넉히 60s.
      const timeoutPromise = new Promise<never>((_, reject) => {
        setTimeout(
          () => reject(new Error('delete-account timeout (60s)')),
          60_000,
        );
      });

      const invokePromise = supabase.functions.invoke('delete-account', {
        body: {
          reason: selectedReason,
        },
      });
      const { error } = await Promise.race([invokePromise, timeoutPromise]);

      if (error) {
        setErrorMessage('계정 삭제에 실패했어요. 잠시 후 다시 시도해 주세요.');
        await captureError(error, { surface: 'account-deletion' });
        return;
      }

      // delete-account CASCADE 가 fcm_tokens 행을 정리하지만, 클라이언트
      // SecureStore 에 남은 pending push token / lastRegistered 캐시도
      // 비워야 동일 디바이스로 다른 계정 로그인 시 토큰이 누설되지 않는다.
      await deactivateCurrentPushToken().catch((err) =>
        captureError(err, { surface: 'account-deletion:push' }),
      );
      await supabase.auth.signOut();
      router.replace('/chat');
    } catch (error) {
      const message =
        error instanceof Error && error.message.includes('timeout')
          ? '시간이 너무 오래 걸려 중단됐어요. 네트워크를 확인하고 다시 시도해 주세요.'
          : '알 수 없는 오류가 발생했어요. 잠시 후 다시 시도해 주세요.';
      setErrorMessage(message);
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
        {/* 삭제 사유 선택 (선택 사항). 선택 시 delete-account 요청 body 에
            포함되어 운영팀 피드백 데이터로 활용. 기본은 미선택. */}
        {deletionReasons.map((reason) => {
          const isSelected = selectedReason === reason;
          return (
            <Pressable
              key={reason}
              onPress={() =>
                setSelectedReason(isSelected ? null : reason)
              }
              disabled={isDeleting}
              accessibilityRole="radio"
              accessibilityState={{ selected: isSelected }}
            >
              <Card
                style={{
                  backgroundColor: isSelected
                    ? fortuneTheme.colors.accentLight
                    : fortuneTheme.colors.surfaceSecondary,
                  borderWidth: 1,
                  borderColor: isSelected
                    ? fortuneTheme.colors.ctaBackground
                    : 'transparent',
                }}
              >
                <AppText variant="bodyMedium">{reason}</AppText>
              </Card>
            </Pressable>
          );
        })}
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
