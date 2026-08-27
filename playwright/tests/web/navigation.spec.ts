import { expect, test } from '@playwright/test';

test('Korean route links do not emit non-ISO RSC header errors', async ({ page }) => {
  const rscHeaderErrors: string[] = [];

  page.on('console', (message) => {
    if (message.type() === 'error' && message.text().includes('non ISO-8859-1 code point')) {
      rscHeaderErrors.push(message.text());
    }
  });

  await page.goto('/');
  await page.getByRole('link', { name: '운세', exact: true }).first().hover();
  await page.waitForTimeout(750);

  expect(rscHeaderErrors).toEqual([]);
});
