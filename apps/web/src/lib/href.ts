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
 * 미리 퍼센트 인코딩해 두면 헤더 값이 ASCII 로 유지돼 정상 동작한다.
 * 주소창은 어차피 디코딩해서 보여주므로 사용자에게 보이는 URL 은 그대로 한글이다.
 */
export function encodePath(path: string): string {
  return path
    .split('/')
    .map((segment) => encodeURIComponent(segment))
    .join('/');
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
