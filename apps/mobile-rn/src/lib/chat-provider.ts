import { type ChatCharacterSpec } from './chat-characters';
import {
  invokeStoryChat,
  type StoryChatResponse,
  type StoryChatThreadSnapshot,
} from './story-chat-runtime';
import { type AiMode } from './mobile-app-state';
import { OnDeviceChatProvider } from './on-device-chat-provider';

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
  if (aiMode === 'on-device' && onDeviceProvider.isAvailable()) {
    return onDeviceProvider;
  }
  if (aiMode === 'auto' && onDeviceProvider.isAvailable()) {
    return onDeviceProvider;
  }
  // cloud mode, or fallback when on-device is not available
  return cloudProvider;
}
