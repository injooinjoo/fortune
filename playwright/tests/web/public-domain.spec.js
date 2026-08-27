const { test, expect } = require('@playwright/test');

const PUBLIC_DOCUMENTS = [
  { path: '/privacy', heading: 'Ondo 개인정보처리방침' },
  { path: '/terms', heading: 'Ondo 이용약관' },
  { path: '/support', heading: 'Ondo 고객 지원' },
  { path: '/delete-account', heading: 'Ondo 계정 삭제 안내' },
];

test.describe('Ondo public-domain contract', () => {
  for (const document of PUBLIC_DOCUMENTS) {
    test(`${document.path} is served by the product site`, async ({ page }) => {
      const response = await page.goto(document.path);

      expect(response?.status()).toBe(200);
      await expect(page.locator('h1')).toHaveText(document.heading);
    });
  }

  test('public pages expose canonical metadata and hardened browser headers', async ({ page }) => {
    const response = await page.goto('/');

    expect(response?.headers()['x-content-type-options']).toBe('nosniff');
    expect(response?.headers()['referrer-policy']).toBe('strict-origin-when-cross-origin');
    expect(response?.headers()['permissions-policy']).toContain('camera=()');
    expect(response?.headers()['content-security-policy']).toContain("frame-ancestors 'none'");
    await expect(page.locator('link[rel="canonical"]')).toHaveAttribute('href', /zpzg\.co\.kr\/?$/);
    await expect(page.locator('meta[property="og:image"]')).toHaveAttribute('content', /opengraph-image/);
  });

  test('unknown routes render a Korean recovery screen', async ({ page }) => {
    const response = await page.goto('/존재하지-않는-화면');
    expect(response?.status()).toBe(404);
    await expect(page.getByRole('heading', { level: 1 })).toContainText('찾을 수 없어요');
    await expect(page.getByRole('link', { name: '온도 홈으로' })).toBeVisible();
  });

  test('footer keeps every public document on the product origin', async ({ page }) => {
    await page.goto('/');

    const origin = new URL(page.url()).origin;
    const hrefs = await page.locator('footer nav a').evaluateAll((links) =>
      links.map((link) => link.getAttribute('href')),
    );

    expect(hrefs).toEqual(PUBLIC_DOCUMENTS.map((document) => document.path));
    for (const href of hrefs) {
      expect(new URL(href, origin).origin).toBe(origin);
    }
  });
});
