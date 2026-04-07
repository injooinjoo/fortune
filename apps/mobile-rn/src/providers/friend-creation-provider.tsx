import {
  createContext,
  useContext,
  useMemo,
  useState,
  type PropsWithChildren,
} from 'react';

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
}

interface FriendCreationContextValue {
  draft: FriendCreationDraft;
  isBasicComplete: boolean;
  isPersonaComplete: boolean;
  isStoryComplete: boolean;
  updateBasic: (patch: Partial<FriendCreationDraft>) => void;
  updatePersona: (patch: Partial<FriendCreationDraft>) => void;
  updateStory: (patch: Partial<FriendCreationDraft>) => void;
  resetDraft: () => void;
}

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
};

const FriendCreationContext = createContext<FriendCreationContextValue>({
  draft: emptyDraft,
  isBasicComplete: false,
  isPersonaComplete: false,
  isStoryComplete: false,
  updateBasic: () => undefined,
  updatePersona: () => undefined,
  updateStory: () => undefined,
  resetDraft: () => undefined,
});

export function FriendCreationProvider({ children }: PropsWithChildren) {
  const [draft, setDraft] = useState<FriendCreationDraft>(emptyDraft);

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
      isBasicComplete,
      isPersonaComplete,
      isStoryComplete,
      updateBasic: (patch) => {
        setDraft((current) => ({
          ...current,
          ...patch,
        }));
      },
      updatePersona: (patch) => {
        setDraft((current) => ({
          ...current,
          ...patch,
        }));
      },
      updateStory: (patch) => {
        setDraft((current) => ({
          ...current,
          ...patch,
        }));
      },
      resetDraft: () => {
        setDraft(emptyDraft);
      },
    };
  }, [draft]);

  return (
    <FriendCreationContext.Provider value={value}>
      {children}
    </FriendCreationContext.Provider>
  );
}

export function useFriendCreation() {
  return useContext(FriendCreationContext);
}
