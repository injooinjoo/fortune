import { useEffect, useState } from 'react';

import { router } from 'expo-router';
import {
  appRoutes,
  findFortuneExpert,
  fortuneCharacters,
  fortuneTypeSpecs,
  resolveFortuneEndpoint,
  type FortuneTypeId,
} from '@fortune/product-contracts';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { Chip } from '../components/chip';
import { PrimaryButton } from '../components/primary-button';
import { Screen } from '../components/screen';
import { captureError } from '../lib/error-reporting';
import { appEnv } from '../lib/env';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';

export function ChatScreen() {
  const {
    completeOnboarding,
    consumePendingChatFortuneType,
    gate,
    hasSupabase,
    markAuthComplete,
    markGuestBrowse,
    onboardingProgress,
    pendingChatFortuneType,
    session,
    status,
  } = useAppBootstrap();
  const [activeFortuneType, setActiveFortuneType] = useState<FortuneTypeId | null>(
    null,
  );

  useEffect(() => {
    if (!pendingChatFortuneType) {
      return;
    }

    setActiveFortuneType(pendingChatFortuneType);
    consumePendingChatFortuneType().catch((error) => {
      captureError(error, { surface: 'chat:consume-pending-fortune' }).catch(
        () => undefined,
      );
    });
  }, [consumePendingChatFortuneType, pendingChatFortuneType]);

  const highlightedExpert = activeFortuneType
    ? findFortuneExpert(activeFortuneType)
    : undefined;

  return (
    <Screen>
      <AppText variant="labelMedium" color={fortuneTheme.colors.accentSecondary}>
        /chat
      </AppText>
      <AppText variant="displaySmall">Fortune React Native</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        Flutter의 chat-first 제품면을 RN에서 동일한 계약으로 재구성하는 기반입니다.
      </AppText>

      <Card>
        <AppText variant="heading4">Bootstrap</AppText>
        <Chip label={`status:${status}`} tone="accent" />
        <Chip label={hasSupabase ? 'supabase:on' : 'supabase:off'} />
        <Chip label={session ? 'session:authenticated' : 'session:guest'} tone={session ? 'success' : 'neutral'} />
        <Chip label={`gate:${gate}`} />
        <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
          env: {appEnv.environment} · scheme: com.beyond.fortune
        </AppText>
      </Card>

      {status === 'loading' ? (
        <Card>
          <AppText variant="heading4">Bootstrap Loading</AppText>
          <AppText variant="bodyMedium">
            세션 복원, 온보딩 상태, 딥링크 의도를 읽는 중입니다.
          </AppText>
        </Card>
      ) : null}

      {status === 'ready' && gate === 'auth-entry' ? (
        <Card>
          <AppText variant="heading4">Auth Entry Gate</AppText>
          <AppText variant="bodyMedium">
            Flutter `/chat` 셸과 동일하게 첫 진입 게스트는 soft gate를 먼저 통과해야 합니다.
          </AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            softGateCompleted=false 이므로 채팅 본문 대신 인증 진입 카드를 우선 노출합니다.
          </AppText>
          <PrimaryButton
            onPress={() => {
              markGuestBrowse().catch((error) => {
                captureError(error, { surface: 'chat:guest-browse' }).catch(
                  () => undefined,
                );
              });
            }}
          >
            게스트로 둘러보기
          </PrimaryButton>
          <PrimaryButton
            onPress={() => {
              markAuthComplete().catch((error) => {
                captureError(error, { surface: 'chat:auth-complete' }).catch(
                  () => undefined,
                );
              });
            }}
            tone="secondary"
          >
            인증 완료 상태로 전환
          </PrimaryButton>
          <PrimaryButton onPress={() => router.push('/signup')} tone="secondary">
            회원가입 표면 보기
          </PrimaryButton>
        </Card>
      ) : null}

      {status === 'ready' && gate === 'profile-flow' ? (
        <Card>
          <AppText variant="heading4">Profile Flow Gate</AppText>
          <AppText variant="bodyMedium">
            인증은 되었지만 출생 정보, 관심사, 첫 진입 handoff가 모두 완료되지 않아 온보딩을 계속해야 합니다.
          </AppText>
          <Chip
            label={`birth:${onboardingProgress.birthCompleted ? 'done' : 'todo'}`}
          />
          <Chip
            label={`interest:${onboardingProgress.interestCompleted ? 'done' : 'todo'}`}
          />
          <Chip
            label={`handoff:${onboardingProgress.firstRunHandoffSeen ? 'done' : 'todo'}`}
          />
          <PrimaryButton
            onPress={() => {
              completeOnboarding().catch((error) => {
                captureError(error, {
                  surface: 'chat:complete-onboarding',
                }).catch(() => undefined);
              });
            }}
          >
            온보딩 완료 처리
          </PrimaryButton>
          <PrimaryButton
            onPress={() => router.push('/onboarding')}
            tone="secondary"
          >
            온보딩 표면 보기
          </PrimaryButton>
        </Card>
      ) : null}

      {status === 'ready' && gate === 'ready' && activeFortuneType ? (
        <Card>
          <AppText variant="heading4">Pending Fortune Launch</AppText>
          <AppText variant="bodyMedium">
            딥링크로 전달된 운세 타입을 채팅 셸에서 보존했고, RN도 동일하게 캐릭터 진입 준비를 마쳤습니다.
          </AppText>
          <Chip label={`fortune:${activeFortuneType}`} tone="accent" />
          {highlightedExpert ? (
            <>
              <AppText variant="labelLarge">{highlightedExpert.name}</AppText>
              <AppText
                variant="bodySmall"
                color={fortuneTheme.colors.textSecondary}
              >
                {highlightedExpert.shortDescription}
              </AppText>
              <PrimaryButton
                onPress={() =>
                  router.push(`/character/${highlightedExpert.id}` as never)
                }
              >
                전문가 프로필 열기
              </PrimaryButton>
            </>
          ) : null}
        </Card>
      ) : null}

      {status === 'ready' && gate === 'ready' ? (
        <>
      <Card>
        <AppText variant="heading4">Active Surface Inventory</AppText>
        <AppText variant="bodyMedium">
          RN 셸은 현재 활성 제품 표면 {appRoutes.length}개를 기준으로 생성되었습니다.
        </AppText>
        {appRoutes.slice(0, 8).map((route) => (
          <Chip key={route.id} label={`${route.path} · ${route.group}`} />
        ))}
      </Card>

      <Card>
        <AppText variant="heading4">Fortune Experts</AppText>
        {fortuneCharacters.map((character) => (
          <Card
            key={character.id}
            style={{
              backgroundColor: fortuneTheme.colors.surfaceSecondary,
            }}
          >
            <AppText variant="labelLarge">{character.name}</AppText>
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              {character.shortDescription}
            </AppText>
            <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
              {character.specialties.join(', ')}
            </AppText>
          </Card>
        ))}
      </Card>

      <Card>
        <AppText variant="heading4">Endpoint Registry Preview</AppText>
        {fortuneTypeSpecs.slice(0, 12).map((spec) => (
          <AppText key={spec.id} variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {spec.id}
            {' -> '}
            {resolveFortuneEndpoint(spec.id) ?? 'local-only'}
          </AppText>
        ))}
      </Card>

      <Card>
        <AppText variant="heading4">Next Surfaces</AppText>
        <PrimaryButton onPress={() => router.push('/premium')}>
          Premium surface
        </PrimaryButton>
        <PrimaryButton onPress={() => router.push('/profile')} tone="secondary">
          Profile surface
        </PrimaryButton>
      </Card>
        </>
      ) : null}
    </Screen>
  );
}
