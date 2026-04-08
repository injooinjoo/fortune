import { View } from 'react-native';
import { type UnifiedOnboardingProgress } from '@fortune/product-contracts';

import type {
  MobileProfileState,
  PremiumState,
} from '../lib/mobile-app-state';
import { fortuneTheme } from '../lib/theme';
import { AppText } from './app-text';
import { Card } from './card';

interface AccountStateSummaryCardProps {
  title?: string;
  description?: string;
  sessionActive: boolean;
  gate?: string;
  onboardingProgress?: UnifiedOnboardingProgress;
  profile: MobileProfileState;
  premium: PremiumState;
  emptyCopy: string;
}

export function AccountStateSummaryCard({
  description,
  emptyCopy,
  gate,
  onboardingProgress,
  premium,
  profile,
  sessionActive,
  title = '저장된 상태',
}: AccountStateSummaryCardProps) {
  const hasProfileHint = Boolean(
    profile.displayName ||
      profile.birthDate ||
      profile.birthTime ||
      profile.mbti ||
      profile.bloodType,
  );
  const tokenBalanceLabel = premium.isUnlimited
    ? '보유 토큰 무제한'
    : `보유 토큰 ${premium.tokenBalance.toLocaleString('ko-KR')}개`;

  return (
    <Card>
      <AppText variant="heading4">{title}</AppText>
      {description ? (
        <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
          {description}
        </AppText>
      ) : null}
      <View style={{ gap: 8 }}>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {sessionActive ? '로그인한 상태로 보고 있어요.' : '게스트 상태로 보고 있어요.'}
        </AppText>
        {gate ? (
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {gate === 'ready'
              ? '기본 확인 단계가 끝났어요.'
              : '기본 확인 단계가 아직 진행 중이에요.'}
          </AppText>
        ) : null}
        {onboardingProgress ? (
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {onboardingProgress.softGateCompleted
              ? '첫 흐름 확인은 완료됐어요.'
              : '첫 흐름 확인은 아직 진행 중이에요.'}
          </AppText>
        ) : null}
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {hasProfileHint ? '저장된 프로필 정보가 있어요.' : emptyCopy}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {premium.status === 'inactive'
            ? '구독 전 상태예요.'
            : premium.status === 'subscription'
              ? '구독이 활성화되어 있어요.'
              : '평생 이용 상태예요.'}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {tokenBalanceLabel}
        </AppText>
      </View>
      {hasProfileHint ? (
        <View style={{ gap: 8 }}>
          <AppText variant="labelLarge">
            {profile.displayName || '저장된 이름 없음'}
          </AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {[
              profile.birthDate ? `생년월일 ${profile.birthDate}` : null,
              profile.birthTime ? `시간 ${profile.birthTime}` : null,
              profile.mbti ? `MBTI ${profile.mbti}` : null,
              profile.bloodType ? `혈액형 ${profile.bloodType}` : null,
            ]
              .filter(Boolean)
              .join(' · ')}
          </AppText>
        </View>
      ) : (
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {emptyCopy}
        </AppText>
      )}
    </Card>
  );
}
