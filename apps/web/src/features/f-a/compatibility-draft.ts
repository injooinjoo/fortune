export interface CompatibilityDraft {
  firstName: string;
  firstBirthDate: string;
  secondName: string;
  secondBirthDate: string;
}

export interface CompatibilityDraftStorage {
  getItem(key: string): string | null;
  setItem(key: string, value: string): unknown;
  removeItem(key: string): unknown;
}

const COMPATIBILITY_DRAFT_KEY = 'ondo:compatibility-draft';

function isDraft(value: unknown): value is CompatibilityDraft {
  if (!value || typeof value !== 'object') return false;
  const draft = value as Record<string, unknown>;
  return (
    typeof draft.firstName === 'string' &&
    typeof draft.firstBirthDate === 'string' &&
    typeof draft.secondName === 'string' &&
    typeof draft.secondBirthDate === 'string'
  );
}

export function readCompatibilityDraft(
  storage: CompatibilityDraftStorage,
): CompatibilityDraft | null {
  try {
    const raw = storage.getItem(COMPATIBILITY_DRAFT_KEY);
    if (!raw) return null;
    const value: unknown = JSON.parse(raw);
    return isDraft(value) ? value : null;
  } catch {
    return null;
  }
}

export function writeCompatibilityDraft(
  storage: CompatibilityDraftStorage,
  draft: CompatibilityDraft,
): void {
  const empty = Object.values(draft).every((value) => value === '');
  try {
    if (empty) storage.removeItem(COMPATIBILITY_DRAFT_KEY);
    else storage.setItem(COMPATIBILITY_DRAFT_KEY, JSON.stringify(draft));
  } catch {
    // Storage can be unavailable in private or restricted browser contexts.
  }
}

export function clearCompatibilityDraft(storage: CompatibilityDraftStorage): void {
  try {
    storage.removeItem(COMPATIBILITY_DRAFT_KEY);
  } catch {
    // A completed reading must not fail only because storage cleanup is unavailable.
  }
}
