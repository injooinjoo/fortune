import { expect, test } from '@playwright/test';

/**
 * @fortune/web 스모크.
 *
 * 세션이 없는 상태만 다룬다 — `/app/*` 은 `app/app/layout.tsx` 가
 * `supabase.auth.getUser()` 로 막고 있어서, 폼 자체를 그리려면 실제 Supabase
 * 세션 쿠키가 필요하다. 여기서는 랜딩 / 게이트 / 로그인 진입만 검증한다.
 */

test.describe('랜딩 페이지', () => {
  test('제목과 두 개의 CTA 가 보인다', async ({ page }) => {
    await page.goto('/');

    await expect(page.getByRole('heading', { level: 1 })).toContainText('생년월일');
    await expect(page.getByRole('link', { name: '오늘의 운세 보기' })).toBeVisible();
    await expect(page.getByRole('link', { name: '이메일로 로그인' })).toBeVisible();
  });

  test('robots.txt 가 로그인 뒤 화면을 제외한다', async ({ request }) => {
    const response = await request.get('/robots.txt');
    expect(response.ok()).toBeTruthy();

    const body = await response.text();
    expect(body).toContain('Disallow: /app/');
    expect(body).toContain('Disallow: /auth/');
    expect(body).toContain('Disallow: /api/');
  });
});

test.describe('일일 운세', () => {
  test('로그인 없이 접근하면 로그인 화면으로 보낸다', async ({ page }) => {
    await page.goto('/app/f/daily');

    await expect(page).toHaveURL(/\/auth\/login/);
    await expect(page.getByLabel('이메일 주소')).toBeVisible();
    await expect(page.getByRole('button', { name: '로그인 링크 받기' })).toBeVisible();
  });

  test('랜딩의 CTA 가 일일 운세 경로를 가리킨다', async ({ page }) => {
    await page.goto('/');

    await expect(page.getByRole('link', { name: '오늘의 운세 보기' })).toHaveAttribute(
      'href',
      '/app/f/daily',
    );
  });
});
