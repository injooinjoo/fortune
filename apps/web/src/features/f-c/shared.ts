/**
 * 재물/직업/건강/행운아이템 4개 운세 공용 런타임 헬퍼.
 *
 * 왜 필요한가 — 전부 실제 Edge Function 동작에서 온 제약이다:
 *
 * 1. **봉투가 함수마다 다르다.** `fortune-wealth` 는 캐시/코호트 경로에서
 *    `{ fortune, cached }` 를, LLM 경로에서 `{ success, data, cached }` 를
 *    내려준다 (index.ts:256 / 334 / 620). `fortune-career`,
 *    `fortune-health`, `fortune-lucky-items` 는 항상 `{ success, data }`.
 *    한 화면에서 두 키를 다 받아야 하므로 `readFortunePayload` 로 흡수한다.
 *
 * 2. **선언한 타입이 런타임 보장이 아니다.** 응답 본문은 LLM 이 만든 JSON 을
 *    그대로 실어 나른 것이라, 배열이어야 할 자리에 문자열이 오는 일이 있다.
 *    kit 의 `BulletList`/`TextSection`/`KeyValueGrid` 는 내부에서 값을
 *    검사하지만 `CardList` 는 넘어온 값에 `.map` 을 부른다. 그래서 매핑하기
 *    전에 항상 `asArray` 를 통과시킨다.
 *
 * 3. **`\n\n` 문단이 실려 온다.** `fortune-health` 는 프롬프트에서 줄바꿈으로
 *    문단을 나누라고 지시한다 (index.ts:625~). `<p>` 는 개행을 공백으로
 *    접기 때문에 `splitLines` 로 쪼개 문단 배열로 넘긴다.
 */

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}

/**
 * `{ data }` → `{ fortune }` 순으로 본문을 꺼낸다.
 *
 * 빈 객체는 없는 것으로 본다 — `fortune-career`/`fortune-health` 의 실패 응답이
 * `{ success: false, data: {}, error }` 라서, 혹시 `error` 없이 이 모양만 와도
 * 빈 화면 대신 "응답이 비어 있어요" 로 떨어지게 하려는 것이다.
 */
export function readFortunePayload<T>(body: unknown): T | undefined {
  if (!isRecord(body)) return undefined;

  for (const key of ['data', 'fortune'] as const) {
    const candidate = body[key];
    if (isRecord(candidate) && Object.keys(candidate).length > 0) {
      return candidate as T;
    }
  }

  return undefined;
}

/** 저장된 결과 재생 여부. 구버전 Edge 는 이 필드를 안 보낼 수도 있다. */
export function readCached(body: unknown): boolean {
  return isRecord(body) && body.cached === true;
}

/** 배열이 아니면 빈 배열. `.map` 호출 전에 반드시 통과시킨다 (위 2번). */
export function asArray<T>(value: unknown): T[] {
  return Array.isArray(value) ? (value as T[]) : [];
}

/** 공백만 있는 문자열은 없는 것으로. 숫자는 문자열로 접어준다. */
export function asText(value: unknown): string | undefined {
  if (typeof value === 'number' && Number.isFinite(value)) return String(value);
  if (typeof value !== 'string') return undefined;
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : undefined;
}

/** `\n` 으로 나뉜 본문을 문단 배열로 (위 3번). */
export function splitLines(value: unknown): string[] {
  if (typeof value !== 'string') return [];
  return value
    .split(/\r?\n+/u)
    .map((line) => line.trim())
    .filter((line) => line.length > 0);
}

/**
 * 값이 있는 조각만 이어붙인다. 전부 비면 undefined —
 * kit 프리미티브가 undefined 를 받으면 알아서 렌더를 생략한다.
 */
export function joinParts(
  parts: ReadonlyArray<string | number | null | undefined>,
  separator = ' · ',
): string | undefined {
  const cleaned = parts.map(asText).filter((part): part is string => part !== undefined);
  return cleaned.length > 0 ? cleaned.join(separator) : undefined;
}

/**
 * `라벨 · 값` 한 줄. 값이 없으면 undefined —
 * `joinParts(['라벨', 값])` 은 값이 비면 라벨만 남아서 "추천 유형" 처럼
 * 내용 없는 껍데기 줄이 생긴다. 라벨+값 쌍에는 반드시 이쪽을 쓴다.
 */
export function labeledValue(
  label: string,
  value: string | number | null | undefined,
): string | undefined {
  const text = asText(value);
  return text === undefined ? undefined : `${label} · ${text}`;
}

/** 상위 퍼센타일 안내. 서버가 `percentile: null` 을 줄 수 있어 숫자만 통과시킨다. */
export function percentileNote(percentile: number | null | undefined): string | undefined {
  if (typeof percentile !== 'number' || !Number.isFinite(percentile)) return undefined;
  return `오늘 본 사람들 중 상위 ${percentile}%`;
}
