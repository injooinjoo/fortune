/**
 * LLM 이 한 문자열 안에 줄바꿈으로 밀어 넣은 덩어리를 화면용 배열로 쪼갠다.
 *
 * 필요한 이유: 결과 프리미티브(`TextSection`)는 문자열 하나를 `<p>` 하나로
 * 그리는데, HTML 은 `\n` 을 공백으로 접어버려 서버 프롬프트가 지시한 문단 구분
 * (`fortune-traditional-saju` 의 "긴 내용은 \n\n 으로 문단을 나누어 작성")이
 * 화면에서 통째로 사라진다. 배열로 넘기면 문단마다 `<p>` 가 생긴다.
 */

/** 줄바꿈 단위로 문단 분리. 값이 없으면 undefined → 섹션 자체가 안 그려진다. */
export function splitParagraphs(text: string | null | undefined): string[] | undefined {
  if (typeof text !== 'string') return undefined;
  const parts = text
    .split(/\n+/)
    .map((part) => part.trim())
    .filter((part) => part.length > 0);
  return parts.length > 0 ? parts : undefined;
}

/**
 * 불릿 문자열("• 첫째\n• 둘째")을 항목 배열로. 마커는 떼어낸다 —
 * `BulletList` 가 이미 `<ul>` 로 그리므로 남겨두면 점이 두 번 찍힌다.
 */
export function splitBullets(text: string | null | undefined): string[] | undefined {
  const lines = splitParagraphs(text);
  if (!lines) return undefined;
  const items = lines
    .map((line) => line.replace(/^[•·\-*]\s*/, '').trim())
    .filter((line) => line.length > 0);
  return items.length > 0 ? items : undefined;
}
