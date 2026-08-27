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
