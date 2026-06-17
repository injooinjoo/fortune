/**
 * 운세 결과 생성 직전 토큰 사용 안내 toast.
 *
 * 디자인:
 * - 설문 완료 후 LLM/큐 호출 직전에 1초 미만으로 토큰 사용량만 안내
 * - 별도 확인/취소 버튼 없이 자동으로 이어서 진행
 * - 잔액 부족 시 짧게 안내한 뒤 충전 화면으로 라우팅
 */

import { useEffect } from 'react';
import { View } from 'react-native';

import { type FortuneCatalogEntry } from '@fortune/product-contracts';

import { AppText } from '../../components/app-text';
import { fortuneTheme } from '../../lib/theme';

interface CostConfirmationSheetProps {
  visible: boolean;
  entry: FortuneCatalogEntry | null;
  currentBalance: number | null;
  /** daily 운세 1일 1회 무료. 호출자가 daily_free_fortune 상태로 결정. */
  freeForDaily?: boolean;
  onConfirm: () => void;
  onCancel: () => void;
  onTopUpRequest: () => void;
}

const TOKEN_NOTICE_DURATION_MS = 950;

export function CostConfirmationSheet({
  visible,
  entry,
  currentBalance,
  freeForDaily = false,
  onConfirm,
  onCancel,
  onTopUpRequest,
}: CostConfirmationSheetProps) {
  const effectiveCost = entry && !freeForDaily ? entry.costPoints : 0;
  const insufficient = Boolean(
    entry &&
      !freeForDaily &&
      currentBalance !== null &&
      currentBalance < effectiveCost,
  );

  useEffect(() => {
    if (!visible || !entry) return;

    const timer = setTimeout(() => {
      if (insufficient) {
        onTopUpRequest();
        return;
      }
      onConfirm();
    }, TOKEN_NOTICE_DURATION_MS);

    return () => clearTimeout(timer);
  }, [entry, insufficient, onConfirm, onTopUpRequest, visible]);

  if (!visible || !entry) return null;

  return (
    <View
      pointerEvents="none"
      style={{
        position: 'absolute',
        left: 0,
        right: 0,
        bottom: fortuneTheme.spacing.md,
        alignItems: 'center',
        paddingHorizontal: fortuneTheme.spacing.md,
        zIndex: 999,
      }}
    >
      <View
        style={{
          backgroundColor: fortuneTheme.colors.surfaceSecondary,
          borderRadius: fortuneTheme.radius.full,
          paddingHorizontal: fortuneTheme.spacing.md,
          paddingVertical: fortuneTheme.spacing.sm,
          gap: 2,
          maxWidth: '92%',
        }}
      >
        <AppText
          variant="labelLarge"
          color={fortuneTheme.colors.textPrimary}
          style={{ textAlign: 'center' }}
        >
          {freeForDaily
            ? '오늘은 무료로 볼 수 있어요'
            : insufficient
              ? '토큰이 부족해요'
              : `${entry.costPoints} 토큰이 사용돼요`}
        </AppText>
        <AppText
          variant="bodySmall"
          color={fortuneTheme.colors.textPrimary}
          style={{ textAlign: 'center', opacity: 0.82 }}
        >
          {insufficient
            ? `현재 잔액 ${currentBalance ?? 0} 토큰`
            : freeForDaily
              ? `다음부터 ${entry.costPoints} 토큰`
              : `현재 잔액 ${currentBalance ?? '...'} 토큰`}
        </AppText>
      </View>
    </View>
  );
}
