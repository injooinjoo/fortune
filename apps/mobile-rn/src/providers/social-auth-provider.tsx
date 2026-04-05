import {
  createContext,
  useContext,
  useMemo,
  type PropsWithChildren,
} from 'react';

import {
  isSocialAuthSupported,
  socialAuthProviderIds,
  socialAuthProviderLabelById,
  startSocialAuth,
  type SocialAuthProviderId,
  type SocialAuthStartResult,
} from '../lib/social-auth';

interface SocialAuthContextValue {
  supportedProviders: SocialAuthProviderId[];
  providerLabels: Record<SocialAuthProviderId, string>;
  isSupported: (provider: SocialAuthProviderId) => boolean;
  startSocialAuth: (provider: SocialAuthProviderId) => Promise<SocialAuthStartResult>;
}

const SocialAuthContext = createContext<SocialAuthContextValue>({
  supportedProviders: socialAuthProviderIds,
  providerLabels: socialAuthProviderLabelById,
  isSupported: isSocialAuthSupported,
  startSocialAuth,
});

export function SocialAuthProvider({ children }: PropsWithChildren) {
  const value = useMemo(
    () => ({
      supportedProviders: socialAuthProviderIds,
      providerLabels: socialAuthProviderLabelById,
      isSupported: isSocialAuthSupported,
      startSocialAuth,
    }),
    [],
  );

  return (
    <SocialAuthContext.Provider value={value}>
      {children}
    </SocialAuthContext.Provider>
  );
}

export function useSocialAuth() {
  return useContext(SocialAuthContext);
}
