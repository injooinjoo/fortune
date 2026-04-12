import { useEffect, useState } from 'react';

import { Ionicons } from '@expo/vector-icons';
import { router, useLocalSearchParams, type Href } from 'expo-router';
import { Pressable, View } from 'react-native';

import { AppleAuthButton } from '../components/apple-auth-button';
import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { PrimaryButton } from '../components/primary-button';
import {
  resolveBackDestinationLabel,
  RouteBackHeader,
} from '../components/route-back-header';
import { Screen } from '../components/screen';
import { SocialAuthPillButton } from '../components/social-auth-pill-button';
import { captureError } from '../lib/error-reporting';
import { confirmAction } from '../lib/haptics';
import {
  socialAuthProviderLabelById,
  type SocialAuthProviderId,
} from '../lib/social-auth';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';
import { useSocialAuth } from '../providers/social-auth-provider';

const authOptions: readonly {
  id: SocialAuthProviderId;
  label: string;
  note: string;
}[] = [
  {
    id: 'apple',
    label: '애플 로그인',
    note: 'iPhone에서 가장 자연스럽게 인증하고 기록을 이어갑니다.',
  },
  {
    id: 'google',
    label: '구글 로그인',
    note: '구글 계정으로 개인화와 구매 내역을 바로 연결합니다.',
  },
  {
    id: 'kakao',
    label: '카카오 로그인',
    note: '카카오 계정으로 빠르게 시작하고 추천 흐름을 이어갑니다.',
  },
  {
    id: 'naver',
    label: '네이버 로그인',
    note: '네이버 계정으로 프로필과 저장 기록을 연결합니다.',
  },
] as const;

function readSearchParam(
  value: string | string[] | undefined,
): string | undefined {
  return Array.isArray(value) ? value[0] : value;
}

function normalizeReturnTo(value: string | undefined) {
  return value && value.startsWith('/') ? value : '/chat';
}

export function SignupScreen() {
  const params = useLocalSearchParams<{ returnTo?: string | string[] }>();
  const [activeProviderId, setActiveProviderId] =
    useState<SocialAuthProviderId | null>(null);
  const [authMessage, setAuthMessage] = useState<string | null>(null);
  const {
    markGuestBrowse,
    session,
    status: bootstrapStatus,
  } = useAppBootstrap();
  const { startSocialAuth } = useSocialAuth();
  const returnTo = normalizeReturnTo(readSearchParam(params.returnTo));
  const backDestinationLabel = resolveBackDestinationLabel(returnTo as Href);

  useEffect(() => {
    if (bootstrapStatus !== 'ready' || !session) {
      return;
    }

    router.replace({
      pathname: '/auth/callback',
      params: { returnTo },
    });
  }, [bootstrapStatus, returnTo, session]);

  async function handleSocialAuthStart(providerId: SocialAuthProviderId) {
    try {
      setActiveProviderId(providerId);
      setAuthMessage(null);

      const result = await startSocialAuth(providerId, returnTo);

      if (result.status === 'started') {
        setAuthMessage(
          `${socialAuthProviderLabelById[providerId]} 로그인을 진행하고 있습니다. 잠시만 기다려 주세요.`,
        );
        return;
      }

      setAuthMessage(result.errorMessage ?? '로그인을 시작하지 못했습니다.');
    } catch (error) {
      await captureError(error, { surface: 'signup:start-social-auth' });
      setAuthMessage('소셜 로그인을 시작하지 못했습니다.');
    } finally {
      setActiveProviderId(null);
    }
  }

  return (
    <Screen
      header={
        <RouteBackHeader
          fallbackHref={returnTo as Href}
          label={backDestinationLabel}
        />
      }
    >
      <AppText variant="displaySmall">계정을 연결하고 시작</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        원하는 계정으로 시작하면 분석 기록, 구매 내역, 추천 설정이 계속 이어집니다.
      </AppText>

      <Card>
        <AppText variant="heading4">연결하고 바로 시작</AppText>
        {authMessage ? (
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {authMessage}
          </AppText>
        ) : null}
        {authOptions.map((option) => (
          <View key={option.id}>
            {option.id === 'apple' ? (
              <AppleAuthButton
                disabled={activeProviderId === option.id}
                label={option.label}
                onPress={() => void handleSocialAuthStart(option.id)}
              />
            ) : (
              <SocialAuthPillButton
                disabled={activeProviderId === option.id}
                label={
                  activeProviderId === option.id
                    ? `${option.label} 준비 중...`
                    : option.label
                }
                onPress={() => void handleSocialAuthStart(option.id)}
                provider={option.id}
              />
            )}
          </View>
        ))}
      </Card>

      <View
        style={{
          alignItems: 'center',
          flexDirection: 'row',
          gap: fortuneTheme.spacing.md,
        }}
      >
        <View
          style={{
            flex: 1,
            height: 1,
            backgroundColor: fortuneTheme.colors.divider,
          }}
        />
        <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
          또는
        </AppText>
        <View
          style={{
            flex: 1,
            height: 1,
            backgroundColor: fortuneTheme.colors.divider,
          }}
        />
      </View>

      <Card>
        <AppText variant="heading4">다른 방법으로 시작</AppText>
        <Pressable
          accessibilityLabel="이메일로 시작"
          accessibilityRole="button"
          onPress={() => {
            confirmAction();
            router.push('/auth/email');
          }}
          style={({ pressed }) => ({
            alignItems: 'center',
            backgroundColor: '#FFFFFF',
            borderRadius: fortuneTheme.radius.full,
            flexDirection: 'row',
            justifyContent: 'center',
            minHeight: 52,
            opacity: pressed ? 0.84 : 1,
            paddingHorizontal: 16,
            width: '100%',
          })}
        >
          <View
            style={{
              alignItems: 'center',
              flexDirection: 'row',
              width: '100%',
            }}
          >
            <View
              style={{
                alignItems: 'center',
                justifyContent: 'center',
                width: 24,
              }}
            >
              <Ionicons color="#111111" name="mail-outline" size={18} />
            </View>
            <View style={{ flex: 1 }}>
              <AppText
                variant="labelLarge"
                color="#111111"
                style={{ fontWeight: '700', textAlign: 'center' }}
              >
                이메일로 시작
              </AppText>
            </View>
            <View style={{ width: 24 }} />
          </View>
        </Pressable>
        <Pressable
          accessibilityLabel="전화번호로 시작"
          accessibilityRole="button"
          onPress={() => {
            confirmAction();
            router.push('/auth/phone');
          }}
          style={({ pressed }) => ({
            alignItems: 'center',
            backgroundColor: '#FFFFFF',
            borderRadius: fortuneTheme.radius.full,
            flexDirection: 'row',
            justifyContent: 'center',
            minHeight: 52,
            opacity: pressed ? 0.84 : 1,
            paddingHorizontal: 16,
            width: '100%',
          })}
        >
          <View
            style={{
              alignItems: 'center',
              flexDirection: 'row',
              width: '100%',
            }}
          >
            <View
              style={{
                alignItems: 'center',
                justifyContent: 'center',
                width: 24,
              }}
            >
              <Ionicons color="#111111" name="call-outline" size={18} />
            </View>
            <View style={{ flex: 1 }}>
              <AppText
                variant="labelLarge"
                color="#111111"
                style={{ fontWeight: '700', textAlign: 'center' }}
              >
                전화번호로 시작
              </AppText>
            </View>
            <View style={{ width: 24 }} />
          </View>
        </Pressable>
      </Card>

      <Card>
        <AppText variant="heading4">로그인 없이 먼저 보기</AppText>
        <PrimaryButton
          onPress={() => {
            markGuestBrowse()
              .then(() => router.replace(returnTo as Href))
              .catch(() => router.replace(returnTo as Href));
          }}
        >
          로그인 없이 둘러보기
        </PrimaryButton>
        <PrimaryButton
          onPress={() =>
            router.push({
              pathname: '/onboarding',
              params: { returnTo },
            })
          }
          tone="secondary"
        >
          정보 먼저 입력하기
        </PrimaryButton>
        <PrimaryButton
          onPress={() => router.replace(returnTo as Href)}
          tone="secondary"
        >
          {returnTo === '/chat' ? '채팅으로 돌아가기' : '이전 화면으로 돌아가기'}
        </PrimaryButton>
      </Card>
    </Screen>
  );
}
