import { router } from 'expo-router';
import { Pressable, View } from 'react-native';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { Chip } from '../components/chip';
import { PrimaryButton } from '../components/primary-button';
import { Screen } from '../components/screen';
import { captureError } from '../lib/error-reporting';
import { supabase } from '../lib/supabase';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';

export function ProfileScreen() {
  const { onboardingProgress, session } = useAppBootstrap();
  const fallbackName =
    (session?.user.user_metadata.name as string | undefined) ??
    (session?.user.user_metadata.full_name as string | undefined) ??
    session?.user.email ??
    '게스트';
  const provider =
    (session?.user.app_metadata.provider as string | undefined) ?? 'guest';

  async function handleSignOut() {
    try {
      await supabase?.auth.signOut();
      router.replace('/chat');
    } catch (error) {
      await captureError(error, { surface: 'profile:sign-out' });
    }
  }

  if (!session) {
    return (
      <Screen>
        <AppText
          variant="labelMedium"
          color={fortuneTheme.colors.accentSecondary}
        >
          /profile
        </AppText>
        <AppText variant="displaySmall">프로필</AppText>
        <Card>
          <AppText variant="heading4">로그인이 필요합니다</AppText>
          <AppText
            variant="bodyMedium"
            color={fortuneTheme.colors.textSecondary}
          >
            프로필 허브, 구매 복원, 관계 관리 등 계정 기반 표면은 로그인 후 열립니다.
          </AppText>
          <PrimaryButton onPress={() => router.push('/signup')}>
            회원가입 / 로그인
          </PrimaryButton>
          <PrimaryButton onPress={() => router.replace('/chat')} tone="secondary">
            Chat 허브로 이동
          </PrimaryButton>
        </Card>
      </Screen>
    );
  }

  return (
    <Screen>
      <AppText
        variant="labelMedium"
        color={fortuneTheme.colors.accentSecondary}
      >
        /profile
      </AppText>
      <AppText variant="displaySmall">프로필 허브</AppText>

      <Card>
        <AppText variant="labelLarge">{fallbackName}</AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {session.user.email ?? 'email 없음'}
        </AppText>
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          <Chip label={`provider:${provider}`} tone="accent" />
          <Chip
            label={`soft-gate:${onboardingProgress.softGateCompleted ? 'done' : 'todo'}`}
          />
          <Chip
            label={`birth:${onboardingProgress.birthCompleted ? 'done' : 'todo'}`}
          />
          <Chip
            label={`interest:${onboardingProgress.interestCompleted ? 'done' : 'todo'}`}
          />
        </View>
      </Card>

      <Card>
        <AppText variant="heading4">나의 온도</AppText>
        <ProfileMenuRow
          label="프로필 수정"
          description="이름, 출생 정보, 이미지 표면"
          onPress={() => router.push('/profile/edit')}
        />
        <ProfileMenuRow
          label="사주 요약"
          description="사주 요약 및 기반 정보 확인"
          onPress={() => router.push('/profile/saju-summary')}
        />
        <ProfileMenuRow
          label="인간관계"
          description="관계 프로필과 연결 관리"
          onPress={() => router.push('/profile/relationships')}
        />
        <ProfileMenuRow
          label="알림 설정"
          description="푸시 및 딥링크 기본값"
          onPress={() => router.push('/profile/notifications')}
        />
      </Card>

      <Card>
        <AppText variant="heading4">구독 관리</AppText>
        <ProfileMenuRow
          label="구독 및 토큰"
          description="프리미엄 구독과 토큰 패키지"
          onPress={() => router.push('/premium')}
        />
        <ProfileMenuRow
          label="개인정보처리방침"
          description="법률 및 정책 문서"
          onPress={() => router.push('/privacy-policy')}
        />
        <ProfileMenuRow
          label="이용약관"
          description="서비스 이용 정책"
          onPress={() => router.push('/terms-of-service')}
        />
      </Card>

      <Card>
        <AppText variant="heading4">계정</AppText>
        <PrimaryButton onPress={() => void handleSignOut()} tone="secondary">
          로그아웃
        </PrimaryButton>
        <PrimaryButton onPress={() => router.push('/account-deletion')}>
          계정 삭제
        </PrimaryButton>
      </Card>
    </Screen>
  );
}

function ProfileMenuRow({
  description,
  label,
  onPress,
}: {
  description: string;
  label: string;
  onPress: () => void;
}) {
  return (
    <Pressable
      accessibilityRole="button"
      onPress={onPress}
      style={({ pressed }) => ({
        opacity: pressed ? 0.82 : 1,
      })}
    >
      <View
        style={{
          borderBottomColor: fortuneTheme.colors.border,
          borderBottomWidth: 1,
          gap: fortuneTheme.spacing.xs,
          paddingVertical: fortuneTheme.spacing.sm,
        }}
      >
        <AppText variant="bodyMedium">{label}</AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {description}
        </AppText>
      </View>
    </Pressable>
  );
}
