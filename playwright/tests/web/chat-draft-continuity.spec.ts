import { expect, test } from '@playwright/test';

declare const process: { env: Record<string, string | undefined> };

const chromeExecutable = process.env.PLAYWRIGHT_CHROME_EXECUTABLE;
test.use({
  video: 'off',
  ...(chromeExecutable ? { launchOptions: { executablePath: chromeExecutable } } : {}),
});

const VIEWPORTS = [
  { name: 'large desktop', width: 1440, height: 900 },
  { name: 'compact desktop', width: 1280, height: 800 },
  { name: 'mobile', width: 390, height: 844 },
] as const;

for (const viewport of VIEWPORTS) {
  test(`${viewport.name} character chat keeps an unsent draft across a same-tab detour`, async ({ page }) => {
    await page.setViewportSize(viewport);
    await page.route('**/auth/v1/**', async (route) => {
      await route.fulfill({
        status: 401,
        contentType: 'application/json',
        body: JSON.stringify({ message: 'QA keeps authentication local' }),
      });
    });

    await page.goto('/');
    await page.getByRole('link', { name: /대화 상대 고르기/ }).click();
    await expect(page).toHaveURL(/\/%EB%8C%80%ED%99%94$/);

    await page.getByRole('link', { name: /서하은/ }).last().click();
    const composer = page.getByRole('textbox', { name: '서하은에게 보낼 메시지' });
    await expect(composer).toBeEnabled();

    const draft = `${viewport.name}에서 아직 보내지 않은 대화 초안`;
    await composer.fill(draft);
    await page.getByRole('link', { name: '고객 지원' }).click();
    await expect(page).toHaveURL(/\/support$/);
    await expect(page.getByRole('heading', { name: '고객 지원' })).toBeVisible();

    await page.goBack();
    await expect(page).toHaveURL(/\/%EB%8C%80%ED%99%94\/ondo_seo_haeun$/);
    await expect(composer).toBeEnabled();
    await expect(composer).toHaveValue(draft);
    await expect(page.getByRole('button', { name: '보내기' })).toBeEnabled();
  });
}
