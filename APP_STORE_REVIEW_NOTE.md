# App Store Review Reply Draft - ZPZG

Hello App Review Team,

We addressed both issues from the review dated February 23, 2026 for submission `e77d128e-763f-4670-b865-efbbc1fa39c2`.

## Guideline 2.1 - Sign in with Apple

We fixed the iPad Sign in with Apple flow.

### What changed
- Deep link handling for OAuth callbacks is now initialized before app startup completes, so cold-start callback links are no longer missed.
- The Apple login flow now uses explicit auth result states, so an OAuth fallback launched from iPad native sign-in is treated as an in-progress authentication flow instead of a silent failure.
- Native Sign in with Apple remains enabled, and iPad fallback to OAuth is handled explicitly when needed.

### Review path
- Primary review path: sign in with the review test account
  - Email: `test@zpzg.com`
  - Password: `TestPassword123!`
- Optional validation path: Sign in with Apple is also available on iPhone and iPad.

## Guideline 3.1.2 - Subscription Metadata

We updated the App Store metadata to include the required policy links.

### Policy links
- Terms of Use (EULA): `https://zpzg.co.kr/terms`
- Privacy Policy: `https://zpzg.co.kr/privacy`

### Metadata update
- The Privacy Policy field now uses the canonical privacy URL.
- The App Description includes the Terms of Use (EULA) link.
- Review notes now direct review through the provided test account first.

Thank you for your review.
