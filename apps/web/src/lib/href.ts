/**
 * 한글 경로 링크 헬퍼.
 *
 * 한글 slug 를 `<Link href>` 에 **디코딩된 그대로** 넣으면 안 된다.
 * Next 는 클라이언트 네비게이션/프리페치 때 RSC 요청을 보내면서 pathname 을
 * `Next-Url` 헤더에 싣는데, HTTP 헤더 값은 ISO-8859-1 만 허용한다. 한글이 들어가면
 * fetch 가 통째로 던진다:
 *
 *   TypeError: Failed to execute 'fetch' on 'Window':
 *     Failed to read the 'headers' property from 'RequestInit':
 *     String contains non ISO-8859-1 code point.
 *
 * Next 는 이 실패를 잡아 전체 페이지 리로드로 폴백하므로 "동작은 하는" 것처럼
 * 보이지만, soft navigation 이 전부 죽고 콘솔이 에러로 도배된다.
 * (실제로 배포 후 브라우저 콘솔에서 확인함 — 모든 링크에서 발생)
 *
 * 목적지 경로의 퍼센트 인코딩은 필수지만, 현재 경로를 담는 Next-Url 이 다시
 * 디코딩될 수 있어 그것만으로는 충분하지 않다. `AppLink`가 한글 경로 전환을
 * native navigation으로 격리하고, 이 헬퍼들은 목적지 자체를 ASCII로 유지한다.
 * 주소창은 디코딩해서 보여주므로 사용자에게 보이는 URL은 그대로 한글이다.
 */
export function encodePath(path: string): string {
  return path
    .split('/')
    .map((segment) => encodeURIComponent(segment))
    .join('/');
}

function hasUnicodePathSegment(path: string): boolean {
  try {
    return /[^\u0000-\u007f]/.test(decodeURI(path));
  } catch {
    return true;
  }
}

/**
 * Next App Router serialises route state into request headers. When either side
 * of a client transition has a Korean segment, that state can contain raw
 * Unicode and Chromium rejects the RSC request before it leaves the browser.
 * Use a normal document navigation for those transitions instead.
 */
export function requiresNativeNavigation(currentPath: string, destination: string): boolean {
  return hasUnicodePathSegment(currentPath) || hasUnicodePathSegment(destination);
}

/** `/운세/<slug>` */
export function fortuneHref(slug: string): string {
  return encodePath(`/운세/${slug}`);
}

/** `/대화` 또는 `/대화/<characterId>` */
export function chatHref(characterId?: string): string {
  return encodePath(characterId ? `/대화/${characterId}` : '/대화');
}

/** `/운세` 목록 */
export const FORTUNE_INDEX_HREF = encodePath('/운세');

/** `/대화` 목록 */
export const CHAT_INDEX_HREF = encodePath('/대화');
