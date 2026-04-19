import { Redirect } from 'expo-router';

export default function IndexScreen() {
  // Always route through /splash so the gate logic (auth-entry → welcome,
  // profile-flow → onboarding, ready → chat) — and the dev-forced welcome
  // carousel — runs on every cold start. Previously this redirected to
  // /chat directly, which silently skipped the welcome onboarding.
  return <Redirect href="/splash" />;
}
