/**
 * On-Device Chat Provider — Gemma 2B를 이용한 로컬 캐릭터 채팅 구현
 *
 * 클라우드 character-chat Edge Function과 동일한 StoryChatResponse를 반환하되,
 * affinityDelta/romanceStatePatch는 미반환 (기존 클라이언트 휴리스틱으로 폴백).
 */

import { type ChatCharacterSpec } from './chat-characters';
import { type ChatShellTextMessage } from './chat-shell';
import { type ChatProviderOptions, type IChatProvider } from './chat-provider';
import {
  onDeviceLLMEngine,
  type OnDeviceMessage,
} from './on-device-llm';
import { buildStoryRomanceSystemPrompt } from './story-romance-pilots';
import {
  type StoryChatResponse,
  type StoryChatThreadSnapshot,
} from './story-chat-runtime';

// ---------------------------------------------------------------------------
// System prompt — 2B 모델용 간소화 버전
// ---------------------------------------------------------------------------

function buildOnDeviceSystemPrompt(
  character: ChatCharacterSpec,
  _thread: StoryChatThreadSnapshot | null,
): string {
  // 파일럿 캐릭터: 등록된 시스템 프롬프트 사용 (이미 한국어)
  const pilotPrompt = buildStoryRomanceSystemPrompt(character);
  if (pilotPrompt) {
    // 2B 모델에는 핵심 성격 + 간단한 규칙만 전달
    const coreLines = pilotPrompt.split('\n').filter((l) => l.trim()).slice(0, 8);
    return [
      ...coreLines,
      '',
      '## 규칙',
      '- 한국어로만 답변해.',
      '- 짧고 자연스럽게 대화해. 2-3문장 이내.',
      '- 이모지는 가끔만 사용해.',
      `- 너의 이름은 ${character.name}이야.`,
    ].join('\n');
  }

  // 커스텀 캐릭터: 기본 프롬프트 생성
  const desc = 'shortDescription' in character ? character.shortDescription : '';
  return [
    `너는 "${character.name}"이라는 캐릭터야.`,
    desc ? `배경: ${desc}` : '',
    '',
    '## 규칙',
    '- 한국어로만 답변해.',
    '- 짧고 자연스럽게 대화해. 2-3문장 이내.',
    '- 이모지는 가끔만 사용해.',
    '- 캐릭터의 성격에 맞게 행동해.',
  ]
    .filter(Boolean)
    .join('\n');
}

// ---------------------------------------------------------------------------
// Message window — 2B 모델은 컨텍스트가 작으므로 최근 8개만
// ---------------------------------------------------------------------------

function buildOnDeviceMessages(
  thread: StoryChatThreadSnapshot | null,
  userMessage: string,
): OnDeviceMessage[] {
  const history: OnDeviceMessage[] = (thread?.messages ?? [])
    .filter((m): m is ChatShellTextMessage => m.kind === 'text')
    .slice(-8)
    .map((m) => ({
      role: (m.sender === 'user' ? 'user' : 'assistant') as 'user' | 'assistant',
      content: m.text,
    }));

  return [...history, { role: 'user', content: userMessage }];
}

// ---------------------------------------------------------------------------
// Response normalization
// ---------------------------------------------------------------------------

function normalizeOnDeviceResponse(
  rawText: string,
  latencyMs: number,
): StoryChatResponse {
  return {
    success: true,
    response: rawText,
    // 2B 모델은 구조화된 감정/친밀도 데이터를 안정적으로 생성할 수 없음
    // → story-chat-runtime의 applyStoryRomancePatch가 텍스트 기반 휴리스틱으로 처리
    emotionTag: undefined,
    delaySec: Math.random() * 1.5 + 0.5,
    affinityDelta: undefined,
    romanceStatePatch: undefined,
    followUpHint: undefined,
    meta: {
      provider: 'on-device',
      model: 'gemma-2b-it-q4km',
      latencyMs,
      fallbackUsed: false,
    },
  };
}

// ---------------------------------------------------------------------------
// Provider class
// ---------------------------------------------------------------------------

export class OnDeviceChatProvider implements IChatProvider {
  async invoke(
    character: ChatCharacterSpec,
    userMessage: string,
    thread: StoryChatThreadSnapshot | null,
    _options?: ChatProviderOptions,
  ): Promise<StoryChatResponse> {
    const systemPrompt = buildOnDeviceSystemPrompt(character, thread);
    const messages = buildOnDeviceMessages(thread, userMessage);

    const startTime = Date.now();
    const rawResponse = await onDeviceLLMEngine.generate(
      systemPrompt,
      messages,
      { temperature: 0.7, maxTokens: 512 },
    );
    const latencyMs = Date.now() - startTime;

    console.log(`[OnDeviceChat] Generated in ${latencyMs}ms`);
    return normalizeOnDeviceResponse(rawResponse, latencyMs);
  }

  getProviderName(): 'on-device' {
    return 'on-device';
  }

  isAvailable(): boolean {
    return onDeviceLLMEngine.getStatus() === 'ready';
  }
}
