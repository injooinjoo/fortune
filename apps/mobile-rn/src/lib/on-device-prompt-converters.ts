/**
 * Prompt converters — 모델 계열별 메시지 포맷 변환기.
 *
 * llama.rn 의 `completion({ messages, jinja })` 는 GGUF 내장 chat template 을
 * 쓰지만, 모델 계열마다 "template 이 받아들이는 메시지 모양"이 다르다:
 *
 * - Gemma (2/3/3n/4): system role 미지원, user/assistant 엄격 교대
 *     → 시스템 프롬프트를 첫 user 메시지에 fold.
 * - Phi-4 / Phi-3: system role 지원, `<|system|>...<|end|>` 포맷
 * - Qwen2/Qwen3: system role 지원, `<|im_start|>...<|im_end|>` 포맷
 * - Llama3+: system role 지원, `<|start_header_id|>...<|eot_id|>` 포맷
 *
 * 이 파일은 계열별로 PromptConverter 구현을 두고, variant 가 지정한
 * `promptFamily` 로 적절한 변환기를 돌려준다. 새 모델을 추가할 때는
 *   (1) 여기에 컨버터 구현 추가
 *   (2) Registry 의 ModelVariant.promptFamily 에 해당 계열 지정
 * 만 하면 엔진 코드 수정 없이 적용된다.
 */

export type PromptFamily = 'gemma' | 'phi' | 'qwen' | 'llama' | 'default';

export type RNRole = 'system' | 'user' | 'assistant';

export interface PlainMessage {
  role: 'user' | 'assistant';
  content: string;
}

export interface ContentPart {
  type: 'text' | 'image_url';
  text?: string;
  image_url?: { url: string };
}

export interface MultimodalMessage {
  role: 'user' | 'assistant';
  content: ContentPart[];
}

export interface RNConvertedMessage {
  role: RNRole;
  content: string | ContentPart[];
}

export interface ConvertedPrompt {
  messages: RNConvertedMessage[];
  /** llama.rn completion 에 `jinja: true` 로 전달할지 여부. */
  jinja: boolean;
  /** 모델 계열별 추가 stop 토큰 (엔진 공통 stop 에 병합). */
  extraStop?: string[];
}

export interface PromptConverter {
  family: PromptFamily;
  convertText(systemPrompt: string, messages: PlainMessage[]): ConvertedPrompt;
  convertMultimodal(
    systemPrompt: string,
    messages: MultimodalMessage[],
  ): ConvertedPrompt;
}

// ---------------------------------------------------------------------------
// Gemma family — user/assistant 엄격 교대, system 미지원.
// ---------------------------------------------------------------------------

function foldSystemIntoFirstUserText(
  systemPrompt: string,
  messages: PlainMessage[],
): RNConvertedMessage[] {
  const firstUserIdx = messages.findIndex((m) => m.role === 'user');
  if (firstUserIdx < 0) {
    // 히스토리에 user 가 없으면 system 을 단독 user 로 추가.
    return [
      { role: 'user', content: systemPrompt },
      ...messages.map((m) => ({ role: m.role, content: m.content })),
    ];
  }
  return messages.map((m, i) =>
    i === firstUserIdx
      ? {
          role: 'user' as const,
          content: `${systemPrompt}\n\n---\n\n${m.content}`,
        }
      : { role: m.role, content: m.content },
  );
}

function foldSystemIntoFirstUserMultimodal(
  systemPrompt: string,
  messages: MultimodalMessage[],
): RNConvertedMessage[] {
  const firstUserIdx = messages.findIndex((m) => m.role === 'user');
  if (firstUserIdx < 0) {
    return [
      {
        role: 'user',
        content: [{ type: 'text', text: systemPrompt }],
      },
      ...messages.map((m) => ({ role: m.role, content: m.content })),
    ];
  }
  return messages.map((m, i) =>
    i === firstUserIdx
      ? {
          role: 'user' as const,
          content: [
            { type: 'text' as const, text: `${systemPrompt}\n\n---\n\n` },
            ...m.content,
          ],
        }
      : { role: m.role, content: m.content },
  );
}

export const gemmaConverter: PromptConverter = {
  family: 'gemma',
  convertText(systemPrompt, messages) {
    return {
      messages: foldSystemIntoFirstUserText(systemPrompt, messages),
      jinja: true,
      extraStop: ['<end_of_turn>', '<start_of_turn>'],
    };
  },
  convertMultimodal(systemPrompt, messages) {
    return {
      messages: foldSystemIntoFirstUserMultimodal(systemPrompt, messages),
      jinja: true,
      extraStop: ['<end_of_turn>', '<start_of_turn>'],
    };
  },
};

// ---------------------------------------------------------------------------
// Phi family — system role 전용, <|system|>/<|user|>/<|assistant|>/<|end|>.
// ---------------------------------------------------------------------------

function withSystemRoleText(
  systemPrompt: string,
  messages: PlainMessage[],
): RNConvertedMessage[] {
  return [
    { role: 'system', content: systemPrompt },
    ...messages.map((m) => ({ role: m.role, content: m.content })),
  ];
}

function withSystemRoleMultimodal(
  systemPrompt: string,
  messages: MultimodalMessage[],
): RNConvertedMessage[] {
  return [
    { role: 'system', content: [{ type: 'text', text: systemPrompt }] },
    ...messages.map((m) => ({ role: m.role, content: m.content })),
  ];
}

export const phiConverter: PromptConverter = {
  family: 'phi',
  convertText(systemPrompt, messages) {
    return {
      messages: withSystemRoleText(systemPrompt, messages),
      jinja: true,
      extraStop: ['<|end|>', '<|endoftext|>'],
    };
  },
  convertMultimodal(systemPrompt, messages) {
    // 현재 Phi-4 mini 는 vision 미지원 — 보호용 fallback.
    return {
      messages: withSystemRoleMultimodal(systemPrompt, messages),
      jinja: true,
      extraStop: ['<|end|>', '<|endoftext|>'],
    };
  },
};

// ---------------------------------------------------------------------------
// Qwen family — system role 지원, <|im_start|>/<|im_end|> 포맷.
// ---------------------------------------------------------------------------

export const qwenConverter: PromptConverter = {
  family: 'qwen',
  convertText(systemPrompt, messages) {
    return {
      messages: withSystemRoleText(systemPrompt, messages),
      jinja: true,
      extraStop: ['<|im_end|>', '<|endoftext|>'],
    };
  },
  convertMultimodal(systemPrompt, messages) {
    return {
      messages: withSystemRoleMultimodal(systemPrompt, messages),
      jinja: true,
      extraStop: ['<|im_end|>', '<|endoftext|>'],
    };
  },
};

// ---------------------------------------------------------------------------
// Llama3+ family — system role 지원, <|eot_id|> 포맷.
// ---------------------------------------------------------------------------

export const llamaConverter: PromptConverter = {
  family: 'llama',
  convertText(systemPrompt, messages) {
    return {
      messages: withSystemRoleText(systemPrompt, messages),
      jinja: true,
      extraStop: ['<|eot_id|>', '<|end_of_text|>'],
    };
  },
  convertMultimodal(systemPrompt, messages) {
    return {
      messages: withSystemRoleMultimodal(systemPrompt, messages),
      jinja: true,
      extraStop: ['<|eot_id|>', '<|end_of_text|>'],
    };
  },
};

// ---------------------------------------------------------------------------
// Default — 아직 변환기를 정의하지 않은 모델용 보수 기본값 (system role + jinja).
// ---------------------------------------------------------------------------

export const defaultConverter: PromptConverter = {
  family: 'default',
  convertText(systemPrompt, messages) {
    return {
      messages: withSystemRoleText(systemPrompt, messages),
      jinja: true,
    };
  },
  convertMultimodal(systemPrompt, messages) {
    return {
      messages: withSystemRoleMultimodal(systemPrompt, messages),
      jinja: true,
    };
  },
};

// ---------------------------------------------------------------------------
// Registry lookup
// ---------------------------------------------------------------------------

const CONVERTERS: Record<PromptFamily, PromptConverter> = {
  gemma: gemmaConverter,
  phi: phiConverter,
  qwen: qwenConverter,
  llama: llamaConverter,
  default: defaultConverter,
};

export function getConverter(family: PromptFamily): PromptConverter {
  return CONVERTERS[family] ?? defaultConverter;
}
