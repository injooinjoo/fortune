const { test, expect } = require('@playwright/test');

const TODAY_PATH = '/운세/오늘';

async function layoutMetrics(page) {
  return page.locator('[data-testid="daily-layout"]').evaluate((layout) => {
    const panel = layout.querySelector('[data-testid="daily-form-panel"]');
    const context = layout.querySelector('[data-testid="daily-context"]');
    const submit = layout.querySelector('button[type="submit"]');
    if (!panel || !context || !submit) throw new Error('daily layout landmarks are missing');

    const layoutRect = layout.getBoundingClientRect();
    const contextRect = context.getBoundingClientRect();
    const panelRect = panel.getBoundingClientRect();
    const submitRect = submit.getBoundingClientRect();

    return {
      columns: getComputedStyle(layout).gridTemplateColumns,
      layoutWidth: layoutRect.width,
      contextLeft: contextRect.left,
      contextTop: contextRect.top,
      panelLeft: panelRect.left,
      panelTop: panelRect.top,
      panelWidth: panelRect.width,
      submitBottom: submitRect.bottom,
      submitTop: submitRect.top,
      submitWidth: submitRect.width,
      clientWidth: document.documentElement.clientWidth,
      scrollWidth: document.documentElement.scrollWidth,
    };
  });
}

test.describe('Ondo daily fortune responsive journey', () => {
  for (const [width, height] of [[1440, 900], [1280, 800]]) {
    test(`uses a focused desktop form instead of stretching mobile controls at ${width}px`, async ({ page }) => {
      await page.setViewportSize({ width, height });
      await page.goto(TODAY_PATH);

      const metrics = await layoutMetrics(page);
      expect(metrics.columns.split(' ').length).toBe(2);
      expect(metrics.contextLeft).toBeLessThan(metrics.panelLeft);
      expect(metrics.panelWidth).toBeLessThanOrEqual(620);
      expect(metrics.submitWidth).toBeLessThanOrEqual(560);
      expect(metrics.submitBottom).toBeLessThanOrEqual(height);
      expect(metrics.scrollWidth).toBeLessThanOrEqual(metrics.clientWidth);

      const timeOptions = page.getByRole('group', { name: '태어난 시간 (선택)' }).getByRole('button');
      const first = await timeOptions.nth(0).boundingBox();
      const second = await timeOptions.nth(1).boundingBox();
      const third = await timeOptions.nth(2).boundingBox();
      const fourth = await timeOptions.nth(3).boundingBox();
      const fifth = await timeOptions.nth(4).boundingBox();
      expect(first).not.toBeNull();
      expect(second).not.toBeNull();
      expect(third).not.toBeNull();
      expect(fourth).not.toBeNull();
      expect(fifth).not.toBeNull();
      expect(Math.abs(first.y - second.y)).toBeLessThan(2);
      expect(Math.abs(first.y - third.y)).toBeLessThan(2);
      expect(Math.abs(first.y - fourth.y)).toBeLessThan(2);
      expect(fifth.y).toBeGreaterThan(first.y);
    });
  }

  test('keeps the mobile flow compact and free of horizontal overflow', async ({ page }) => {
    await page.setViewportSize({ width: 390, height: 844 });
    await page.goto(TODAY_PATH);

    const metrics = await layoutMetrics(page);
    expect(metrics.columns.split(' ').length).toBe(1);
    expect(metrics.panelTop).toBeGreaterThan(metrics.contextTop);
    expect(metrics.panelWidth).toBeLessThanOrEqual(358);
    expect(metrics.scrollWidth).toBeLessThanOrEqual(metrics.clientWidth);
    await expect(page.getByRole('button', { name: '오늘의 운세 보기' })).toBeVisible();
  });

  test('lets people enter first and explains account connection only at the value boundary', async ({ page }) => {
    await page.goto(TODAY_PATH);

    const form = page.getByRole('form', { name: '오늘의 운세 입력' });
    await expect(form).toBeVisible();
    await expect(form.getByText(/로그인 없이 바로 확인/)).toBeVisible();
    await expect(form.getByText(/결과를 저장하거나 온도가 더 필요할 때만 계정을 연결/)).toBeVisible();
    await expect(form.getByRole('link', { name: '개인정보처리방침' })).toHaveAttribute('href', '/privacy');
    await expect(form.getByRole('link', { name: /로그인/ })).toHaveCount(0);
  });
});
