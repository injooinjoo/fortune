import * as Updates from 'expo-updates';
import { router } from 'expo-router';
import { Alert } from 'react-native';

import { captureError } from './error-reporting';
import { deactivateCurrentPushToken } from './push-notifications';
import { deleteSecureItem } from './secure-store-storage';
import { supabase } from './supabase';
import { updateRemoteUserProfile } from './user-profile-remote';
import { WELCOME_SEEN_KEY } from './welcome-state';

const DISCLAIMER_STORAGE_KEY = 'fortune.disclaimer-accepted.v1';

/**
 * 앱을 처음 설치한 상태로 되돌리기 위해 서버 프로필·로컬 캐시·로그인 세션
 * 까지 모두 지운다. 테스트 계정 전용 도구라 일반 사용자에겐 노출되지 않는다.
 *
 * 분리 이유: 기존엔 profile-screen.tsx 내부 함수였는데, dev-tools 화면에서도
 * 같은 동작이 필요해져 모듈로 추출. UI 호출 로직(Alert 확인 다이얼로그 +
 * 재시작)도 함께 묶어 양쪽에서 동일 동선 보장.
 */
async function runResetSteps(
  userId: string | null,
): Promise<string[]> {
  const failures: string[] = [];

  async function step(label: string, fn: () => Promise<unknown>) {
    try {
      await fn();
      console.log(`[reset-onboarding] ok: ${label}`);
    } catch (error) {
      console.warn(`[reset-onboarding] fail: ${label}`, error);
      failures.push(label);
      await captureError(error, {
        surface: `dev-tools:reset-onboarding:${label}`,
      }).catch(() => undefined);
    }
  }

  // 1. 서버 프로필 비우기 — 재로그인 시 빈 상태로 hydrate.
  //    name 은 NOT NULL 컬럼이라 '' 로 채운다.
  if (userId) {
    await step('clear-remote', () =>
      updateRemoteUserProfile(userId, {
        name: '',
        birth_date: null,
        birth_time: null,
        mbti: null,
        blood_type: null,
        fortune_preferences: { category_weights: {}, showPersonalized: true },
        onboarding_completed: false,
      }),
    );
  }

  // 2. 푸시 토큰은 sign-out 전에 비활성화. signOut 후엔 invoke 가 401 로
  //    떨어져 fcm_tokens 행을 정리할 수 없게 된다.
  await step('deactivate-push-token', () => deactivateCurrentPushToken());
  await step('sign-out', async () => {
    await supabase?.auth.signOut();
  });

  // 3. SecureStore 의 알려진 키 전부 삭제 → 다음 부팅이 신규 설치처럼 보임.
  await step('clear-onboarding-progress', () =>
    deleteSecureItem('unified_onboarding_progress_v1'),
  );
  await step('clear-welcome-seen', () => deleteSecureItem(WELCOME_SEEN_KEY));
  await step('clear-disclaimer', () =>
    deleteSecureItem(DISCLAIMER_STORAGE_KEY),
  );
  await step('clear-app-state-user', () =>
    deleteSecureItem(
      userId
        ? `fortune.mobile-app-state.v1.${userId}`
        : 'fortune.mobile-app-state.v1.guest',
    ),
  );
  await step('clear-app-state-guest', () =>
    deleteSecureItem('fortune.mobile-app-state.v1.guest'),
  );
  await step('clear-last-auth', () =>
    deleteSecureItem('fortune.last-auth-user-id.v1'),
  );
  await step('clear-pending-deeplink', () =>
    deleteSecureItem('pending_deep_link_fortune_type'),
  );
  await step('clear-created-friends', () =>
    deleteSecureItem('fortune.created-friends.v1'),
  );
  await step('clear-favorite-celebrities', () =>
    deleteSecureItem('fortune.favorite-celebrities.v1'),
  );

  return failures;
}

export function confirmAndRunFactoryReset(userId: string | null): void {
  Alert.alert(
    '앱 초기화 (테스트)',
    '서버 프로필, 로컬 캐시, 로그인 세션까지 모두 지우고 앱을 재시작합니다. 앱을 처음 설치한 상태로 돌아가며, 재시작 후 직접 다시 로그인해야 합니다. 프로필 데이터는 복구되지 않습니다.',
    [
      { text: '취소', style: 'cancel' },
      {
        text: '초기화 후 재시작',
        style: 'destructive',
        onPress: async () => {
          const failures = await runResetSteps(userId);
          if (failures.length > 0) {
            Alert.alert(
              '일부 단계 실패',
              `다음 단계에서 오류: ${failures.join(', ')}\n그래도 재시작을 진행합니다. Metro 콘솔에서 상세 에러를 확인하세요.`,
              [
                {
                  text: '확인',
                  onPress: () => {
                    void Updates.reloadAsync().catch(() =>
                      router.replace('/onboarding'),
                    );
                  },
                },
              ],
            );
            return;
          }
          try {
            await Updates.reloadAsync();
          } catch {
            // dev builds may not support reloadAsync reliably → fallback
            router.replace('/onboarding');
          }
        },
      },
    ],
  );
}
