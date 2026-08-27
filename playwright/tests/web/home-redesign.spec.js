const { test, expect } = require('@playwright/test');

const HOME_SECTIONS = [
  '지금 어떤 흐름이 궁금한가요?',
  '가장 많이 찾는 운세',
  '오늘의 리딩은 이렇게 도착해요',
  '결과를 보고 끝내지 말고, 오늘의 마음을 이어서 이야기해 보세요.',
  '온도는 이렇게 사용해요',
];

test.describe('Warm Celestial Editorial home', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
  });

  test('builds one clear path from the value proposition to a real reading', async ({ page }) => {
    await expect(page.getByRole('heading', {
      level: 1,
      name: '오늘 하루가 어떻게 흘러갈지, 생년월일 하나로 읽어드려요.',
    })).toBeVisible();
    await expect(page.getByRole('link', { name: '오늘의 운세 보기', exact: true }).first()).toHaveAttribute(
      'href',
      /%EC%98%A4%EB%8A%98|오늘/,
    );
    await expect(page.getByRole('link', { name: '어떤 결과가 나오나요?' })).toHaveAttribute(
      'href',
      '#result-preview',
    );
    await expect(page.getByText('로그인 없이 시작 가능', { exact: true })).toBeVisible();
    await expect(page.getByText('약 1분 내 확인', { exact: true })).toBeVisible();
  });

  test('exposes the full editorial story without inventing unavailable services', async ({ page }) => {
    for (const heading of HOME_SECTIONS) {
      await expect(page.getByRole('heading', { name: heading })).toBeVisible();
    }

    for (const fortune of ['오늘의 운세', '오늘의 타로', '연애운', '재물운']) {
      await expect(page.getByRole('heading', { name: fortune, exact: true })).toBeVisible();
    }

    for (const character of ['서하은', '차도경', '윤제이', '한소월']) {
      await expect(page.getByRole('heading', { name: character, exact: true })).toBeVisible();
    }

    await expect(page.getByText('AI 캐릭터', { exact: true })).toBeVisible();
    await expect(page.getByText('온도 1개', { exact: true }).first()).toBeVisible();
    await expect(page.getByText('온도 5개', { exact: true }).first()).toBeVisible();
  });

  test('uses the shared Ondo dark editorial visual system', async ({ page }) => {
    const body = page.locator('body');
    await expect(body).toHaveCSS('background-color', 'rgb(11, 11, 16)');
    await expect(body).toHaveCSS('color', 'rgb(245, 246, 251)');

    const heading = page.getByRole('heading', { level: 1 });
    const headingFont = await heading.evaluate((element) => getComputedStyle(element).fontFamily);
    expect(headingFont).toMatch(/MaruBuri|Noto Serif KR|serif/i);

    const mainWidth = await page.locator('main').evaluate((element) => element.getBoundingClientRect().width);
    expect(mainWidth).toBeGreaterThanOrEqual(1100);
  });

  test('keeps editorial body copy readable and the example evergreen', async ({ page }) => {
    const bodyCopy = [
      page.getByText('로그인 없이 바로 시작 · 1회에 온도 1개가 사용돼요'),
      page.getByText('지금 밀어도 되는 일과 잠시 두어야 할 일을 봐요.'),
      page.getByText('운세 결과는 엔터테인먼트 목적이며 중요한 결정의 근거가 되어서는 안 됩니다.'),
    ];

    for (const copy of bodyCopy) {
      await expect(copy).toHaveCSS('font-size', '16px');
    }

    await expect(page.getByText('오늘 · 오늘의 흐름', { exact: true })).toBeVisible();
    await expect(page.getByText('8월 24일 · 오늘의 흐름', { exact: true })).toHaveCount(0);

    const resultBody = page.getByText(/오전에는 답이 늦어도 재촉하지 마세요/);
    const lineHeightRatio = await resultBody.evaluate((element) => {
      const style = getComputedStyle(element);
      return Number.parseFloat(style.lineHeight) / Number.parseFloat(style.fontSize);
    });
    expect(lineHeightRatio).toBeGreaterThanOrEqual(1.65);
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
    await expect(page.getByRole('link', { name: '오늘의 운세 보기', exact: true }).first()).toBeVisible();
  });
});
