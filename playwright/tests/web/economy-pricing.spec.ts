import { expect, test } from '@playwright/test';

test('운세 목록은 기본 운세 1온도와 사주 12온도를 표시한다', async ({ page }) => {
  test.skip(!process.env.WEB_BASE_URL, '한글 경로를 제공하는 명시적 미리보기 대상에서 검증');
  await page.goto('/운세');
  await expect(page.locator('.ondo-fortune-link')).toHaveCount(13);
  const cards = await page.locator('.ondo-fortune-link').evaluateAll((links) => links.map((link) => ({
    href: decodeURIComponent(link.getAttribute('href') || ''),
    text: (link as HTMLElement).innerText,
  })));
  for (const slug of ['오늘', '타로', '연애', '궁합', '재물', '직업']) {
    expect(cards.find((card) => card.href.endsWith(`/${slug}`))?.text).toContain('온도 1개');
  }
  expect(cards.find((card) => card.href.endsWith('/사주'))?.text).toContain('온도 12개');
});
