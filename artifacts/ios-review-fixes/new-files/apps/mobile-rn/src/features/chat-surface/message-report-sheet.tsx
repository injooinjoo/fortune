/**
 * MessageReportSheet — AI 캐릭터 응답 신고용 모달 시트.
 *
 * Apple 5.2.3 — UGC 신고 경로를 앱 내에 제공해야 한다. 사용자가 assistant
 * bubble을 long-press 하면 호출되어 6개 사유 중 하나를 선택 후 submit.
 *
 * 성공 시: `supabase.functions.invoke('report-message', ...)` → 200 → 토스트 후 닫힘.
 * 실패 시: Alert 로 피드백. 재시도 가능.
 */
import { useEffect, useState } from 'react';
import { ActivityIndicator, Alert, Modal, Pressable, View } from 'react-native';

import { AppText } from '../../components/app-text';
import { PrimaryButton } from '../../components/primary-button';
import { captureError } from '../../lib/error-reporting';
import { supabase } from '../../lib/supabase';
import { fortuneTheme } from '../../lib/theme';

type ReasonCode =
  | 'sexual'
  | 'violence'
  | 'self_harm'
  | 'minor'
  | 'hate'
  | 'spam'
  | 'other';

const REASONS: ReadonlyArray<{ code: ReasonCode; label: string }> = [
  { code: 'sexual', label: '성적/선정적 내용' },
  { code: 'violence', label: '폭력/잔혹' },
  { code: 'self_harm', label: '자해/자살 조장' },
  { code: 'minor', label: '미성년 관련 부적절' },
  { code: 'hate', label: '혐오/차별' },
  { code: 'spam', label: '스팸/광고' },
  { code: 'other', label: '기타' },
];

interface MessageReportSheetProps {
  visible: boolean;
  characterId: string;
  messageText: string;
  messageId?: string | null;
  onClose: () => void;
}

export function MessageReportSheet({
  visible,
  characterId,
  messageText,
  messageId,
  onClose,
}: MessageReportSheetProps) {
  const [selected, setSelected] = useState<ReasonCode | null>(null);
  const [submitting, setSubmitting] = useState(false);

  // 시트가 닫히면 사유 선택 초기화 — 다음 신고에서 이전 선택이 남지 않도록.
  useEffect(() => {
    if (!visible) {
      setSelected(null);
    }
  }, [visible]);

  async function handleSubmit() {
    if (!selected) return;
    if (!supabase) {
      Alert.alert('오프라인', '네트워크 연결 후 다시 시도해 주세요.');
      return;
    }
    setSubmitting(true);
    try {
      const { data, error } = await supabase.functions.invoke('report-message', {
        body: {
          character_id: characterId,
          message_id: messageId ?? null,
          message_text: messageText,
          reason_code: selected,
        },
      });

      if (error || !data?.success) {
        throw error ?? new Error('report-message non-success response');
      }

      Alert.alert(
        '신고 접수',
        '신고가 접수되었어요. 24시간 이내에 검토할게요.',
        [{ text: '확인', onPress: onClose }],
      );
      setSelected(null);
    } catch (err) {
      await captureError(err, { surface: 'chat:report-message' }).catch(() => undefined);
      Alert.alert('신고 실패', '일시적 오류가 발생했어요. 잠시 후 다시 시도해 주세요.');
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <Modal
      animationType="slide"
      transparent
      visible={visible}
      onRequestClose={onClose}
    >
      <Pressable
        onPress={onClose}
        style={{ flex: 1, backgroundColor: 'rgba(0,0,0,0.5)' }}
      />
      <View
        style={{
          position: 'absolute',
          left: 0,
          right: 0,
          bottom: 0,
          backgroundColor: fortuneTheme.colors.background,
          borderTopLeftRadius: fortuneTheme.radius.lg,
          borderTopRightRadius: fortuneTheme.radius.lg,
          padding: fortuneTheme.spacing.lg,
          gap: fortuneTheme.spacing.md,
        }}
      >
        <AppText variant="heading4">메시지 신고</AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          이 메시지를 신고하는 이유를 선택해 주세요. 신고된 콘텐츠는 24시간 이내에
          검토하고, 가이드라인 위반 시 제거합니다.
        </AppText>

        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          {REASONS.map(({ code, label }) => {
            const isSelected = selected === code;
            return (
              <Pressable
                key={code}
                onPress={() => setSelected(code)}
                accessibilityRole="radio"
                accessibilityState={{ selected: isSelected }}
                accessibilityLabel={`신고 사유: ${label}`}
                style={{
                  paddingHorizontal: 14,
                  paddingVertical: 10,
                  borderRadius: fortuneTheme.radius.full,
                  borderWidth: 1,
                  borderColor: isSelected
                    ? fortuneTheme.colors.ctaBackground
                    : fortuneTheme.colors.border,
                  backgroundColor: isSelected
                    ? fortuneTheme.colors.ctaBackground
                    : fortuneTheme.colors.surface,
                }}
              >
                <AppText
                  variant="labelMedium"
                  color={
                    isSelected
                      ? fortuneTheme.colors.ctaForeground
                      : fortuneTheme.colors.textPrimary
                  }
                >
                  {label}
                </AppText>
              </Pressable>
            );
          })}
        </View>

        <View style={{ flexDirection: 'row', gap: fortuneTheme.spacing.sm, marginTop: 4 }}>
          <View style={{ flex: 1 }}>
            <PrimaryButton tone="secondary" onPress={onClose} disabled={submitting}>
              취소
            </PrimaryButton>
          </View>
          <View style={{ flex: 1 }}>
            <PrimaryButton onPress={handleSubmit} disabled={!selected || submitting}>
              {submitting ? <ActivityIndicator color="white" /> : '신고하기'}
            </PrimaryButton>
          </View>
        </View>
      </View>
    </Modal>
  );
}
