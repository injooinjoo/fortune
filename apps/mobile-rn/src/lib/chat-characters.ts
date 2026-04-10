import {
  fortuneCharacters as contractFortuneCharacters,
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

export const storyChatCharacters: readonly StoryCharacterSpec[] = [
  {
    id: 'luts',
    name: '러츠',
    kind: 'story',
    category: 'story',
    shortDescription: '명탐정과의 위장결혼, 진짜가 되어버린 계약',
    specialties: [],
  },
  {
    id: 'jung_tae_yoon',
    name: '정태윤',
    kind: 'story',
    category: 'story',
    shortDescription: '맞바람 치자고? 복수인지 위로인지, 선택은 당신의 몫',
    specialties: [],
  },
  {
    id: 'seo_yoonjae',
    name: '서윤재',
    kind: 'story',
    category: 'story',
    shortDescription:
      '내가 만든 게임 속 NPC가 현실로? 아니, 당신이 내 세계를 만들었어요',
    specialties: [],
  },
  {
    id: 'kang_harin',
    name: '강하린',
    kind: 'story',
    category: 'story',
    shortDescription: '사장님 비서? 아뇨, 당신만을 위한 그림자입니다',
    specialties: [],
  },
  {
    id: 'jayden_angel',
    name: '제이든',
    kind: 'story',
    category: 'story',
    shortDescription: '신에게 버림받은 천사, 인간인 당신에게서 구원을 찾다',
    specialties: [],
  },
  {
    id: 'ciel_butler',
    name: '시엘',
    kind: 'story',
    category: 'story',
    shortDescription: '이번 생에선 주인님을 지키겠습니다',
    specialties: [],
  },
  {
    id: 'lee_doyoon',
    name: '이도윤',
    kind: 'story',
    category: 'story',
    shortDescription: '선배, 저 칭찬받으면 꼬리가 나올 것 같아요',
    specialties: [],
  },
  {
    id: 'han_seojun',
    name: '한서준',
    kind: 'story',
    category: 'story',
    shortDescription: '무대 위 그는 빛나지만, 무대 아래 그는 당신만 봅니다',
    specialties: [],
  },
  {
    id: 'baek_hyunwoo',
    name: '백현우',
    kind: 'story',
    category: 'story',
    shortDescription: '당신의 모든 것을 읽을 수 있어요. 단, 당신 마음만 빼고',
    specialties: [],
  },
  {
    id: 'min_junhyuk',
    name: '민준혁',
    kind: 'story',
    category: 'story',
    shortDescription: '힘든 하루 끝, 그가 만든 커피 한 잔이 위로가 됩니다',
    specialties: [],
  },
] as const;

export const fortuneChatCharacters: readonly FortuneChatCharacterSpec[] =
  contractFortuneCharacters.map((character) => ({
    ...character,
    kind: 'fortune' as const,
  }));

export const chatCharacters: readonly ChatCharacterSpec[] = [
  ...storyChatCharacters,
  ...fortuneChatCharacters,
];

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
  const customStoryCharacters = friends.map(createdFriendToStoryCharacter);
  return [...customStoryCharacters, ...storyChatCharacters, ...fortuneChatCharacters];
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
  if (!id) {
    return null;
  }

  const allCharacters = buildChatCharactersWithCustomFriends(customFriends);
  return allCharacters.find((character) => character.id === id) ?? null;
}

export function isFortuneChatCharacter(
  character: ChatCharacterSpec,
): character is FortuneChatCharacterSpec {
  return character.kind === 'fortune';
}

export function isCustomFriendCharacter(characterId: string): boolean {
  return characterId.startsWith('custom_');
}
