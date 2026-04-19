const TEST_ACCOUNT_EMAILS: ReadonlySet<string> = new Set([
  'ink595@g.harvard.edu',
]);

export function isTestAccountEmail(
  email: string | null | undefined,
): boolean {
  if (!email) return false;
  return TEST_ACCOUNT_EMAILS.has(email.trim().toLowerCase());
}
