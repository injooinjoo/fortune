/**
 * 오픈 리다이렉트 방지: `?next=` 로 넘어온 값 중 같은 오리진의 경로만 통과시킨다.
 *
 * 거르는 것:
 *  - `//evil.com` (protocol-relative)
 *  - `https://evil.com`
 *  - `/\evil.com` (백슬래시를 브라우저가 `/` 로 정규화)
 */
export function sanitizeNextPath(raw: string | null | undefined, fallback = '/app'): string {
  if (!raw) return fallback;
  if (!raw.startsWith('/')) return fallback;
  if (raw.startsWith('//') || raw.startsWith('/\\')) return fallback;
  return raw;
}
