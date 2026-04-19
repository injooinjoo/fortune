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
import { OnDeviceNotReadyError } from './chat-provider-errors';

export interface ChatProviderOptions {
  userDescription?: string;
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

// ---------------------------------------------------------------------------
// Routing — picks the best available provider for the requested mode
// ---------------------------------------------------------------------------

export function resolveChatProvider(aiMode: AiMode): IChatProvider {
  if (aiMode === 'on-device') {
    // 엄격 모드: 유저가 명시적으로 온디바이스를 선택했다면 준비 안 됐을 때
    // 은폐 클라우드 폴백 금지. 호출자가 준비 UX를 보여줘야 함.
    if (!onDeviceProvider.isAvailable()) {
      throw new OnDeviceNotReadyError(onDeviceLLMEngine.getStatus());
    }
    return onDeviceProvider;
  }
  if (aiMode === 'auto' && onDeviceProvider.isAvailable()) {
    return onDeviceProvider;
  }
  // cloud mode, or explicit 'auto' fallback when on-device is not ready
  return cloudProvider;
}
