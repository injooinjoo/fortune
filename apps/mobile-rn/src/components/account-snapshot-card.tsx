import { type UnifiedOnboardingProgress } from '@fortune/product-contracts';

import type {
  MobileProfileState,
  PremiumState,
} from '../lib/mobile-app-state';
import { AccountStateSummaryCard } from './account-state-summary-card';

interface AccountSnapshotCardProps {
  title?: string;
  description?: string;
  emptyCopy?: string;
  sessionActive: boolean;
  gate?: string;
  profile: MobileProfileState;
  premium: PremiumState;
  onboardingProgress?: UnifiedOnboardingProgress;
}

export function AccountSnapshotCard(props: AccountSnapshotCardProps) {
  const { emptyCopy, ...rest } = props;

  return (
    <AccountStateSummaryCard
      emptyCopy={emptyCopy ?? '저장된 프로필이 아직 없습니다.'}
      {...rest}
    />
  );
}
