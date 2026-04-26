import { useEffect, useState } from 'react';

import { Ionicons } from '@expo/vector-icons';
import { router, useLocalSearchParams, type Href } from 'expo-router';
import { Alert, Pressable, View } from 'react-native';

import { AppleAuthButton } from '../components/apple-auth-button';
import { AppText } from '../components/app-text';
import { Card } from '../components/card';
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
import { getLastAuthenticatedUserId } from '../lib/storage';
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
  // TODO: 카카오/네이버 OAuth 연동 완료 후 복원
  // {
  //   id: 'kakao',
  //   label: '카카오 로그인',
  //   note: '카카오 계정으로 빠르게 시작하고 추천 흐름을 이어갑니다.',
  // },
  // {
  //   id: 'naver',
  //   label: '네이버 로그인',
  //   note: '네이버 계정으로 프로필과 저장 기록을 연결합니다.',
  // },
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
  const [otherMethodsExpanded, setOtherMethodsExpanded] = useState(false);
  // 가입 필수 동의 3종: 이용약관, 개인정보처리방침, 만 14세 이상 확인.
  // 마케팅 수신은 선택. 필수 3종 모두 체크돼야 소셜/이메일 가입 버튼 활성화.
  // 단, "이미 한 번이라도 이 디바이스에서 로그인한 적 있는 사용자" 는 가입이
  // 아니라 로그인 흐름이므로 동의 UI 자체를 건너뛴다 (필수 동의는 최초 가입
  // 시점에 이미 받았다는 전제).
  const [isReturningUser, setIsReturningUser] = useState<boolean | null>(null);
  const [agreedTerms, setAgreedTerms] = useState(false);
  const [agreedPrivacy, setAgreedPrivacy] = useState(false);
  const [agreedAge, setAgreedAge] = useState(false);
  const [agreedMarketing, setAgreedMarketing] = useState(false);
  // returning user 는 동의 강제 안 함. 신규 가입자만 필수 3종 체크 요구.
  const requiredConsentGiven =
    isReturningUser === true ||
    (agreedTerms && agreedPrivacy && agreedAge);
  const allConsentToggled = agreedTerms && agreedPrivacy && agreedAge && agreedMarketing;
  const showConsentBlock = isReturningUser === false;

  useEffect(() => {
    let mounted = true;
    getLastAuthenticatedUserId()
      .then((lastId) => {
        if (mounted) setIsReturningUser(Boolean(lastId));
      })
      .catch((error: unknown) => {
        // 조회 실패 시 안전 측 — 신규 가입자로 취급 (동의 UI 노출).
        if (mounted) setIsReturningUser(false);
        captureError(error, {
          surface: 'signup:detect-returning-user',
        }).catch(() => undefined);
      });
    return () => {
      mounted = false;
    };
  }, []);
  const { session, status: bootstrapStatus } = useAppBootstrap();
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
    if (!requiredConsentGiven) {
      Alert.alert(
        '약관 동의가 필요해요',
        '계속하려면 이용약관, 개인정보처리방침, 만 14세 이상 확인에 모두 체크해 주세요.',
      );
      return;
    }
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
      centerContent
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

      {showConsentBlock ? (
        <Card>
          <AppText variant="heading4">약관 동의</AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            가입을 위해 아래 항목에 동의해 주세요.
          </AppText>

          <Pressable
            accessibilityRole="checkbox"
            accessibilityState={{ checked: allConsentToggled }}
            onPress={() => {
              confirmAction();
              const next = !allConsentToggled;
              setAgreedTerms(next);
              setAgreedPrivacy(next);
              setAgreedAge(next);
              setAgreedMarketing(next);
            }}
            style={({ pressed }) => ({
              alignItems: 'center',
              flexDirection: 'row',
              gap: 10,
              opacity: pressed ? 0.72 : 1,
              paddingVertical: 8,
            })}
          >
            <Ionicons
              color={
                allConsentToggled
                  ? fortuneTheme.colors.accentTertiary
                  : fortuneTheme.colors.textTertiary
              }
              name={allConsentToggled ? 'checkbox' : 'square-outline'}
              size={22}
            />
            <AppText variant="bodyMedium" style={{ fontWeight: '700' }}>
              전체 동의
            </AppText>
          </Pressable>

          <View
            style={{
              height: 1,
              backgroundColor: fortuneTheme.colors.divider,
              marginVertical: 4,
            }}
          />

          <ConsentRow
            checked={agreedAge}
            label="만 14세 이상입니다 (필수)"
            onToggle={() => {
              confirmAction();
              setAgreedAge((v) => !v);
            }}
          />
          <ConsentRow
            checked={agreedTerms}
            label="이용약관에 동의합니다 (필수)"
            linkLabel="약관 보기"
            onLinkPress={() => router.push('/terms-of-service')}
            onToggle={() => {
              confirmAction();
              setAgreedTerms((v) => !v);
            }}
          />
          <ConsentRow
            checked={agreedPrivacy}
            label="개인정보처리방침에 동의합니다 (필수)"
            linkLabel="방침 보기"
            onLinkPress={() => router.push('/privacy-policy')}
            onToggle={() => {
              confirmAction();
              setAgreedPrivacy((v) => !v);
            }}
          />
          <ConsentRow
            checked={agreedMarketing}
            label="마케팅·혜택 알림 수신 (선택)"
            onToggle={() => {
              confirmAction();
              setAgreedMarketing((v) => !v);
            }}
          />
        </Card>
      ) : null}

      <Card>
        <AppText variant="heading4">연결하고 바로 시작</AppText>
        {authMessage ? (
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {authMessage}
          </AppText>
        ) : null}
        {!requiredConsentGiven ? (
          <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
            약관 동의 후 계정 연결이 가능합니다.
          </AppText>
        ) : null}
        {authOptions.map((option) => (
          <View key={option.id}>
            {option.id === 'apple' ? (
              <AppleAuthButton
                disabled={
                  activeProviderId === option.id || !requiredConsentGiven
                }
                label={option.label}
                onPress={() => void handleSocialAuthStart(option.id)}
              />
            ) : (
              <SocialAuthPillButton
                disabled={
                  activeProviderId === option.id || !requiredConsentGiven
                }
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
        <Pressable
          accessibilityLabel="다른 방법으로 시작"
          accessibilityRole="button"
          accessibilityState={{ expanded: otherMethodsExpanded }}
          onPress={() => {
            confirmAction();
            setOtherMethodsExpanded((prev) => !prev);
          }}
          style={({ pressed }) => ({
            alignItems: 'center',
            flexDirection: 'row',
            justifyContent: 'space-between',
            opacity: pressed ? 0.72 : 1,
          })}
        >
          <AppText variant="heading4">다른 방법으로 시작</AppText>
          <Ionicons
            color={fortuneTheme.colors.textSecondary}
            name={otherMethodsExpanded ? 'chevron-up' : 'chevron-down'}
            size={20}
          />
        </Pressable>
        {otherMethodsExpanded ? (
          <>
            <Pressable
              accessibilityLabel="이메일로 시작"
              accessibilityRole="button"
              onPress={() => {
                if (!requiredConsentGiven) {
                  Alert.alert(
                    '약관 동의가 필요해요',
                    '계속하려면 이용약관, 개인정보처리방침, 만 14세 이상 확인에 모두 체크해 주세요.',
                  );
                  return;
                }
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
                if (!requiredConsentGiven) {
                  Alert.alert(
                    '약관 동의가 필요해요',
                    '계속하려면 이용약관, 개인정보처리방침, 만 14세 이상 확인에 모두 체크해 주세요.',
                  );
                  return;
                }
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
          </>
        ) : null}
      </Card>
    </Screen>
  );
}

function ConsentRow({
  checked,
  label,
  linkLabel,
  onLinkPress,
  onToggle,
}: {
  checked: boolean;
  label: string;
  linkLabel?: string;
  onLinkPress?: () => void;
  onToggle: () => void;
}) {
  return (
    <View
      style={{
        alignItems: 'center',
        flexDirection: 'row',
        gap: 10,
        paddingVertical: 6,
      }}
    >
      <Pressable
        accessibilityRole="checkbox"
        accessibilityState={{ checked }}
        onPress={onToggle}
        style={({ pressed }) => ({
          alignItems: 'center',
          flex: 1,
          flexDirection: 'row',
          gap: 10,
          opacity: pressed ? 0.72 : 1,
        })}
      >
        <Ionicons
          color={
            checked
              ? fortuneTheme.colors.accentTertiary
              : fortuneTheme.colors.textTertiary
          }
          name={checked ? 'checkbox' : 'square-outline'}
          size={20}
        />
        <AppText
          variant="bodySmall"
          color={fortuneTheme.colors.textSecondary}
          style={{ flex: 1 }}
        >
          {label}
        </AppText>
      </Pressable>
      {linkLabel && onLinkPress ? (
        <Pressable
          accessibilityRole="link"
          onPress={onLinkPress}
          style={({ pressed }) => ({ opacity: pressed ? 0.6 : 1 })}
        >
          <AppText
            variant="labelSmall"
            color={fortuneTheme.colors.accentTertiary}
            style={{ textDecorationLine: 'underline' }}
          >
            {linkLabel}
          </AppText>
        </Pressable>
      ) : null}
    </View>
  );
}
