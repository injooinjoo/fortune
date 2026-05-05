/**
 * process-long-running-jobs handler 등록부.
 *
 * job_type 별로 LLM 호출 + 결과 cardPayload 빌드를 담당하는 handler 를 export.
 * worker (index.ts) 가 dispatch 키로 사용. Phase D 에서 tarot/dream/compatibility/
 * traditional-saju handler 를 추가 등록한다.
 *
 * Handler contract:
 *   - 입력: { job, admin (service-role client), supabaseUrl, serviceKey }
 *   - 출력: LongRunningJobOutcome
 *     - cardPayload: 클라이언트 ChatShellEmbeddedResultMessage 형식 객체
 *       (id 는 `result-{job.id}` 권장, 멱등성 확보).
 *     - previewText (선택): 옛 클라 fallback 용 한 줄 미리보기.
 *     - pushBody (선택): push 본문. 미지정 시 worker default 사용.
 *     - result (선택): long_running_jobs.result 컬럼에 저장할 JSON
 *       (디버깅/audit 용 — 실제 표시는 cardPayload).
 *   - throw 하면 worker 가 status=failed 처리 + 사용자 실패 메시지 INSERT.
 */

import type { SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2';

export interface LongRunningJobRow {
  id: string;
  user_id: string;
  character_id: string;
  character_name: string;
  job_type: string;
  payload: Record<string, unknown>;
  retry_count: number;
}

export interface LongRunningJobHandlerInput {
  job: LongRunningJobRow;
  admin: SupabaseClient;
  supabaseUrl: string;
  serviceKey: string;
}

export interface LongRunningJobCardPayload {
  id: string;
  kind: string;
  sender: 'assistant';
  embeddedWidgetType: 'fortune_result_card';
  fortuneType: string;
  resultKind: string;
  title: string;
  payload: Record<string, unknown>;
}

export interface LongRunningJobOutcome {
  cardPayload: LongRunningJobCardPayload;
  previewText?: string;
  pushBody?: string;
  result?: Record<string, unknown>;
}

export type LongRunningJobHandler = (
  input: LongRunningJobHandlerInput,
) => Promise<LongRunningJobOutcome>;

/**
 * job_type 별 운세 라벨 + resultKind + 위임할 fortune Edge Function 정보.
 * 4개 텍스트-운세는 모두 동일 패턴 — 기존 fortune-* 엔드포인트로 위임 + 응답을
 * cardPayload 로 감싸기. 따라서 1 함수로 일반화 가능.
 *
 * resultKind 는 RN `apps/mobile-rn/src/features/fortune-results/mapping.ts` 의
 * resolveResultKindFromFortuneType 매핑과 일치해야 한다 — 클라가 카드를 어떤
 * 결과 컴포넌트로 렌더할지 결정.
 */
const TEXT_FORTUNE_REGISTRY: Record<
  string,
  { endpoint: string; resultKind: string; label: string; pushBody?: string }
> = {
  tarot: {
    endpoint: '/fortune-tarot',
    resultKind: 'tarot',
    label: '타로',
  },
  dream: {
    endpoint: '/fortune-dream',
    // dream 결과 화면이 tarot UI 를 재사용 (mapping.ts 의 dream→tarot 매핑).
    resultKind: 'tarot',
    label: '꿈 해몽',
  },
  compatibility: {
    endpoint: '/fortune-compatibility',
    resultKind: 'compatibility',
    label: '궁합',
  },
  'traditional-saju': {
    endpoint: '/fortune-traditional-saju',
    resultKind: 'traditional-saju',
    label: '전통 사주',
  },
};

/**
 * 일반화된 텍스트 운세 worker.
 *
 * 흐름:
 *   1. job.payload 를 fortune-* Edge Function 에 그대로 forward.
 *   2. 응답을 rawApiResponse 에 박은 cardPayload 빌드.
 *   3. previewText / pushBody 도 동봉해 worker 가 INSERT/push 에 사용.
 *
 * 같은 fortune-* endpoint 가 동기 직접 호출 (edge-runtime.ts) 과 비동기 큐
 * (handler) 양쪽에서 동일하게 작동 — 내부 LLMFactory 로직은 두 호출자를 구분하지
 * 않으므로 안전.
 *
 * 인증 위임 — 두 갈래로 동작:
 *   1) `fortune-tarot`: deriveUserIdFromJwt 를 사용 → 본 worker 가 보내는
 *      service_role + X-Internal-User-Id 조합으로 위임 식별 (auth.ts 의 internal
 *      bypass).
 *   2) `fortune-dream` / `fortune-compatibility` / `fortune-traditional-saju`:
 *      현재 본문 `userId` 만 참조 (JWT 미사용). worker 가 forward 하는 `payload`
 *      에 buildFortuneRequestBody 가 이미 정확한 userId 를 박아두므로 동작 OK.
 *      단, 본 3개 endpoint 는 외부 직접 호출 시 body.userId 위조 가능한 기존
 *      문제를 그대로 보유 — 별도 PR 에서 deriveUserIdFromJwt 일원화 예정.
 */
async function handleTextFortuneJob(
  input: LongRunningJobHandlerInput,
): Promise<LongRunningJobOutcome> {
  const entry = TEXT_FORTUNE_REGISTRY[input.job.job_type];
  if (!entry) {
    throw new Error(`text fortune registry missing for ${input.job.job_type}`);
  }

  const url = `${input.supabaseUrl}/functions/v1${entry.endpoint}`;
  // Internal-worker 위임 헤더 — fortune-* 의 deriveUserIdFromJwt 가 이 두 헤더
  // 조합을 보고 user identity 를 X-Internal-User-Id 로 신뢰. 일반 클라이언트는
  // service_role 키를 보유하지 못하므로 위조 불가.
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${input.serviceKey}`,
      'X-Internal-User-Id': input.job.user_id,
      'X-Internal-Worker': 'process-long-running-jobs',
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(input.job.payload ?? {}),
  });

  if (!response.ok) {
    const errBody = await response.text();
    throw new Error(
      `${entry.endpoint} returned ${response.status}: ${errBody.slice(0, 300)}`,
    );
  }

  const apiData = (await response.json()) as Record<string, unknown>;

  // `data` 키가 있는 응답 (`{success, data: {...}}`) 도 있고 결과를 최상단에
  // 펼친 응답도 있어 둘 다 수용. RN edge-runtime.ts:177 와 동일 처리.
  const rawApiResponse =
    typeof apiData === 'object' && apiData !== null && 'data' in apiData
      ? ((apiData.data as Record<string, unknown>) ?? apiData)
      : apiData;

  const messageId = `result-${input.job.id}`;
  const generatedAt = new Date().toISOString();

  const cardPayload: LongRunningJobCardPayload = {
    id: messageId,
    kind: 'embedded-result',
    sender: 'assistant',
    embeddedWidgetType: 'fortune_result_card',
    fortuneType: input.job.job_type,
    resultKind: entry.resultKind,
    title: entry.label,
    payload: {
      kind: entry.resultKind,
      fortuneType: input.job.job_type,
      resultKind: entry.resultKind,
      generatedAt,
      rawApiResponse,
    },
  };

  return {
    cardPayload,
    previewText: `[운세 결과 — ${entry.label}]`,
    pushBody: `${entry.label} 결과가 도착했어! 확인해봐 👀`,
    result: rawApiResponse,
  };
}

/**
 * job_type → handler 등록부.
 *
 * 4개 텍스트 운세 모두 같은 forward-and-wrap 패턴이라 단일 핸들러로 등록.
 * 향후 image-gen 등 다른 패턴이 추가되면 별도 함수로 분기.
 */
export const JOB_HANDLERS: Record<string, LongRunningJobHandler> = {
  tarot: handleTextFortuneJob,
  dream: handleTextFortuneJob,
  compatibility: handleTextFortuneJob,
  'traditional-saju': handleTextFortuneJob,
};
