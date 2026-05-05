/**
 * Ondo design system — component barrel.
 *
 * Import the canonical component library through this entry point so the
 * app uses one mental model for primitives. Grouped by role:
 *
 *   • Typography / text
 *   • Actions (CTA, Pill)
 *   • Inputs / pickers
 *   • Surfaces & cards
 *   • Chat / oracle
 *   • Auth / social
 *
 * Existing ad-hoc imports from individual files still work; this barrel is
 * additive. Prefer `import { Pill, DateInput } from '@/components'`
 * for new code.
 */

// --- Text / typography ---
export { AppText } from './app-text';

// --- Actions ---
// `PrimaryButton` is the Ondo Pill primitive (variant/size/loading/fullWidth).
export { PrimaryButton } from './primary-button';

// --- Inputs / pickers (Ondo onboarding primitives) ---
export { DateInput, type DateInputValue } from './date-input';
export { MBTIPicker, type MbtiType } from './mbti-picker';
export { ToneSlider } from './tone-slider';

// --- Onboarding scaffolding ---
export { OnboardingShell } from './onboarding-shell';
export { RelationshipCard } from './relationship-card';

// --- Chips ---
// `Chip` is a non-interactive pastel label tag (existing).
// `SelectableChip` is the interactive selected/unselected chip (Ondo spec).
export { Chip } from './chip';
export { SelectableChip } from './selectable-chip';

// --- Surfaces / media ---
export { Avatar } from './avatar';
export { Card } from './card';
export { CharacterCard, type CharacterCardProps } from './character-card';
export { Screen } from './screen';

// --- Auth / social ---
export { AppleAuthButton } from './apple-auth-button';
export { SocialAuthPillButton } from './social-auth-pill-button';
