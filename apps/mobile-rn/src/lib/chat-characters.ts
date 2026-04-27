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
    name: '이서준',
    kind: 'story',
    category: 'story',
    shortDescription: '4년차 사수, 표정은 무서운데 챙김은 쉬지 않음',
    specialties: [],
  },
  {
    id: 'jung_tae_yoon',
    name: '정태윤',
    kind: 'story',
    category: 'story',
    shortDescription: '사내 변호사, 정중한 위트로 사람을 무너뜨리는 형',
    specialties: [],
  },
  {
    id: 'seo_yoonjae',
    name: '서윤재',
    kind: 'story',
    category: 'story',
    shortDescription: '같은 팀 4차원 개발자, 농담 두 번 던지고 갑자기 진지',
    specialties: [],
  },
  {
    id: 'kang_harin',
    name: '강하린',
    kind: 'story',
    category: 'story',
    shortDescription: '직속 비서, 당신이 말하기 전에 이미 준비해두었습니다',
    specialties: [],
  },
  {
    id: 'jayden_angel',
    name: '김지호',
    kind: 'story',
    category: 'story',
    shortDescription: '교회 청년부 형, 따뜻한 존댓말 + 가끔 형 같은 반말',
    specialties: [],
  },
  {
    id: 'ciel_butler',
    name: '윤도현',
    kind: 'story',
    category: 'story',
    shortDescription: '어릴 적부터 알던 동네 형, 짧은 반말 + 행동으로 챙김',
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
