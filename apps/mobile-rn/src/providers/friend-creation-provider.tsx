import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type PropsWithChildren,
} from 'react';

import * as Crypto from 'expo-crypto';

import {
  deleteSecureItem,
  getSecureItem,
  setSecureItem,
} from '../lib/secure-store-storage';

export type FriendDraftGender = 'female' | 'male' | 'other';
export type FriendDraftRelationship =
  | 'friend'
  | 'crush'
  | 'partner'
  | 'colleague';
export type FriendDraftStylePreset = 'warm' | 'calm' | 'chic' | 'dreamy';
export type FriendDraftTimeMode = 'realTime' | 'timeless';

export interface FriendCreationDraft {
  name: string;
  gender: FriendDraftGender | null;
  relationship: FriendDraftRelationship | null;
  stylePreset: FriendDraftStylePreset | null;
  personalityTags: string[];
  interestTags: string[];
  scenario: string;
  memoryNote: string;
  timeMode: FriendDraftTimeMode | null;
  avatarPrompt: string;
  avatarUrl: string | null;
}

export interface CreatedFriend {
  id: string;
  name: string;
  gender: FriendDraftGender;
  relationship: FriendDraftRelationship;
  stylePreset: FriendDraftStylePreset;
  personalityTags: string[];
  interestTags: string[];
  scenario: string;
  memoryNote: string;
  timeMode: FriendDraftTimeMode;
  avatarUrl: string | null;
  createdAt: string;
}

interface FriendCreationContextValue {
  draft: FriendCreationDraft;
  createdFriends: readonly CreatedFriend[];
  isBasicComplete: boolean;
  isPersonaComplete: boolean;
  isStoryComplete: boolean;
  updateBasic: (patch: Partial<FriendCreationDraft>) => void;
  updatePersona: (patch: Partial<FriendCreationDraft>) => void;
  updateStory: (patch: Partial<FriendCreationDraft>) => void;
  updateAvatar: (patch: Partial<Pick<FriendCreationDraft, 'avatarPrompt' | 'avatarUrl'>>) => void;
  resetDraft: () => void;
  saveFriend: (draft: FriendCreationDraft) => Promise<CreatedFriend>;
  removeFriend: (friendId: string) => Promise<void>;
}

const createdFriendsStorageKey = 'fortune.created-friends.v1';

const emptyDraft: FriendCreationDraft = {
  name: '',
  gender: null,
  relationship: null,
  stylePreset: null,
  personalityTags: [],
  interestTags: [],
  scenario: '',
  memoryNote: '',
  timeMode: null,
  avatarPrompt: '',
  avatarUrl: null,
};

function isValidCreatedFriend(value: unknown): value is CreatedFriend {
  if (typeof value !== 'object' || value === null) {
    return false;
  }

  const record = value as Record<string, unknown>;

  return (
    typeof record.id === 'string' &&
    typeof record.name === 'string' &&
    typeof record.gender === 'string' &&
    typeof record.relationship === 'string' &&
    typeof record.stylePreset === 'string' &&
    Array.isArray(record.personalityTags) &&
    Array.isArray(record.interestTags) &&
    typeof record.scenario === 'string' &&
    typeof record.memoryNote === 'string' &&
    typeof record.timeMode === 'string' &&
    typeof record.createdAt === 'string'
  );
}

async function loadCreatedFriends(): Promise<CreatedFriend[]> {
  try {
    const raw = await getSecureItem(createdFriendsStorageKey);

    if (!raw) {
      return [];
    }

    const parsed = JSON.parse(raw) as unknown;

    if (!Array.isArray(parsed)) {
      return [];
    }

    return parsed.filter(isValidCreatedFriend);
  } catch {
    return [];
  }
}

async function persistCreatedFriends(friends: CreatedFriend[]): Promise<void> {
  if (friends.length === 0) {
    await deleteSecureItem(createdFriendsStorageKey);
    return;
  }

  await setSecureItem(createdFriendsStorageKey, JSON.stringify(friends));
}

const FriendCreationContext = createContext<FriendCreationContextValue>({
  draft: emptyDraft,
  createdFriends: [],
  isBasicComplete: false,
  isPersonaComplete: false,
  isStoryComplete: false,
  updateBasic: () => undefined,
  updatePersona: () => undefined,
  updateStory: () => undefined,
  updateAvatar: () => undefined,
  resetDraft: () => undefined,
  saveFriend: () => Promise.reject(new Error('Provider not mounted')),
  removeFriend: () => Promise.reject(new Error('Provider not mounted')),
});

export function FriendCreationProvider({ children }: PropsWithChildren) {
  const [draft, setDraft] = useState<FriendCreationDraft>(emptyDraft);
  const [createdFriends, setCreatedFriends] = useState<CreatedFriend[]>([]);

  useEffect(() => {
    let cancelled = false;

    loadCreatedFriends()
      .then((friends) => {
        if (!cancelled) {
          setCreatedFriends(friends);
        }
      })
      .catch(() => undefined);

    return () => {
      cancelled = true;
    };
  }, []);

  const saveFriend = useCallback(
    async (draftToSave: FriendCreationDraft): Promise<CreatedFriend> => {
      const friend: CreatedFriend = {
        id: `custom_${Crypto.randomUUID()}`,
        name: draftToSave.name.trim(),
        gender: draftToSave.gender!,
        relationship: draftToSave.relationship!,
        stylePreset: draftToSave.stylePreset!,
        personalityTags: [...draftToSave.personalityTags],
        interestTags: [...draftToSave.interestTags],
        scenario: draftToSave.scenario.trim(),
        memoryNote: draftToSave.memoryNote.trim(),
        timeMode: draftToSave.timeMode!,
        avatarUrl: draftToSave.avatarUrl ?? null,
        createdAt: new Date().toISOString(),
      };

      const nextFriends = [...createdFriends, friend];
      await persistCreatedFriends(nextFriends);
      setCreatedFriends(nextFriends);

      return friend;
    },
    [createdFriends],
  );

  const removeFriend = useCallback(
    async (friendId: string): Promise<void> => {
      const nextFriends = createdFriends.filter(
        (friend) => friend.id !== friendId,
      );
      await persistCreatedFriends(nextFriends);
      setCreatedFriends(nextFriends);
    },
    [createdFriends],
  );

  const updateBasic = useCallback(
    (patch: Partial<FriendCreationDraft>) => setDraft((c) => ({ ...c, ...patch })),
    [],
  );
  const updatePersona = useCallback(
    (patch: Partial<FriendCreationDraft>) => setDraft((c) => ({ ...c, ...patch })),
    [],
  );
  const updateStory = useCallback(
    (patch: Partial<FriendCreationDraft>) => setDraft((c) => ({ ...c, ...patch })),
    [],
  );
  const updateAvatar = useCallback(
    (patch: Partial<Pick<FriendCreationDraft, 'avatarPrompt' | 'avatarUrl'>>) =>
      setDraft((c) => ({ ...c, ...patch })),
    [],
  );
  const resetDraft = useCallback(() => setDraft(emptyDraft), []);

  const value = useMemo<FriendCreationContextValue>(() => {
    const isBasicComplete =
      draft.name.trim().length > 0 &&
      draft.gender !== null &&
      draft.relationship !== null;
    const isPersonaComplete =
      draft.stylePreset !== null &&
      draft.personalityTags.length >= 2 &&
      draft.interestTags.length >= 2;
    const isStoryComplete =
      draft.scenario.trim().length > 0 && draft.timeMode !== null;

    return {
      draft,
      createdFriends,
      isBasicComplete,
      isPersonaComplete,
      isStoryComplete,
      updateBasic,
      updatePersona,
      updateStory,
      updateAvatar,
      resetDraft,
      saveFriend,
      removeFriend,
    };
  }, [createdFriends, draft, removeFriend, saveFriend, updateAvatar, updateBasic, updatePersona, updateStory, resetDraft]);

  return (
    <FriendCreationContext.Provider value={value}>
      {children}
    </FriendCreationContext.Provider>
  );
}

export function useFriendCreation() {
  return useContext(FriendCreationContext);
}
