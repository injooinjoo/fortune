import { useEffect } from 'react';

import { useMobileAppState } from '../providers/mobile-app-state-provider';
import { onDeviceLLMEngine } from './on-device-llm';

/**
 * aiMode !== 'cloud' 이면서 로컬 모델이 아직 없을 때 백그라운드 다운로드를
 * 자동 시작. 유저가 명시적으로 취소했거나 기기가 지원 안 하면 no-op.
 *
 * 렌더는 하지 않음 — 사이드이펙트만 있는 마커 컴포넌트.
 */
export function OnDeviceAutoDownloader() {
  const { state } = useMobileAppState();
  const aiMode = state.settings.aiMode;

  useEffect(() => {
    if (aiMode === 'cloud') return;
    if (!onDeviceLLMEngine.isDeviceCapable()) return;
    if (onDeviceLLMEngine.getStatus() !== 'not-downloaded') return;

    onDeviceLLMEngine.startDownload().catch(() => {
      // 네트워크 오류 등은 무시 — 유저가 프로필에서 재시도 가능
    });
  }, [aiMode]);

  return null;
}
