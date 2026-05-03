/**
 * Poster Guide 결과 화면 (generic) — gpt-image 결과 이미지를 full-bleed 로 노출.
 *
 * Edge Function `/generate-poster-guide` 응답:
 *   { success: true, posterType: PosterType, imageUrl: string, generatedAt: string }
 *
 * `posterType` 별로 라벨/공유 메시지/aspect 비율이 다르므로 단일 컴포넌트가 분기 처리.
 *
 * - 레퍼런스: `screens/palm-reading.tsx` 의 OndoPalmReadingResult 패턴.
 * - `OndoPalmReadingResult` 는 본 컴포넌트의 thin alias 로 유지 (registry 호환).
 */
import { useState } from 'react';
import { ActivityIndicator, Image, Share, View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { Card } from '../../../components/card';
import { PrimaryButton } from '../../../components/primary-button';
import { captureError } from '../../../lib/error-reporting';
import { fortuneTheme } from '../../../lib/theme';
import type { FortuneResultComponentProps } from '../types';

// ── Constants ────────────────────────────────────────────────────────────────
const DEFAULT_PORTRAIT_WIDTH = 1024;
const DEFAULT_PORTRAIT_HEIGHT = 1536;
const DEFAULT_PORTRAIT_ASPECT = DEFAULT_PORTRAIT_WIDTH / DEFAULT_PORTRAIT_HEIGHT;
const FALLBACK_LOAD_ERROR =
  '이미지를 불러오지 못했어요. 잠시 후 다시 시도해주세요.';
const GENERIC_FALLBACK_TITLE = '결과를 불러오지 못했어요';
const GENERIC_LOADING_TEXT = '이미지를 불러오는 중...';

// 7종 PosterType — server-side `_shared/poster_registry.ts` 의 PosterType union 과
// 1:1 대응. RN 측에서는 단순 string 매칭만 한다.
const POSTER_TYPES = [
  'palm-reading',
  'beauty-simulation',
  'hair-style-guide',
  'face-reading-guide',
  'ootd-guide',
  'blind-date-guide',
  'past-life-guide',
] as const;
type PosterType = (typeof POSTER_TYPES)[number];

interface PosterCopy {
  title: string;
  body: string;
  shareMessage: string;
  accessibilityLabel: string;
  aspect: number;
}

const POSTER_COPY: Record<PosterType, PosterCopy> = {
  'palm-reading': {
    title: '손금가이드',
    body: '이 가이드는 AI 가 만든 한국어 손금 분석 이미지예요. 캡쳐하거나 공유해서 보관하세요.',
    shareMessage: 'Ondo 손금가이드 — 내 손금 분석 결과',
    accessibilityLabel: '손금가이드 결과 이미지',
    aspect: DEFAULT_PORTRAIT_ASPECT,
  },
  'beauty-simulation': {
    title: '뷰티 시뮬레이션',
    body: '내 얼굴 사진을 바탕으로 좌측 원본 / 우측 부드러운 스타일링 시뮬레이션을 비교한 가이드입니다.',
    shareMessage: 'Ondo 뷰티 시뮬레이션 — 내 얼굴 스타일링 비교',
    accessibilityLabel: '뷰티 시뮬레이션 결과 이미지',
    aspect: DEFAULT_PORTRAIT_ASPECT,
  },
  'hair-style-guide': {
    title: '헤어스타일 가이드',
    body: '내 얼굴형에 어울리는 10가지 헤어스타일을 한 장에 정리한 가이드입니다. 미용실에 그대로 보여줘도 좋아요.',
    shareMessage: 'Ondo 헤어스타일 가이드 — 추천 헤어 10선',
    accessibilityLabel: '헤어스타일 가이드 결과 이미지',
    aspect: DEFAULT_PORTRAIT_ASPECT,
  },
  'face-reading-guide': {
    title: '얼굴 인상 리포트',
    body: '눈·코·입·얼굴형·분위기 등 인상을 종합 분석한 한 장짜리 인상 리포트입니다.',
    shareMessage: 'Ondo 얼굴 인상 리포트 — 내 인상 분석 결과',
    accessibilityLabel: '얼굴 인상 리포트 결과 이미지',
    aspect: DEFAULT_PORTRAIT_ASPECT,
  },
  'ootd-guide': {
    title: 'OOTD 가이드',
    body: '오늘 입은 옷의 색감/톤/상황 적합도를 분석하고 어울리는 스타일링을 정리한 가이드입니다.',
    shareMessage: 'Ondo OOTD 가이드 — 오늘의 코디 분석',
    accessibilityLabel: 'OOTD 가이드 결과 이미지',
    aspect: DEFAULT_PORTRAIT_ASPECT,
  },
  'blind-date-guide': {
    title: '소개팅 가이드',
    body: '얼굴과 상황 맥락을 바탕으로 옷·헤어·말투·첫인상까지 정리한 소개팅 종합 가이드입니다.',
    shareMessage: 'Ondo 소개팅 가이드 — 내 소개팅 전략',
    accessibilityLabel: '소개팅 가이드 결과 이미지',
    aspect: DEFAULT_PORTRAIT_ASPECT,
  },
  'past-life-guide': {
    title: '전생 리포트',
    body: '시대·역할·배운 교훈을 narrative 한 장에 담은 전생 리포트입니다.',
    shareMessage: 'Ondo 전생 리포트 — 나의 전생 이야기',
    accessibilityLabel: '전생 리포트 결과 이미지',
    aspect: DEFAULT_PORTRAIT_ASPECT,
  },
};

const FALLBACK_COPY: PosterCopy = {
  title: '포스터 가이드',
  body: '이 가이드는 AI 가 만든 결과 이미지예요. 캡쳐하거나 공유해서 보관하세요.',
  shareMessage: 'Ondo 포스터 가이드 — 결과 이미지',
  accessibilityLabel: '포스터 가이드 결과 이미지',
  aspect: DEFAULT_PORTRAIT_ASPECT,
};

function isPosterType(value: unknown): value is PosterType {
  return (
    typeof value === 'string' &&
    (POSTER_TYPES as readonly string[]).includes(value)
  );
}

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

function readPosterType(
  raw: unknown,
  fallback: PosterType | null,
): PosterType | null {
  if (raw && typeof raw === 'object') {
    const candidate = (raw as Record<string, unknown>).posterType;
    if (isPosterType(candidate)) return candidate;
    const nested = (raw as Record<string, unknown>).data;
    if (nested && typeof nested === 'object') {
      const innerCandidate = (nested as Record<string, unknown>).posterType;
      if (isPosterType(innerCandidate)) return innerCandidate;
    }
  }
  return fallback;
}

interface OndoPosterGuideResultProps extends FortuneResultComponentProps {
  /** 명시적으로 posterType 을 지정하면 응답에 누락돼도 fallback 으로 사용. */
  posterType?: PosterType;
}

export function OndoPosterGuideResult({
  payload,
  posterType: explicitPosterType,
}: OndoPosterGuideResultProps) {
  const imageUrl = readImageUrl(payload?.rawApiResponse);
  // posterType 결정 우선순위: explicit prop > 응답 > payload.fortuneType
  const fallbackFromPayload = isPosterType(payload?.fortuneType)
    ? (payload?.fortuneType as PosterType)
    : null;
  const posterType =
    explicitPosterType ??
    readPosterType(payload?.rawApiResponse, fallbackFromPayload);
  const copy = (posterType && POSTER_COPY[posterType]) ?? FALLBACK_COPY;

  const [imageLoading, setImageLoading] = useState<boolean>(true);
  const [imageError, setImageError] = useState<boolean>(false);
  const [sharing, setSharing] = useState<boolean>(false);

  async function handleShare() {
    if (!imageUrl || sharing) return;
    setSharing(true);
    try {
      await Share.share({
        url: imageUrl,
        message: copy.shareMessage,
      });
    } catch (error) {
      // Share sheet 취소도 throw 됨 → silent capture.
      void captureError(error, {
        surface: `share:poster-guide:${posterType ?? 'unknown'}`,
      });
    } finally {
      setSharing(false);
    }
  }

  if (!imageUrl) {
    return (
      <Card>
        <View style={{ gap: fortuneTheme.spacing.sm }}>
          <AppText variant="heading4">{`${copy.title} ${GENERIC_FALLBACK_TITLE}`}</AppText>
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
            aspectRatio: copy.aspect,
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
              accessibilityLabel={copy.accessibilityLabel}
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
              <ActivityIndicator
                size="small"
                color={fortuneTheme.colors.accentSecondary}
              />
              <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
                {GENERIC_LOADING_TEXT}
              </AppText>
            </View>
          ) : null}
        </View>
      </Card>

      <Card>
        <View style={{ gap: fortuneTheme.spacing.sm }}>
          <AppText variant="heading4">{copy.title}</AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {copy.body}
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
