/**
 * WidgetSyncBridge — iOS 홈 화면 위젯 데이터 sync 를 위한 "빈" 컴포넌트.
 *
 * useWidgetSync 는 useMySaju → useMobileAppState 훅 체인을 쓰므로 반드시
 * MobileAppStateProvider 자식 트리 안에서만 호출 가능하다. 루트 layout
 * 에 직접 훅을 호출하면 Provider 바깥이 되므로, 이렇게 null-rendering
 * 자식 컴포넌트로 감싸서 Provider 내부에 마운트한다.
 */
import { useWidgetSync } from '../hooks/use-widget-sync';

export function WidgetSyncBridge(): null {
  useWidgetSync();
  return null;
}
