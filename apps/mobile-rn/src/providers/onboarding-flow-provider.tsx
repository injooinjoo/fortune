import {
  createContext,
  useCallback,
  useContext,
  useMemo,
  useState,
  type ReactNode,
} from 'react';

// Minimal in-memory onboarding flow store. Mirrors the Ondo Design System
// `rn/src/state/onboarding.tsx` schema verbatim so future data-shape
// migrations stay in lock-step with the design handoff. Values are flushed
// into the production `MobileAppState.profile` + `updateOnboardingProgress`
// only at the end of the flow (see `/onboarding/first-chat`).

export type RelationshipId = '친구' | '선배' | '연인' | '멘토' | '전문가';

export interface OnboardingFlowData {
  name: string;
  birth?: { y: string; m: string; d: string };
  mbti?: string;
  relationship?: RelationshipId;
  tone: {
    formality: 0 | 1 | 2; // 존댓말 ↔ 반말
    warmth: 0 | 1 | 2; // 따뜻함 ↔ 직설
    length: 0 | 1 | 2; // 짧게 ↔ 길게
  };
  topics: string[];
}

const DEFAULT: OnboardingFlowData = {
  name: '',
  tone: { formality: 0, warmth: 0, length: 1 },
  topics: [],
};

interface OnboardingFlowContextValue {
  data: OnboardingFlowData;
  update: (patch: Partial<OnboardingFlowData>) => void;
  reset: () => void;
}

const OnboardingFlowContext = createContext<OnboardingFlowContextValue | null>(
  null,
);

export function OnboardingFlowProvider({ children }: { children: ReactNode }) {
  const [data, setData] = useState<OnboardingFlowData>(DEFAULT);

  const update = useCallback((patch: Partial<OnboardingFlowData>) => {
    setData((current) => ({ ...current, ...patch }));
  }, []);

  const reset = useCallback(() => setData(DEFAULT), []);

  const value = useMemo(
    () => ({ data, update, reset }),
    [data, update, reset],
  );

  return (
    <OnboardingFlowContext.Provider value={value}>
      {children}
    </OnboardingFlowContext.Provider>
  );
}

export function useOnboardingFlow() {
  const ctx = useContext(OnboardingFlowContext);
  if (!ctx) {
    throw new Error(
      'useOnboardingFlow must be called inside <OnboardingFlowProvider>',
    );
  }
  return ctx;
}

