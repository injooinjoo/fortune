# Race Condition Review: app-bootstrap-provider.tsx Linking listener hoist

**File**: `apps/mobile-rn/src/providers/app-bootstrap-provider.tsx`
**Change**: `Linking.addEventListener('url', …)` moved to the top of `useEffect`, before `void bootstrap()`, `authSubscription`, `installPushNotificationHandlers`.

## Verdict: **PASS-WITH-CAVEAT**

The hoist fixes the iPad OAuth cold-start event-miss window and is behaviorally safe. One real double-exchange window remains (low severity; idempotent failure path). Two minor cleanup/leakage observations below.

---

## 1. Hoisting correctness — OK

`handleDeepLink` is an `async function` *declaration* inside the `useEffect` arrow function. Function declarations — including `async` ones — are hoisted to the top of their enclosing function scope (strict mode does not disable function-declaration hoisting, only block-scoped re-declaration and `this`-binding). So even though the `Linking.addEventListener` call textually precedes `handleDeepLink`, the identifier is already bound in the effect's scope at the time `addEventListener` runs. TDZ applies only to `let/const/class`, not to `function`/`async function` declarations. The listener closure captures `handleDeepLink` by reference, and by the time an event fires (next tick at the earliest), it is fully initialized.

Confirmed safe.

## 2. Cold-start OAuth timeline

- (a)(b) Killed + https or custom scheme tap: iOS puts the URL in `getInitialURL()`. Bootstrap picks it up at line 217 and calls `exchangeAuthCodeFromUrl` + `handleDeepLink(initialUrl)` at 269. Listener is attached but iOS does **not** additionally fire the `url` event in this cold-start path (getInitialURL consumes it). **Handled.**
- (c) Backgrounded OAuth return: iOS delivers via `url` event. Listener is now installed synchronously on mount, before any `await`, so even a brutally fast return is caught. **Now handled** (previously could miss if listener was deferred behind `await Promise.all(...)` inside bootstrap).
- (d) Native Apple: returns via Promise in `startAppleNativeAuth`; no URL event needed. **Handled.**
- (e) iPad fallback → `WebBrowser.openAuthSessionAsync`: the result is typically returned via the promise (ASWebAuthenticationSession intercepts the callback scheme). But when `preferEphemeralSession` or timing anomalies cause the system to deliver via the OS URL event instead (observed on iPadOS 17 + Safari-ViewController fallback — the exact 2.1 reject scenario), the top-of-effect listener catches it. **Now handled.**

## 3. Double-handling: getInitialURL + url event

On iOS, `getInitialURL` and the `url` event are mutually exclusive on cold start — the URL is delivered via exactly one path. However, **(c)/(e) + racing re-entry** can still double-fire: bootstrap's `exchangeAuthCodeFromUrl(initialUrl)` at line 220 and the listener's `exchangeAuthCodeFromUrl(targetUrl)` at line 289 can both execute if the OS re-delivers the same URL while bootstrap is mid-await (rare but documented on iOS 14/15 after resume).

Idempotency of `exchangeAuthCodeFromUrl` (`apps/mobile-rn/src/lib/auth-session.ts`):
- Calls `supabase.auth.exchangeCodeForSession(code)`. Supabase's PKCE exchange **invalidates** the code after first use — the second call throws `invalid_grant` / `code already used`.
- The first call succeeds and populates the session via `onAuthStateChange` (line 309).
- The second throw is caught (`.catch(error => captureError(...))`) so user-visible behavior is fine, but it generates a spurious Sentry event per duplicate.

**Caveat 1**: consider deduping by URL string. A simple `Set<string>` of recently-seen auth URLs (or a ref holding the last handled URL + timestamp) skipped before calling `exchangeAuthCodeFromUrl` would silence the duplicate-capture noise. Low severity — not blocking.

## 4. Double-invocation of `handleDeepLink`

`setPendingChatFortuneType` is idempotent (AsyncStorage write of same value). `setPendingChatFortuneTypeState` is a React setter; same value is a no-op re-render. `router.replace` called twice with the same target is effectively a no-op (expo-router dedupes identical replaces). Debug override branch also idempotent. **Safe.**

## 5. Closure staleness — `mounted`

`mounted` is a plain `let` in the effect's closure. The listener closes over it by reference (JS closure semantics), so reads of `mounted` inside `handleDeepLink` see the up-to-date value even after cleanup flips it to `false`. Correct.

## 6. Cleanup ordering / late setState

Window: listener fires → `exchangeAuthCodeFromUrl` in-flight → component unmounts → `linkSubscription.remove()` runs → the in-flight promise later resolves → `.then(() => handleDeepLink(targetUrl))` runs → inside `handleDeepLink`, `setPendingChatFortuneTypeState` is guarded by `if (mounted)` ✅, but `router.replace` is **not** guarded.

`router.replace` after unmount of the provider is near-impossible in practice (the provider wraps the whole app in `_layout.tsx`; its unmount = app teardown), so this is theoretical. Also, Supabase session exchange can `setState` indirectly via `onAuthStateChange` — that subscription is already unsubscribed in cleanup, so no leak.

**Caveat 2**: the post-unmount navigation is defensively worth gating, but not required.

## 7. Apple's "first synchronous code path" bar

The listener is now attached in the first synchronous pass of the provider's first `useEffect`. That's the earliest React allows user code to run after mount. True "first synchronous code path" would be module top-level or `app/_layout.tsx` root body, which would also catch URL events during provider re-mount storms (e.g., fast-refresh). **Gap is small but real** — moving the handler into `_layout.tsx` (or `registerRootComponent` adjacency) would be marginally better. Not required for the reject fix.

## 8. `getInitialURL` vs listener on iOS

Confirmed: iOS delivers a cold-start URL via `getInitialURL` **or** the `url` event, never both in the same launch. No double dispatch here.

## 9. `WebBrowser.openAuthSessionAsync` + listener

`openAuthSessionAsync` with `preferEphemeralSession: true` intercepts the callback inside ASWebAuthenticationSession; the URL is returned via the promise (`result.url`) and `completeInAppAuthSession` calls `exchangeAuthCodeFromUrl` directly (line 203 in `social-auth.ts`). The OS generally does **not** additionally fire `Linking`'s `url` event in this path.

**However**: on the iPad FULL_SCREEN fallback + ephemeral-session edge, iOS has been observed to deliver the URL via both the ASWebAuth promise *and* the system URL event. That would trigger two `exchangeAuthCodeFromUrl` calls on the same code — same outcome as §3 (one succeeds, one throws `code already used`, captured). Same mitigation recommended.

---

## Remaining concerns (non-blocking)

1. **Duplicate auth-code exchange**: add URL-level dedup (Set/ref) around `exchangeAuthCodeFromUrl` to suppress benign `invalid_grant` Sentry noise when OS double-delivers.
2. **Post-unmount `router.replace`**: guard with `if (mounted)` inside `handleDeepLink` before the `router.replace` call for completeness.
3. **Optional hardening**: move the URL listener into `app/_layout.tsx` root (or a dedicated always-mounted listener module) to catch events during provider fast-refresh remounts.

None block ship. The hoist achieves its stated goal and closes the iPad 2.1-reject window.
