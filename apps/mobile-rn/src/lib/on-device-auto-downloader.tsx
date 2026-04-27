import { useEffect } from 'react';

import { onDeviceLLMEngine } from './on-device-llm';

/**
 * 앱 시작 시 로컬 모델이 없으면 무조건 백그라운드 다운로드를 자동 시작.
 * 기기 미지원 / 이미 받는 중 / 이미 받음 → no-op.
 *
 * aiMode와 무관 — cloud 모드 유저도 미리 받아 두어야 오프라인/차단 시에
 * 자연스럽게 폴백할 수 있음. 유저가 프로필에서 취소하면 `cancelDownload`로
 * 중단 가능.
 *
 * 렌더는 하지 않음 — 사이드이펙트만 있는 마커 컴포넌트.
 */
export function OnDeviceAutoDownloader() {
  useEffect(() => {
    if (!onDeviceLLMEngine.isDeviceCapable()) return;
    if (onDeviceLLMEngine.getStatus() !== 'not-downloaded') return;

    onDeviceLLMEngine.startDownload().catch(() => {
      // 네트워크 오류 등은 무시 — 유저가 프로필에서 재시도 가능
    });
  }, []);

  return null;
}
