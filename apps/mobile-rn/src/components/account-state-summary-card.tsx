import { View } from 'react-native';
import { type UnifiedOnboardingProgress } from '@fortune/product-contracts';

import type {
  MobileProfileState,
  PremiumState,
} from '../lib/mobile-app-state';
import { fortuneTheme } from '../lib/theme';
import { AppText } from './app-text';
import { Card } from './card';
import { Chip } from './chip';

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

  return (
    <Card>
      <AppText variant="heading4">{title}</AppText>
      {description ? (
        <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
          {description}
        </AppText>
      ) : null}
      <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
        <Chip
          label={sessionActive ? 'session:active' : 'session:guest'}
          tone={sessionActive ? 'success' : 'neutral'}
        />
        {gate ? <Chip label={`gate:${gate}`} /> : null}
        {onboardingProgress ? (
          <Chip
            label={`soft:${onboardingProgress.softGateCompleted ? 'done' : 'todo'}`}
          />
        ) : null}
        <Chip
          label={`profile:${hasProfileHint ? 'saved' : 'empty'}`}
          tone={hasProfileHint ? 'success' : 'neutral'}
        />
        <Chip
          label={`plan:${premium.status}`}
          tone={premium.status === 'inactive' ? 'neutral' : 'accent'}
        />
        <Chip label={`tokens:${premium.tokenBalance.toLocaleString('ko-KR')}`} />
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
