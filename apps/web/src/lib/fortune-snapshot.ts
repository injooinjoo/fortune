/**
 * 결과를 다시 열어보기 위한 스냅샷 투영.
 *
 * `projectFortuneSummary` 는 대화 컨텍스트용이라 하이라이트 8개·각 240자로
 * 자른다. 그게 `fortune_history.fortune_data` 에 저장되는 전부였고, 그래서 온도를
 * 내고 본 결과를 다시 열 방법이 없었다. 실측으로도 결제 직후 다른 페이지에
 * 갔다가 돌아오니 빈 폼이었다.
 *
 * 그렇다고 provider 응답을 통째로 넣지는 않는다(runner 의 기존 원칙). 여기서는
 * 화면에 실제로 쓰이는 모양만 남기고 나머지를 잘라낸 구조 복사본을 만든다.
 *
 * - `BLOCKED_KEY` 에 걸리는 키는 통째로 버린다. 프롬프트·자격증명·내부 제어값이
 *   결과 JSON 에 섞여 들어와도 저장되지 않는다.
 * - 문자열·배열·깊이·전체 크기에 상한을 둔다. `save_web_fortune_history` 의
 *   `p_fortune_data` 는 256KB 를 넘기면 거절한다.
 * - 함수·심볼·순환 참조 같은 건 애초에 통과하지 못한다.
 */

/** runner 의 요약 투영과 같은 차단 목록을 쓴다. 한쪽만 느슨해지면 의미가 없다. */
const BLOCKED_KEY =
  /(system|prompt|instruction|secret|token|api.?key|credential|password|control|approval|action)/i;

const MAX_DEPTH = 8;
const MAX_ARRAY = 40;
const MAX_STRING = 4000;
const MAX_KEYS = 60;
/** RPC 상한(256KB)보다 넉넉히 낮게 잡아 인코딩 오버헤드를 흡수한다. */
const MAX_SERIALIZED_BYTES = 120_000;

export const FORTUNE_SNAPSHOT_VERSION = 1 as const;

export interface FortuneSnapshot {
  version: typeof FORTUNE_SNAPSHOT_VERSION;
  fortuneType: string;
  value: unknown;
}

function pruneValue(input: unknown, depth: number): unknown {
  if (input === null) return null;

  if (typeof input === 'string') {
    // 제어문자는 렌더링을 깨고 로그를 오염시킨다. 탭·줄바꿈은 남긴다.
    const text = input.replace(/[\u0000-\u0008\u000b\u000c\u000e-\u001f\u007f]/g, '');
    return text.length > MAX_STRING ? text.slice(0, MAX_STRING) : text;
  }
  if (typeof input === 'number') return Number.isFinite(input) ? input : null;
  if (typeof input === 'boolean') return input;
  if (typeof input !== 'object') return undefined; // function, symbol, undefined, bigint

  if (depth >= MAX_DEPTH) return undefined;

  if (Array.isArray(input)) {
    const items: unknown[] = [];
    for (const entry of input.slice(0, MAX_ARRAY)) {
      const pruned = pruneValue(entry, depth + 1);
      if (pruned !== undefined) items.push(pruned);
    }
    return items;
  }

  const output: Record<string, unknown> = {};
  let kept = 0;
  for (const [key, value] of Object.entries(input as Record<string, unknown>)) {
    if (kept >= MAX_KEYS) break;
    if (BLOCKED_KEY.test(key)) continue;
    const pruned = pruneValue(value, depth + 1);
    if (pruned === undefined) continue;
    output[key] = pruned;
    kept += 1;
  }
  return output;
}

/**
 * 저장 가능한 스냅샷을 만든다. 남길 게 없거나 상한을 넘기면 `null` 을 준다 —
 * 이력 저장 자체는 요약만으로도 계속 되어야 하므로 호출부가 그냥 건너뛴다.
 */
export function projectFortuneSnapshot(fortuneType: string, input: unknown): FortuneSnapshot | null {
  const value = pruneValue(input, 0);
  if (value === undefined || value === null || typeof value !== 'object') return null;
  if (Array.isArray(value) ? value.length === 0 : Object.keys(value).length === 0) return null;

  const snapshot: FortuneSnapshot = { version: FORTUNE_SNAPSHOT_VERSION, fortuneType, value };
  if (JSON.stringify(snapshot).length > MAX_SERIALIZED_BYTES) return null;
  return snapshot;
}

/** 저장된 `fortune_data` 에서 스냅샷을 꺼낸다. 옛 행에는 요약만 있어서 `null` 이 된다. */
export function readFortuneSnapshot(fortuneData: unknown): FortuneSnapshot | null {
  if (fortuneData === null || typeof fortuneData !== 'object') return null;
  const candidate = (fortuneData as Record<string, unknown>).snapshot;
  if (candidate === null || typeof candidate !== 'object') return null;

  const record = candidate as Record<string, unknown>;
  if (record.version !== FORTUNE_SNAPSHOT_VERSION) return null;
  if (typeof record.fortuneType !== 'string') return null;
  if (record.value === null || typeof record.value !== 'object') return null;

  return { version: FORTUNE_SNAPSHOT_VERSION, fortuneType: record.fortuneType, value: record.value };
}
