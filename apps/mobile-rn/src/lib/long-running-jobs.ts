/**
 * Long-running job (poster-guide / 사주 / 타로 등 30s+ Edge Function) 진행 카드
 * 도트 라벨 상수.
 *
 * 진행 카드 stuck 정리는 ProgressMessageCard 컴포넌트의 self-polling
 * (`useSelfReconcile`) 한 곳에서만 처리한다 — 외부 의존(Realtime, provider
 * polling, AppState reconcile, trackedJobs Map) 다 제거됨. 카드가 mount 된
 * 동안 자기 jobId 의 status 만 두 큐 테이블에서 직접 조회하면 끝.
 */

/** Image-gen (poster-guide) 진행 도트 라벨 */
export const POSTER_PHASE_STEPS = ['준비', '분석', '마무리', '완료'] as const;

/** LLM-text (tarot/dream/compatibility/saju) 진행 도트 라벨 */
export const LLM_TEXT_PHASE_STEPS = ['준비', '해석', '마무리', '완료'] as const;
