const { test, expect } = require('@playwright/test');

const HOME_SECTIONS = [
  '지금 필요한 깊이만큼',
  '읽고 끝나지 않도록',
  '정답 대신, 오늘의 마음을 더 잘 말할 수 있게.',
  '세 번이면 충분해요.',
];

test.describe('Ondo daily-tool home', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
  });

  test('builds one clear path from the value proposition to a real reading', async ({ page }) => {
    await expect(page.getByRole('heading', {
      level: 1,
      name: /생년월일로 오늘의 흐름을 읽고.*지금 할 한 가지를 골라보세요/,
    })).toBeVisible();
    await expect(page.getByRole('link', { name: '오늘의 운세 보기', exact: true })).toHaveAttribute(
      'href',
      /%EC%98%A4%EB%8A%98|오늘/,
    );
    await expect(page.getByRole('navigation', { name: '운세 카테고리' })).toBeVisible();
    await expect(page.getByText(/로그인 없이 시작하고/)).toBeVisible();
    await expect(page.getByText('약 1분', { exact: true })).toBeVisible();
  });

  test('exposes the complete daily-tool story without inventing unavailable services', async ({ page }) => {
    for (const heading of HOME_SECTIONS) {
      await expect(page.getByRole('heading', { name: heading, exact: true })).toBeVisible();
    }

    for (const fortune of ['오늘의 운세', '오늘의 타로', '연애운', '재물운']) {
      await expect(page.getByText(fortune, { exact: true })).toBeVisible();
    }

    await expect(page.getByText('온도 1개', { exact: true }).first()).toBeVisible();
    await expect(page.getByText('AI 캐릭터 대화', { exact: true })).toBeVisible();
  });

  test('uses the shared Ondo light daily-tool visual system', async ({ page }) => {
    const body = page.locator('body');
    await expect(body).toHaveCSS('background-color', 'rgb(250, 250, 251)');
    await expect(body).toHaveCSS('color', 'rgb(20, 22, 26)');

    const heading = page.getByRole('heading', { level: 1 });
    const headingFont = await heading.evaluate((element) => getComputedStyle(element).fontFamily);
    expect(headingFont).toMatch(/MaruBuri|Noto Serif KR|serif/i);

    const todayPanel = page.locator('section[aria-labelledby="home-title"] article').first();
    await expect(todayPanel).toHaveCSS('background-color', 'rgb(255, 255, 255)');
  });

  test('keeps core explanation readable and the preview evergreen', async ({ page }) => {
    const intro = page.getByText(/가볍게 오늘을 확인하거나/);
    const lineHeightRatio = await intro.evaluate((element) => {
      const style = getComputedStyle(element);
      return Number.parseFloat(style.lineHeight) / Number.parseFloat(style.fontSize);
    });
    expect(lineHeightRatio).toBeGreaterThanOrEqual(1.6);

    await expect(page.getByText('오늘의 리딩 · 구성 예시', { exact: true })).toBeVisible();
    await expect(page.getByText(/\d{1,2}월 \d{1,2}일 · 오늘의 흐름/)).toHaveCount(0);
    await expect(page.getByText(/엔터테인먼트 목적으로 제공/)).toBeVisible();
  });

  test('keeps mobile discovery usable without horizontal overflow', async ({ page }) => {
    await page.setViewportSize({ width: 390, height: 844 });
    await page.reload();

    const sizes = await page.evaluate(() => ({
      clientWidth: document.documentElement.clientWidth,
      scrollWidth: document.documentElement.scrollWidth,
    }));
    expect(sizes.scrollWidth).toBeLessThanOrEqual(sizes.clientWidth);

    await expect(page.locator('summary', { hasText: '메뉴' })).toBeVisible();
    await expect(page.getByRole('link', { name: '오늘의 운세 보기', exact: true })).toBeVisible();
  });
});
