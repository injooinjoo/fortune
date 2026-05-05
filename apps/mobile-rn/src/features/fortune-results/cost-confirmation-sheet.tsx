/**
 * PR-B2: 운세 결과 생성 직전 비용 확인 sheet.
 *
 * 디자인:
 * - 사용자가 메뉴 카드 탭 → 본 sheet 노출 → 확인/취소
 * - 잔액 부족 시 본 sheet 안에서 "충전하기" 안내 + /premium 으로 라우팅
 * - daily 운세는 1일 1회 무료 — 본 sheet 가 자동 "오늘 무료" 모드 (cost 0)
 *
 * 기존 흐름과 차이:
 * - 기존: 침묵 차감 (생성 후 실패 시 텍스트 메시지로 통보)
 * - PR-B2: 사전 확인 modal — 사용자가 비용 인지 후 진행
 *
 * 사용:
 * ```tsx
 * <CostConfirmationSheet
 *   visible={visible}
 *   entry={selectedEntry}
 *   currentBalance={balance}
 *   isUnlimited={isUnlimited}
 *   freeForDaily={daily첫사용여부}
 *   onConfirm={() => triggerGeneration()}
 *   onCancel={() => setVisible(false)}
 *   onTopUpRequest={() => router.push('/premium')}
 * />
 * ```
 */

import { Modal, Pressable, View } from 'react-native';

import { type FortuneCatalogEntry } from '@fortune/product-contracts';

import { AppText } from '../../components/app-text';
import { fortuneTheme } from '../../lib/theme';

interface CostConfirmationSheetProps {
  visible: boolean;
  entry: FortuneCatalogEntry | null;
  currentBalance: number | null;
  isUnlimited: boolean;
  /** daily 운세 1일 1회 무료. 호출자가 daily_free_fortune 상태로 결정. */
  freeForDaily?: boolean;
  onConfirm: () => void;
  onCancel: () => void;
  onTopUpRequest: () => void;
}

export function CostConfirmationSheet({
  visible,
  entry,
  currentBalance,
  isUnlimited,
  freeForDaily = false,
  onConfirm,
  onCancel,
  onTopUpRequest,
}: CostConfirmationSheetProps) {
  if (!entry) return null;

  const effectiveCost = freeForDaily ? 0 : entry.costPoints;
  const insufficient =
    !isUnlimited &&
    !freeForDaily &&
    currentBalance !== null &&
    currentBalance < effectiveCost;

  return (
    <Modal
      visible={visible}
      transparent
      animationType="fade"
      onRequestClose={onCancel}
      accessibilityViewIsModal
    >
      <View
        style={{
          flex: 1,
          backgroundColor: 'rgba(0,0,0,0.55)',
          justifyContent: 'flex-end',
        }}
      >
        <Pressable
          style={{ flex: 1 }}
          accessibilityRole="button"
          accessibilityLabel="시트 닫기"
          onPress={onCancel}
        />
        <View
          style={{
            backgroundColor: fortuneTheme.colors.surface,
            borderTopLeftRadius: fortuneTheme.radius.xl,
            borderTopRightRadius: fortuneTheme.radius.xl,
            padding: fortuneTheme.spacing.md,
            gap: fortuneTheme.spacing.sm,
          }}
        >
          <AppText variant="heading3" color={fortuneTheme.colors.textPrimary}>
            {entry.displayName}
          </AppText>
          <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
            {entry.shortDesc}
          </AppText>

          <View
            style={{
              backgroundColor: fortuneTheme.colors.surfaceSecondary,
              borderRadius: fortuneTheme.radius.lg,
              padding: fortuneTheme.spacing.sm,
              gap: 4,
            }}
          >
            {isUnlimited ? (
              <AppText variant="labelLarge" color={fortuneTheme.colors.textPrimary}>
                무제한 이용권 — 차감 없음
              </AppText>
            ) : freeForDaily ? (
              <>
                <AppText variant="labelLarge" color={fortuneTheme.colors.textPrimary}>
                  오늘 무료
                </AppText>
                <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                  데일리 운세 1일 1회 무료. 다음부터는 {entry.costPoints} 포인트 차감.
                </AppText>
              </>
            ) : (
              <>
                <AppText variant="labelLarge" color={fortuneTheme.colors.textPrimary}>
                  {entry.costPoints} 포인트 차감
                </AppText>
                <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                  현재 잔액: {currentBalance ?? '...'} 포인트
                </AppText>
              </>
            )}
          </View>

          {insufficient ? (
            <Pressable
              accessibilityRole="button"
              onPress={onTopUpRequest}
              style={({ pressed }) => ({
                backgroundColor: fortuneTheme.colors.ctaBackground,
                borderRadius: fortuneTheme.radius.full,
                paddingVertical: 14,
                opacity: pressed ? 0.84 : 1,
              })}
            >
              <AppText
                variant="labelLarge"
                color={fortuneTheme.colors.ctaForeground}
                style={{ textAlign: 'center' }}
              >
                포인트 충전하기
              </AppText>
            </Pressable>
          ) : (
            <Pressable
              accessibilityRole="button"
              onPress={onConfirm}
              style={({ pressed }) => ({
                backgroundColor: fortuneTheme.colors.ctaBackground,
                borderRadius: fortuneTheme.radius.full,
                paddingVertical: 14,
                opacity: pressed ? 0.84 : 1,
              })}
            >
              <AppText
                variant="labelLarge"
                color={fortuneTheme.colors.ctaForeground}
                style={{ textAlign: 'center' }}
              >
                {freeForDaily ? '무료로 시작' : '확인하고 진행'}
              </AppText>
            </Pressable>
          )}

          <Pressable
            accessibilityRole="button"
            onPress={onCancel}
            style={({ pressed }) => ({
              paddingVertical: 12,
              opacity: pressed ? 0.84 : 1,
            })}
          >
            <AppText
              variant="labelLarge"
              color={fortuneTheme.colors.textSecondary}
              style={{ textAlign: 'center' }}
            >
              취소
            </AppText>
          </Pressable>
        </View>
      </View>
    </Modal>
  );
}
