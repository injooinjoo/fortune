import { expect, test } from '@playwright/test';

/**
 * @fortune/web 스모크.
 *
 * 로컬 `next start` 는 인코딩된 한글 App Router 경로를 404 로 처리하지만
 * Vercel 배포에서는 정상 제공한다. 그래서 한글 상세 경로의 렌더링은
 * `WEB_BASE_URL` 이 주어진 배포 스모크에서만 실행하고, 로컬/CI는 링크 계약을
 * 검증한다.
 */

test.describe('랜딩 페이지', () => {
  test('첫 운세와 로그인 진입점이 보인다', async ({ page }) => {
    await page.goto('/');

    await expect(page.getByRole('heading', { level: 1 })).toContainText('생년월일');
    await expect(page.getByRole('link', { name: '오늘의 운세 보기' })).toBeVisible();
    await expect(page.getByRole('link', { name: '로그인' })).toBeVisible();
  });

  test('robots.txt 가 로그인 뒤 화면을 제외한다', async ({ request }) => {
    const response = await request.get('/robots.txt');
    expect(response.ok()).toBeTruthy();

    const body = await response.text();
    expect(body).toContain('Disallow: /app/');
    expect(body).toContain('Disallow: /auth/');
    expect(body).toContain('Disallow: /api/');
  });

  test('푸터가 운영 정책과 고객지원 문서를 연결한다', async ({ page }) => {
    await page.goto('/');

    const documents = [
      ['개인정보처리방침', 'https://fortune-mocha.vercel.app/privacy'],
      ['이용약관', 'https://fortune-mocha.vercel.app/terms'],
      ['고객 지원', 'https://fortune-mocha.vercel.app/support'],
      ['계정 삭제 안내', 'https://fortune-mocha.vercel.app/delete-account'],
    ] as const;

    for (const [name, href] of documents) {
      await expect(page.getByRole('link', { name })).toHaveAttribute('href', href);
    }
  });
});

test.describe('일일 운세', () => {
  test('로그인 없이 공개 폼에 접근할 수 있다', async ({ page }) => {
    test.skip(!process.env.WEB_BASE_URL, '배포된 한글 경로에서 실행하는 스모크입니다.');

    await page.goto('/');
    await page.getByRole('link', { name: '오늘의 운세 보기' }).click();

    await expect(page).toHaveURL(/\/%EC%9A%B4%EC%84%B8\/%EC%98%A4%EB%8A%98/);
    await expect(page.getByRole('textbox', { name: '생년월일' })).toBeVisible();
    await expect(page.getByRole('button', { name: '오늘의 운세 보기' })).toBeDisabled();
  });

  test('랜딩 CTA 가 공개 일일 운세 경로를 가리킨다', async ({ page }) => {
    await page.goto('/');

    const href = await page.getByRole('link', { name: '오늘의 운세 보기' }).getAttribute('href');
    expect(href && decodeURIComponent(href)).toBe('/운세/오늘');
  });
});
