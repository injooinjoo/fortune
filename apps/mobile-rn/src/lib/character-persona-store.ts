/**
 * Per-user, per-character persona customization storage.
 * Stores custom instructions that get appended to the character's system prompt.
 */

import { getSecureItem, setSecureItem } from './secure-store-storage';

const STORAGE_KEY_PREFIX = 'fortune.mobile-rn.character-persona.v1';

export interface CharacterPersona {
  customInstructions: string;
  updatedAt: string;
}

function buildStorageKey(characterId: string, userId: string | null): string {
  return `${STORAGE_KEY_PREFIX}.${userId ?? 'guest'}.${characterId}`;
}

export async function loadCharacterPersona(
  characterId: string,
  userId: string | null,
): Promise<CharacterPersona | null> {
  const key = buildStorageKey(characterId, userId);
  const raw = await getSecureItem(key);

  if (!raw) {
    return null;
  }

  try {
    const parsed = JSON.parse(raw) as Partial<CharacterPersona>;

    if (
      typeof parsed.customInstructions !== 'string' ||
      !parsed.customInstructions.trim()
    ) {
      return null;
    }

    return {
      customInstructions: parsed.customInstructions.trim(),
      updatedAt: typeof parsed.updatedAt === 'string' ? parsed.updatedAt : new Date().toISOString(),
    };
  } catch {
    return null;
  }
}

export async function saveCharacterPersona(
  characterId: string,
  userId: string | null,
  customInstructions: string,
): Promise<void> {
  const key = buildStorageKey(characterId, userId);

  if (!customInstructions.trim()) {
    await setSecureItem(key, '');
    return;
  }

  const persona: CharacterPersona = {
    customInstructions: customInstructions.trim(),
    updatedAt: new Date().toISOString(),
  };

  await setSecureItem(key, JSON.stringify(persona));
}
