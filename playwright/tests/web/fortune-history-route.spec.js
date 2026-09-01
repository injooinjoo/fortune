const { test, expect } = require('@playwright/test');

/**
 * 저장된 운세 상세는 로그인 뒤 화면이라 내용까지는 여기서 확인하지 않는다.
 * 지키려는 건 하나다 — "라우트가 매칭은 되는가".
 *
 * 처음에 이 페이지를 `/운세/기록/<id>` 로 냈다가 프로덕션에서 통째로 404 가
 * 났다(`x-matched-path: /404`). Next 는 요청으로 들어온 퍼센트 인코딩 경로를
 * 디코딩해서 앱 라우터 세그먼트에 맞추지 않는다(vercel/next.js#62292). 지금
 * 동작하는 한글 경로는 전부 `generateStaticParams` 로 미리 만들어져 출력 맵에
 * 들어간 것들이라 이 차이가 빌드에서는 안 보였고, 배포하고 curl 로 찔러보고서야
 * 알았다. 그래서 ASCII 경로로 옮겼고, 다시 사라지지 않게 여기서 잡는다.
 *
 * 인증 결과(로그인 리다이렉트냐 404 냐)는 단언하지 않는다. 로컬 `next start` 에는
 * Supabase 환경변수가 없어서 분기가 배포와 다르게 흐르고, 그런 단언은 실패했을
 * 때 제품이 아니라 실행 환경을 알려줄 뿐이다.
 */
const SAMPLE_ID = '550e8400-e29b-41d4-a716-446655440000';

test('저장된 운세 상세 경로가 앱 라우터에 매칭된다', async ({ page }) => {
  const response = await page.goto(`/app/history/${SAMPLE_ID}`);

  // 404 면 라우트가 아예 안 잡힌 것이다. 이게 프로덕션에서 실제로 났던 상태다.
  expect(response?.status()).not.toBe(404);
});
