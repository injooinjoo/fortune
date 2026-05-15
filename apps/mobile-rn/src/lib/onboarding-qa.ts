export const ONBOARDING_QA_EMAIL = 'injoo1222@naver.com';

export function isOnboardingQaEmail(email: string | null | undefined): boolean {
  return email?.trim().toLowerCase() === ONBOARDING_QA_EMAIL;
}
