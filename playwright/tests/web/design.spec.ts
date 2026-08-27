import { expect, test } from '@playwright/test';

test.describe('온도 daily-tool 디자인 계약', () => {
  test('밝은 제품 셸에서 오늘의 시작점과 운세 카테고리를 한눈에 제공한다', async ({ page }) => {
    await page.goto('/');

    const bodyBackground = await page.locator('body').evaluate((element) =>
      getComputedStyle(element).backgroundColor,
    );
    expect(bodyBackground).toBe('rgb(250, 250, 251)');

    await expect(page.locator('header.ondo-site-header')).toHaveCSS('position', 'sticky');
    await expect(page.getByRole('link', { name: '오늘의 운세 보기', exact: true })).toHaveCount(1);
    await expect(page.getByRole('navigation', { name: '운세 카테고리' })).toBeVisible();
    await expect(page.getByRole('link', { name: '내 기록', exact: true }).first()).toBeVisible();
  });

  test('모바일에서 주요 시작점은 44px 이상이고 가로 화면을 넘지 않는다', async ({ page }) => {
    await page.setViewportSize({ width: 390, height: 844 });
    await page.goto('/');

    const primary = page.getByRole('link', { name: '오늘의 운세 보기', exact: true });
    const box = await primary.boundingBox();
    expect(box).not.toBeNull();
    expect(box?.height ?? 0).toBeGreaterThanOrEqual(44);

    const dimensions = await page.evaluate(() => ({
      innerWidth: window.innerWidth,
      scrollWidth: document.documentElement.scrollWidth,
    }));
    expect(dimensions.scrollWidth).toBeLessThanOrEqual(dimensions.innerWidth);
  });
});
