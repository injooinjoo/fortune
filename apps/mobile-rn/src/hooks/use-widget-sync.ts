/**
 * useWidgetSync — iOS 홈/잠금화면 위젯용 App Group UserDefaults flush 훅.
 *
 * 사주 변경 시 (생년월일시/이름) `buildWidgetData(saju, birthDate)` 의 결과를
 * native App Group 으로 동기화. 위젯 extension 은 timeline refresh(자정 5분)
 * 시점에 이 값을 읽어 UI에 반영.
 *
 * Sprint W2: 별자리 위젯용 birthDate 인자 추가. MobileAppStateProvider에서
 * profile.birthDate 를 직접 꺼내 buildWidgetData로 전달.
 *
 * 소비자: `<WidgetSyncBridge />` (src/components/widget-sync-bridge.tsx)
 * 에서 루트 Provider 트리 안에 한 번 마운트. MobileAppStateProvider 내부
 * 라서 `useMySaju()` / `useMobileAppState()` 호출 가능.
 */
import { useEffect } from 'react';

import { useMySaju } from './use-saju';
import { useMobileAppState } from '../providers/mobile-app-state-provider';
import { buildWidgetData, syncWidgetData } from '../lib/widget-data-sync';

export function useWidgetSync(): void {
  const saju = useMySaju();
  const { state } = useMobileAppState();
  const birthDate = state.profile.birthDate ?? null;

  useEffect(() => {
    // 비동기 flush — 위젯 값은 최신화되면 좋고, 실패해도 앱 UX에 영향 없음.
    void syncWidgetData(buildWidgetData(saju, birthDate));
  }, [saju, birthDate]);
}
