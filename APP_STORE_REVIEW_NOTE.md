# App Store Review Note Source - Ondo

> Current submission source. Use this file together with `apps/mobile-rn/appstore-metadata.md` and `metadata/review_information/notes.txt`. Do **not** use older review-reply drafts that described sign-in as the primary review path.

## Current review strategy

- **Primary path:** guest-first review path.
- **App Store Connect Sign-in required:** `NO`.
- **Optional test account:** provide for account-gated flows such as profile sync, purchase verification, purchase restore, subscription/token balance sync, and account deletion.
- **Current release decision:** `NO-GO` until clean frozen SHA, fresh EAS iOS production build, and required iPhone/iPad/IAP evidence are captured.

## Review notes to paste into App Store Connect

Ondo is an AI-powered entertainment and lifestyle app for fortune-style insights and interactive AI character chat. All fortune/insight content is AI-generated for entertainment purposes only and does not provide medical, legal, financial, or factual prediction advice.

Login is not required to launch the app or review the core guest experience. On a clean install, the app opens through the splash screen and allows access to the main chat/fortune experience without creating an account.

Account sign-in is optional for profile sync, saved history across devices, purchase verification, purchase restore, subscription/token balance sync, and account deletion. For review of these account-gated flows, please use:

Email: test@zpzg.com
Password: TestPassword123!

In-app purchases are available from Profile > Subscription and Tokens, or from the Premium screen. Guest users can view product information, but purchase, restore, and subscription status sync require sign-in so purchases can be linked to an account.

Sign in with Apple is available on iPhone and iPad as an optional authentication method.

Terms of Use: https://hayjukwfcsdmppairazc.supabase.co/functions/v1/legal-pages/terms-of-service
Privacy Policy: https://hayjukwfcsdmppairazc.supabase.co/functions/v1/legal-pages/privacy-policy
Support: https://hayjukwfcsdmppairazc.supabase.co/functions/v1/legal-pages

## Evidence required before GO

- iPhone clean install guest path and Apple sign-in start/cancel/success behavior.
- iPad clean install and Apple sign-in path.
- IAP product listing, purchase success, purchase cancellation recovery, and restore purchases.
- Optional but recommended: NAT64/IPv6-only network smoke test.
