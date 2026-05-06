import type { FortuneTypeId } from '@fortune/product-contracts';

export type ChatSurveyInputKind =
  | 'chips'
  | 'multi-select'
  | 'text'
  | 'text-with-skip'
  | 'date'
  | 'card-draw'
  | 'image'
  | 'mbti-axis'
  | 'deck-picker';

export interface ChatSurveyOption {
  id: string;
  label: string;
  emoji?: string;
  /** 'deck-picker' inputKind 에서 카드 하단에 1줄로 표시되는 부가 설명. */
  description?: string;
  /** 'deck-picker' / 'card-draw' 에서 카드 표지 그라데이션 색상. */
  coverColors?: {
    primary: string;
    secondary: string;
  };
}

export interface ChatSurveyStep {
  id: string;
  question: string;
  inputKind: ChatSurveyInputKind;
  options?: readonly ChatSurveyOption[];
  required?: boolean;
  showWhen?: Partial<Record<string, string | readonly string[]>>;
  maxSelections?: number;
  placeholder?: string;
}

export interface ChatSurveyDefinition {
  fortuneType: FortuneTypeId;
  title: string;
  introReply: string;
  submitReply: string;
  steps: readonly ChatSurveyStep[];
}

export interface ActiveChatSurvey {
  fortuneType: FortuneTypeId;
  definition: ChatSurveyDefinition;
  currentStepIndex: number;
  answers: Record<string, unknown>;
}

export interface CompletedChatSurvey {
  fortuneType: FortuneTypeId;
  answers: Record<string, unknown>;
}
