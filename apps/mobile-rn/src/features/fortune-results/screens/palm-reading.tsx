/**
 * 손금가이드 결과 화면 — full-bleed gpt-image-2 결과 이미지 + 공유 버튼.
 *
 * Edge Function 응답:
 *   { success: true, imageUrl: string, generatedAt: string }
 *
 * imageUrl 은 `EmbeddedResultPayload.rawApiResponse.imageUrl` 경로로 들어온다
 * (edge-runtime.ts 가 응답 raw data 를 그대로 attach).
 *
 * UI:
 *   - 1024×1536 portrait 이미지를 전체 너비로 노출 (aspectRatio 보존).
 *   - 로딩/에러 상태 처리.
 *   - 공유 버튼: RN built-in `Share.share({ url })`. iOS 의 사진 앱 저장,
 *     Android 다운로드는 시스템 share sheet 가 제공.
 *   - 갤러리 직접 저장은 별도 native module(`expo-media-library`) 필요 →
 *     OTA 가능 범위 밖이므로 본 sprint 에서는 share 한 버튼으로 통합.
 */
import { useState } from 'react';
import { ActivityIndicator, Image, Share, View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { Card } from '../../../components/card';
import { PrimaryButton } from '../../../components/primary-button';
import { captureError } from '../../../lib/error-reporting';
import { fortuneTheme } from '../../../lib/theme';
import type { FortuneResultComponentProps } from '../types';

const PALM_IMAGE_ASPECT = 1024 / 1536; // portrait (gpt-image-2 OUTPUT_SIZE)
const SHARE_FALLBACK_MESSAGE = 'Ondo 손금가이드 — 내 손금 분석 결과';
const FALLBACK_LOAD_ERROR =
  '이미지를 불러오지 못했어요. 잠시 후 다시 시도해주세요.';

function readImageUrl(raw: unknown): string | null {
  if (raw == null || typeof raw !== 'object') return null;
  const candidate = (raw as Record<string, unknown>).imageUrl;
  if (typeof candidate === 'string' && candidate.trim().length > 0) {
    return candidate.trim();
  }
  // edge-runtime 이 `data: { ... }` 한 단계 더 감쌀 수 있으므로 fallback.
  const nested = (raw as Record<string, unknown>).data;
  if (nested && typeof nested === 'object') {
    const inner = (nested as Record<string, unknown>).imageUrl;
    if (typeof inner === 'string' && inner.trim().length > 0) {
      return inner.trim();
    }
  }
  return null;
}

export function OndoPalmReadingResult({ payload }: FortuneResultComponentProps) {
  const imageUrl = readImageUrl(payload?.rawApiResponse);
  const [imageLoading, setImageLoading] = useState<boolean>(true);
  const [imageError, setImageError] = useState<boolean>(false);
  const [sharing, setSharing] = useState<boolean>(false);

  async function handleShare() {
    if (!imageUrl || sharing) return;
    setSharing(true);
    try {
      await Share.share({
        url: imageUrl,
        message: SHARE_FALLBACK_MESSAGE,
      });
    } catch (error) {
      // Share sheet 취소도 throw 됨 → silent capture.
      void captureError(error, { surface: 'share:palm-reading' });
    } finally {
      setSharing(false);
    }
  }

  if (!imageUrl) {
    return (
      <Card>
        <View style={{ gap: fortuneTheme.spacing.sm }}>
          <AppText variant="heading4">손금가이드 결과를 불러오지 못했어요</AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            잠시 후 다시 시도해주세요. 토큰은 차감되지 않았어요.
          </AppText>
        </View>
      </Card>
    );
  }

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <Card
        style={{
          backgroundColor: fortuneTheme.colors.surface,
          padding: 0,
          overflow: 'hidden',
        }}
      >
        <View
          style={{
            width: '100%',
            aspectRatio: PALM_IMAGE_ASPECT,
            backgroundColor: fortuneTheme.colors.surfaceSecondary,
            justifyContent: 'center',
            alignItems: 'center',
          }}
        >
          {!imageError ? (
            <Image
              source={{ uri: imageUrl }}
              style={{ width: '100%', height: '100%' }}
              resizeMode="contain"
              onLoadStart={() => {
                setImageLoading(true);
                setImageError(false);
              }}
              onLoadEnd={() => setImageLoading(false)}
              onError={() => {
                setImageLoading(false);
                setImageError(true);
              }}
              accessibilityLabel="손금가이드 결과 이미지"
            />
          ) : (
            <View
              style={{
                gap: fortuneTheme.spacing.xs,
                alignItems: 'center',
                paddingHorizontal: fortuneTheme.spacing.md,
              }}
            >
              <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                {FALLBACK_LOAD_ERROR}
              </AppText>
            </View>
          )}

          {imageLoading && !imageError ? (
            <View
              style={{
                position: 'absolute',
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                justifyContent: 'center',
                alignItems: 'center',
                gap: fortuneTheme.spacing.xs,
              }}
            >
              <ActivityIndicator size="small" color={fortuneTheme.colors.accentSecondary} />
              <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
                이미지를 불러오는 중...
              </AppText>
            </View>
          ) : null}
        </View>
      </Card>

      <Card>
        <View style={{ gap: fortuneTheme.spacing.sm }}>
          <AppText variant="heading4">손금가이드</AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            이 가이드는 AI 가 만든 한국어 손금 분석 이미지예요. 캡쳐하거나 공유해서
            보관하세요. 다시 보려면 같은 흐름으로 새로 생성해야 해요.
          </AppText>
          <PrimaryButton
            variant="primary"
            size="lg"
            fullWidth
            onPress={handleShare}
            loading={sharing}
            disabled={imageError}
          >
            공유하기
          </PrimaryButton>
        </View>
      </Card>
    </View>
  );
}
