# RN Photo Input Discovery

Date: 2026-04-08
Scope: `apps/mobile-rn`

## Findings

- RN workspace had no active survey photo pipeline, so this batch adds `expo-image-picker` and wires it into survey-scoped input.
- The only existing app-level photo entry point was an alert stub in [chat-screen.tsx](/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/chat-screen.tsx).
- Survey UI already had custom footer rendering, so the safest path was to extend survey input kinds instead of building a separate attachment system.
- `fortune-face-reading` requires real image data and throws when no image is provided. `analysis_source=upload` plus base64 image works.
- `fortune-ootd` requires `imageBase64|image` and `tpo`; text-only notes are supplementary and not sufficient.

## Implementation Direction

- Add `photo` survey step support in RN survey/footer
- Use `expo-image-picker` with media-library permission and base64 enabled
- Submit the selected photo as a structured survey answer and map it explicitly in edge request bodies
- Keep generic composer photo upload out of scope for now; only survey-scoped photo input is enabled in this batch
