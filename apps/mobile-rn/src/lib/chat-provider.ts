import { type ChatCharacterSpec } from './chat-characters';
import {
  invokeStoryChat,
  type StoryChatResponse,
  type StoryChatThreadSnapshot,
} from './story-chat-runtime';
import { type AiMode } from './mobile-app-state';
import { OnDeviceChatProvider } from './on-device-chat-provider';
import { onDeviceLLMEngine } from './on-device-llm';

export { OnDeviceNotReadyError } from './chat-provider-errors';

export interface ChatProviderOptions {
  userDescription?: string;
  /**
   * 사용자 메시지와 함께 보낼 이미지. base64 data URL 또는 raw base64.
   * On-device 에서만 의미 있음 — cloud 경로에선 무시 (이미지 fortune 은 별도
   * Edge Function 경로로 감).
   */
  imageBase64?: string;
}

export interface IChatProvider {
  invoke(
    character: ChatCharacterSpec,
    userMessage: string,
    thread: StoryChatThreadSnapshot | null,
    options?: ChatProviderOptions,
  ): Promise<StoryChatResponse>;

  getProviderName(): 'cloud' | 'on-device';
  isAvailable(): boolean;
}

// ---------------------------------------------------------------------------
// Cloud provider — wraps the existing invokeStoryChat edge function call
// ---------------------------------------------------------------------------

class CloudChatProvider implements IChatProvider {
  async invoke(
    character: ChatCharacterSpec,
    userMessage: string,
    thread: StoryChatThreadSnapshot | null,
    options?: ChatProviderOptions,
  ): Promise<StoryChatResponse> {
    return invokeStoryChat(character, userMessage, thread, options);
  }

  getProviderName(): 'cloud' {
    return 'cloud';
  }

  isAvailable(): boolean {
    return true;
  }
}

// ---------------------------------------------------------------------------
// Singleton instances
// ---------------------------------------------------------------------------

const cloudProvider = new CloudChatProvider();
const onDeviceProvider = new OnDeviceChatProvider();

/**
 * 온디바이스 실패 시 같은 메시지를 즉시 클라우드로 재시도할 때 쓰는 강제 클라우드 핸들.
 */
export const cloudChatProvider: IChatProvider = cloudProvider;

// ---------------------------------------------------------------------------
// Routing — picks the best available provider for the requested mode
// ---------------------------------------------------------------------------

export interface ResolveChatProviderOptions {
  /** 이 호출이 이미지 입력을 포함하는가. 온디바이스 variant 가 mmproj 를
   * 가지지 않으면 자동으로 cloud 로 라우팅한다. */
  requiresImageInput?: boolean;
}

export function resolveChatProvider(
  aiMode: AiMode,
  options?: ResolveChatProviderOptions,
): IChatProvider {
  if (aiMode !== 'cloud' && onDeviceProvider.isAvailable()) {
    if (options?.requiresImageInput) {
      // 텍스트 전용 variant (mmproj null) 은 이미지 처리 불가 → cloud.
      const variant = onDeviceLLMEngine.getActiveVariant();
      if (!variant?.mmproj) {
        return cloudProvider;
      }
    }
    return onDeviceProvider;
  }
  // cloud mode, or on-device/auto 선택됐지만 모델이 아직 준비 안 된 경우
  // → 조용히 클라우드로 폴백 (백그라운드 다운로드는 OnDeviceAutoDownloader가 처리)
  return cloudProvider;
}
