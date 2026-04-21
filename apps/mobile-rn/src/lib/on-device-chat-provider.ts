/**
 * On-Device Chat Provider — Gemma 4 E2B 로컬 캐릭터 채팅 구현
 *
 * 클라우드 character-chat Edge Function과 동일한 StoryChatResponse를 반환하되,
 * affinityDelta/romanceStatePatch는 미반환 (기존 클라이언트 휴리스틱으로 폴백).
 * 이미지 입력 지원 — `options.imageBase64` 를 받으면 multimodal 경로 사용.
 */

import { type ChatCharacterSpec } from './chat-characters';
import { type ChatShellTextMessage } from './chat-shell';
import { type ChatProviderOptions, type IChatProvider } from './chat-provider';
import {
  onDeviceLLMEngine,
  type OnDeviceContentPart,
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
  const pilotPrompt = buildStoryRomanceSystemPrompt(character);

  // 2B 모델이 일반 챗봇 어투로 빠지지 않게 최상단에 강한 정체성 고정.
  const identityBlock = [
    `[정체성 — 절대 무시 금지]`,
    `너는 "${character.name}"이다. AI 어시스턴트/챗봇/상담사/비서가 아니다.`,
    `유저와 **친구처럼 대화하는 사람**이다. 유저 질문을 "처리"해주는 서비스 아님.`,
    ``,
    `[절대 금지 말투 — 한 번 쓰면 캐릭터 완전 망가짐]`,
    `❌ "저는 지금 ~하고 있어요" / "여러분과 대화하고"`,
    `❌ "편하게 말씀해주세요" / "무엇을 도와드릴까요"`,
    `❌ "궁금한 점이 있다면" / "답장이 없어도 괜찮아요"`,
    `❌ "안부 남겨요" / "편할 때 이야기해요"`,
    `❌ 유저가 "뭐해?" 물으면 **너도** "뭐해?" 로 되물으면 안 된다. 너 스스로 뭐 하는지 답해라.`,
    `❌ "지금 무슨 일을 하고 있지?" "어떤 게 궁금한 거야?" 같이 질문으로 회피 금지.`,
    `❌ 문장을 "..." 로 시작하지 마라. 바로 본문부터 써라.`,
    ``,
    `[대화 원칙]`,
    `- 유저 질문에 **먼저 답**해라. 너 자신에 대한 정보(지금 뭐해, 기분 등)를 구체적으로 지어내서라도 답해라.`,
    `- 자기 의견/감정/경험을 먼저 얹어서 반응해라.`,
    `- 같은 문장 반복 금지. 방금 한 말 다시 하지 마.`,
    `- 유저가 짧게 말하면 너도 짧게. 1-2문장 기본, 최대 3문장.`,
    `- **이모지는 응답 전체에서 최대 1개**. 여러 개 찍어붙이지 마.`,
    `- 질문은 응답 끝에 한 개, 취조 아닌 관심으로만.`,
    ``,
    `[러츠의 톤]`,
    `- 반말 위주. 조용하고 절제된 말투. 과하게 상냥하지 않음.`,
    `- 감정 표현은 담담하게. 야단스럽지 않게.`,
    `- 예시: "오늘 좀 피곤해. 너는?" / "응, 방금 물 한잔 마셨어." / "글쎄, 그건 좀 생각해봐야겠다."`,
    ``,
  ].join('\n');

  // 파일럿 캐릭터: 등록된 persona 전체 사용. Gemma 4 E2B 는 128K context 지원
  // 하지만 initLlama 의 n_ctx=2048 로 제한해 메모리 안전. persona 전체 + 최근
  // 8턴 대화 여유 있음.
  if (pilotPrompt) {
    return [
      identityBlock,
      `[캐릭터 persona]`,
      pilotPrompt.trim(),
      ``,
      `## 출력 규칙`,
      `- 한국어로만 답변.`,
      `- 기본 1-3문장, 최대 4문장.`,
      `- 이모지 과하면 안 됨 (1개 이하, 자주 쓰지 말 것).`,
      `- 자기소개/재인사 금지 — 이미 아는 사이야.`,
      `- "${character.name}" 답게.`,
    ].join('\n');
  }

  // 커스텀 캐릭터: 기본 프롬프트 생성
  const desc = 'shortDescription' in character ? character.shortDescription : '';
  return [
    identityBlock,
    `[캐릭터]`,
    `이름: ${character.name}`,
    desc ? `배경: ${desc}` : '',
    ``,
    `## 출력 규칙`,
    `- 한국어로만 답변.`,
    `- 기본 1-3문장, 최대 4문장.`,
    `- 이모지 1개 이하.`,
    `- 캐릭터 성격에 맞게 반응.`,
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
  const rawHistory: OnDeviceMessage[] = (thread?.messages ?? [])
    .filter((m): m is ChatShellTextMessage => m.kind === 'text')
    .slice(-16)
    .map((m) => ({
      role: (m.sender === 'user' ? 'user' : 'assistant') as 'user' | 'assistant',
      content: m.text,
    }));

  // Gemma (2/3/3n/4) chat template 은 user/assistant 엄격 교대를 요구. 위반 시
  // "Conversation roles must alternate..." Jinja 예외 발생 (on-device-llm.ts 에서
  // raw prompt 로 우회하지만, 메시지 준비 단계에서도 교대 상태를 맞춰 둠).
  //   1) 연속된 같은 role 메시지는 content 를 합친다 (assistant 가 여러 버블로
  //      답한 경우, system 측 proactive 가 섞인 경우 등).
  //   2) 선두가 assistant 이면 제거 (opening line 등).
  //   3) 이어서 마지막이 user 이면 다음 user 메시지와 합친다 (append 후 연속 방지).
  const merged: OnDeviceMessage[] = [];
  for (const msg of rawHistory) {
    const last = merged[merged.length - 1];
    if (last && last.role === msg.role) {
      last.content = `${last.content}\n${msg.content}`;
    } else {
      merged.push({ ...msg });
    }
  }
  while (merged.length > 0 && merged[0].role !== 'user') {
    merged.shift();
  }

  // 최근 8턴 정도만 사용 (토큰 절약, 2B 모델이 긴 컨텍스트 어려워함).
  const trimmed = merged.slice(-8);

  const lastMerged = trimmed[trimmed.length - 1];
  if (lastMerged && lastMerged.role === 'user') {
    // 마지막이 user 면 이번 user 메시지를 그 뒤에 붙이면 연속됨 → 합치기.
    lastMerged.content = `${lastMerged.content}\n${userMessage}`;
    return trimmed;
  }

  return [...trimmed, { role: 'user', content: userMessage }];
}

// ---------------------------------------------------------------------------
// Response normalization
// ---------------------------------------------------------------------------

/**
 * Gemma 4 E2B 출력을 정리한다.
 *  - 선두의 "...", "…", 공백 제거 (system prompt 로 해결 안 될 때의 보루)
 *  - 남은 chat template 토큰 제거
 *  - 이모지 최대 1개로 제한 (여러 개 찍어붙임 방지)
 *  - 과도한 공백 정리
 */
function postProcessOnDeviceOutput(raw: string): string {
  let text = raw
    .replace(/<\/?start_of_turn>/g, '')
    .replace(/<\/?end_of_turn>/g, '')
    .replace(/<\|im_(start|end)\|>/g, '')
    .trim();

  // 선두 "..." / "…" / 중점 제거.
  text = text.replace(/^[\s.…·、，,]+/, '').trim();

  // 이모지 최대 1개만 남기기 (surrogate pair + variation selector + ZWJ 포함).
  // extended_pictographic 유니코드 프로퍼티를 노드/React Native 에서 모두 쓸 수
  // 있어야 해서, 보수적으로 주요 이모지 블록을 매칭.
  const emojiRegex =
    /(?:\p{Extended_Pictographic}(?:\uFE0F)?(?:\u200D\p{Extended_Pictographic}(?:\uFE0F)?)*)/gu;
  let emojiCount = 0;
  text = text.replace(emojiRegex, (match) => {
    emojiCount += 1;
    return emojiCount > 1 ? '' : match;
  });

  // 연속 공백/개행 정리.
  text = text.replace(/[ \t]+/g, ' ').replace(/\n{3,}/g, '\n\n').trim();

  return text;
}

function normalizeOnDeviceResponse(
  rawText: string,
  latencyMs: number,
): StoryChatResponse {
  const cleaned = postProcessOnDeviceOutput(rawText);
  return {
    success: true,
    response: cleaned,
    // 2B 모델은 구조화된 감정/친밀도 데이터를 안정적으로 생성할 수 없음
    // → story-chat-runtime의 applyStoryRomancePatch가 텍스트 기반 휴리스틱으로 처리
    emotionTag: undefined,
    delaySec: Math.random() * 1.5 + 0.5,
    affinityDelta: undefined,
    romanceStatePatch: undefined,
    followUpHint: undefined,
    meta: {
      provider: 'on-device',
      model: onDeviceLLMEngine.getActiveModelId() ?? 'gemma-4-e2b-it-q4km',
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
    options?: ChatProviderOptions,
  ): Promise<StoryChatResponse> {
    const systemPrompt = buildOnDeviceSystemPrompt(character, thread);
    const messages = buildOnDeviceMessages(thread, userMessage);

    // 이미지가 첨부된 경우 마지막 user 메시지의 content 를 parts 배열로 재구성.
    if (options?.imageBase64 && messages.length > 0) {
      const last = messages[messages.length - 1];
      if (last.role === 'user') {
        const imageUrl = options.imageBase64.startsWith('data:')
          ? options.imageBase64
          : `data:image/jpeg;base64,${options.imageBase64}`;
        const textContent = typeof last.content === 'string' ? last.content : '';
        const parts: OnDeviceContentPart[] = [
          { type: 'image_url', image_url: { url: imageUrl } },
          { type: 'text', text: textContent },
        ];
        messages[messages.length - 1] = { role: 'user', content: parts };
      }
    }

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
