# KAN-325 Verify Report

## Scope
- Aligned social auth CTA wording to the `로그인` action family.
- Switched the Apple native button from the `CONTINUE` variant to the `SIGN_IN` variant.

## Verification
1. Diff safety
   - `git diff --check -- apps/mobile-rn/src/components/apple-auth-button.tsx apps/mobile-rn/src/screens/signup-screen.tsx apps/mobile-rn/src/features/chat-surface/chat-surface.tsx artifacts/design/mobile-rn/KAN-325_discovery_report.md`
   - Result: passed
2. Type validation
   - `npm run rn:typecheck`
   - Result: passed
3. Repository validation
   - `flutter analyze`
   - Result: `No issues found!`
4. Runtime verification
   - `npm run ios --workspace @fortune/mobile-rn -- --device 9ED1D212-A3D3-43F1-9E36-2F1F54367878`
   - Result: build, install, and app launch succeeded on iPhone 17 simulator
5. Visual verification
   - Deep link used: `com.beyond.fortune://signup?returnTo=%2Fchat`
   - Screenshot: `artifacts/runtime/KAN-325-rn-auth-copy-aligned.png`
   - Result:
     - Apple button now uses the native sign-in variant rather than the continue variant
     - Google, Kakao, and Naver buttons all use the `로그인` wording pattern

## Note
- `AppleAuthenticationButton` text is controlled by the native iOS control and localized by the system locale.
- On this simulator, the button renders as `Sign in with Apple`.
- On Korean-localized devices, the same native control will localize accordingly.
- This was kept intentionally to preserve the official/native Apple sign-in control instead of replacing it with a custom shell.
