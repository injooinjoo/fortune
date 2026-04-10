import { useMemo, useState, useCallback } from 'react';

import { Ionicons } from '@expo/vector-icons';
import { router } from 'expo-router';
import { Linking, Platform, Pressable, View } from 'react-native';
import type { Href } from 'expo-router';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { PrimaryButton } from '../components/primary-button';
import { Screen } from '../components/screen';
import { captureError } from '../lib/error-reporting';
import { supabase } from '../lib/supabase';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';
import { useMobileAppState } from '../providers/mobile-app-state-provider';

const APP_VERSION = '2.3.1';

const ZODIAC_ANIMALS = ['쥐', '소', '호랑이', '토끼', '용', '뱀', '말', '양', '원숭이', '닭', '개', '돼지'];
const ZODIAC_EMOJI = ['🐭', '🐄', '🐯', '🐰', '🐉', '🐍', '🐴', '🐑', '🐵', '🐓', '🐶', '🐷'];

function getZodiacAnimal(birthDate: string) {
  const year = new Date(birthDate).getFullYear();
  if (!year || year < 1900) return null;
  const idx = (year - 4) % 12;
  return { name: ZODIAC_ANIMALS[idx], emoji: ZODIAC_EMOJI[idx], year };
}

function getConstellation(birthDate: string) {
  const d = new Date(birthDate);
  const m = d.getMonth() + 1;
  const day = d.getDate();
  const signs = [
    { name: '물병자리', emoji: '♒', start: [1, 20] },
    { name: '물고기자리', emoji: '♓', start: [2, 19] },
    { name: '양자리', emoji: '♈', start: [3, 21] },
    { name: '황소자리', emoji: '♉', start: [4, 20] },
    { name: '쌍둥이자리', emoji: '♊', start: [5, 21] },
    { name: '게자리', emoji: '♋', start: [6, 22] },
    { name: '사자자리', emoji: '♌', start: [7, 23] },
    { name: '처녀자리', emoji: '♍', start: [8, 23] },
    { name: '천칭자리', emoji: '♎', start: [9, 23] },
    { name: '전갈자리', emoji: '♏', start: [10, 23] },
    { name: '사수자리', emoji: '♐', start: [11, 22] },
    { name: '염소자리', emoji: '♑', start: [12, 22] },
  ];
  for (let i = signs.length - 1; i >= 0; i--) {
    const [sm, sd] = signs[i]!.start;
    if (m > sm! || (m === sm && day >= sd!)) return signs[i]!;
  }
  return signs[signs.length - 1]!;
}

export function ProfileScreen() {
  const [isRestoring, setIsRestoring] = useState(false);
  const [themeMode, setThemeMode] = useState<'system' | 'light' | 'dark'>('system');
  const { session } = useAppBootstrap();
  const { restorePurchases, state, syncRemoteProfile } = useMobileAppState();

  const savedName =
    state.profile.displayName.trim() ||
    (session?.user.user_metadata.name as string | undefined) ||
    (session?.user.user_metadata.full_name as string | undefined) ||
    session?.user.email ||
    '사용자';

  const email = session?.user.email ?? null;

  const authProvider = useMemo(() => {
    const provider = session?.user.app_metadata.provider;
    if (provider === 'google') return 'Google';
    if (provider === 'apple') return 'Apple';
    if (provider === 'kakao') return 'Kakao';
    if (provider) return '이메일';
    return null;
  }, [session]);

  const tokenLabel = state.premium.isUnlimited
    ? '∞'
    : `${state.premium.tokenBalance}`;

  const initial = savedName.charAt(0).toUpperCase() || 'U';

  async function handleSignOut() {
    try {
      await supabase?.auth.signOut();
      router.replace('/chat');
    } catch (error) {
      await captureError(error, { surface: 'profile:sign-out' });
    }
  }

  async function handleRestorePurchases() {
    try {
      setIsRestoring(true);
      await restorePurchases();
    } catch (error) {
      await captureError(error, { surface: 'profile:restore-purchases' });
    } finally {
      setIsRestoring(false);
    }
  }

  async function handleOpenSubscriptionManagement() {
    const url =
      Platform.OS === 'ios'
        ? 'https://apps.apple.com/account/subscriptions'
        : 'https://play.google.com/store/account/subscriptions';

    await Linking.openURL(url).catch((error) =>
      captureError(error, { surface: 'profile:subscription-management' }),
    );
  }

  return (
    <Screen
      header={
        <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'center', position: 'relative' }}>
          <Pressable
            accessibilityLabel="뒤로 가기"
            onPress={() => router.canGoBack() ? router.back() : router.replace('/chat')}
            style={({ pressed }) => ({
              position: 'absolute',
              left: 0,
              opacity: pressed ? 0.6 : 1,
              padding: 4,
            })}
          >
            <Ionicons name="chevron-back" size={22} color={fortuneTheme.colors.accentSecondary} />
          </Pressable>
          <AppText variant="heading3" style={{ fontWeight: '700' }}>
            프로필
          </AppText>
        </View>
      }
    >
      {/* Profile Summary Card */}
      <Card style={{ alignItems: 'center', paddingVertical: 28 }}>
        <View
          style={{
            width: 80,
            height: 80,
            borderRadius: 40,
            backgroundColor: fortuneTheme.colors.ctaBackground + '30',
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          <AppText
            variant="displaySmall"
            color={fortuneTheme.colors.ctaBackground}
            style={{ fontWeight: '800', fontSize: 32 }}
          >
            {initial}
          </AppText>
        </View>
        <AppText variant="heading4" style={{ fontWeight: '700', marginTop: 14 }}>
          {savedName}
        </AppText>
        {email ? (
          <AppText
            variant="bodySmall"
            color={fortuneTheme.colors.textSecondary}
            style={{ marginTop: 4 }}
          >
            {email}
          </AppText>
        ) : null}
        <View style={{ marginTop: 16 }}>
          <PrimaryButton onPress={() => router.push('/profile/edit')}>
            프로필 수정
          </PrimaryButton>
        </View>
      </Card>

      {/* User Info Grid */}
      <ProfileInfoGrid
        profile={state.profile}
        tokenLabel={tokenLabel}
        messageCount={state.chat.sentMessageCount}
      />

      {/* 나의 온도 */}
      <SectionLabel>나의 온도</SectionLabel>
      <Card style={{ paddingHorizontal: 0, paddingVertical: 0, overflow: 'hidden' }}>
        <IconMenuTile
          icon="ellipse-outline"
          title="사주 요약"
          onPress={() => router.push('/profile/saju-summary')}
        />
        <IconMenuTile
          icon="people-outline"
          title="인간관계"
          onPress={() => router.push('/profile/relationships')}
        />
        <IconMenuTile
          icon="notifications-outline"
          title="알림 설정"
          onPress={() => router.push('/profile/notifications')}
          showDivider={false}
        />
      </Card>

      {/* 구독 관리 */}
      <SectionLabel>구독 관리</SectionLabel>
      <Card style={{ paddingHorizontal: 0, paddingVertical: 0, overflow: 'hidden' }}>
        <IconMenuTile
          icon="star-outline"
          title="구독 및 토큰"
          onPress={() => router.push('/premium')}
        />
        <IconMenuTile
          icon="refresh-outline"
          title={isRestoring ? '구매 복원 중...' : '구매 복원'}
          onPress={() => void handleRestorePurchases()}
        />
        <IconMenuTile
          icon="card-outline"
          title="구독 관리"
          onPress={() => void handleOpenSubscriptionManagement()}
          showDivider={false}
        />
      </Card>

      {/* 설정 */}
      <SectionLabel>설정</SectionLabel>
      <Card style={{ paddingHorizontal: 16, paddingVertical: 14, gap: 16 }}>
        {/* 테마 모드 */}
        <View
          style={{
            flexDirection: 'row',
            alignItems: 'center',
            justifyContent: 'space-between',
          }}
        >
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 10 }}>
            <Ionicons
              name="moon-outline"
              size={18}
              color={fortuneTheme.colors.textSecondary}
            />
            <AppText variant="bodyMedium">테마 모드</AppText>
          </View>
          <View style={{ flexDirection: 'row', gap: 4 }}>
            <ThemeChip label="시스템" active={themeMode === 'system'} onPress={() => setThemeMode('system')} />
            <ThemeChip label="라이트" active={themeMode === 'light'} onPress={() => setThemeMode('light')} />
            <ThemeChip label="다크" active={themeMode === 'dark'} onPress={() => setThemeMode('dark')} />
          </View>
        </View>

        {/* 계정 연결 */}
        {authProvider ? (
          <View
            style={{
              flexDirection: 'row',
              alignItems: 'center',
              justifyContent: 'space-between',
            }}
          >
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 10 }}>
              <Ionicons
                name="link-outline"
                size={18}
                color={fortuneTheme.colors.textSecondary}
              />
              <AppText variant="bodyMedium">계정 연결</AppText>
            </View>
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
              <View
                style={{
                  backgroundColor: fortuneTheme.colors.surfaceSecondary,
                  borderRadius: fortuneTheme.radius.sm,
                  paddingHorizontal: 10,
                  paddingVertical: 4,
                }}
              >
                <AppText variant="labelSmall" color={fortuneTheme.colors.textSecondary}>
                  {authProvider}
                </AppText>
              </View>
              <Ionicons
                name="chevron-forward"
                size={16}
                color={fortuneTheme.colors.textTertiary}
              />
            </View>
          </View>
        ) : null}
      </Card>

      {/* 정보 */}
      <SectionLabel>정보</SectionLabel>
      <Card style={{ paddingHorizontal: 0, paddingVertical: 0, overflow: 'hidden' }}>
        <IconMenuTile
          icon="document-text-outline"
          title="개인정보처리방침"
          onPress={() => router.push('/privacy-policy')}
        />
        <IconMenuTile
          icon="document-outline"
          title="이용약관"
          onPress={() => router.push('/terms-of-service')}
        />
        <IconMenuTile
          icon="alert-circle-outline"
          title="면책 조항"
          onPress={() => router.push('/disclaimer')}
          showDivider={false}
        />
      </Card>

      {/* 로그인 / 계정 */}
      {!session ? (
        <Card style={{ alignItems: 'center', paddingVertical: 24 }}>
          <Ionicons
            name="lock-closed-outline"
            size={28}
            color={fortuneTheme.colors.textSecondary}
          />
          <AppText
            variant="bodySmall"
            color={fortuneTheme.colors.textSecondary}
            style={{ textAlign: 'center', marginTop: 8 }}
          >
            로그인하면 프로필을 클라우드에 동기화할 수 있어요.
          </AppText>
          <PrimaryButton
            onPress={() =>
              router.push({
                pathname: '/signup',
                params: { returnTo: '/profile' },
              })
            }
          >
            회원가입 / 로그인
          </PrimaryButton>
        </Card>
      ) : (
        <View style={{ alignItems: 'center', gap: 8, marginTop: 12 }}>
          <Pressable
            onPress={() => void handleSignOut()}
            style={({ pressed }) => ({ opacity: pressed ? 0.6 : 1 })}
          >
            <AppText
              variant="bodyMedium"
              color={fortuneTheme.colors.textSecondary}
            >
              로그아웃
            </AppText>
          </Pressable>
          <Pressable
            onPress={() => router.push('/account-deletion')}
            style={({ pressed }) => ({ opacity: pressed ? 0.6 : 1 })}
          >
            <AppText
              variant="bodySmall"
              color={fortuneTheme.colors.textTertiary}
            >
              계정 삭제
            </AppText>
          </Pressable>
        </View>
      )}

      {/* Version */}
      <AppText
        variant="caption"
        color={fortuneTheme.colors.textTertiary}
        style={{ textAlign: 'center', marginTop: 4 }}
      >
        v{APP_VERSION}
      </AppText>
    </Screen>
  );
}

function ProfileInfoGrid({
  profile,
  tokenLabel,
  messageCount,
}: {
  profile: { displayName: string; birthDate: string; birthTime: string; mbti: string; bloodType: string };
  tokenLabel: string;
  messageCount: number;
}) {
  const zodiac = profile.birthDate ? getZodiacAnimal(profile.birthDate) : null;
  const constellation = profile.birthDate ? getConstellation(profile.birthDate) : null;

  const formatBirthDate = (bd: string) => {
    if (!bd) return null;
    const d = new Date(bd);
    if (isNaN(d.getTime())) return bd;
    return `${d.getFullYear()}.${d.getMonth() + 1}.${d.getDate()}`;
  };

  const items: { label: string; value: string; icon: string; editField?: string }[] = [
    { label: '이름', value: profile.displayName || '—', icon: '👤', editField: 'displayName' },
    { label: '생년월일', value: formatBirthDate(profile.birthDate) || '—', icon: '📅', editField: 'birthDate' },
    { label: '태어난 시간', value: profile.birthTime || '—', icon: '🕐', editField: 'birthTime' },
    { label: 'MBTI', value: profile.mbti || '—', icon: '🧠', editField: 'mbti' },
    { label: '혈액형', value: profile.bloodType ? `${profile.bloodType}형` : '—', icon: '🩸', editField: 'bloodType' },
    { label: '띠', value: zodiac ? `${zodiac.emoji} ${zodiac.name}띠` : '—', icon: '' },
    { label: '별자리', value: constellation && profile.birthDate ? `${constellation.emoji} ${constellation.name}` : '—', icon: '' },
    { label: '토큰', value: tokenLabel, icon: '💎' },
  ];

  return (
    <Card style={{ paddingHorizontal: 0, paddingVertical: 8, gap: 0 }}>
      {items.map((item, idx) => (
        <Pressable
          key={item.label}
          onPress={item.editField ? () => router.push('/profile/edit' as Href) : undefined}
          style={({ pressed }) => ({
            flexDirection: 'row',
            alignItems: 'center',
            justifyContent: 'space-between',
            paddingHorizontal: 16,
            paddingVertical: 13,
            opacity: pressed && item.editField ? 0.7 : 1,
            borderBottomWidth: idx < items.length - 1 ? 1 : 0,
            borderBottomColor: fortuneTheme.colors.border,
          })}
        >
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
            {item.icon ? (
              <AppText style={{ fontSize: 16 }}>{item.icon}</AppText>
            ) : null}
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              {item.label}
            </AppText>
          </View>
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
            <AppText
              variant="bodyMedium"
              style={{ fontWeight: '600' }}
              color={item.value === '—' ? fortuneTheme.colors.textTertiary : undefined}
            >
              {item.value}
            </AppText>
            {item.editField ? (
              <Ionicons name="chevron-forward" size={14} color={fortuneTheme.colors.textTertiary} />
            ) : null}
          </View>
        </Pressable>
      ))}
    </Card>
  );
}

function SectionLabel({ children }: { children: string }) {
  return (
    <AppText
      variant="labelLarge"
      style={{ marginTop: 4, fontWeight: '700' }}
    >
      {children}
    </AppText>
  );
}

function IconMenuTile({
  icon,
  title,
  onPress,
  showDivider = true,
}: {
  icon: keyof typeof Ionicons.glyphMap;
  title: string;
  onPress: () => void;
  showDivider?: boolean;
}) {
  return (
    <Pressable
      accessibilityRole="button"
      onPress={onPress}
      style={({ pressed }) => ({
        flexDirection: 'row',
        alignItems: 'center',
        paddingHorizontal: 16,
        paddingVertical: 16,
        opacity: pressed ? 0.7 : 1,
        borderBottomWidth: showDivider ? 1 : 0,
        borderBottomColor: fortuneTheme.colors.border,
      })}
    >
      <Ionicons
        name={icon}
        size={18}
        color={fortuneTheme.colors.textSecondary}
        style={{ marginRight: 12 }}
      />
      <AppText variant="bodyMedium" style={{ flex: 1 }}>
        {title}
      </AppText>
      <Ionicons
        name="chevron-forward"
        size={16}
        color={fortuneTheme.colors.textTertiary}
      />
    </Pressable>
  );
}

function ThemeChip({ label, active = false, onPress }: { label: string; active?: boolean; onPress?: () => void }) {
  return (
    <Pressable
      onPress={onPress}
      style={({ pressed }) => ({
        backgroundColor: active
          ? fortuneTheme.colors.surfaceSecondary
          : 'transparent',
        borderRadius: fortuneTheme.radius.sm,
        paddingHorizontal: 10,
        paddingVertical: 4,
        opacity: pressed ? 0.7 : 1,
      })}
    >
      <AppText
        variant="labelSmall"
        color={
          active
            ? fortuneTheme.colors.textPrimary
            : fortuneTheme.colors.textTertiary
        }
      >
        {label}
      </AppText>
    </Pressable>
  );
}
