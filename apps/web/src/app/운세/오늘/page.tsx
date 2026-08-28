import type { Metadata } from 'next';

import { DailyForm } from '@/features/daily/daily-form';

/**
 * 공개 오늘의 운세.
 *
 * 로그인 벽 뒤가 아니라 여기가 첫 방문자의 도착점이다. 한글 slug 를 쓰는 이유는
 * 제품이 한국어 전용이고 SERP/카카오 링크 프리뷰에서 경로 토큰이 그대로 읽히기
 * 때문이다 (plans/web-first-pivot.md §5.2).
 */
export const metadata: Metadata = {
  title: '오늘의 운세 — 생년월일로 바로 보기',
  description:
    '생년월일 하나로 오늘 하루의 흐름을 종합·애정·재물·일·건강으로 나눠 읽어드려요. 설치도 로그인도 없이 바로 볼 수 있어요.',
  alternates: { canonical: '/운세/오늘' },
};

export default function TodayFortunePage() {
  return (
    <main className="ondo-shell ondo-daily-page">
      <div className="ondo-daily-layout" data-testid="daily-layout">
        <section className="ondo-daily-context ondo-stack" data-testid="daily-context">
          <header className="ondo-stack ondo-daily-heading">
            <p className="ondo-kicker">오늘의 운세</p>
            <h1 className="ondo-h1">오늘의 흐름을 가볍게 확인해보세요</h1>
            <p className="ondo-muted">
              생년월일 하나면 충분해요. 전체 흐름을 먼저 읽고 애정·재물·일·건강 중 지금 필요한 부분을 살펴봅니다.
            </p>
          </header>

          <section aria-labelledby="today-reading-guide" className="ondo-daily-guide ondo-stack">
            <p className="ondo-kicker">읽기 전에</p>
            <h2 className="ondo-h3" id="today-reading-guide">
              아는 정보만 편하게 입력하세요
            </h2>
            <p className="ondo-muted">
              태어난 시간과 성별은 선택 사항이에요. 모르는 정보 때문에 오늘의 운세를 미룰 필요는 없어요.
            </p>
          </section>

          <dl className="ondo-daily-facts" aria-label="오늘의 운세 이용 정보">
            <div>
              <dt>필수 입력</dt>
              <dd>생년월일</dd>
            </div>
            <div>
              <dt>예상 시간</dt>
              <dd>약 1분</dd>
            </div>
            <div>
              <dt>사용 온도</dt>
              <dd>1개</dd>
            </div>
          </dl>
        </section>

        <section
          aria-labelledby="today-form-title"
          className="ondo-card ondo-daily-form-panel ondo-stack"
          data-testid="daily-form-panel"
        >
          <header className="ondo-stack ondo-daily-form-heading">
            <p className="ondo-kicker">오늘을 읽는 정보</p>
            <h2 className="ondo-h3" id="today-form-title">기본 정보를 알려주세요</h2>
            <p className="ondo-muted">생년월일만 필수이며 나머지는 건너뛸 수 있어요.</p>
          </header>
          <DailyForm />
        </section>
      </div>
    </main>
  );
}
