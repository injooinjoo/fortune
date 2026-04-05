# Fortune DESIGN.md

This file is the agent-facing visual contract for Fortune.

- Official design source of truth: `paper/README.md` and `docs/design/PAPER_*`
- Runtime source of truth: Flutter design system tokens and widgets under `lib/core/design_system/`
- Inspiration source for this file's structure: `VoltAgent/awesome-design-md`
- Visual reference direction: `linear.app`, adapted to Fortune's existing Paper-aligned tokens and Korean-first product surface

If this file conflicts with Paper docs or checked-in Flutter tokens, Paper and the Flutter runtime win.

## 1. Visual Theme & Atmosphere

Fortune is a dark-mode-native conversational product. The base canvas is almost black with a cool navy cast, then layered with muted graphite surfaces and a single luminous violet CTA. It should feel calm, modern, and a little mysterious, not playful and not neon-heavy.

The product is chat-first. Most screens should feel like they belong to the same family as a premium messenger or a focused AI companion app. Information should emerge from darkness through contrast, spacing, and careful typography instead of loud color.

The emotional mix:
- quiet, premium, slightly mystical
- Korean-first product writing, crisp and contemporary
- intimate rather than dashboard-like
- cinematic in tone, restrained in motion

Key traits:
- deep navy-black background, not flat pure black
- cool white primary text, blue-gray secondary text
- single primary accent in violet
- rounded panels with subtle borders and very soft elevation
- generous breathing room around titles, cards, and conversation clusters
- serif or calligraphic accents only for selective fortune moments, never for core navigation

## 2. Color Palette & Roles

### Dark Mode Core

- Background: `#0B0B10`
- Background Secondary: `#1A1A1A`
- Background Tertiary: `#151821`
- Surface: `#1A1A1A`
- Surface Secondary: `#23232B`
- Surface Elevated: `#17171D`
- Primary Text: `#F5F6FB`
- Secondary Text: `#9198AA`
- Tertiary Text: `#9EA3B3`
- Subtitle Text: `#D0D4E0`
- Divider / Opaque Border: `#2C2C2E`
- Subtle Border: `rgba(255,255,255,0.08)`

### Brand & Interactive

- Primary CTA Background: `#8B7BE8`
- Primary CTA Foreground: `#F5F6FB`
- Secondary Accent: `#8FB8FF`
- Warm Highlight Accent: `#E0A76B`
- Success: `#34C759`
- Warning: `#FFCC00`
- Error: `#FF3B30`

### Chat & Utility

- User Bubble: `#2C2C2E`
- Overlay: `rgba(0,0,0,0.6)`
- Toggle Active: `#34C759`
- Toggle Inactive: `#39393D`

### Light Mode Reference

Use the existing `Lt` token family from `DSColors` for light mode. Light mode should keep the same structure, only inverted:
- white page background
- near-black primary text
- soft gray surfaces
- same violet CTA family

### Color Rules

- Accent color is sparse. Use violet for primary actions, selected states, and key emphasis only.
- Most hierarchy comes from luminance and spacing, not adding more colors.
- Fortune-specific warm accents can appear in result cards, quote blocks, and ritual moments, but they should stay secondary to the core violet system.

## 3. Typography Rules

### Font Families

- Primary UI Font: `NotoSansKR`
- Default English / numbers: `NotoSansKR`
- Monospace when needed: platform default monospace
- Traditional editorial accent: `NanumMyeongjo`, only for selective fortune content

### Hierarchy

| Role | Font | Size | Weight | Line Height | Notes |
|------|------|------|--------|-------------|-------|
| Display Large | NotoSansKR | 40px | 800 | 1.06 | Splash, premium hero, major campaign moments |
| Display Medium | NotoSansKR | 34px | 800 | 1.12 | Large section hero |
| Display Small | NotoSansKR | 28px | 800 | 1.28 | Main emotional headline |
| Heading 1 | NotoSansKR | 28px | 800 | 1.21 | Screen title |
| Heading 2 | NotoSansKR | 22px | 800 | 1.22 | Section title |
| Heading 3 | NotoSansKR | 20px | 500 | 1.20 | Subsection header |
| Heading 4 | NotoSansKR | 18px | 800 | 1.22 | Emphasized callout title |
| Body Large | NotoSansKR | 16px | 400 | 1.58 | Main descriptive copy |
| Body Medium | NotoSansKR | 15px | 400 | 1.55 | Standard content |
| Body Small | NotoSansKR | 14px | 400 | 1.50 | Chat messages, dense metadata |
| Label Large | NotoSansKR | 14px | 700 | 1.28 | Chip label, strong UI label |
| Label Medium | NotoSansKR | 13px | 400 | 1.40 | Secondary label |
| Label Small | NotoSansKR | 12px | 500 | 1.33 | Compact utility label |
| Caption | NotoSansKR | 11px | 400 | 1.36 | Fine metadata |
| Calligraphy Title | NanumMyeongjo | 24px | 700 | 1.50 | Select fortune title only |
| Calligraphy Body | NanumMyeongjo | 17px | 400 | 1.80 | Select quote or ritual block only |

### Typography Principles

- Use bold, tight sans-serif headings for structure.
- Keep body copy highly legible and Korean-friendly.
- Calligraphy is an accent, not the base system.
- Same semantic position should use the same typography token everywhere.
- Respect system font scaling. Do not create brittle layouts that break under accessibility text sizes.

## 4. Component Stylings

### Buttons

**Primary Button**
- Background: violet CTA
- Text: cool white
- Radius: medium to large, never pill by default
- Feel: bright focal action on a dark field

**Secondary Button**
- Background: dark secondary surface
- Text: primary text
- Border: subtle
- Use for fallback, dismissive, or supporting actions

**Ghost Button**
- Transparent or near-transparent background
- Text: secondary or primary text depending on emphasis
- Border optional, but still subtle

### Cards

- Background: `surface` or `surfaceSecondary`
- Border: thin and low-contrast
- Radius: soft, consistent, usually 12-20px visual feel depending on container size
- Shadow: restrained, diffuse, rarely dramatic
- Important cards can use warm accent details, but not full warm backgrounds

### Chat Surfaces

- Conversation bubbles are dense but soft-edged
- User bubbles use darker neutral separation, not saturated accent fills
- Expert/fortune responses can contain stacked modules, summary, detail, and suggestion chips
- Avoid giant walls of uninterrupted text, prefer sectional rhythm

### Inputs

- Background: dark nested surface
- Border: subtle, visible on focus
- Radius: aligned with buttons and cards
- Placeholder text stays tertiary

### Chips & Pills

- Rounded, compact, clear tap target
- Use pastel fills or subdued outlines for category and recommendation chips
- Do not turn every chip into a CTA

### App Bar / Navigation

- iOS-style back affordance when a back button exists
- Minimal chrome, title-first
- Navigation should not compete with content

### Blur & Glass

- Use blur selectively for premium overlays, modal treatment, or hero polish
- Blur should support atmosphere, not reduce readability

## 5. Layout Principles

Fortune is mobile-first.

- Prefer one strong vertical column
- Let chat, onboarding, premium, and profile feel structurally related
- Use clear section breaks rather than dense grid mosaics
- Keep first-view content emotionally legible within one screen

Spacing rhythm:
- Base spacing should follow existing design-system tokens
- Small rhythm: 4, 8, 12
- Primary rhythm: 16, 20, 24
- Large section separation: 32+

Layout behavior:
- chat screens prioritize message rhythm and composer placement
- onboarding screens prioritize one primary decision at a time
- premium and result screens can become more cinematic, but still keep a strong linear reading path

## 6. Depth & Elevation

- Depth is subtle and layered
- Use contrast between `background`, `surface`, and `surfaceSecondary` before adding heavier shadow
- Borders do most of the separation work
- Elevated states should feel like floating sheets, not hard cards
- Modals and bottom sheets can be slightly brighter than the page background, with clean rounded corners

## 7. Do's and Don'ts

### Do

- Use existing `DSColors`, typography, spacing, radius, and shadow tokens
- Preserve dark-mode-first visual tone
- Keep UI calm, precise, and premium
- Make fortune moments feel special through copy, spacing, and selective warm accents
- Keep chat surfaces readable and emotionally paced

### Don't

- Do not hardcode colors, raw font sizes, or `Colors.white/black`
- Do not flood the UI with gradients, sparkles, or mystical decoration
- Do not turn the whole app into a fantasy theme park
- Do not use serif or calligraphy for core navigation and dense UI
- Do not introduce bright secondary accents that compete with violet CTA
- Do not create generic SaaS dashboard layouts for conversational surfaces

## 8. Responsive Behavior

- Primary target is phone portrait
- Tablet should preserve hierarchy, not simply stretch every panel
- Large screens can widen reading areas and create two-column support layouts, but chat and fortune reading should still feel intimate
- Minimum touch targets should remain comfortable
- Typography and spacing should scale without collapsing card rhythm

## 9. Agent Prompt Guide

When generating new UI for this project, use prompts like:

- "Use the Fortune DESIGN.md and build a dark-mode-first mobile screen with a calm premium chat aesthetic, cool white text, graphite surfaces, and a single violet CTA."
- "Match the Paper-aligned Fortune design system. Keep the layout mobile-first, rounded, understated, and emotionally readable."
- "Use NotoSansKR for the main interface, reserve NanumMyeongjo only for selective fortune content, and avoid generic dashboard patterns."

Quick checklist for agents:
- Is the page clearly mobile-first?
- Is violet the only strong interactive accent?
- Are cards and panels dark, layered, and low-noise?
- Is text hierarchy doing the work instead of extra decoration?
- Does the screen feel like it belongs beside `/chat`, `/premium`, and fortune result flows?
