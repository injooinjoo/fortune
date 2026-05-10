import type { FortuneTypeId } from './fortunes';

export interface FortuneCharacterSpec {
  id: string;
  name: string;
  category: string;
  shortDescription: string;
  specialties: FortuneTypeId[];
}

// 2026-05-10: 모든 fortune_* preset 캐릭터 제거. 운세는 하늘이 (haneul_oracle,
// chat-characters.ts) 단독으로 통합. 빈 배열 export 는 legacy 참조 호환용.
export const fortuneCharacters = [] as const satisfies readonly FortuneCharacterSpec[];
