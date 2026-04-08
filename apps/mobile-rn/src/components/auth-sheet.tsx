import type { ReactNode } from 'react';

import { Ionicons } from '@expo/vector-icons';
import { Pressable, View } from 'react-native';

import { fortuneTheme } from '../lib/theme';
import { AppleAuthButton } from './apple-auth-button';
import { AppText } from './app-text';
import { Card } from './card';
import { SocialAuthPillButton } from './social-auth-pill-button';

type AuthProviderId = 'apple' | 'google' | 'kakao' | 'naver';

const defaultTitle = '기록과 개인화를 계속 이어가세요';
const defaultSubtitle =
  '로그인하면 분석 기록, 맞춤 추천, 구매 내역이 계정에 안전하게 연결됩니다.';

function buildProviderButtonLabel(
  providerId: AuthProviderId,
  activeProviderId: AuthProviderId | null | undefined,
) {
  const labelById: Record<AuthProviderId, string> = {
    apple: '애플 로그인',
    google: '구글 로그인',
    kakao: '카카오 로그인',
    naver: '네이버 로그인',
  };

  const baseLabel = labelById[providerId];

  if (activeProviderId !== providerId) {
    return baseLabel;
  }

  return `${baseLabel} 준비 중...`;
}

export function AuthSheetModal({
  children,
  onDismiss,
}: {
  children: ReactNode;
  onDismiss?: () => void;
}) {
  return (
    <View
      style={{
        backgroundColor: 'rgba(9, 10, 15, 0.72)',
        flex: 1,
        justifyContent: 'flex-end',
      }}
    >
      <Pressable
        accessibilityLabel="로그인 시트 닫기"
        accessibilityRole="button"
        onPress={onDismiss}
        style={{
          bottom: 0,
          left: 0,
          position: 'absolute',
          right: 0,
          top: 0,
        }}
      />

      <View
        pointerEvents="box-none"
        style={{
          paddingBottom: fortuneTheme.spacing.pageVertical,
          paddingHorizontal: fortuneTheme.spacing.pageHorizontal,
          paddingTop: fortuneTheme.spacing.xl,
        }}
      >
        {children}
      </View>
    </View>
  );
}

export function AuthSheetCard({
  activeProviderId,
  authMessage,
  footer,
  onApple,
  onBrowse,
  onDismiss,
  onGoogle,
  onKakao,
  onNaver,
  subtitle = defaultSubtitle,
  title = defaultTitle,
}: {
  activeProviderId?: AuthProviderId | null;
  authMessage?: string | null;
  footer?: ReactNode;
  onApple: () => void;
  onBrowse?: () => void;
  onDismiss?: () => void;
  onGoogle: () => void;
  onKakao?: () => void;
  onNaver?: () => void;
  subtitle?: string;
  title?: string;
}) {
  const isBusy = Boolean(activeProviderId);

  return (
    <Card
      style={{
        borderTopLeftRadius: 32,
        borderTopRightRadius: 32,
        gap: fortuneTheme.spacing.md,
        paddingBottom: fortuneTheme.spacing.xl,
        paddingTop: fortuneTheme.spacing.lg,
      }}
    >
      <View
        style={{
          alignItems: 'center',
          flexDirection: 'row',
          justifyContent: 'center',
          minHeight: 28,
          position: 'relative',
        }}
      >
        <View
          style={{
            backgroundColor: fortuneTheme.colors.borderOpaque,
            borderRadius: 999,
            height: 4,
            width: 44,
          }}
        />

        {onDismiss ? (
          <Pressable
            accessibilityLabel="로그인 닫기"
            accessibilityRole="button"
            hitSlop={10}
            onPress={onDismiss}
            style={({ pressed }) => ({
              opacity: pressed ? 0.76 : 1,
              position: 'absolute',
              right: 0,
            })}
          >
            <Ionicons
              color={fortuneTheme.colors.textSecondary}
              name="close"
              size={22}
            />
          </Pressable>
        ) : null}
      </View>

      <View style={{ gap: fortuneTheme.spacing.xs }}>
        <AppText variant="labelMedium" color={fortuneTheme.colors.accentSecondary}>
          계정을 연결하고 시작
        </AppText>
        <AppText variant="displaySmall">{title}</AppText>
        <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
          {subtitle}
        </AppText>
      </View>

      <View style={{ gap: fortuneTheme.spacing.sm }}>
        <AppleAuthButton
          disabled={isBusy}
          label={buildProviderButtonLabel('apple', activeProviderId)}
          onPress={onApple}
        />
        <SocialAuthPillButton
          disabled={isBusy}
          label={buildProviderButtonLabel('google', activeProviderId)}
          onPress={onGoogle}
          provider="google"
        />
        {onKakao ? (
          <SocialAuthPillButton
            disabled={isBusy}
            label={buildProviderButtonLabel('kakao', activeProviderId)}
            onPress={onKakao}
            provider="kakao"
          />
        ) : null}
        {onNaver ? (
          <SocialAuthPillButton
            disabled={isBusy}
            label={buildProviderButtonLabel('naver', activeProviderId)}
            onPress={onNaver}
            provider="naver"
          />
        ) : null}
      </View>

      <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
        계속하면 이용약관과 개인정보처리방침에 동의하게 됩니다.
      </AppText>

      {authMessage ? (
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {authMessage}
        </AppText>
      ) : null}

      {onBrowse ? (
        <Pressable
          accessibilityRole="button"
          onPress={onBrowse}
          style={({ pressed }) => ({
            opacity: pressed ? 0.8 : 1,
            paddingTop: 4,
          })}
        >
          <AppText
            variant="labelLarge"
            color={fortuneTheme.colors.textPrimary}
            style={{ textAlign: 'center' }}
          >
            로그인 없이 둘러보기
          </AppText>
        </Pressable>
      ) : null}

      {footer}
    </Card>
  );
}
