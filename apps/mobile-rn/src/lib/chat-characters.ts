import {
  type FortuneCharacterSpec,
  type FortuneTypeId,
} from '@fortune/product-contracts';

import { type CreatedFriend } from '../providers/friend-creation-provider';

export type ChatCharacterTab = 'story' | 'fortune';

export interface StoryCharacterSpec {
  id: string;
  name: string;
  kind: 'story';
  category: 'story';
  shortDescription: string;
  specialties: readonly FortuneTypeId[];
}

export interface FortuneChatCharacterSpec extends FortuneCharacterSpec {
  kind: 'fortune';
}

export type ChatCharacterSpec = StoryCharacterSpec | FortuneChatCharacterSpec;

// 2026-05-10: 9명 추가 캐릭터 (정태윤/서윤재/강하린/김지호/윤도현/이도윤/한서준/
// 백현우/민준혁) 제거. 메시지 리스트엔 이서준 + 하늘이 둘만 노출. 다른 9명의
// 사진은 이서준 프로필 갤러리로 통합 (character-details.ts:luts.galleryAvatars).
export const storyChatCharacters: readonly StoryCharacterSpec[] = [
  {
    id: 'luts',
    name: '이서준',
    kind: 'story',
    category: 'story',
    shortDescription: '4년차 사수, 표정은 무서운데 챙김은 쉬지 않음',
    specialties: [],
  },
] as const;

// 2026-05-10: contractFortuneCharacters 가 빈 배열로 정리됨. legacy 참조 호환용
// 빈 배열 export 유지.
export const fortuneChatCharacters: readonly FortuneChatCharacterSpec[] = [];

/**
 * PR-A: 하늘이 — 모든 운세 카테고리의 단일 진입점 캐릭터.
 *
 * 본 PR 에서는 `chatCharacters` 배열에 자동 포함되지 않음 — `haneul_enabled` flag
 * 가 true 인 사용자만 보여야 함. PR-B 에서 `getVisibleChatCharacters(flag)` 헬퍼
 * 통해 노출.
 *
 * specialties 는 단일 캐릭터에 운세 전체를 통합하므로 비워둠 (FORTUNE_CATALOG 가
 * 메뉴 카드의 SoT).
 */
export const haneulOracleCharacter: FortuneChatCharacterSpec = {
  id: 'haneul_oracle',
  name: '하늘이',
  kind: 'fortune',
  category: 'lifestyle',
  shortDescription: '오늘 어떤 흐름이 있는지 같이 봐줄게',
  specialties: [],
};

export function normalizeChatCharacterId(
  id: string | null | undefined,
): string | null {
  const trimmed = id?.trim();
  if (!trimmed) {
    return null;
  }

  // 하늘이 통합 이전 iOS Widget/deep link/local state는 fortune_* 캐릭터 ID를
  // 보낼 수 있다. 해당 ID를 그대로 lookup 하면 제거된 캐릭터라 null → luts 로
  // fallback 될 수 있으므로 운세 계열은 모두 하늘이로 정규화한다.
  return trimmed.startsWith('fortune_') ? haneulOracleCharacter.id : trimmed;
}

// 하늘이 통합 후: chatCharacters = story 10명 + 하늘이.
// 기존 fortuneChatCharacters (fortune_haneul, fortune_muhyeon, fortune_stella,
// fortune_dr_mind, fortune_rose 등) 는 deprecated — 채팅 리스트/도메인 lookup
// 모두에서 제외. 운세는 하늘이 단독으로 통합.
//
// fortuneChatCharacters export 자체는 친구 만들기 등 legacy 참조 호환을 위해
// 유지하지만, chatCharacters union 에는 포함 X.
export const chatCharacters: readonly ChatCharacterSpec[] = [
  ...storyChatCharacters,
  haneulOracleCharacter,
];

/**
 * 채팅 리스트에 노출할 캐릭터 — flag 와 무관하게 항상 story + 하늘이.
 * (이전엔 haneul_enabled flag 게이팅이 있었지만 fortune 탭 자체가 사라져서 단순화.)
 */
export function getVisibleChatCharacters(_opts?: {
  haneulEnabled?: boolean;
}): readonly ChatCharacterSpec[] {
  return chatCharacters;
}

export function createdFriendToStoryCharacter(
  friend: CreatedFriend,
): StoryCharacterSpec {
  const relationshipLabel =
    friend.relationship === 'friend'
      ? '친구'
      : friend.relationship === 'crush'
        ? '썸'
        : friend.relationship === 'partner'
          ? '연인'
          : '동료';

  return {
    id: friend.id,
    name: friend.name,
    kind: 'story',
    category: 'story',
    shortDescription: `${relationshipLabel} · ${friend.personalityTags.slice(0, 2).join(', ')}`,
    specialties: [],
  };
}

export function buildChatCharactersWithCustomFriends(
  friends: readonly CreatedFriend[],
): readonly ChatCharacterSpec[] {
  // 하늘이 통합 후: 운세 캐릭터는 하늘이 단독. fortuneChatCharacters 미포함.
  const customStoryCharacters = friends.map(createdFriendToStoryCharacter);
  return [...customStoryCharacters, ...storyChatCharacters, haneulOracleCharacter];
}

export function buildStoryCharactersWithCustomFriends(
  friends: readonly CreatedFriend[],
): readonly StoryCharacterSpec[] {
  const customStoryCharacters = friends.map(createdFriendToStoryCharacter);
  return [...customStoryCharacters, ...storyChatCharacters];
}

export function findChatCharacterById(
  id: string | null | undefined,
  customFriends: readonly CreatedFriend[] = [],
) {
  const normalizedId = normalizeChatCharacterId(id);
  if (!normalizedId) {
    return null;
  }

  const allCharacters = buildChatCharactersWithCustomFriends(customFriends);
  return allCharacters.find((character) => character.id === normalizedId) ?? null;
}

export function isFortuneChatCharacter(
  character: ChatCharacterSpec,
): character is FortuneChatCharacterSpec {
  return character.kind === 'fortune';
}

export function isCustomFriendCharacter(characterId: string): boolean {
  return characterId.startsWith('custom_');
}
