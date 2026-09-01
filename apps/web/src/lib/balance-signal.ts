/**
 * 온도 잔액이 바뀌었다는 클라이언트 내 신호.
 *
 * 헤더의 잔액은 마운트와 `onAuthStateChange` 에서만 읽었다. 그런데 온도는
 * 로그인 상태가 바뀔 때가 아니라 운세를 뽑거나 답장을 받을 때 깎인다. 그래서
 * 운세를 하나 보고 나면 헤더는 차감 전 숫자를 계속 들고 있었다 — 실측으로
 * 헤더가 "내 온도 3개" 인데 `/app` 은 "2개" 인 상태를 재현했다. 잔액을 안
 * 보여주는 것보다 실제보다 많다고 보여주는 쪽이 나쁘다.
 *
 * 차감은 엣지 함수 안에서 일어나므로 클라이언트는 응답을 받은 시점에만 알 수
 * 있다. 그 시점에 이 신호를 쏘고, 헤더가 받아서 다시 조회한다. 잔액 표시가
 * 여러 곳으로 늘어나도 호출부는 그대로 두면 된다.
 */

const BALANCE_CHANGED = 'ondo:balance-changed';

/** 온도를 소비했을 수 있는 요청이 끝난 직후에 부른다. 성공/잔액부족 모두 해당된다. */
export function notifyBalanceChanged(): void {
  if (typeof window === 'undefined') return;
  window.dispatchEvent(new Event(BALANCE_CHANGED));
}

/** 신호와 화면 복귀를 함께 구독한다. 정리 함수를 돌려준다. */
export function subscribeBalanceChanged(handler: () => void): () => void {
  if (typeof window === 'undefined') return () => {};

  // 다른 탭에서 충전하고 돌아오는 경우는 이벤트가 오지 않는다. 화면이 다시
  // 보이는 시점에도 한 번 맞춘다.
  const onVisible = () => {
    if (document.visibilityState === 'visible') handler();
  };

  window.addEventListener(BALANCE_CHANGED, handler);
  window.addEventListener('focus', handler);
  document.addEventListener('visibilitychange', onVisible);

  return () => {
    window.removeEventListener(BALANCE_CHANGED, handler);
    window.removeEventListener('focus', handler);
    document.removeEventListener('visibilitychange', onVisible);
  };
}
