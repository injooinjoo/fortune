import { type Session } from '@supabase/supabase-js';

import { selectedOnboardingInterestIds } from './onboarding-interest-catalog';
import { supabase } from './supabase';
import { type MobileAppStatePatch } from './mobile-app-state';

interface RemoteUserProfileRow {
  id: string;
  email?: string | null;
  name?: string | null;
  birth_date?: string | null;
  birth_time?: string | null;
  mbti?: string | null;
  mbti_type?: string | null;
  blood_type?: string | null;
  fortune_preferences?: Record<string, unknown> | null;
  token_balance?: number | null;
  onboarding_completed?: boolean | null;
  primary_provider?: string | null;
  linked_providers?: string[] | null;
  profile_image_url?: string | null;
}

function sessionProvider(session: Session) {
  const provider = session.user.app_metadata.provider;
  return typeof provider === 'string' && provider.length > 0 ? provider : null;
}

function sessionName(session: Session) {
  const metadata = session.user.user_metadata ?? {};
  const name = metadata.name ?? metadata.full_name;
  return typeof name === 'string' && name.length > 0 ? name : null;
}

function sessionAvatarUrl(session: Session) {
  const avatarUrl = session.user.user_metadata?.avatar_url;
  return typeof avatarUrl === 'string' && avatarUrl.length > 0 ? avatarUrl : null;
}

function buildInsertPayload(session: Session) {
  const provider = sessionProvider(session);

  return {
    id: session.user.id,
    email: session.user.email ?? null,
    name: sessionName(session),
    profile_image_url: sessionAvatarUrl(session),
    primary_provider: provider,
    linked_providers: provider ? [provider] : [],
    token_balance: 100,
  };
}

function buildSyncUpdates(
  session: Session,
  current: RemoteUserProfileRow,
): Record<string, unknown> {
  const updates: Record<string, unknown> = {};
  const nextEmail = session.user.email ?? null;
  const nextName = sessionName(session);
  const nextAvatarUrl = sessionAvatarUrl(session);
  const provider = sessionProvider(session);
  const linkedProviders = Array.isArray(current.linked_providers)
    ? [...current.linked_providers]
    : [];

  if (nextEmail && current.email !== nextEmail) {
    updates.email = nextEmail;
  }

  if (nextName && current.name !== nextName) {
    updates.name = nextName;
  }

  if (nextAvatarUrl && current.profile_image_url !== nextAvatarUrl) {
    updates.profile_image_url = nextAvatarUrl;
  }

  if (provider && !linkedProviders.includes(provider)) {
    updates.linked_providers = [...linkedProviders, provider];
  }

  if (provider && !current.primary_provider) {
    updates.primary_provider = provider;
  }

  return updates;
}

export async function ensureRemoteUserProfile(session: Session) {
  if (!supabase) {
    return null;
  }

  const client = supabase;
  const userId = session.user.id;
  const { data: existingProfile, error: selectError } = await client
    .from('user_profiles')
    .select()
    .eq('id', userId)
    .maybeSingle<RemoteUserProfileRow>();

  if (selectError) {
    throw selectError;
  }

  if (!existingProfile) {
    const { data: createdProfile, error: insertError } = await client
      .from('user_profiles')
      .insert(buildInsertPayload(session))
      .select()
      .single<RemoteUserProfileRow>();

    if (insertError) {
      throw insertError;
    }

    return createdProfile;
  }

  const updates = buildSyncUpdates(session, existingProfile);

  if (Object.keys(updates).length === 0) {
    return existingProfile;
  }

  const { data: syncedProfile, error: updateError } = await client
    .from('user_profiles')
    .update(updates)
    .eq('id', userId)
    .select()
    .single<RemoteUserProfileRow>();

  if (updateError) {
    throw updateError;
  }

  return syncedProfile;
}

export async function updateRemoteUserProfile(
  userId: string,
  updates: Record<string, unknown>,
) {
  if (!supabase || Object.keys(updates).length === 0) {
    return null;
  }

  const { data, error } = await supabase
    .from('user_profiles')
    .update(updates)
    .eq('id', userId)
    .select()
    .single<RemoteUserProfileRow>();

  if (error) {
    throw error;
  }

  return data;
}

export function remoteProfileToPatch(
  profile: RemoteUserProfileRow,
): MobileAppStatePatch {
  const patch: MobileAppStatePatch = {
    profile: {
      displayName: profile.name ?? '',
      birthDate: profile.birth_date ?? '',
      birthTime: profile.birth_time ?? '',
      mbti: profile.mbti ?? profile.mbti_type ?? '',
      bloodType: profile.blood_type ?? '',
      interestIds: selectedOnboardingInterestIds(
        (profile.fortune_preferences as Record<string, unknown> | null)
          ?.category_weights,
      ),
    },
  };

  if (typeof profile.token_balance === 'number') {
    patch.premium = {
      tokenBalance: profile.token_balance,
    };
  }

  return patch;
}

export function remoteProfileToOnboardingPatch(profile: RemoteUserProfileRow) {
  const hasBirthDate =
    typeof profile.birth_date === 'string' && profile.birth_date.length > 0;
  const onboardingCompleted =
    profile.onboarding_completed === true ||
    selectedOnboardingInterestIds(
      (profile.fortune_preferences as Record<string, unknown> | null)
        ?.category_weights,
    ).length > 0;

  return {
    birthCompleted: hasBirthDate,
    interestCompleted: onboardingCompleted,
  };
}
